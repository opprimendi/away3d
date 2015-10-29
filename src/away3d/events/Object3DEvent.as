package away3d.events
{
	import away3d.arcane;
	import away3d.core.base.*;
	
	import flash.events.Event;
	
	use namespace arcane;
	
	/**
	 * Passed as a parameter when a 3d object event occurs
	 */
	public class Object3DEvent extends Event
	{
		/**
		 * Defines the value of the type property of a visiblityUpdated event object.
		 */
		public static const VISIBLITY_UPDATED:String = "visiblityUpdated";
		
		/**
		 * Defines the value of the type property of a scenetransformChanged event object.
		 */
		public static const SCENE_TRANSFORM_CHANGED:String = "sceneTransformChanged";
		
		/**
		 * Defines the value of the type property of a sceneChanged event object.
		 */
		public static const SCENE_CHANGED:String = "sceneChanged";
		
		/**
		 * Defines the value of the type property of a positionChanged event object.
		 */
		public static const POSITION_CHANGED:String = "positionChanged";
		
		/**
		 * Defines the value of the type property of a rotationChanged event object.
		 */
		public static const ROTATION_CHANGED:String = "rotationChanged";
		
		/**
		 * Defines the value of the type property of a scaleChanged event object.
		 */
		public static const SCALE_CHANGED:String = "scaleChanged";
		
		/**
		 * Creates a new <code>MaterialEvent</code> object.
		 *
		 * @param    type        The type of the event. Possible values are: <code>Object3DEvent.TRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENETRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENE_CHANGED</code>, <code>Object3DEvent.RADIUS_CHANGED</code> and <code>Object3DEvent.DIMENSIONS_CHANGED</code>.
		 * @param    object        A reference to the 3d object that is relevant to the event.
		 */
		public function Object3DEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		arcane var $stopped:Boolean;
		arcane var $canceled:Boolean;
		
		arcane var $target:Object;
		public override function get target():Object {
			return this.$target || super.target;
		}
		
		arcane var $eventPhase:uint;
		public override function get eventPhase():uint {
			return this.$eventPhase || super.eventPhase;
		}
		
		public override function stopImmediatePropagation():void {
			super.stopImmediatePropagation();
			this.$stopped = true;
		}

		public override function stopPropagation():void {
			super.stopPropagation();
			this.$stopped = true;
		}

		public override function preventDefault():void {
			if (super.cancelable) {
				super.preventDefault();
				this.$canceled = true;
			}
		}

		public override function isDefaultPrevented():Boolean {
			return this.$canceled;
		}

		public override function clone():Event {
			var type:Class = Object(this)["constructor"] as Class;
			return new type(super.type, super.bubbles, super.cancelable);
		}
	}
}
