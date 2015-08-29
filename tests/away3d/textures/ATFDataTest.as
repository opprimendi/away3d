package away3d.textures {
	import away3d.textures.ATFData;
	import flash.display3D.Context3DTextureFormat;
	import org.flexunit.asserts.assertEquals;
	
	/**
	 * @author SlavaRa
	 */
	public class ATFDataTest {
		
		[Test]
		public function testGetFormat():void {
			assertEquals(Context3DTextureFormat.BGRA, ATFData.getFormat(0));
			assertEquals(Context3DTextureFormat.BGRA, ATFData.getFormat(1));
			assertEquals(Context3DTextureFormat.COMPRESSED, ATFData.getFormat(2));
			assertEquals(Context3DTextureFormat.COMPRESSED, ATFData.getFormat(3));
			assertEquals(Context3DTextureFormat.COMPRESSED_ALPHA, ATFData.getFormat(4));
			assertEquals(Context3DTextureFormat.COMPRESSED_ALPHA, ATFData.getFormat(5));
		}
		
		[Test(expects="Error")]
		public function testGetFormatWithUnsupportedFlag():void {
			ATFData.getFormat(6);
		}
		
		[Test]
		public function testGetType():void {
			assertEquals(ATFData.TYPE_NORMAL, ATFData.getType(0));
			assertEquals(ATFData.TYPE_CUBE, ATFData.getType(1));
		}
		
		[Test(expects="Error")]
		public function testGetTypeWithUnsupportedFlag():void {
			ATFData.getType(2);
		}
	}
}