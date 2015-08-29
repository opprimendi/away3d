package away3d.cameras.lenses
{
	import away3d.core.math.Matrix3DUtils;
	import flash.geom.Vector3D;
	
	/**
	 * The PerspectiveLens object provides a projection matrix that projects 3D geometry isometrically. This entails
	 * there is no perspective distortion, and lines that are parallel in the scene will remain parallel on the screen.
	 */
	public class OrthographicLens extends LensBase
	{
		private var _projectionHeight:Number;
		private var _xMax:Number;
		private var _yMax:Number;
		
		/**
		 * Creates a new OrthogonalLens object.
		 */
		public function OrthographicLens(projectionHeight:Number = 500)
		{
			super();
			_projectionHeight = projectionHeight;
		}
		
		/**
		 * The vertical field of view of the projection.
		 */
		public function get projectionHeight():Number
		{
			return _projectionHeight;
		}
		
		public function set projectionHeight(value:Number):void
		{
			if (value == _projectionHeight)
				return;
			_projectionHeight = value;
			invalidateMatrix();
		}
		
		/**
		 * Calculates the scene position relative to the camera of the given normalized coordinates in screen space.
		 *
		 * @param nX The normalised x coordinate in screen space, -1 corresponds to the left edge of the viewport, 1 to the right.
		 * @param nY The normalised y coordinate in screen space, -1 corresponds to the top edge of the viewport, 1 to the bottom.
		 * @param sZ The z coordinate in screen space, representing the distance into the screen.
		 * @param result The destination Vector3D object
		 * @return The scene position relative to the camera of the given screen coordinates.
		 */
		override public function unproject(nX:Number, nY:Number, sZ:Number, result:Vector3D = null):Vector3D
		{
			result ||= new Vector3D();
			var translation:Vector3D = Matrix3DUtils.CALCULATION_VECTOR3D;
			matrix.copyColumnTo(3, translation);
			result.x = nX + translation.x;
			result.y = -nY + translation.y;
			result.z = sZ;
			result.w = 1;
			Matrix3DUtils.transformVector(unprojectionMatrix, result, result);
			//z is unaffected by transform
			result.z = sZ;
			return result;
		}
		
		override public function clone():LensBase
		{
			var result:OrthographicLens = new OrthographicLens();
			result._near = _near;
			result._far = _far;
			result._aspectRatio = _aspectRatio;
			result.projectionHeight = _projectionHeight;
			return result;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateMatrix():void
		{
			var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			_yMax = _projectionHeight*.5;
			_xMax = _yMax*_aspectRatio;
			
			var left:Number, right:Number, top:Number, bottom:Number;
			
			if (_scissorRect.x == 0 && _scissorRect.y == 0 && _scissorRect.width == _viewPort.width && _scissorRect.height == _viewPort.height) {
				// assume symmetric frustum
				
				left = -_xMax;
				right = _xMax;
				top = -_yMax;
				bottom = _yMax;
				
				raw[0] = 2/(_projectionHeight*_aspectRatio);
				raw[5] = 2/_projectionHeight;
				raw[10] = 1/(_far - _near);
				raw[14] = _near/(_near - _far);
				raw[1] = 0;
				raw[2] = 0;
				raw[3] = 0;
				raw[4] = 0;
				raw[6] = 0;
				raw[7] = 0;
				raw[8] = 0;
				raw[9] = 0;
				raw[11] = 0;
				raw[12] = 0;
				raw[13] = 0;
				raw[15] = 1;
				
			} else {
				
				var xWidth:Number = _xMax*(_viewPort.width/_scissorRect.width);
				var yHgt:Number = _yMax*(_viewPort.height/_scissorRect.height);
				var center:Number = _xMax*(_scissorRect.x*2 - _viewPort.width)/_scissorRect.width + _xMax;
				var middle:Number = -_yMax*(_scissorRect.y*2 - _viewPort.height)/_scissorRect.height - _yMax;
				
				left = center - xWidth;
				right = center + xWidth;
				top = middle - yHgt;
				bottom = middle + yHgt;
				
				raw[0] = 2*1/(right - left);
				raw[5] = -2*1/(top - bottom);
				raw[10] = 1/(_far - _near);
				raw[12] = (right + left)/(right - left);
				raw[13] = (bottom + top)/(bottom - top);
				raw[14] = _near/(near - far);
				raw[1] = 0;
				raw[2] = 0;
				raw[3] = 0;
				raw[4] = 0;
				raw[6] = 0;
				raw[7] = 0;
				raw[8] = 0;
				raw[9] = 0;
				raw[11] = 0;
				raw[15] = 1;
			}
			
			_frustumCorners[0] = _frustumCorners[9] = _frustumCorners[12] = _frustumCorners[21] = left;
			_frustumCorners[3] = _frustumCorners[6] = _frustumCorners[15] = _frustumCorners[18] = right;
			_frustumCorners[1] = _frustumCorners[4] = _frustumCorners[13] = _frustumCorners[16] = top;
			_frustumCorners[7] = _frustumCorners[10] = _frustumCorners[19] = _frustumCorners[22] = bottom;
			_frustumCorners[2] = _frustumCorners[5] = _frustumCorners[8] = _frustumCorners[11] = _near;
			_frustumCorners[14] = _frustumCorners[17] = _frustumCorners[20] = _frustumCorners[23] = _far;
			
			_matrix.copyRawDataFrom(raw);
			
			_matrixInvalid = false;
		}
	}
}