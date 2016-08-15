package away3d.tools.utils 
{
	public class Context3DProfile 
	{
		public var value:String;
		public var versionAvailableFrom:Number;
		public var priority:int;
		
		public function Context3DProfile(value:String, versionAvailableFrom:Number, priority:int) 
		{
			this.priority = priority;
			this.versionAvailableFrom = versionAvailableFrom;
			this.value = value;
		}
		
		public function toString():String
		{
			return value;
		}
	}
}