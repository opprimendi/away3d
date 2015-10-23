////////////////////////////////////////////////////////////////////////////////
//
//  © 2015 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////
package away3d.entities {
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.core.base.Geometry;
	import away3d.materials.MaterialBase;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	
	/**
	 * @author					SlavaRa
	 * @langversion				3.0
	 * @date					23.10.2015 16:29
	 */
	public class MeshTest {
		
		[Test]
		public function dispose():void {
			var mesh:Mesh = new Mesh(new Geometry(), new MaterialBase());
			mesh.animator = new SkeletonAnimator(new SkeletonAnimationSet(), new Skeleton());
			mesh.addChildren(new Entity(), new Entity());
			mesh.dispose();
			assertNull(mesh.geometry);
			assertNull(mesh.material);
			assertNull(mesh.animator);
			assertEquals(0, mesh.numChildren);
		}
	}
}