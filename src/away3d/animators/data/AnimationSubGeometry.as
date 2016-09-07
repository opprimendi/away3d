package away3d.animators.data
{
	import away3d.arcane;
	import away3d.core.context3DProxy.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	
	use namespace arcane;
	
	public class AnimationSubGeometry
	{
		protected var _vertexData:Vector.<Number>;
		
		protected var _vertexBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		protected var _bufferContext3D:Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _bufferDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
		
		private var _numVertices:uint;
		
		private var _totalLenOfOneVertex:uint;
		
		public var numProcessedVertices:int = 0;
		
		public var previousTime:Number = Number.NEGATIVE_INFINITY;
		
		public var animationParticles:Vector.<ParticleAnimationData> = new Vector.<ParticleAnimationData>();
		
		public function AnimationSubGeometry()
		{
			for (var i:int = 0; i < 8; i++)
				_bufferDirty[i] = true;
		}
		
		public function createVertexData(numVertices:uint, totalLenOfOneVertex:uint):void
		{
			_numVertices = numVertices;
			_totalLenOfOneVertex = totalLenOfOneVertex;
			_vertexData = new Vector.<Number>(numVertices*totalLenOfOneVertex, true);
		}
		
		public function activateVertexBuffer(index:int, bufferOffset:int, stage3DProxy:Stage3DProxy, format:String):void
		{
			var contextIndex:int = stage3DProxy.stage3DIndex;
			var context3D:Context3D = stage3DProxy._context3D;
			var context3DProxy:Context3DProxy = stage3DProxy._context3DProxy;
			
			var buffer:VertexBuffer3D = _vertexBuffer[contextIndex];
			if (!buffer || _bufferContext3D[contextIndex] != context3D) {
				buffer = _vertexBuffer[contextIndex] = context3D.createVertexBuffer(_numVertices, _totalLenOfOneVertex);
				_bufferContext3D[contextIndex] = context3D;
				_bufferDirty[contextIndex] = true;
			}
			if (_bufferDirty[contextIndex]) {
				buffer.uploadFromVector(_vertexData, 0, _numVertices);
				_bufferDirty[contextIndex] = false;
			}
			context3DProxy.setVertexBufferAt(index, buffer, bufferOffset, format);
		}
		
		public function dispose():void
		{
			while (_vertexBuffer.length) {
				var vertexBuffer:VertexBuffer3D = _vertexBuffer.pop();
				if (vertexBuffer)
					vertexBuffer.dispose();
			}
		}
		
		public function invalidateBuffer():void
		{
			for (var i:int = 0; i < 8; i++)
				_bufferDirty[i] = true;
		}
		
		public function get vertexData():Vector.<Number>
		{
			return _vertexData;
		}
		
		public function get numVertices():uint
		{
			return _numVertices;
		}
		
		public function get totalLenOfOneVertex():uint
		{
			return _totalLenOfOneVertex;
		}
	}
}