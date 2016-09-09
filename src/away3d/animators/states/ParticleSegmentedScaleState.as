package away3d.animators.states {
	import away3d.arcane;
	import away3d.animators.data.AnimationRegisterCache;
	import away3d.animators.data.AnimationSubGeometry;
	import away3d.animators.nodes.ParticleSegmentedScaleNode;
	import away3d.animators.ParticleAnimator;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import flash.geom.Vector3D;
	
	use namespace arcane;

	public class ParticleSegmentedScaleState extends ParticleStateBase
	{
		private var _startScale:Vector3D;
		private var _endScale:Vector3D;
		private var _segmentPoints:Vector.<Vector3D>;
		private var _numSegmentPoint:int;
		
		
		private var _scaleData:Vector.<Number>;
		
		/**
		 * Defines the start scale of the state, when in global mode.
		 */
		public function get startScale():Vector3D
		{
			return _startScale;
		}
		
		public function set startScale(value:Vector3D):void
		{
			_startScale = value;
			
			updateScaleData();
		}
		
		/**
		 * Defines the end scale of the state, when in global mode.
		 */
		public function get endScale():Vector3D
		{
			return _endScale;
		}
		public function set endScale(value:Vector3D):void
		{
			_endScale = value;
			updateScaleData();
		}
		
		/**
		 * Defines the number of segments.
		 */
		public function get numSegmentPoint():int
		{
			return _numSegmentPoint;
		}
		
		/**
		 * Defines the key points of Scale
		 */
		public function get segmentPoints():Vector.<Vector3D>
		{
			return _segmentPoints;
		}
		
		public function set segmentPoints(value:Vector.<Vector3D>):void
		{
			_segmentPoints = value;
			updateScaleData();
		}
		
		
		public function ParticleSegmentedScaleState(animator:ParticleAnimator, particleSegmentedScaleNode:ParticleSegmentedScaleNode)
		{
			super(animator, particleSegmentedScaleNode);
			
			_startScale = particleSegmentedScaleNode._startScale;
			_endScale = particleSegmentedScaleNode._endScale;
			_segmentPoints = particleSegmentedScaleNode._segmentScales;
			_numSegmentPoint = particleSegmentedScaleNode._numSegmentPoint;
			updateScaleData();
		}
		
		override public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, animationSubGeometry:AnimationSubGeometry, animationRegisterCache:AnimationRegisterCache, camera:Camera3D) : void
		{
			animationRegisterCache.setVertexConstFromVector(animationRegisterCache.getRegisterIndex(_animationNode, ParticleSegmentedScaleNode.START_INDEX), _scaleData);
		}
		
		private function updateScaleData():void
		{
			var _timeLifeData:Vector.<Number> = new Vector.<Number>;
			_scaleData = new Vector.<Number>;
			var i:int;
			for (i = 0; i < _numSegmentPoint; i++)
			{
				if (i == 0)
					_timeLifeData[_timeLifeData.length] = _segmentPoints[i].w;
				else
					_timeLifeData[_timeLifeData.length] = _segmentPoints[i].w - _segmentPoints[i - 1].w;
			}
			if (_numSegmentPoint == 0)
				_timeLifeData[_timeLifeData.length] = 1;
			else
				_timeLifeData[_timeLifeData.length] = 1 - _segmentPoints[i - 1].w;
				
			var scaleDataLength:Number = _scaleData.length;
			_scaleData[scaleDataLength++] = _startScale.x;
			_scaleData[scaleDataLength++] = _startScale.y;
			_scaleData[scaleDataLength++] = _startScale.z;
			_scaleData[scaleDataLength++] = 0;
			
			var timeData:Number;
			var segmentPoint2:Vector3D;
			for (i = 0; i < _numSegmentPoint; i++)
			{
				var segmentPoint:Vector3D = _segmentPoints[i];
				timeData = _timeLifeData[i];
				
				if (i == 0)
				{
					_scaleData[scaleDataLength++] = (segmentPoint.x - _startScale.x) / timeData;
					_scaleData[scaleDataLength++] =  (segmentPoint.y - _startScale.y) / timeData;
					_scaleData[scaleDataLength++] =  (segmentPoint.z - _startScale.z) / timeData;
					_scaleData[scaleDataLength++] = timeData;
				}
				else
				{
					segmentPoint2 = _segmentPoints[i - 1];
					_scaleData[scaleDataLength++] = (segmentPoint.x - segmentPoint2.x) / timeData;
					_scaleData[scaleDataLength++] = (segmentPoint.y - segmentPoint2.y) / timeData;
					_scaleData[scaleDataLength++] = (segmentPoint.z - segmentPoint2.z) / timeData;
					_scaleData[scaleDataLength++] = timeData;
				}
			}
			
			if (_numSegmentPoint == 0)
			{
				_scaleData[scaleDataLength++] = _endScale.x - _startScale.x;
				_scaleData[scaleDataLength++] = _endScale.y - _startScale.y;
				_scaleData[scaleDataLength++] = _endScale.z - _startScale.z;
				_scaleData[scaleDataLength++] = 1;
			}
			else
			{
				segmentPoint2 = _segmentPoints[i - 1];
				_scaleData[scaleDataLength++] = (_endScale.x - segmentPoint2.x) / timeData;
				_scaleData[scaleDataLength++] = (_endScale.y - segmentPoint2.y) / timeData;
				_scaleData[scaleDataLength++] = (_endScale.z - segmentPoint2.z) / timeData;
				_scaleData[scaleDataLength++] = timeData;
			}
		}
	}
}