package away3d.core.partition
{
	import away3d.arcane;
	import away3d.entities.Entity;
	
	use namespace arcane;
	
	public class ViewVolumePartition extends Partition3D
	{
		public function ViewVolumePartition()
		{
			super(new ViewVolumeRootNode());
		}
		
		override arcane function markForUpdate(entity:Entity):void
		{
			// ignore if static, will be handled separately by visibility list
			if (!entity.staticNode)
				super.markForUpdate(entity);
		}
		
		/**
		 * Adds a view volume to provide visibility info for a given region.
		 */
		public function addViewVolume(viewVolume:ViewVolume):void
		{
			(_rootNode as ViewVolumeRootNode).addViewVolume(viewVolume);
		}
		
		public function removeViewVolume(viewVolume:ViewVolume):void
		{
			(_rootNode as ViewVolumeRootNode).removeViewVolume(viewVolume);
		}
		
		/**
		 * A dynamic grid to be able to determine visibility of dynamic objects. If none is provided, dynamic objects are only frustum-culled.
		 * If provided, ViewVolumes need to have visible grid cells assigned from the same DynamicGrid instance.
		 */
		public function get dynamicGrid():DynamicGrid
		{
			return (_rootNode as ViewVolumeRootNode).dynamicGrid;
		}
		
		public function set dynamicGrid(value:DynamicGrid):void
		{
			(_rootNode as ViewVolumeRootNode).dynamicGrid = value;
		}
	}
}
