package away3d.textures
{
	import away3d.tools.utils.MathUtils;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	
	public class CubeTextureBase extends TextureProxyBase
	{
		protected var _size:int;
		
		public function CubeTextureBase()
		{
			super();
		}
		
		override protected function setSize(width:int, height:int):void 
		{
			_size = MathUtils.maxi(width, height);
		}
		
		public function get size():int
		{
			return _size;
		}
		
		override protected function createTexture(context3D:Context3D):TextureBase
		{
			return context3D.createCubeTexture(_size, Context3DTextureFormat.BGRA, false);
		}
	}
}