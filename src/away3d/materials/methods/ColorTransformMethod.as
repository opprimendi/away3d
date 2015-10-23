package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import flash.geom.ColorTransform;
	
	use namespace arcane;
	
	/**
	 * ColorTransformMethod provides a shading method that changes the colour of a material analogous to a
	 * ColorTransform object.
	 */
	public class ColorTransformMethod extends EffectMethodBase
	{
		private static const INV:Number = 1 / 0xff;
		private var _colorTransform:ColorTransform;
		
		/**
		 * Creates a new ColorTransformMethod.
		 */
		public function ColorTransformMethod()
		{
			super();
		}
		
		/**
		 * The ColorTransform object to transform the colour of the material with.
		 */
		public function get colorTransform():ColorTransform
		{
			return _colorTransform;
		}
		
		public function set colorTransform(value:ColorTransform):void
		{
			_colorTransform = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var colorMultReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var colorOffsReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			vo.fragmentConstantsIndex = colorMultReg.index * 4;
			var result:String = "mul " + targetReg + ", " + targetReg.toString() + ", " + colorMultReg + "\n" +
								"add " + targetReg + ", " + targetReg.toString() + ", " + colorOffsReg + "\n";
			return result;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			var index:int = vo.fragmentConstantsIndex;
			var data:Vector.<Number> = vo.fragmentData;
			data[index] = _colorTransform.redMultiplier;
			data[index + 1] = _colorTransform.greenMultiplier;
			data[index + 2] = _colorTransform.blueMultiplier;
			data[index + 3] = _colorTransform.alphaMultiplier;
			data[index + 4] = _colorTransform.redOffset*INV;
			data[index + 5] = _colorTransform.greenOffset*INV;
			data[index + 6] = _colorTransform.blueOffset*INV;
			data[index + 7] = _colorTransform.alphaOffset*INV;
		}
	}
}
