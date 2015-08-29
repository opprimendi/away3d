package away3d.controllers
{
	import away3d.arcane;
	import away3d.core.math.*;
	import away3d.entities.*;
	
	use namespace arcane;
	
	/**
	 * Extended camera used to hover round a specified target object.
	 *
	 * @see    away3d.containers.View3D
	 */
	public class FirstPersonController extends ControllerBase
	{
		arcane var _currentPanAngle:Number = 0;
		arcane var _currentTiltAngle:Number = 90;
		
		private var _panAngle:Number = 0;
		private var _tiltAngle:Number = 90;
		private var _minTiltAngle:Number = -90;
		private var _maxTiltAngle:Number = 90;
		private var _steps:uint;
		private var _walkIncrement:Number = 0;
		private var _strafeIncrement:Number = 0;
		private var _wrapPanAngle:Boolean;
		
		public var fly:Boolean;
		
		/**
		 * Fractional step taken each time the <code>hover()</code> method is called. Defaults to 8.
		 *
		 * Affects the speed at which the <code>tiltAngle</code> and <code>panAngle</code> resolve to their targets.
		 *
		 * @see    #tiltAngle
		 * @see    #panAngle
		 */
		public function get steps():uint
		{
			return _steps;
		}
		
		public function set steps(value:uint):void
		{
			value = (value < 1)? 1 : value;
			
			if (_steps == value)
				return;
			
			_steps = value;
			
			notifyUpdate();
		}
		
		/**
		 * Rotation of the camera in degrees around the y axis. Defaults to 0.
		 */
		public function get panAngle():Number
		{
			return _panAngle;
		}
		
		public function set panAngle(value:Number):void
		{
			if (_panAngle == value)
				return;
			
			_panAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Elevation angle of the camera in degrees. Defaults to 90.
		 */
		public function get tiltAngle():Number
		{
			return _tiltAngle;
		}
		
		public function set tiltAngle(value:Number):void
		{
			value = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, value));
			
			if (_tiltAngle == value)
				return;
			
			_tiltAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Minimum bounds for the <code>tiltAngle</code>. Defaults to -90.
		 *
		 * @see    #tiltAngle
		 */
		public function get minTiltAngle():Number
		{
			return _minTiltAngle;
		}
		
		public function set minTiltAngle(value:Number):void
		{
			if (_minTiltAngle == value)
				return;
			
			_minTiltAngle = value;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		/**
		 * Maximum bounds for the <code>tiltAngle</code>. Defaults to 90.
		 *
		 * @see    #tiltAngle
		 */
		public function get maxTiltAngle():Number
		{
			return _maxTiltAngle;
		}
		
		public function set maxTiltAngle(value:Number):void
		{
			if (_maxTiltAngle == value)
				return;
			
			_maxTiltAngle = value;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		
		/**
		 * Defines whether the value of the pan angle wraps when over 360 degrees or under 0 degrees. Defaults to false.
		 */
		public function get wrapPanAngle():Boolean
		{
			return _wrapPanAngle;
		}
		
		public function set wrapPanAngle(value:Boolean):void
		{
			if (_wrapPanAngle == value)
				return;
			
			_wrapPanAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Creates a new <code>HoverController</code> object.
		 */
		public function FirstPersonController(targetObject:Entity = null, panAngle:Number = 0, tiltAngle:Number = 90, minTiltAngle:Number = -90, maxTiltAngle:Number = 90, steps:uint = 8, wrapPanAngle:Boolean = false)
		{
			super(targetObject);
			
			this.panAngle = panAngle;
			this.tiltAngle = tiltAngle;
			this.minTiltAngle = minTiltAngle;
			this.maxTiltAngle = maxTiltAngle;
			this.steps = steps;
			this.wrapPanAngle = wrapPanAngle;
			
			//values passed in contrustor are applied immediately
			_currentPanAngle = _panAngle;
			_currentTiltAngle = _tiltAngle;
		}
		
		/**
		 * Updates the current tilt angle and pan angle values.
		 *
		 * Values are calculated using the defined <code>tiltAngle</code>, <code>panAngle</code> and <code>steps</code> variables.
		 *
		 * @param interpolate   If the update to a target pan- or tiltAngle is interpolated. Default is true.
		 *
		 * @see    #tiltAngle
		 * @see    #panAngle
		 * @see    #steps
		 */
		public override function update(interpolate:Boolean = true):void
		{
			if (_tiltAngle != _currentTiltAngle || _panAngle != _currentPanAngle) {
				
				notifyUpdate();
				
				if (_wrapPanAngle) {
					if (_panAngle < 0) {
						_currentPanAngle += _panAngle%360 + 360 - _panAngle;
						_panAngle = _panAngle%360 + 360;
					} else {
						_currentPanAngle += _panAngle%360 - _panAngle;
						_panAngle = _panAngle%360;
					}
					
					while (_panAngle - _currentPanAngle < -180)
						_currentPanAngle -= 360;
					
					while (_panAngle - _currentPanAngle > 180)
						_currentPanAngle += 360;
				}
				
				if (interpolate) {
					_currentTiltAngle += (_tiltAngle - _currentTiltAngle)/(steps + 1);
					_currentPanAngle += (_panAngle - _currentPanAngle)/(steps + 1);
				} else {
					_currentTiltAngle = _tiltAngle;
					_currentPanAngle = _panAngle;
				}
				
				//snap coords if angle differences are close
				if ((Math.abs(tiltAngle - _currentTiltAngle) < 0.01) && (Math.abs(_panAngle - _currentPanAngle) < 0.01)) {
					_currentTiltAngle = _tiltAngle;
					_currentPanAngle = _panAngle;
				}
			}
			
			targetObject.rotationX = _currentTiltAngle;
			targetObject.rotationY = _currentPanAngle;
			
			if (_walkIncrement) {
				if (fly)
					targetObject.moveForward(_walkIncrement);
				else {
					targetObject.x += _walkIncrement*Math.sin(_panAngle*MathConsts.DEGREES_TO_RADIANS);
					targetObject.z += _walkIncrement*Math.cos(_panAngle*MathConsts.DEGREES_TO_RADIANS);
				}
				_walkIncrement = 0;
			}
			
			if (_strafeIncrement) {
				targetObject.moveRight(_strafeIncrement);
				_strafeIncrement = 0;
			}
		
		}
		
		public function incrementWalk(value:Number):void
		{
			if (value == 0)
				return;
			
			_walkIncrement += value;
			
			notifyUpdate();
		}
		
		public function incrementStrafe(value:Number):void
		{
			if (value == 0)
				return;
			
			_strafeIncrement += value;
			
			notifyUpdate();
		}
	
	}
}
