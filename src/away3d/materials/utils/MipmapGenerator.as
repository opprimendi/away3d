package away3d.materials.utils
{
	import away3d.tools.utils.MathUtils;
	import flash.display.BitmapData;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * MipmapGenerator is a helper class that uploads BitmapData to a Texture including mipmap levels.
	 */
	public class MipmapGenerator
	{
		private static var _matrix:Matrix = new Matrix();
		private static var _rect:Rectangle = new Rectangle();
		
		private static var alphaMipMaps:Object = {};
		private static var mipMaps:Object = {};
		
		/**
		 * Uploads a BitmapData with mip maps to a target Texture object.
		 * @param source The source BitmapData to upload.
		 * @param target The target Texture to upload to.
		 * @param mipmap An optional mip map holder to avoids creating new instances for fe animated materials.
		 * @param alpha Indicate whether or not the uploaded bitmapData is transparent.
		 */
		public static function generateMipMaps(source:BitmapData, target:TextureBase, alpha:Boolean = false, side:int = -1, startLevel:int = -1, levelsToUpload:int = -1):void
		{
			var sourceWidth:int = source.width;
			var sourceHeight:int = source.height;
			
			var w:int = 0;
			var h:int = 0;
			var mipmap:BitmapData;
			
			var largestSide:int = MathUtils.maxi(sourceWidth, sourceHeight);
			var mipLevel:int = startLevel;
			
			if (mipLevel == -1)
				mipLevel = MathUtils.log(largestSide, 2);
				
			var endLvel:int = -1;
			if (levelsToUpload != -1)
				endLvel = mipLevel - levelsToUpload;
				
			for (var i:int = mipLevel; i > endLvel; i--)
			{
				w = sourceWidth >> i;
				h = sourceHeight >> i;
				
				//for rectangle textures
				if (w == 0)
					w = 1;
					
				if (h == 0)
					h = 1;
				
				//for rectangle textures
				_rect.width = w > sourceWidth? sourceWidth:w;
				_rect.height = h > sourceHeight? sourceHeight:h;
				
				mipmap = getMipMapHolder(w, h, alpha);
				
				if (alpha)
					mipmap.fillRect(_rect, 0);
				
				_matrix.a = _rect.width / source.width;
				_matrix.d = _rect.height / source.height;
				
				mipmap.draw(source, _matrix, null, null, null, true);
				
				if (target is Texture)
				{
					(target as Texture).uploadFromBitmapData(mipmap, i);
				}
				else
				{
					(target as CubeTexture).uploadFromBitmapData(mipmap, side, i);
				}
			}
		}
		
		[Inline]
		public static function getMipMapHolder(w:int, h:int, alpha:Boolean):BitmapData
		{
			var holder:Object = alpha? alphaMipMaps:mipMaps;
			
			var wHolder:Object = holder[w];
			
			if (wHolder == null)
			{
				wHolder = { };
				holder[w] = wHolder;
			}
				
			var mipmap:BitmapData = wHolder[h];
			
			if (mipmap == null)
			{
				mipmap = new BitmapData(w, h, alpha);
				wHolder[h] = mipmap;
			}
			
			return mipmap;
		}
	}
}
