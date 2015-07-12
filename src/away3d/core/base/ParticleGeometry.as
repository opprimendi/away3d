package away3d.core.base
{
	import away3d.core.base.data.ParticleData;
	
	/**
	 * ...
	 */
	public class ParticleGeometry extends Geometry
	{
		public var particles:Vector.<ParticleData>;
		
		public var numParticles:uint;
		
		public function ParticleGeometry()
		{
			
		}
		
		public function reduceParticlesNum(count:int):void
		{
			particles.splice(particles.length-count-1, count)
			numParticles -= count;
		}
	
	}

}
