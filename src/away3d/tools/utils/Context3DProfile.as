package away3d.tools.utils 
{
	public class Context3DProfile 
	{
		public static const BASELINE:String = "baseline";
		public static const BASELINE_CONSTRAINED:String = "baselineConstrained";
		public static const BASELINE_EXTENDED:String = "baselineExtended";
		public static const STANDARD:String = "standard";
		public static const STANDARD_CONSTRAINED:String = "standardConstrained";
		public static const STANDARD_EXTENDED:String = "standardExtended";
		
		public var value:String;
		public var versionAvailableFrom:Number;
		public var priority:int;
		
		public function Context3DProfile(value:String, versionAvailableFrom:Number, priority:int) 
		{
			this.priority = priority;
			this.versionAvailableFrom = versionAvailableFrom;
			this.value = value;
		}
		
		public function isAvalible():Boolean
		{
			return versionAvailableFrom <= Context3DProfiles.getVersion();
		}
		
		public function toString():String
		{
			return value;
		}
	}
}