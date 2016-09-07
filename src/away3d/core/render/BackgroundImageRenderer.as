package away3d.core.render
{
	import away3d.arcane;
	import away3d.core.context3DProxy.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.textures.Texture2DBase;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	
	use namespace arcane;
	
	public class BackgroundImageRenderer
	{
		private var _program3d:Program3D;
		private var _texture:Texture2DBase;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _stage3DProxy:Stage3DProxy;
		private var _context3D:Context3D;
		
		public function BackgroundImageRenderer(stage3DProxy:Stage3DProxy)
		{
			this.stage3DProxy = stage3DProxy;
		}
		
		public function get stage3DProxy():Stage3DProxy
		{
			return _stage3DProxy;
		}
		
		public function set stage3DProxy(value:Stage3DProxy):void
		{
			if (value == _stage3DProxy)
				return;
			_stage3DProxy = value;
			
			removeBuffers();
		}
		
		private function removeBuffers():void
		{
			if (_vertexBuffer) {
				_vertexBuffer.dispose();
				_vertexBuffer = null;
				_program3d.dispose();
				_program3d = null;
				_indexBuffer.dispose();
				_indexBuffer = null;
			}
		}
		
		private function getVertexCode():String
		{
			return "mov op, va0\n" +
				"mov v0, va1";
		}
		
		private function getFragmentCode():String
		{
			var format:String;
			switch (_texture.format) {
				case Context3DTextureFormat.COMPRESSED:
					format = "dxt1,";
					break;
				case "compressedAlpha":
					format = "dxt5,";
					break;
				default:
					format = "";
			}
			return "tex ft0, v0, fs0 <2d, " + format + "linear>	\n" +
				"mov oc, ft0";
		}
		
		public function dispose():void
		{
			removeBuffers();
		}
		
		public function render():void
		{
			var context3DProxy:Context3DProxy = _stage3DProxy._context3DProxy;
			var context3D:Context3D = _stage3DProxy._context3D;
			
			if (context3D != _context3D) {
				removeBuffers();
				_context3D = context3D;
			}
			
			if (!_context3D)
				return;
			
			if (!_vertexBuffer)
				initBuffers(_context3D);
			
			context3DProxy.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context3DProxy.setProgram(_program3d);
			context3DProxy.setTextureAt(0, _texture.getTextureForStage3D(_stage3DProxy));
			context3DProxy.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3DProxy.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			_context3D.drawTriangles(_indexBuffer, 0, 2);
			
			context3DProxy.clearVertexBufferAt(0);
			context3DProxy.clearVertexBufferAt(1);
			context3DProxy.setTextureAt(0, null);
		}
		
		private function initBuffers(context3D:Context3D):void
		{
			_vertexBuffer = context3D.createVertexBuffer(4, 4);
			_program3d = context3D.createProgram();
			_indexBuffer = context3D.createIndexBuffer(6);
			_indexBuffer.uploadFromVector(Vector.<uint>([2, 1, 0, 3, 2, 0]), 0, 6);
			_program3d.upload(new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.VERTEX, getVertexCode()),
				new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.FRAGMENT, getFragmentCode())
				);
			
			var w:Number = 2;
			var h:Number = 2;
			var x:Number = -1;
			var y:Number = 1;
			
			if (_stage3DProxy.scissorRect) {
				x = (_stage3DProxy.scissorRect.x * 2 - _stage3DProxy.viewPort.width) / _stage3DProxy.viewPort.width;
				y = (_stage3DProxy.scissorRect.y * 2 - _stage3DProxy.viewPort.height) / _stage3DProxy.viewPort.height * -1;
				w = 2 / (_stage3DProxy.viewPort.width / _stage3DProxy.scissorRect.width);
				h = 2 / (_stage3DProxy.viewPort.height / _stage3DProxy.scissorRect.height);
			}
			
			_vertexBuffer.uploadFromVector(Vector.<Number>([x, y-h, 0, 1,
			x+w, y-h, 1, 1,
			x+w, y, 1, 0,
			x, y, 0, 0
			]), 0, 4);
		}
		
		public function get texture():Texture2DBase
		{
			return _texture;
		}
		
		public function set texture(value:Texture2DBase):void
		{
			_texture = value;
		}
	}
}
