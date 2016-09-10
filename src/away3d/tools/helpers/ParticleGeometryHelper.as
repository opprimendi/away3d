package away3d.tools.helpers
{
	import away3d.core.base.ParticleGeometry;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.data.ParticleData;
	import away3d.core.base.Geometry;
	import away3d.core.base.ISubGeometry;
	import away3d.tools.helpers.data.ParticleGeometryTransform;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 */
	public class ParticleGeometryHelper
	{
		public static const MAX_VERTEX:int = 65535;
		
		public static function generateGeometry(geometries:Vector.<Geometry>, transforms:Vector.<ParticleGeometryTransform> = null):ParticleGeometry
		{
			var verticesVector:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			var verticesVectorLength:int = 0;
			
			var indicesVector:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
			var indicesVectorLength:int = 0;
			
			var vertexCounters:Vector.<uint> = new Vector.<uint>();
			var vertexCountersLength:int = 0;
			
			var particles:Vector.<ParticleData> = new Vector.<ParticleData>();
			var particlesLength:int = 0;
			
			var subGeometries:Vector.<CompactSubGeometry> = new Vector.<CompactSubGeometry>();
			var subGeometriesLength:int = 0;
			
			var numParticles:uint = geometries.length;
			
			var sourceSubGeometries:Vector.<ISubGeometry>;
			var sourceSubGeometry:ISubGeometry;
			var numSubGeometries:uint;
			var vertices:Vector.<Number>;
			var indices:Vector.<uint>;
			var vertexCounter:uint;
			var subGeometry:CompactSubGeometry;
			var i:int;
			var j:int;
			var sub2SubMap:Vector.<int> = new Vector.<int>;
			var sub2SubMapLength:int = 0;
			
			var tempVertex:Vector3D = new Vector3D;
			var tempNormal:Vector3D = new Vector3D;
			var tempTangents:Vector3D = new Vector3D;
			var tempUV:Point = new Point;
			
			for (i = 0; i < numParticles; i++) 
			{
				sourceSubGeometries = geometries[i].subGeometries;
				numSubGeometries = sourceSubGeometries.length;
				
				for (var srcIndex:int = 0; srcIndex < numSubGeometries; srcIndex++) 
				{
					//create a different particle subgeometry group for each source subgeometry in a particle.
					if (sub2SubMapLength <= srcIndex) 
					{
						sub2SubMap[sub2SubMapLength++] = subGeometries.length;
						verticesVector[verticesVectorLength++] = new Vector.<Number>;
						indicesVector[indicesVectorLength++] = new Vector.<uint>;
						subGeometries[subGeometriesLength++] = new CompactSubGeometry();
						vertexCounters[vertexCountersLength++] = 0;
					}
					
					sourceSubGeometry = sourceSubGeometries[srcIndex];
					
					//add a new particle subgeometry if this source subgeometry will take us over the maxvertex limit
					if (sourceSubGeometry.numVertices + vertexCounters[sub2SubMap[srcIndex]] > MAX_VERTEX) 
					{
						//update submap and add new subgeom vectors
						sub2SubMap[srcIndex] = subGeometriesLength;
						verticesVector[verticesVectorLength++] = new Vector.<Number>;
						indicesVector[indicesVectorLength++] = new Vector.<uint>;
						subGeometries[subGeometriesLength++] = new CompactSubGeometry();
						vertexCounters[vertexCountersLength++] = 0;
					}
					
					j = sub2SubMap[srcIndex];
					
					//select the correct vector
					vertices = verticesVector[j];
					indices = indicesVector[j];
					vertexCounter = vertexCounters[j];
					subGeometry = subGeometries[j];
					
					var particleData:ParticleData = new ParticleData();
					particleData.numVertices = sourceSubGeometry.numVertices;
					particleData.startVertexIndex = vertexCounter;
					particleData.particleIndex = i;
					particleData.subGeometry = subGeometry;
					particles[particles.length] = particleData;
					
					vertexCounters[j] += sourceSubGeometry.numVertices;
					
					var k:int;
					var tempLen:int;
					var compact:CompactSubGeometry = sourceSubGeometry as CompactSubGeometry;
					var product:uint;
					var sourceVertices:Vector.<Number>;
					
					if (compact) {
						tempLen = compact.numVertices;
						compact.numTriangles;
						sourceVertices = compact.vertexData;
						
						if (transforms) {
							var particleGeometryTransform:ParticleGeometryTransform = transforms[i];
							var vertexTransform:Matrix3D = particleGeometryTransform.vertexTransform;
							var invVertexTransform:Matrix3D = particleGeometryTransform.invVertexTransform;
							var UVTransform:Matrix = particleGeometryTransform.UVTransform;
							
							for (k = 0; k < tempLen; k++) {
								/*
								 * 0 - 2: vertex position X, Y, Z
								 * 3 - 5: normal X, Y, Z
								 * 6 - 8: tangent X, Y, Z
								 * 9 - 10: U V
								 * 11 - 12: Secondary U V*/
								product = k*13;
								tempVertex.x = sourceVertices[product];
								tempVertex.y = sourceVertices[product + 1];
								tempVertex.z = sourceVertices[product + 2];
								tempNormal.x = sourceVertices[product + 3];
								tempNormal.y = sourceVertices[product + 4];
								tempNormal.z = sourceVertices[product + 5];
								tempTangents.x = sourceVertices[product + 6];
								tempTangents.y = sourceVertices[product + 7];
								tempTangents.z = sourceVertices[product + 8];
								tempUV.x = sourceVertices[product + 9];
								tempUV.y = sourceVertices[product + 10];
								
								if (vertexTransform) 
								{
									tempVertex = vertexTransform.transformVector(tempVertex);
									tempNormal = invVertexTransform.deltaTransformVector(tempNormal);
									tempTangents = invVertexTransform.deltaTransformVector(tempNormal);
								}
								
								if (UVTransform)
									tempUV = UVTransform.transformPoint(tempUV);
									
								var vertsLength:int = vertices.length;
								//this is faster than that only push one data
								
								vertices[vertsLength++] = tempVertex.x;
								vertices[vertsLength++] = tempVertex.y;
								vertices[vertsLength++] = tempVertex.z;
								vertices[vertsLength++] = tempNormal.y;
								vertices[vertsLength++] = tempNormal.z;
								vertices[vertsLength++] = tempTangents.x;
								vertices[vertsLength++] = tempTangents.y;
								vertices[vertsLength++] = tempTangents.z;
								vertices[vertsLength++] = tempUV.x;
								vertices[vertsLength++] = tempUV.y;
								vertices[vertsLength++] = sourceVertices[product + 11];
								vertices[vertsLength++] = sourceVertices[product + 12];
							}
						} 
						else 
						{
							var verticesLength:int = vertices.length;
							
							for (k = 0; k < tempLen; k++) 
							{
								product = k * 13;
								//this is faster than that only push one data
								vertices[verticesLength++] = sourceVertices[product];
								vertices[verticesLength++] = sourceVertices[product + 1];
								vertices[verticesLength++] = sourceVertices[product + 2];
								vertices[verticesLength++] = sourceVertices[product + 3];
								vertices[verticesLength++] = sourceVertices[product + 4];
								vertices[verticesLength++] = sourceVertices[product + 5];
								vertices[verticesLength++] = sourceVertices[product + 6];
								vertices[verticesLength++] = sourceVertices[product + 7];
								vertices[verticesLength++] = sourceVertices[product + 8];
								vertices[verticesLength++] = sourceVertices[product + 9];
								vertices[verticesLength++] = sourceVertices[product + 10];
								vertices[verticesLength++] = sourceVertices[product + 11];
								vertices[verticesLength++] = sourceVertices[product + 12];
							}
						}
					} 
					else 
					{
						//Todo
					}
					
					var sourceIndices:Vector.<uint> = sourceSubGeometry.indexData;
					tempLen = sourceSubGeometry.numTriangles;
					var indicesLength:int = indices.length;
					for (k = 0; k < tempLen; k++) 
					{
						product = k * 3;
						
						indices[indicesLength] = sourceIndices[product] + vertexCounter;
						indices[indicesLength] = sourceIndices[product + 1] + vertexCounter;
						indices[indicesLength] = sourceIndices[product + 2] + vertexCounter;
					}
				}
			}
			
			var particleGeometry:ParticleGeometry = new ParticleGeometry();
			particleGeometry.particles = particles;
			particleGeometry.numParticles = numParticles;
			
			numParticles = subGeometries.length;
			for (i = 0; i < numParticles; i++) {
				subGeometry = subGeometries[i];
				subGeometry.updateData(verticesVector[i]);
				subGeometry.updateIndexData(indicesVector[i]);
				particleGeometry.addSubGeometry(subGeometry);
			}
			
			return particleGeometry;
		}
	}

}
