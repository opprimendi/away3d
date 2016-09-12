package away3d.core.context3DProxy 
{
	import away3d.tools.utils.MathUtils;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	public class ConstantBuffer 
	{
		private var registerOffset:int;
		
		private var identityVector:Vector.<Number>;
		private var constantsValue:Vector.<Number>;
		
		private var size:int = 0;
		
		private var type:String;
		
		private var registersUploaded:int = 0;
		
		public function ConstantBuffer(size:int, type:String = Context3DProgramType.VERTEX) 
		{
			this.type = type;
			
			constantsValue = new Vector.<Number>(size, true);
			identityVector = new Vector.<Number>(size, true);
		}
		
		[Inline]
		public final function setMatrix(data:Matrix3D, firstRegister:int, startFrom:Number, transposed:Boolean):void 
		{
			var setProgramConstantsFromVector:int = firstRegister * 4;
			data.copyRawDataTo(constantsValue, setProgramConstantsFromVector, transposed);
			size = MathUtils.maxi(size, setProgramConstantsFromVector + 16);
		}
		
		[Inline]
		public final function setValue(position:int, value:Number):void
		{
			constantsValue[position] = value;
			size = MathUtils.maxi(size, position);
		}
		
		[Inline]
		public final function setVector(vector:Vector.<Number>, registerIndex:int, startFrom:int, length:int):void
		{	
			var startPosition:int = registerIndex * 4;
			size = Math.max(size, startPosition + length);
			
			length += startFrom;
			for (var i:int = startFrom; i < length; i++)
			{
				constantsValue[startPosition++] = vector[i];
			}
		}
		
		[Inline]
		public final function upload(context3D:Context3D, registerOffset:int):void
		{
			if (size != 0)
			{
				this.registerOffset = registerOffset;
				this.registersUploaded = Math.ceil(size / 4);
				
				context3D.setProgramConstantsFromVector(type, registerOffset, constantsValue, registersUploaded);
			}
		}
		
		[Inline]
		public final function clear(context3D:Context3D):void
		{
			if (registersUploaded != 0)
			{
				registerOffset = 0;
				context3D.setProgramConstantsFromVector(type, registerOffset, identityVector, registersUploaded);
				//TODO: possible to clear at upload only register > then we upload next time
				registersUploaded = 0;
			}
		}
		
		[Inline]
		public final function clearConstants():void
		{
			size = 0;
		}
	}
}