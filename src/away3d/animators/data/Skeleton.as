package away3d.animators.data
{
	import away3d.library.assets.*;
	
	/**
	 * A Skeleton object is a hierarchical grouping of joint objects that can be used for skeletal animation.
	 *
	 * @see away3d.animators.data.SkeletonJoint
	 */
	public class Skeleton extends NamedAssetBase implements IAsset
	{
		/**
		 * A flat list of joint objects that comprise the skeleton. Every joint except for the root has a parentIndex
		 * property that is an index into this list.
		 * A child joint should always have a higher index than its parent.
		 */
		public var joints:Vector.<SkeletonJoint>;
		
		/**
		 * The total number of joints in the skeleton.
		 */
		public function get numJoints():int
		{
			return joints.length;
		}
		
		/**
		 * Creates a new <code>Skeleton</code> object
		 */
		public function Skeleton()
		{
			// in the long run, it might be a better idea to not store Joint objects, but keep all data in Vectors, that we can upload easily?
			joints = new Vector.<SkeletonJoint>();
		}
		
		/**
		 * Returns the joint object in the skeleton with the given name, otherwise returns a null object.
		 *
		 * @param jointName The name of the joint object to be found.
		 * @return The joint object with the given name.
		 *
		 * @see #joints
		 */
		public function jointFromName(jointName:String):SkeletonJoint
		{
			var length:int = joints.length;
			for (var i:int = 0; i < length; i++) {
				var joint:SkeletonJoint = joints[i];
				if (joint.name == jointName)
					return joint;
			}
			return null;
		}
		
		/**
		 * Returns the joint index, given the joint name. -1 is returned if the joint name is not found.
		 *
		 * @param jointName The name of the joint object to be found.
		 * @return The index of the joint object in the joints vector.
		 *
		 * @see #joints
		 */
		public function jointIndexFromName(jointName:String):int
		{
			var length:int = joints.length;
			for (var i:int = 0; i < length; i++)
				if (joints[i].name == jointName)
					return i;
			return -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			joints.length = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get assetType():String
		{
			return AssetType.SKELETON;
		}
	}
}