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
		[Inline]
		public static function generateMipMaps(source:BitmapData, target:TextureBase, alpha:Boolean = false, side:int = -1):void
		{
			var sourceWidth:Number = source.width;
			var sourceHeight:Number = source.height;
			
			var w:int = 1;// source.width;
			var h:int = 1;// source.height;
			var mipmap:BitmapData;
			
			_rect.width = w;
			_rect.height = h;
			
			var largestSide:int = Math.max(sourceWidth, sourceHeight);
			var mipLevel:int = MathUtils.log(largestSide);
			
			for (var i:int = mipLevel; i > -1; i--)
			{
				mipmap = getMipMapHolder(w, h, alpha);
				
				if (alpha)
					mipmap.fillRect(_rect, 0);
				
				_matrix.a = _rect.width/source.width;
				_matrix.d = _rect.height/source.height;
				
				mipmap.draw(source, _matrix, null, null, null, true);
				
				if (target is Texture)
				{
					Texture(target).uploadFromBitmapData(mipmap, i);
				}
				else
					CubeTexture(target).uploadFromBitmapData(mipmap, side, i);
				
				w = w << 1;
				h = h << 1;
				
				//for rectangle textures
				_rect.width = w > sourceWidth? sourceWidth:w;
				_rect.height = h > sourceHeight? sourceHeight:h;
			}
		}
		
		[Inline]
		private static function getMipMapHolder(w:int, h:int, alpha:Boolean):BitmapData
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
