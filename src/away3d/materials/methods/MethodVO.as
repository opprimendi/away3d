package away3d.materials.methods
{
	import away3d.textures.Anisotropy;
	/**
	 * MethodVO contains data for a given method for the use within a single material.
	 * This allows methods to be shared across materials while their non-public state differs.
	 */
	public class MethodVO
	{
		public var vertexData:Vector.<Number>;
		public var fragmentData:Vector.<Number>;
		
		// public register indices
		public var texturesIndex:int;
		public var secondaryTexturesIndex:int; // sometimes needed for composites
		public var vertexConstantsIndex:int;
		public var secondaryVertexConstantsIndex:int; // sometimes needed for composites
		public var fragmentConstantsIndex:int;
		public var secondaryFragmentConstantsIndex:int; // sometimes needed for composites
		
		public var useMipmapping:Boolean;
		public var useSmoothTextures:Boolean;
		public var repeatTextures:Boolean;
		
		public var anisotropy:int = Anisotropy.NONE;
		public var bias:Number = 0;
		
		// internal stuff for the material to know before assembling code
		public var needsProjection:Boolean;
		public var needsView:Boolean;
		public var needsNormals:Boolean;
		public var needsTangents:Boolean;
		public var needsUV:Boolean;
		public var needsSecondaryUV:Boolean;
		public var needsGlobalVertexPos:Boolean;
		public var needsGlobalFragmentPos:Boolean;
		
		public var numLights:int;
		public var useLightFallOff:Boolean = true;
		
		

		/**
		 * Creates a new MethodVO object.
		 */
		public function MethodVO()
		{
		
		}

		/**
		 * Resets the values of the value object to their "unused" state.
		 */
		public function reset():void
		{
			texturesIndex = -1;
			vertexConstantsIndex = -1;
			fragmentConstantsIndex = -1;
			
			useMipmapping = true;
			useSmoothTextures = true;
			repeatTextures = false;
			
			needsProjection = false;
			needsView = false;
			needsNormals = false;
			needsTangents = false;
			needsUV = false;
			needsSecondaryUV = false;
			needsGlobalVertexPos = false;
			needsGlobalFragmentPos = false;
			
			bias = 0;
			anisotropy = Anisotropy.NONE;
			
			numLights = 0;
			useLightFallOff = true;
		}
	}
}
