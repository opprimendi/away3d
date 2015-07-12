package away3d.lights
{
	import away3d.arcane;
	import away3d.bounds.BoundingSphere;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.core.base.IRenderable;
	import away3d.core.math.Matrix3DUtils;
	import away3d.core.partition.EntityNode;
	import away3d.core.partition.PointLightNode;
	import away3d.lights.shadowmaps.CubeMapShadowMapper;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	/**
	 * PointLight represents an omni-directional light. The light is emitted from a given position in the scene.
	 */
	public class PointLight extends LightBase
	{
		//private static var _pos : Vector3D = new Vector3D();
		arcane var _radius:Number = 90000;
		arcane var _fallOff:Number = 100000;
		arcane var _fallOffFactor:Number;
		
		/**
		 * Creates a new PointLight object.
		 */
		public function PointLight()
		{
			super();
			_fallOffFactor = 1/(_fallOff*_fallOff - _radius*_radius);
		}
		
		override protected function createShadowMapper():ShadowMapperBase
		{
			return new CubeMapShadowMapper();
		}
		
		override protected function createEntityPartitionNode():EntityNode
		{
			return new PointLightNode(this);
		}
		
		/**
		 * The minimum distance of the light's reach.
		 */
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set radius(value:Number):void
		{
			_radius = value;
			if (_radius < 0)
				_radius = 0;
			else if (_radius > _fallOff) {
				_fallOff = _radius;
				invalidateBounds();
			}
			
			_fallOffFactor = 1/(_fallOff*_fallOff - _radius*_radius);
		}
		
		arcane function fallOffFactor():Number
		{
			return _fallOffFactor;
		}
		
		/**
		 * The maximum distance of the light's reach
		 */
		public function get fallOff():Number
		{
			return _fallOff;
		}
		
		public function set fallOff(value:Number):void
		{
			_fallOff = value;
			if (_fallOff < 0)
				_fallOff = 0;
			if (_fallOff < _radius)
				_radius = _fallOff;
			_fallOffFactor = 1/(_fallOff*_fallOff - _radius*_radius);
			invalidateBounds();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateBounds():void
		{
			//			super.updateBounds();
			//			_bounds.fromExtremes(-_fallOff, -_fallOff, -_fallOff, _fallOff, _fallOff, _fallOff);
			_bounds.fromSphere(new Vector3D(), _fallOff);
			_boundsInvalid = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getDefaultBoundingVolume():BoundingVolumeBase
		{
			return new BoundingSphere();
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function getObjectProjectionMatrix(renderable:IRenderable, target:Matrix3D = null):Matrix3D
		{
			var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			var bounds:BoundingVolumeBase = renderable.sourceEntity.bounds;
			var m:Matrix3D = new Matrix3D();
			
			// todo: do not use lookAt on Light
			m.copyFrom(renderable.sceneTransform);
			m.append(_parent.inverseSceneTransform);
			lookAt(m.position);
			
			m.copyFrom(renderable.sceneTransform);
			m.append(inverseSceneTransform);
			m.copyColumnTo(3, _pos);
			
			var v1:Vector3D = m.deltaTransformVector(bounds.min);
			var v2:Vector3D = m.deltaTransformVector(bounds.max);
			var z:Number = _pos.z;
			var d1:Number = v1.x*v1.x + v1.y*v1.y + v1.z*v1.z;
			var d2:Number = v2.x*v2.x + v2.y*v2.y + v2.z*v2.z;
			var d:Number = Math.sqrt(d1 > d2? d1 : d2);
			var zMin:Number, zMax:Number;
			
			zMin = z - d;
			zMax = z + d;
			
			raw[5] = raw[0] = zMin/d;
			raw[10] = zMax/(zMax - zMin);
			raw[11] = 1;
			raw[1] = 0;
			raw[2] = 0;
			raw[3] = 0;
			raw[4] = 0;
			raw[6] = 0;
			raw[7] = 0;
			raw[8] = 0;
			raw[9] = 0;
			raw[12] = 0;
			raw[13] = 0;
			raw[15] = 0;
			raw[14] = -zMin*raw[10];
			
			target ||= new Matrix3D();
			target.copyRawDataFrom(raw);
			target.prepend(m);
			
			return target;
		}
	}
}
