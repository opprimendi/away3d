package away3d.tools.utils 
{
	import flash.display3D.Context3DProfile;
	import flash.system.Capabilities;
	
	public class Context3DProfiles 
	{
		public static const BASELINE:Context3DProfile = new Context3DProfile("baseline", 11.4, 4);
		
		public static const BASELINE_CONSTRAINED:Context3DProfile = new Context3DProfile("baselineConstrained", 11.4, 10);
		
		public static const BASELINE_EXTENDED:Context3DProfile = new Context3DProfile("baselineExtended", 11.8, 3);
		
		public static const STANDARD:Context3DProfile = new Context3DProfile("standard", 14.0, 2);
		
		public static const STANDARD_CONSTRAINED:Context3DProfile = new Context3DProfile("standardConstrained", 16.0, 3);
		
		public static const STANDARD_EXTENDED:Context3DProfile = new Context3DProfile("standardExtended", 17.0, 1);
		
		public static const PROFILES_LIST:Vector.<Context3DProfile> = new <Context3DProfile>
																							[
																								STANDARD_EXTENDED, STANDARD, STANDARD_CONSTRAINED,
																								BASELINE_EXTENDED, BASELINE, BASELINE_CONSTRAINED
																							];
		
		static private var playerVersion:int = -1;
		
		public function Context3DProfiles() 
		{
			
		}
		
		public static function getMatchingProfiles():Vector.<String>
		{
			var i:int;
			
			var version:Number = getVersion();
			
			var availableProfiles:Vector.<Context3DProfile> = new Vector.<Context3DProfile>();
			
			for (i = 0; i < PROFILES_LIST.length; i++)
			{
				if (PROFILES_LIST[i].versionAvailableFrom <= version)
				{
					availableProfiles.push(PROFILES_LIST[i]);
				}
			}
			
			availableProfiles.sort(prioritySort);
			
			var profilesList:Vector.<String> = new Vector.<String>(availableProfiles.length, true);
			for (i = 0; i < availableProfiles.length; i++)
			{
				profilesList[i] = availableProfiles[i].value;
			}
			
			return profilesList;
		}
		
		static private function prioritySort(a:Context3DProfile, b:Context3DProfile):Number 
		{
			var aPriority:Number = a.priority;
			var bPriority:Number = b.priority;
			
			if (aPriority > bPriority)
			{
				return 1;
			}
			else if (aPriority < bPriority)
			{
				return -1;
			}
			else
				return 0;
		}
		
		static private function getVersion():Number 
		{
			if (playerVersion == -1)
			{
				var version:String = Capabilities.version;
				var vaersionParts:Array = version.split(" ")[1].split(",");
				
				var mainVerson:Number = int(vaersionParts[0]);
				var secondVersion:Number = Number(vaersionParts[1]) / 100;
				
				playerVersion = mainVerson + secondVersion;
			}
			
			return playerVersion;
		}
	}
}