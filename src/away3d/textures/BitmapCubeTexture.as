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
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.TextureBase;
	
	use namespace arcane;
	
	public class BitmapCubeTexture extends CubeTextureBase
	{
		private var _bitmapDatas:Vector.<BitmapData>;
		private var _generateMipmaps:Boolean;
		
		//TODO: refactor that upload mechanis should be same to BitmapCubeTexture and BitmapTexture with differend upload strategy(uploadCubeTexture, uploadTexture) probably all bitmap based textures should have same parent class or inject upload mechanism
		private var maxMipLevel:int;
		private var currentMipLevel:int;
		private var isMipMapsUploaded:Boolean;
		
		//private var _useAlpha : Boolean;
		
		public function BitmapCubeTexture(posX:BitmapData, negX:BitmapData, posY:BitmapData, negY:BitmapData, posZ:BitmapData, negZ:BitmapData, generateMipmaps:Boolean = true)
		{
			super();
			_generateMipmaps = generateMipmaps;
			this._hasMipmaps = generateMipmaps;
			_bitmapDatas = new Vector.<BitmapData>(6, true);
			testSize(_bitmapDatas[0] = posX);
			testSize(_bitmapDatas[1] = negX);
			testSize(_bitmapDatas[2] = posY);
			testSize(_bitmapDatas[3] = negY);
			testSize(_bitmapDatas[4] = posZ);
			testSize(_bitmapDatas[5] = negZ);
			setSize(posX.width, posX.height);
		}
		
		/**
		 * The texture on the cube's right face.
		 */
		public function get positiveX():BitmapData
		{
			return _bitmapDatas[0];
		}
		
		public function set positiveX(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[0] = value;
		}
		
		/**
		 * The texture on the cube's left face.
		 */
		public function get negativeX():BitmapData
		{
			return _bitmapDatas[1];
		}
		
		public function set negativeX(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[1] = value;
		}
		
		/**
		 * The texture on the cube's top face.
		 */
		public function get positiveY():BitmapData
		{
			return _bitmapDatas[2];
		}
		
		public function set positiveY(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[2] = value;
		}
		
		/**
		 * The texture on the cube's bottom face.
		 */
		public function get negativeY():BitmapData
		{
			return _bitmapDatas[3];
		}
		
		public function set negativeY(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[3] = value;
		}
		
		/**
		 * The texture on the cube's far face.
		 */
		public function get positiveZ():BitmapData
		{
			return _bitmapDatas[4];
		}
		
		public function set positiveZ(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[4] = value;
		}
		
		/**
		 * The texture on the cube's near face.
		 */
		public function get negativeZ():BitmapData
		{
			return _bitmapDatas[5];
		}
		
		public function set negativeZ(value:BitmapData):void
		{
			testSize(value);
			invalidateContent();
			setSize(value.width, value.height);
			_bitmapDatas[5] = value;
		}
		
		private function testSize(value:BitmapData):void
		{
			if (value.width != value.height)
				throw new Error("BitmapData should have equal width and height!");
			if (!TextureUtils.isBitmapDataValid(value))
				throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");
		}
		
		override protected function createTexture(context3D:Context3D):TextureBase 
		{
			if (_isUseStreamingUpload)
			{
				var mipLevel:int = MathUtils.log(_size);
				maxMipLevel = mipLevel;
				currentMipLevel = maxMipLevel;
				isMipMapsUploaded = false;
				return context3D.createCubeTexture(_size, Context3DTextureFormat.BGRA, false, mipLevel);
			}
			return context3D.createCubeTexture(_size, Context3DTextureFormat.BGRA, false, 0);
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
				
				if (!_generateMipmaps)
					uploadContent(texture);
			}
			
			if(_generateMipmaps && !isMipMapsUploaded)
				uploadContent(texture);
				
			return texture;
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			for (var i:int = 0; i < 6; ++i)
			{
				if (_generateMipmaps)
				{
					if (_isUseStreamingUpload)
					{
						uploadCurrentMipLevel(texture, i);
					}
					else
					{
						isMipMapsUploaded = true;
						MipmapGenerator.generateMipMaps(_bitmapDatas[i], texture, _bitmapDatas[i].transparent, i);
					}
				}
				else
					(texture as CubeTexture).uploadFromBitmapData(_bitmapDatas[i], i, 0);
			}
			
			if (_isUseStreamingUpload)
				currentMipLevel--;
		}
		
		private function uploadCurrentMipLevel(texture:TextureBase, side:int):void 
		{
			if (currentMipLevel == -1)
			{
				isMipMapsUploaded = true;
				return;
			}
			MipmapGenerator.generateMipMaps(_bitmapDatas[side], texture, _bitmapDatas[side].transparent, side, currentMipLevel, 1);
		}
	}
}