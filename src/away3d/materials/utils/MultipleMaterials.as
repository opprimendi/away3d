package away3d.materials.utils
{
	import away3d.materials.MaterialBase;
	
	public class MultipleMaterials
	{
		private var _left:MaterialBase;
		private var _right:MaterialBase;
		private var _bottom:MaterialBase;
		private var _top:MaterialBase;
		private var _front:MaterialBase;
		private var _back:MaterialBase;
		
		/**
		 * Creates a new <code>MultipleMaterials</code> object.
		 * Class can hold up to 6 materials. Class is designed to work as typed object for materials setters in a multitude of classes such as Cube, LatheExtrude (with thickness) etc...
		 *
		 * @param    front:MaterialBase        [optional] The front material.
		 * @param    back:MaterialBase        [optional] The back material.
		 * @param    left:MaterialBase        [optional] The left material.
		 * @param    right:MaterialBase        [optional] The right material.
		 * @param    top:MaterialBase        [optional] The top material.
		 * @param    down:MaterialBase        [optional] The down material.
		 */
		
		public function MultipleMaterials(front:MaterialBase = null, back:MaterialBase = null, left:MaterialBase = null, right:MaterialBase = null, top:MaterialBase = null)
		{
			_left = left;
			_right = right;
			_bottom = bottom;
			_top = top;
			_front = front;
			_back = back;
		}
		
		/**
		 * Defines the material applied to the left side of the cube.
		 */
		public function get left():MaterialBase
		{
			return _left;
		}
		
		public function set left(value:MaterialBase):void
		{
			_left = value;
		}
		
		/**
		 * Defines the material applied to the right side of the cube.
		 */
		public function get right():MaterialBase
		{
			return _right;
		}
		
		public function set right(value:MaterialBase):void
		{
			_right = value;
		}
		
		/**
		 * Defines the material applied to the bottom side of the cube.
		 */
		public function get bottom():MaterialBase
		{
			return _bottom;
		}
		
		public function set bottom(value:MaterialBase):void
		{
			_bottom = value;
		}
		
		/**
		 * Defines the material applied to the top side of the cube.
		 */
		public function get top():MaterialBase
		{
			return _top;
		}
		
		public function set top(value:MaterialBase):void
		{
			_top = value;
		}
		
		/**
		 * Defines the material applied to the front side of the cube.
		 */
		public function get front():MaterialBase
		{
			return _front;
		}
		
		public function set front(value:MaterialBase):void
		{
			_front = value;
		}
		
		/**
		 * Defines the material applied to the back side of the cube.
		 */
		public function get back():MaterialBase
		{
			return _back;
		}
		
		public function set back(value:MaterialBase):void
		{
			_back = value;
		}
	
	}
}