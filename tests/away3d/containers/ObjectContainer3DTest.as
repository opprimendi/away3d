package away3d.containers {
	import away3d.events.Object3DEvent;
	import away3d.events.Scene3DEvent;
	import flash.geom.Matrix3D;
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
		public function dispatchScene3DEventADDED_TO_SCENE():void {
			Async.proceedOnEvent(this, _view.scene, Scene3DEvent.ADDED_TO_SCENE);
			_view.scene.addChild(_container);
		}
		
		[Test(async)]
		public function dispatchScene3DEventREMOVED_FROM_SCENE():void {
			Async.proceedOnEvent(this, _view.scene, Scene3DEvent.REMOVED_FROM_SCENE);
			_view.scene.addChild(_container);
			_view.scene.removeChild(_container);
		}
		
		[Test(async)]
		public function dispatchObject3DEventSCENE_CHANGED():void {
			_view.scene.addChild(_container);
			Async.proceedOnEvent(this, _child, Object3DEvent.SCENE_CHANGED);
			_container.addChild(_child);
		}
		
		[Test(async)]
		public function dispatchObject3DEventSCENETRANSFORM_CHANGED():void {
			_view.scene.addChild(_container);
			Async.proceedOnEvent(this, _child, Object3DEvent.SCENE_TRANSFORM_CHANGED);
			var sceneTransform:Matrix3D = _child.sceneTransform;
			_container.addChild(_child);
		}
		
		[Test]
		public function addChild():void {
			assertNull(_child.parent);
			_container.addChild(_child);
			assertEquals(_container, _child.parent);
		}
		
		[Test]
		public function removeChild():void {
			_container.addChild(_child);
			_container.removeChild(_child);
			assertNull(_child.parent);
		}
		
		[Test]
		public function addChildAt():void {
			_container.addChild(_child);
			_container.addChildAt(new ObjectContainer3D(), 0);
			assertEquals(1, _container.getChildIndex(_child));
		}
		
		[Test]
		public function removeChildAt():void {
			_container.addChild(_child);
			_container.removeChildAt(0);
			assertEquals(0, _container.numChildren);
		}
		
		[Test]
		public function getChildAt():void {
			_container.addChild(_child);
			assertEquals(_child, _container.getChildAt(0));
		}
		
		[Test]
		public function getChildIndex():void {
			_container.addChild(_child);
			assertEquals(0, _container.getChildIndex(_child));
		}
		
		[Test]
		public function addChildren():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1);
			assertEquals(0, _container.getChildIndex(child0));
			assertEquals(1, _container.getChildIndex(child1));
		}
		
		[Test]
		public function removeChildren_0():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1, child2);
			_container.removeChilden();
			assertEquals(0, _container.numChildren);
		}
		
		[Test]
		public function removeChildren_1():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1, child2);
			_container.removeChilden(1);
			assertEquals(1, _container.numChildren);
			assertEquals(child0, _container.getChildAt(0));
		}
		
		[Test]
		public function removeChildren_2():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1, child2);
			_container.removeChilden(0, 1);
			assertEquals(1, _container.numChildren);
			assertEquals(child2, _container.getChildAt(0));
		}
		
		[Test]
		public function dispose_0():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0, child1, child2);
			_container.dispose();
			assertEquals(0, _container.numChildren);
		}
		
		[Test]
		public function dispose_1():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			child2.addChildren(child0, child1);
			_container.addChildren(child2);
			_container.dispose();
			assertEquals(0, _container.numChildren);
			assertEquals(0, child2.numChildren);
		}
		
		[Test]
		public function dispose_2():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			_container.addChildren(child0);
			child0.dispose();
			assertEquals(_container, child0.parent);
		}
		
		[Test]
		public function removeChildWithDispose():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			child2.addChildren(child0, child1);
			_container.addChildren(child2);
			_container.removeChild(child2, true);
			assertEquals(0, child2.numChildren);
		}
		
		[Test]
		public function removeChildAtWithDispose():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var child2:ObjectContainer3D = new ObjectContainer3D();
			child2.addChildren(child0, child1);
			_container.addChildren(child2);
			_container.removeChildAt(0, true);
			assertEquals(0, child2.numChildren);
		}
		
		[Test]
		public function removeChildrenWithDispose():void {
			var child0:ObjectContainer3D = new ObjectContainer3D();
			var child1:ObjectContainer3D = new ObjectContainer3D();
			var container0:ObjectContainer3D = new ObjectContainer3D();
			var child3:ObjectContainer3D = new ObjectContainer3D();
			var child4:ObjectContainer3D = new ObjectContainer3D();
			var container1:ObjectContainer3D = new ObjectContainer3D();
			container0.addChildren(child0, child1);
			container1.addChildren(child3, child4);
			_container.addChildren(container0, container1);
			_container.removeChilden(0, -1, true);
			assertEquals(0, container0.numChildren);
			assertEquals(0, container1.numChildren);
		}
	}
}