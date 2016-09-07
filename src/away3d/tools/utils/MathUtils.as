package away3d.tools.utils 
{
	public class MathUtils
	{	
		/**
		 * Return base logarifm of value e.g log(512, 2) Log2(512) - 9
		 * @param	value
		 * @param	base
		 * @return
		 */
		public static function log(value:Number, base:Number = 2):Number
		{
			return Math.log(value) / Math.log(base);
		}
		
		[Inline]
		public static function convertToRadian(angle:Number):Number
		{
			return angle * Math.PI / 180;
		}
		
		[Inline]
		public static function convertToDegree(angle:Number):Number
		{
			return 180 * angle / Math.PI;
		}	
		
		[Inline]
		public static function maxi(value1:int, value2:int):int
		{
			if (value1 > value2)
				return value1;
			else
				return value2;
		}
		
		/**
		 * Moves 'value' into the range between 'min' and 'max'.
		 */
		[Inline]
		public static function clamp(value:Number, min:Number, max:Number):Number {
			if(value < min) return min;
			if(value > max) return max;
			return value;
		}
	}
}