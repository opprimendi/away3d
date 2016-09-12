package away3d.core.context3DProxy 
{
	import flash.display3D.Context3DCompareMode;
	
	public class DepthTestData 
	{
		public var depthMask:Boolean = false;
		public var passCompareMode:String = Context3DCompareMode.LESS_EQUAL;
		
		public function DepthTestData() 
		{
			
		}
		
		[Inline]
		public final function setTo(depthMask:Boolean, passCompareMode:String):void 
		{
			this.depthMask = depthMask;
			this.passCompareMode = passCompareMode;
		}
	}
}