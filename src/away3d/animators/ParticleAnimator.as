package away3d.animators
{
	import flash.display3D.*;
	import flash.utils.*;
	
	import away3d.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.animators.states.*;
	import away3d.cameras.*;
	import away3d.core.base.*;
	import away3d.core.managers.*;
	import away3d.materials.passes.*;
	
	use namespace arcane;
	
	/**
	 * Provides an interface for assigning paricle-based animation data sets to mesh-based entity objects
	 * and controlling the various available states of animation through an interative playhead that can be
	 * automatically updated or manually triggered.
	 *
	 * Requires that the containing geometry of the parent mesh is particle geometry
	 *
	 * @see away3d.core.base.ParticleGeometry
	 */
	public class ParticleAnimator extends AnimatorBase implements IAnimator
	{
		private var animationEnded:Boolean;
		
		arcane var _duration:Number = 0;
		arcane var _isUsesLoop:Boolean;
		arcane var _maxStartTime:Number = 0;
		arcane var _absoluteAnimationTime:Number = 0;
		
		private var _particleAnimationSet:ParticleAnimationSet;
		private var _animationParticleStates:Vector.<ParticleStateBase> = new Vector.<ParticleStateBase>();
		private var _animatorParticleStates:Vector.<ParticleStateBase> = new Vector.<ParticleStateBase>();
		private var _timeParticleStates:Vector.<ParticleStateBase> = new Vector.<ParticleStateBase>();
		private var _totalLenOfOneVertex:uint = 0;
		private var _animatorSubGeometries:Dictionary = new Dictionary(true);
		
		/**
		 * Creates a new <code>ParticleAnimator</code> object.
		 *
		 * @param particleAnimationSet The animation data set containing the particle animations used by the animator.
		 */
		public function ParticleAnimator(particleAnimationSet:ParticleAnimationSet)
		{
			super(particleAnimationSet);
			
			_particleAnimationSet = particleAnimationSet;
			
			var state:ParticleStateBase;
			var node:ParticleNodeBase;
			
			var particleAnimationSetNodes:Vector.<ParticleNodeBase> = _particleAnimationSet.particleNodes;
			var particleAnimationSetNodesLength:int = particleAnimationSetNodes.length;
			for (var i:int = 0; i < particleAnimationSetNodesLength; i++)
			{
				node = particleAnimationSetNodes[i];
				state = getAnimationState(node) as ParticleStateBase;
				if (node.mode == ParticlePropertiesMode.LOCAL_DYNAMIC) 
				{
					_animatorParticleStates[_animatorParticleStates.length] = state;
					node.dataOffset = _totalLenOfOneVertex;
					_totalLenOfOneVertex += node.dataLength;
				} 
				else
					_animationParticleStates[_animationParticleStates.length] = state;
				if (state.needUpdateTime)
					_timeParticleStates[_timeParticleStates.length] = state;
			}
		}
		
		public function get duration():Number 
		{
			return _duration;
		}
		
		public function get isUsesLoop():Boolean 
		{
			return _isUsesLoop;
		}
		
		public function get maxStartTime():Number 
		{
			return _maxStartTime;
		}
		
		public function get absoluteAnimationTime():Number 
		{
			return _absoluteAnimationTime;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return new ParticleAnimator(_particleAnimationSet);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{
			var i:int;
			var animationRegisterCache:AnimationRegisterCache = _particleAnimationSet._animationRegisterCache;
			
			var subMesh:SubMesh = renderable as SubMesh;
			var state:ParticleStateBase;
			
			if (!subMesh)
				throw(new Error("Must be subMesh"));
			
			//process animation sub geometries
			if (!subMesh.animationSubGeometry)
				_particleAnimationSet.generateAnimationSubGeometries(subMesh.parentMesh);
			
			var animationSubGeometry:AnimationSubGeometry = subMesh.animationSubGeometry;
			
			var animationParticleStatesLength:int = _animationParticleStates.length;
			for (i = 0; i < animationParticleStatesLength; i++)
			{
				state = _animationParticleStates[i];
				state.setRenderState(stage3DProxy, renderable, animationSubGeometry, animationRegisterCache, camera);
			}
			
			//process animator subgeometries
			if (!subMesh.animatorSubGeometry && _animatorParticleStates.length)
				generateAnimatorSubGeometry(subMesh);
			
			var animatorSubGeometry:AnimationSubGeometry = subMesh.animatorSubGeometry;
			
			var animatorParticleStatesLength:int = _animatorParticleStates.length;
			for (i = 0; i < animatorParticleStatesLength; i++)
			{
				state = _animatorParticleStates[i];
				state.setRenderState(stage3DProxy, renderable, animatorSubGeometry, animationRegisterCache, camera);
			}
			
			stage3DProxy._context3DProxy.setProgramConstantsFromVector(Context3DProgramType.VERTEX, animationRegisterCache.vertexConstantOffset, animationRegisterCache.vertexConstantData, animationRegisterCache.numVertexConstant);
			
			if (animationRegisterCache.numFragmentConstant > 0)
				stage3DProxy._context3DProxy.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, animationRegisterCache.fragmentConstantOffset, animationRegisterCache.fragmentConstantData, animationRegisterCache.numFragmentConstant);
		}
		
		/**
		 * @inheritDoc
		 */
		public function testGPUCompatibility(pass:MaterialPassBase):void
		{
		
		}
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			
			var timeParticlesStatesLength:int = _timeParticleStates.length;
			for (var i:int = 0; i < timeParticlesStatesLength; i++)
			{
				var state:ParticleStateBase = _timeParticleStates[i];
				state.offset(_absoluteTime);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDeltaTime(dt:Number):void
		{
			_absoluteTime += dt;
			
			if (animationEnded)
				return;
				
			var timeParticlesStatesLength:int = _timeParticleStates.length;
			for (var i:int = 0; i < timeParticlesStatesLength; i++)
			{
				var state:ParticleStateBase = _timeParticleStates[i];
				state.update(_absoluteTime);
			}
			
			if(!_isUsesLoop && _absoluteAnimationTime > 0)
				animationEnded = _absoluteTime >= _absoluteAnimationTime * 1000;
		}
		
		/**
		 * @inheritDoc
		 */
		public function resetTime(offset:int = 0):void
		{
			var timeParticlesStatesLength:int = _timeParticleStates.length;
			for (var i:int = 0; i < timeParticlesStatesLength; i++)
			{
				var state:ParticleStateBase = _timeParticleStates[i];
				state.offset(_absoluteTime + offset);
			}
				
			update(time);
		}
		
		public override function dispose():void
		{
			super.dispose();
			
			for each(var it:Object in _animatorSubGeometries)
				(it as IDisposable).dispose();
				
			_particleAnimationSet = null;
			_animationParticleStates = null;
			_animatorParticleStates = null;
			_timeParticleStates = null;
			_animationParticleStates = null;
		}
		
		private function generateAnimatorSubGeometry(subMesh:SubMesh):void
		{
			var subGeometry:ISubGeometry = subMesh.subGeometry;
			var animatorSubGeometry:AnimationSubGeometry = new AnimationSubGeometry();
			subMesh.animatorSubGeometry = animatorSubGeometry;
			_animatorSubGeometries[subGeometry] = animatorSubGeometry;
			
			//create the vertexData vector that will be used for local state data
			animatorSubGeometry.createVertexData(subGeometry.numVertices, _totalLenOfOneVertex);
			
			//pass the particles data to the animator subGeometry
			animatorSubGeometry.animationParticles = subMesh.animationSubGeometry.animationParticles;
		}
	}
}