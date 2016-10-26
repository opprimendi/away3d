package away3d.core.context3DProxy 
{
	import away3d.arcane;
	import flash.display.BitmapData;
	import flash.display.TriangleCulling;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	use namespace arcane;
	
	public class Context3DProxy 
	{
		arcane var _context3D:Context3D;
		
		public var _currentProgram3D:Program3D;
		
		private var _texturesRegisterCache:Vector.<TextureBase> = new Vector.<TextureBase>(8, true);
		private var _vertexBufferRegisters:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8, true);
		
		private var _scissorRectangle:Rectangle = new Rectangle();
		private var _isScissorRectangleClear:Boolean = true;
		
		private var _currentCulling:String = Context3DTriangleFace.NONE;
		
		private var _depthTestData:DepthTestData = new DepthTestData();
		private var _depthClear:Boolean = true;
		
		private var _blendFactors:BlendFactors = new BlendFactors();
		
		private var _isReset:Boolean = true;
		
		private var vertexConstantBuffer:ConstantBuffer = new ConstantBuffer(128 * 4, Context3DProgramType.VERTEX);
		private var fragmentConstantBuffer:ConstantBuffer = new ConstantBuffer(64 * 4, Context3DProgramType.FRAGMENT);
		
		public function Context3DProxy() 
		{	
			initialize();
		}
		
		public function setContext3D(context3D:Context3D):void
		{
			this._context3D = context3D;
			reset();
		}
		
		private function reset():void 
		{
			if (_isReset)
				return;
				
			_isReset = true;
		}
		
		private function initialize():void 
		{
			
		}
		
		[Inline]
		public final function setProgram(program3D:Program3D):void 
		{
			if (_currentProgram3D != program3D)
			{	
				_currentProgram3D = program3D;
				_context3D.setProgram(program3D);
			}
		}
		
		[Inline]
		public final function setTextureAt(samplerId:int, texture:TextureBase):void
		{
			if (_texturesRegisterCache[samplerId] != texture)
			{
				_texturesRegisterCache[samplerId] = texture
				_context3D.setTextureAt(samplerId, texture);
			}
		}
		
		[Inline]
		public final function setProgramConstantsFromVector(programType:String, firstRegister:int, data:Vector.<Number>, numRegisters:int):void 
		{
			var size:int = 0;
			
			if (numRegisters == -1)
				size = data.length;
			else
				size = numRegisters * 4;
				
			if(programType == Context3DProgramType.VERTEX)
				vertexConstantBuffer.setVector(data, firstRegister, 0, size);
			else
				fragmentConstantBuffer.setVector(data, firstRegister, 0, size);
		}
		
		[Inline]
		public final function setProgramConstantsFromMatrix(programType:String, firstRegister:int, data:Matrix3D, transposed:Boolean):void 
		{
			if(programType == Context3DProgramType.VERTEX)
				vertexConstantBuffer.setMatrix(data, firstRegister, 0, transposed);
			else
				fragmentConstantBuffer.setMatrix(data, firstRegister, 0, transposed);
		}
		
		[Inline]
		public final function setVertexBufferAt(index:int, vertexBuffer:VertexBuffer3D, bufferOffset:int, format:String):void
		{
			if (vertexBuffer != _vertexBufferRegisters[index])
			{
				_vertexBufferRegisters[index] = vertexBuffer;
				_context3D.setVertexBufferAt(index, vertexBuffer, bufferOffset, format);
			}
		}
		
		[Inline]
		public final function clearVertexBufferAt(index:int):void
		{
			if (_vertexBufferRegisters[index] != null)
			{
				_vertexBufferRegisters[index] = null;
				_context3D.setVertexBufferAt(index, null);
			}
		}
		
		[Inline]
		public final function setScissorRectangle(rectangle:Rectangle):void
		{
			if (!_scissorRectangle.equals(rectangle))
			{
				_isScissorRectangleClear = false;
				_scissorRectangle.setTo(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
				_context3D.setScissorRectangle(_scissorRectangle);
			}
		}
		
		[Inline]
		public final function clearScissorRectangle():void
		{
			if (_isScissorRectangleClear != true)
			{
				_isScissorRectangleClear = true;
				_scissorRectangle.setTo(0, 0, 0, 0);
				_context3D.setScissorRectangle(null);
			}
		}
		
		[Inline]
		public final function setCulling(culling:String):void
		{
			if (culling != _currentCulling)
			{
				_currentCulling = culling;
				_context3D.setCulling(_currentCulling);
			}
		}
		
		[Inline]
		public final function setDepthTest(depthMask:Boolean, passCompareMode:String):void
		{
			if (_depthTestData.depthMask != depthMask || _depthTestData.passCompareMode != passCompareMode)
			{
				_depthTestData.setTo(depthMask, passCompareMode);
				_context3D.setDepthTest(depthMask, passCompareMode);
			}
		}
		
		[Inline]
		public final function setBlendFactors(sourceFactor:String, destinationFactor:String):void
		{
			if (_blendFactors.sourceFactor != sourceFactor || _blendFactors.destinationFactor != destinationFactor)
			{
				_blendFactors.sourceFactor = sourceFactor;
				_blendFactors.destinationFactor = destinationFactor;
					
				_context3D.setBlendFactors(sourceFactor, destinationFactor);
			}
		}
		
		[Inline]
		public final function clearDepthBuffer(depthValue:Number):void
		{
			if (!_depthClear)
			{
				_depthClear = true;
				
				_context3D.clear(0, 0, 0, 1, depthValue, 0, Context3DClearMask.DEPTH);
			}
		}
		
		[Inline]
		public final function drawToBitmapData(destination:BitmapData):void 
		{
			vertexConstantBuffer.upload(_context3D, 0);
			fragmentConstantBuffer.upload(_context3D, 0);
			
			_context3D.drawToBitmapData(destination);
			
			//vertexConstantBuffer.clear(_context3D);
			//fragmentConstantBuffer.clear(_context3D);
			
			vertexConstantBuffer.clearConstants();
			fragmentConstantBuffer.clearConstants();
		}
		
		[Inline]
		public final function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:Number, numTriangles:uint):void 
		{
			vertexConstantBuffer.upload(_context3D, 0);
			fragmentConstantBuffer.upload(_context3D, 0);
			
			_context3D.drawTriangles(indexBuffer, firstIndex, numTriangles);
			
			//vertexConstantBuffer.clear(_context3D);
			//fragmentConstantBuffer.clear(_context3D);
			
			vertexConstantBuffer.clearConstants();
			fragmentConstantBuffer.clearConstants();
		}
		
		[Inline]
		public final function clear(red:Number, green:Number, blue:Number, alpha:Number, depth:Number, stencil:uint, mask:uint):void 
		{
			_currentCulling = TriangleCulling.NONE;

			if (mask == Context3DClearMask.ALL || mask == Context3DClearMask.DEPTH)
				_depthClear = true;
				
			_context3D.clear(red, green, blue, alpha, depth, stencil, mask);
			
			for (var i:int = 0; i < 8; i++)
			{
				//_vertexBufferRegisters[i] = false;
				_texturesRegisterCache[i] = null;
			}
			
			//vertexConstantBuffer.clearConstants();
			//fragmentConstantBuffer.clearConstants();
			
			_currentProgram3D = null;
		}
		
		[Inline]
		public final function clearUsedVertexBuffers():void 
		{
			for (var i:int = 0; i < 8; i++)
			{
				if (_vertexBufferRegisters[i] != null)
					clearVertexBufferAt(i);
			}
		}
		
		[Inline]
		public final function clearUsedTextures():void 
		{
			for (var i:int = 0; i < 8; i++)
			{
				if (_texturesRegisterCache[i] != null)
					setTextureAt(i, null);
			}
		}
	}
}