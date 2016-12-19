package away3d.animators
{
	import away3d.arcane;
	import away3d.animators.states.*;
	import away3d.animators.transitions.*;
	import away3d.animators.data.*;
	import away3d.cameras.Camera3D;
	import away3d.core.base.*;
	import away3d.core.managers.*;
	import away3d.materials.passes.*;
	
	import flash.display3D.*;
	
	use namespace arcane;
	
	/**
	 * Provides an interface for assigning vertex-based animation data sets to mesh-based entity objects
	 * and controlling the various available states of animation through an interative playhead that can be
	 * automatically updated or manually triggered.
	 */
	public class VertexAnimator extends AnimatorBase implements IAnimator
	{
		private var _vertexAnimationSet:VertexAnimationSet;
		private var _poses:Vector.<Geometry> = new Vector.<Geometry>();
		private var _weights:Vector.<Number> = Vector.<Number>([1, 0, 0, 0]);
		private var _numPoses:uint;
		private var _blendMode:String;
		private var _activeVertexState:IVertexAnimationState;
		
		/**
		 * Creates a new <code>VertexAnimator</code> object.
		 *
		 * @param vertexAnimationSet The animation data set containing the vertex animations used by the animator.
		 */
		public function VertexAnimator(vertexAnimationSet:VertexAnimationSet)
		{
			super(vertexAnimationSet);
			
			_vertexAnimationSet = vertexAnimationSet;
			_numPoses = vertexAnimationSet.numPoses;
			_blendMode = vertexAnimationSet.blendMode;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return new VertexAnimator(_vertexAnimationSet);
		}
		
		public override function dispose():void
		{
			super.dispose();
			for each (var pose : Geometry in _poses)
			{
				pose.dispose();
			}
			_poses = null;
			_vertexAnimationSet.dispose();
			_vertexAnimationSet = null;
			_activeVertexState = null;
		}
		
		/**
		 * Plays a sequence with a given name. If the sequence is not found, it may not be loaded yet, and it will retry every frame.
		 * @param sequenceName The name of the clip to be played.
		 */
		public function play(name:String, transition:IAnimationTransition = null, offset:Number = NaN):void
		{
			if (_activeAnimationName != name) {
				_activeAnimationName = name;
				
				//TODO: implement transitions in vertex animator
				
				if (!_animationSet.hasAnimation(name))
					throw new Error("Animation root node " + name + " not found!");
				
				_activeNode = _animationSet.getAnimation(name);
				
				_activeState = getAnimationState(_activeNode);
				
				if (updatePosition) {
					//update straight away to reset position deltas
					_activeState.update(_absoluteTime);
					_activeState.positionDelta;
				}
				
				_activeVertexState = _activeState as IVertexAnimationState;
			}
			
			start();
			
			//apply a time offset if specified
			if (!isNaN(offset))
				reset(name, offset);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDeltaTime(dt:Number):void
		{
			super.updateDeltaTime(dt);
			
			_poses[0] = _activeVertexState.currentGeometry;
			_poses[1] = _activeVertexState.nextGeometry;
			_weights[1] = _activeVertexState.blendWeight
			_weights[0] = 1 - _weights[1];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{
			// todo: add code for when running on cpu
			
			// if no poses defined, set temp data
			if (!_poses.length) {
				setNullPose(stage3DProxy, renderable, vertexConstantOffset, vertexStreamOffset);
				return;
			}
			
			// this type of animation can only be SubMesh
			var subMesh:SubMesh = SubMesh(renderable);
			var subGeom:ISubGeometry;
			var i:uint;
			var len:uint = _numPoses;
			
			stage3DProxy._context3DProxy.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, _weights, 1);
			
			if (_blendMode == VertexAnimationMode.ABSOLUTE) {
				i = 1;
				subGeom = _poses[0].subGeometries[subMesh._index];
				// set the base sub-geometry so the material can simply pick up on this data
				if (subGeom)
					subMesh.subGeometry = subGeom;
			} else
				i = 0;
			
			for (; i < len; ++i) {
				subGeom = _poses[i].subGeometries[subMesh._index] || subMesh.subGeometry;
				
				subGeom.activateVertexBuffer(vertexStreamOffset++, stage3DProxy);
				
				if (_vertexAnimationSet.useNormals)
					subGeom.activateVertexNormalBuffer(vertexStreamOffset++, stage3DProxy);
				
			}
		}
		
		private function setNullPose(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int):void
		{
			stage3DProxy._context3DProxy.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, _weights, 1);
			
			if (_blendMode == VertexAnimationMode.ABSOLUTE) {
				var len:uint = _numPoses;
				for(var i:int = 1; i < len; ++i) {
					renderable.activateVertexBuffer(vertexStreamOffset++, stage3DProxy);
					
					if (_vertexAnimationSet.useNormals)
						renderable.activateVertexNormalBuffer(vertexStreamOffset++, stage3DProxy);
				}
			}
			// todo: set temp data for additive?
		}
		
		/**
		 * Verifies if the animation will be used on cpu. Needs to be true for all passes for a material to be able to use it on gpu.
		 * Needs to be called if gpu code is potentially required.
		 */
		public function testGPUCompatibility(pass:MaterialPassBase):void
		{
		}
	}
}
