package away3d.tools.utils {
	import away3d.tools.utils.MathUtils;
	import org.flexunit.asserts.assertEquals;
	
	/**
	 * @author SlavaRa
	 */
	public class Context3DProfilesTest {
		
		[Test]
		public function testProfileValue():void {
			assertEquals(Context3DProfiles.BASELINE.value, Context3DProfile.BASELINE);
			assertEquals(Context3DProfiles.BASELINE_CONSTRAINED.value, Context3DProfile.BASELINE_CONSTRAINED);
			assertEquals(Context3DProfiles.BASELINE_EXTENDED.value, Context3DProfile.BASELINE_EXTENDED);
			assertEquals(Context3DProfiles.STANDARD.value, Context3DProfile.STANDARD);
			assertEquals(Context3DProfiles.STANDARD_CONSTRAINED.value, Context3DProfile.STANDARD_CONSTRAINED);
			assertEquals(Context3DProfiles.STANDARD_EXTENDED.value, Context3DProfile.STANDARD_EXTENDED);
		}
		
		[Test]
		public function testProfileAvalible():void
		{
			var version:Number = Context3DProfiles.getVersion();
			
			assertEquals(Context3DProfiles.BASELINE.versionAvailableFrom <= version, Context3DProfiles.BASELINE.isAvalible());
			assertEquals(Context3DProfiles.BASELINE_CONSTRAINED.versionAvailableFrom <= version, Context3DProfiles.BASELINE_CONSTRAINED.isAvalible());
			assertEquals(Context3DProfiles.BASELINE_EXTENDED.versionAvailableFrom <= version, Context3DProfiles.BASELINE_EXTENDED.isAvalible());
			assertEquals(Context3DProfiles.STANDARD.versionAvailableFrom <= version, Context3DProfiles.STANDARD.isAvalible());
			assertEquals(Context3DProfiles.STANDARD_CONSTRAINED.versionAvailableFrom <= version, Context3DProfiles.STANDARD_CONSTRAINED.isAvalible());
			assertEquals(Context3DProfiles.STANDARD_EXTENDED.versionAvailableFrom <= version, Context3DProfiles.STANDARD_EXTENDED.isAvalible());
		}
	}
}