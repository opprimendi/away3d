package away3d.textures
{
	import away3d.arcane;
	import away3d.materials.utils.MipmapGenerator;
	import away3d.tools.utils.MathUtils;
	import away3d.tools.utils.TextureUtils;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	use namespace arcane;
	
	public class BitmapTexture extends Texture2DBase
	{
		private var _bitmapData:BitmapData;
		private var _generateMipmaps:Boolean;
		private var _isUseStreamingUpload:Boolean = false;
		
		public function BitmapTexture(bitmapData:BitmapData, generateMipmaps:Boolean = true)
		{
			super();
			
			this.bitmapData = bitmapData;
			_generateMipmaps = generateMipmaps;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			if (value == _bitmapData)
				return;
			
			if (!TextureUtils.isBitmapDataValid(value))
				throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");
			
			invalidateContent();
			setSize(value.width, value.height);
			
			_bitmapData = value;
		}
		
		public function get isUseStreamingUpload():Boolean 
		{
			return _isUseStreamingUpload;
		}
		
		public function set isUseStreamingUpload(value:Boolean):void 
		{
			_isUseStreamingUpload = value;
		}
		
		override protected function createTexture(context:Context3D):TextureBase
		{
			if(!_isUseStreamingUpload || !_generateMipmaps)
				return context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
			else
			{
				var largestSide:int = Math.max(_width, _height);
				var mipLevel:int = MathUtils.log(largestSide);
				
				return context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false, mipLevel);
			}
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			if (_generateMipmaps) //может добавить какой нибудь тик для аплоада чтобы все мипмапы постепенно бы аплоадились а не сразу и аплоадить с самого маленького размера к большему
				MipmapGenerator.generateMipMaps(_bitmapData, texture, true);
			else
				Texture(texture).uploadFromBitmapData(_bitmapData, 0);
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}
