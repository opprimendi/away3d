package away3d.textures
{
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;
	
	public class ATFData
	{
		public static const TYPE_NORMAL:int = 0x0;
		public static const TYPE_CUBE:int = 0x1;
		
		public static function getFormat(flag:int):String {
			switch(flag) {
				case 0:
				case 1:
					return Context3DTextureFormat.BGRA;
				case 2:
				case 3:
					return Context3DTextureFormat.COMPRESSED;
				case 4:
				case 5:
					return Context3DTextureFormat.COMPRESSED_ALPHA;
				default:
					throw new Error("Invalid ATF format");
			}
		}
		
		public static function getType(flag:int):int {
			switch(flag) {
				case 0:
					return TYPE_NORMAL;
				case 1:
					return TYPE_CUBE;
				default:
					throw new Error("Invalid ATF type");
			}
		}
		
		/** 
		 * Create a new instance by parsing the given byte array.
		 */
		public function ATFData(data:ByteArray)
		{
			var sign:String = data.readUTFBytes(3);
			if (sign != "ATF")
				throw new Error("ATF parsing error, unknown format " + sign);
			
			if (data[6] == 255)
				data.position = 12; // new file version
			else
				data.position = 6; // old file version
			
			var tdata:uint = data.readUnsignedByte();
			var _type:int = tdata >> 7; // UB[1]
			var _format:int = tdata & 0x7f; // UB[7]
			format = getFormat(_format);
			type = getType(_type);
			this.width = Math.pow(2, data.readUnsignedByte());
			this.height = Math.pow(2, data.readUnsignedByte());
			this.numTextures = data.readUnsignedByte();
			this.data = data;
		}
		
		public var type:int;
		public var format:String;
		public var width:int;
		public var height:int;
		public var numTextures:int;
		public var data:ByteArray;
	}
}
