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
		
		private var currentMipLevel:int;
		private var isTextureUploaded:Boolean;
		
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
			
			_bitmapData = value;
			invalidateContent();
		}
		
		override public function invalidateContent():void 
		{
			super.invalidateContent();
			
			setSize(_bitmapData.width, _bitmapData.height);
			
			if (_generateMipmaps)
				resetMipMapData();
				
			isTextureUploaded = false;
		}
		
		private function resetMipMapData():void
		{
			var largestSide:int = Math.max(_width, _height);
			currentMipLevel = MathUtils.log(largestSide);
		}
		
		override protected function createTexture(context3D:Context3D):TextureBase
		{
			if(!_isUseStreamingUpload || !_generateMipmaps)
				return context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
			
			resetMipMapData();
			isTextureUploaded = false;
			
			return context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA, false, currentMipLevel);
		}
		
		override public function getTextureForStage3D(stage3DProxy:Stage3DProxy):TextureBase 
		{
			var contextIndex:int = stage3DProxy.arcane::_stage3DIndex;
			var texture:TextureBase = _textures[contextIndex];
			var context3D:Context3D = stage3DProxy.arcane::_context3D;
			
			if (!texture || _dirty[contextIndex] != context3D) 
			{
				texture = createTexture(context3D);
				_textures[contextIndex] = texture;
				_dirty[contextIndex] = context3D;
			}
			
			if(!isTextureUploaded)
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
					isTextureUploaded = true;
					MipmapGenerator.generateMipMaps(_bitmapData, texture, true);
				}
			}
			else
			{
				isTextureUploaded = true;
				(texture as Texture).uploadFromBitmapData(_bitmapData, 0);
			}
		}
		
		private function uploadCurrentMipLevel(texture:TextureBase):void 
		{
			if (currentMipLevel == -1)
			{
				isTextureUploaded = true;
				return;
			}
			
			MipmapGenerator.generateMipMaps(_bitmapData, texture, true, -1, currentMipLevel, 1);
			currentMipLevel--;
		}
	}
}