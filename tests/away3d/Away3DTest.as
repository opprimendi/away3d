package away3d {
	import org.flexunit.asserts.assertEquals;
	
	/**
	 * @author SlavaRa
	 */
	public class Away3DTest {
		
		[Test]
		public function testMethod():void {
			assertEquals(4, Away3D.MAJOR_VERSION);
			assertEquals(1, Away3D.MINOR_VERSION);
			assertEquals(6, Away3D.REVISION);
		}
	}
}