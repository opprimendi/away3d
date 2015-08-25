package away3d.containers {
	import away3d.events.Object3DEvent;
	import away3d.events.Scene3DEvent;
	import flash.geom.Matrix3D;
	import flash.sampler.NewObjectSample;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.async.Async;
	
	/**
	 * @author SlavaRa
	 */
	public class ObjectContainer3DTest {
		
		private var _view:View3D;
		private var _container:ObjectContainer3D;
		private var _child:ObjectContainer3D;
		
		[Before]
		public function initialize():void {
			_view = new View3D();
			_container = new ObjectContainer3D();
			_child = new ObjectContainer3D();
		}
		
		[Test(async)]
		public function testDispatchScene3DEventADDED_TO_SCENE():void {
			Async.proceedOnEvent(this, _view.scene, Scene3DEvent.ADDED_TO_SCENE);
			_view.scene.addChild(_container);
		}
		
		[Test(async)]
		public function testDispatchScene3DEventREMOVED_FROM_SCENE():void {
			Async.proceedOnEvent(this, _view.scene, Scene3DEvent.REMOVED_FROM_SCENE);
			_view.scene.addChild(_container);
			_view.scene.removeChild(_container);
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCENE_CHANGED():void {
			_view.scene.addChild(_container);
			Async.proceedOnEvent(this, _child, Object3DEvent.SCENE_CHANGED);
			_container.addChild(_child);
		}
		
		[Test(async)]
		public function testDispatchObject3DEventSCENETRANSFORM_CHANGED():void {
			_view.scene.addChild(_container);
			Async.proceedOnEvent(this, _child, Object3DEvent.SCENE_TRANSFORM_CHANGED);
			var sceneTransform:Matrix3D = _child.sceneTransform;
			_container.addChild(_child);
		}
		
		[Test]
		public function testAddChild():void {
			assertNull(_child.parent);
			_container.addChild(_child);
			assertEquals(_container, _child.parent);
		}
		
		[Test]
		public function testRemoveChild():void {
			_container.addChild(_child);
			_container.removeChild(_child);
			assertNull(_child.parent);
		}
		
		[Test]
		public function testAddChildAt():void {
			_container.addChild(_child);
			_container.addChildAt(new ObjectContainer3D(), 0);
			assertEquals(1, _container.getChildIndex(_child));
		}
		
		[Test]
		public function testRemoveChildAt():void {
			_container.addChild(_child);
			_container.removeChildAt(0);
			assertEquals(0, _container.numChildren);
		}
		
		[Test]
		public function testGetChildAt():void {
			_container.addChild(_child);
			assertEquals(_child, _container.getChildAt(0));
		}
		
		[Test]
		public function testGetChildIndex():void {
			_container.addChild(_child);
			assertEquals(0, _container.getChildIndex(_child));
		}
		
		[Test]
		public function testAddChildren():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1);
			assertEquals(0, _container.getChildIndex(child0));
			assertEquals(1, _container.getChildIndex(child1));
		}
		
		[Ignore]
		[Test]
		public function testRemoveChildren():void {}
		
		[Ignore]
		[Test]
		public function testContains():void {}
	}
}