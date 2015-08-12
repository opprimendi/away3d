package away3d.animators.data {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	
	/**
	 * @author SlavaRa
	 */
	public class SkeletonUnitTest {
		
		private var _skeleton:Skeleton;
		
		[Before]
		public function initialize():void {
			_skeleton = new Skeleton();
		}
		
		[Test]
		public function testJointIndexFromName():void {
			var name:String = "test";
			assertEquals( -1, _skeleton.jointIndexFromName(name));
			var joint:SkeletonJoint = new SkeletonJoint();
			joint.name = name;
			_skeleton.joints.push(joint);
			assertEquals(0, _skeleton.jointIndexFromName(name));
		}
		
		[Test]
		public function testJointFromName():void {
			var name:String = "test";
			assertNull(_skeleton.jointFromName(name));
			var joint:SkeletonJoint = new SkeletonJoint();
			joint.name = name;
			_skeleton.joints.push(joint);
			assertEquals(joint, _skeleton.jointFromName(name));
		}
	}
}