package away3d.textures
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
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
		
		private var maxMipLevel:int = 0;
		private var currentMipLevel:int = 0;
		private var isMipMapsUploaded:Boolean = false;
		
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
		
		override protected function createTexture(context:Context3D):TextureBase
		{
			if(!_isUseStreamingUpload || !_generateMipmaps)
				return context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
			else
			{
				var largestSide:int = Math.max(_width, _height);
				var mipLevel:int = MathUtils.log(largestSide);
				maxMipLevel = mipLevel;
				currentMipLevel = maxMipLevel;
				isMipMapsUploaded = false;
				
				return context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false, mipLevel);
			}
		}
		
		override public function getTextureForStage3D(stage3DProxy:Stage3DProxy):TextureBase 
		{
			var contextIndex:int = stage3DProxy._stage3DIndex;
			var texture:TextureBase = _textures[contextIndex];
			var context:Context3D = stage3DProxy._context3D;
			
			if (!texture || _dirty[contextIndex] != context) 
			{
				texture = createTexture(context);
				_textures[contextIndex] = texture;
				_dirty[contextIndex] = context;
				
				if (!_generateMipmaps)
					uploadContent(texture);
			}
			
			if(_generateMipmaps && !isMipMapsUploaded)
				uploadContent(texture);
				
			return texture;
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			if (_generateMipmaps)
			{
				if (_isUseStreamingUpload)
				{
					uploadCurrentMipLevel(texture);
				}
				else
				{
					isMipMapsUploaded = true;
					MipmapGenerator.generateMipMaps(_bitmapData, texture, true);
				}
			}
			else
				Texture(texture).uploadFromBitmapData(_bitmapData, 0);
		}
		
		private function uploadCurrentMipLevel(texture:TextureBase):void 
		{
			if (currentMipLevel == -1)
			{
				isMipMapsUploaded = true;
				return;
			}
			else
			{
				MipmapGenerator.generateMipMaps(_bitmapData, texture, true, -1, currentMipLevel, 1);
				currentMipLevel--;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}
