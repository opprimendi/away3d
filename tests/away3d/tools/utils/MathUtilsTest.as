package away3d.tools.utils {
	import away3d.tools.utils.MathUtils;
	import org.flexunit.asserts.assertEquals;
	
	/**
	 * @author SlavaRa
	 */
	public class MathUtilsTest {
		
		[Test]
		public function testMethod():void {
			assertEquals(2, MathUtils.clamp(1, 2, 3));
            assertEquals(2, MathUtils.clamp(2, 2, 3));
            assertEquals(3, MathUtils.clamp(3, 2, 3));
            assertEquals(3, MathUtils.clamp(4, 2, 3));
            assertEquals(-3, MathUtils.clamp(-4, -3, -2));
            assertEquals(-2, MathUtils.clamp(-1, -3, -2));
		}
		
		[Test]
		public function testMin2():void {
			assertEquals(0, MathUtils.min2(0, 1));
			assertEquals(0, MathUtils.min2(1, 0));
			assertEquals(-1, MathUtils.min2(-1, 0));
			assertEquals(-1, MathUtils.min2(0, -1));
		}
		
		[Test]
		public function testMax2():void {
			assertEquals(1, MathUtils.max2(0, 1));
			assertEquals(1, MathUtils.max2(1, 0));
			assertEquals(0, MathUtils.max2(-1, 0));
			assertEquals(0, MathUtils.max2(0, -1));
		}
	}
}