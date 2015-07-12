package away3d.core.base {
	import away3d.events.Object3DEvent;
	import flash.geom.Vector3D;
	import org.flexunit.async.Async;
	
	/**
	 * @author SlavaRa
	 */
	public class Object3DTest {
		
		[Test(async)]
		public function testDispatchObject3DEventPOSITION_CHANGEDAfterSetPosition():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.POSITION_CHANGED);
			target.position = new Vector3D();
		}
		
		[Test(async)]
		public function testDispatchObject3DEventPOSITION_CHANGEDAfterSetX():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.POSITION_CHANGED);
			target.x = 10;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventPOSITION_CHANGEDAfterSetY():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.POSITION_CHANGED);
			target.y = 10;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventPOSITION_CHANGEDAfterSetZ():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.POSITION_CHANGED);
			target.z = 10;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCALE_CHANGEDAfterScale():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.SCALE_CHANGED);
			target.scale(0.1);
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCALE_CHANGEDAfterSetScaleX():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.SCALE_CHANGED);
			target.scaleX = 0.1;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCALE_CHANGEDAfterSetScaleY():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.SCALE_CHANGED);
			target.scaleY = 0.1;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCALE_CHANGEDAfterSetScaleZ():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.SCALE_CHANGED);
			target.scaleZ = 0.1;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventROTATION_CHANGEDAfterRotate():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.ROTATION_CHANGED);
			target.rotate(new Vector3D(), 90);
		}
		
		[Test(async)]
		public function testDispatchObject3DEventROTATION_CHANGEDAfterRotateTo():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.ROTATION_CHANGED);
			target.rotateTo(90, 0, 0);
		}
		
		[Test(async)]
		public function testDispatchObject3DEventROTATION_CHANGEDAfterSetRotationX():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.ROTATION_CHANGED);
			target.rotationX = 90;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventROTATION_CHANGEDAfterSetRotationY():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.ROTATION_CHANGED);
			target.rotationY = 90;
		}
		
		[Test(async)]
		public function testDispatchObject3DEventROTATION_CHANGEDAfterSetRotationZ():void {
			var target:Object3D = new Object3D();
			Async.proceedOnEvent(this, target, Object3DEvent.ROTATION_CHANGED);
			target.rotationZ = 90;
		}
	}
}