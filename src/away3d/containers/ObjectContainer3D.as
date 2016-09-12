package away3d.containers
{
	import away3d.arcane;
	import away3d.core.base.Object3D;
	import away3d.core.partition.Partition3D;
	import away3d.events.Object3DEvent;
	import away3d.events.Scene3DEvent;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	/**
	 * Dispatched when the scene transform matrix of the 3d object changes.
	 *
	 * @eventType away3d.events.Object3DEvent
	 * @see    #sceneTransform
	 */
	[Event(name="sceneTransformChanged", type="away3d.events.Object3DEvent")]
	
	/**
	 * Dispatched when the parent scene of the 3d object changes.
	 *
	 * @eventType away3d.events.Object3DEvent
	 * @see    #scene
	 */
	[Event(name="sceneChanged", type="away3d.events.Object3DEvent")]
	
	/**
	 * Dispatched when a user moves the cursor while it is over the 3d object.
	 *
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseMove3d", type="away3d.events.MouseEvent3D")]
	
	/**
	 * Dispatched when a user presses the left hand mouse button while the cursor is over the 3d object.
	 *
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseDown3d", type="away3d.events.MouseEvent3D")]
	
	/**
	 * Dispatched when a user releases the left hand mouse button while the cursor is over the 3d object.
	 *
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseUp3d", type="away3d.events.MouseEvent3D")]
	
	/**
	 * Dispatched when a user moves the cursor over the 3d object.
	 *
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOver3d", type="away3d.events.MouseEvent3D")]
	
	/**
	 * Dispatched when a user moves the cursor away from the 3d object.
	 *
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOut3d", type="away3d.events.MouseEvent3D")]
	
	/**
	 * ObjectContainer3D is the most basic scene graph node. It can contain other ObjectContainer3Ds.
	 *
	 * ObjectContainer3D can have its own scene partition assigned. However, when assigned to a different scene,
	 * it will loose any partition information, since partitions are tied to a scene.
	 */
	public class ObjectContainer3D extends Object3D implements IAsset
	{
		/** @private */
		arcane var _ancestorsAllowMouseEnabled:Boolean;
		arcane var _isRoot:Boolean;
		
		protected var _scene:Scene3D;
		protected var _sceneTransform:Matrix3D = new Matrix3D();
		protected var _sceneTransformDirty:Boolean = true;
		// these vars allow not having to traverse the scene graph to figure out what partition is set
		protected var _explicitPartition:Partition3D; // what the user explicitly set as the partition
		protected var _implicitPartition:Partition3D; // what is inherited from the parents if it doesn't have its own explicitPartition
		protected var _mouseEnabled:Boolean;
		private var _children:Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>();
		private var _mouseChildren:Boolean = true;
		private var _oldScene:Scene3D;
		private var _inverseSceneTransform:Matrix3D = new Matrix3D();
		private var _inverseSceneTransformDirty:Boolean = true;
		private var _scenePosition:Vector3D = new Vector3D();
		private var _scenePositionDirty:Boolean = true;
		private var _explicitVisibility:Boolean = true;
		private var _implicitVisibility:Boolean = true;
		// visibility passed on from parents
		
		protected var _ignoreTransform:Boolean;
		
		/**
		 * Does not apply any transformations to this object. Allows static objects to be described in world coordinates without any matrix calculations.
		 */
		public function get ignoreTransform():Boolean
		{
			return _ignoreTransform;
		}
		
		public function set ignoreTransform(value:Boolean):void
		{
			_ignoreTransform = value;
			_sceneTransformDirty = !value;
			_inverseSceneTransformDirty = !value;
			_scenePositionDirty = !value;
			
			if (!value) {
				_sceneTransform.identity();
				_scenePosition.setTo(0, 0, 0);
			}
		}
		
		/**
		 * @private
		 * The space partition used for this object, possibly inherited from its parent.
		 */
		arcane function get implicitPartition():Partition3D
		{
			return _implicitPartition;
		}
		
		arcane function set implicitPartition(value:Partition3D):void
		{
			if (value == _implicitPartition)
				return;
			
			_implicitPartition = value;
			
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				
				// assign implicit partition if no explicit one is given
				if (!child._explicitPartition)
					child.implicitPartition = value;
			}
		}
		
		/** @private */
		arcane function get isVisible():Boolean
		{
			return _implicitVisibility && _explicitVisibility;
		}
		
		/** @private */
		arcane override function setParent(value:ObjectContainer3D):void
		{
			super.setParent(value)
			updateMouseChildren();
			if (value == null) {
				scene = null;
				return;
			}
			notifySceneTransformChange();
			notifySceneChange();
		}
		
		private function notifySceneTransformChange():void
		{
			if (_sceneTransformDirty || _ignoreTransform)
				return;
			
			invalidateSceneTransform();
			
			var length:int = _children.length;
			//act recursively on child objects
			for (var i:int = 0; i < length; i++)
				_children[i++].notifySceneTransformChange();
			
			//trigger event if listener exists
			if (hasEventListener(Object3DEvent.SCENE_TRANSFORM_CHANGED)) {
				dispatchEvent(new Object3DEvent(Object3DEvent.SCENE_TRANSFORM_CHANGED));
			}
		}
		
		private function notifySceneChange():void
		{
			notifySceneTransformChange();
			
			var length:int = _children.length;
			//act recursively on child objects
			for (var i:int = 0; i < length; i++)
				_children[i++].notifySceneChange();
			
			if (hasEventListener(Object3DEvent.SCENE_CHANGED))
				dispatchEvent(new Object3DEvent(Object3DEvent.SCENE_CHANGED));
		}
		
		protected function updateMouseChildren():void
		{
			if (_parent && !_parent._isRoot) {
				// Set implicit mouse enabled if parent its children to be so.
				_ancestorsAllowMouseEnabled = parent._ancestorsAllowMouseEnabled && _parent.mouseChildren;
			} else
				_ancestorsAllowMouseEnabled = mouseChildren;
			
			// Sweep children.
			var length:int = _children.length;
			for(var i:int = 0; i < length; ++i)
				_children[i].updateMouseChildren();
		}
		
		/**
		 * Indicates whether the IRenderable should trigger mouse events, and hence should be rendered for hit testing.
		 */
		public function get mouseEnabled():Boolean
		{
			return _mouseEnabled;
		}
		
		public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
			updateMouseChildren();
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function invalidateTransform():void
		{
			super.invalidateTransform();
			
			notifySceneTransformChange();
		}
		
		/**
		 * Invalidates the scene transformation matrix, causing it to be updated the next time it's requested.
		 */
		protected function invalidateSceneTransform():void
		{
			_sceneTransformDirty = !_ignoreTransform;
			_inverseSceneTransformDirty = !_ignoreTransform;
			_scenePositionDirty = !_ignoreTransform;
		}
		
		/**
		 * Updates the scene transformation matrix.
		 */
		protected function updateSceneTransform():void
		{
			if (_parent && !_parent._isRoot) {
				_sceneTransform.copyFrom(_parent.sceneTransform);
				_sceneTransform.prepend(transform);
			} else
				_sceneTransform.copyFrom(transform);
			
			_sceneTransformDirty = false;
		}
		
		/**
		 * 
		 */
		public function get mouseChildren():Boolean
		{
			return _mouseChildren;
		}
		
		public function set mouseChildren(value:Boolean):void
		{
			_mouseChildren = value;
			updateMouseChildren();
		}
		
		/**
		 *
		 */
		public function get visible():Boolean
		{
			return _explicitVisibility;
		}
		
		public function set visible(value:Boolean):void
		{
			
			_explicitVisibility = value;
			
			var length:int = _children.length;
			for(var i:int = 0; i < length; ++i)
				_children[i].updateImplicitVisibility();
		}
		
		public function get assetType():String
		{
			return AssetType.CONTAINER;
		}
		
		/**
		 * The global position of the ObjectContainer3D in the scene. The value of the return object should not be changed.
		 */
		public function get scenePosition():Vector3D
		{
			if (_scenePositionDirty) {
				sceneTransform.copyColumnTo(3, _scenePosition);
				_scenePositionDirty = false;
			}
			return _scenePosition;
		}
		
		/**
		 * The minimum extremum of the object along the X-axis.
		 */
		public function get minX():Number
		{
			var min:Number = Number.POSITIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.minX + child.x;
				if (m < min)
					min = m;
			}
			return min;
		}
		
		/**
		 * The minimum extremum of the object along the Y-axis.
		 */
		public function get minY():Number
		{
			var min:Number = Number.POSITIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.minY + child.y;
				if (m < min)
					min = m;
			}
			return min;
		}
		
		/**
		 * The minimum extremum of the object along the Z-axis.
		 */
		public function get minZ():Number
		{
			var min:Number = Number.POSITIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.minZ + child.z;
				if (m < min)
					min = m;
			}
			return min;
		}
		
		/**
		 * The maximum extremum of the object along the X-axis.
		 */
		public function get maxX():Number
		{
			// todo: this isn't right, doesn't take into account transforms
			var max:Number = Number.NEGATIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.maxX + child.x;
				if (m > max)
					max = m;
			}
			return max;
		}
		
		/**
		 * The maximum extremum of the object along the Y-axis.
		 */
		public function get maxY():Number
		{
			var max:Number = Number.NEGATIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.maxY + child.y;
				if (m > max)
					max = m;
			}
			return max;
		}
		
		/**
		 * The maximum extremum of the object along the Z-axis.
		 */
		public function get maxZ():Number
		{
			var max:Number = Number.NEGATIVE_INFINITY;
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
			{
				var child:ObjectContainer3D = _children[i++];
				var m:Number = child.maxZ + child.z;
				if (m > max)
					max = m;
			}
			return max;
		}
		
		/**
		 * The space partition to be used by the object container and all its recursive children, unless it has its own
		 * space partition assigned.
		 */
		public function get partition():Partition3D
		{
			return _explicitPartition;
		}
		
		public function set partition(value:Partition3D):void
		{
			_explicitPartition = value;
			
			implicitPartition = value? value : (_parent? _parent.implicitPartition : null);
		}
		
		/**
		 * The transformation matrix that transforms from model to world space.
		 */
		public function get sceneTransform():Matrix3D
		{
			if (_sceneTransformDirty)
				updateSceneTransform();
			
			return _sceneTransform;
		}
		
		/**
		 * A reference to the Scene3D object to which this object belongs.
		 */
		public function get scene():Scene3D
		{
			return _scene;
		}
		
		public function set scene(value:Scene3D):void
		{
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
				_children[i++].scene = value;
			
			if (_scene == value)
				return;
			
			// test to see if we're switching roots while we're already using a scene partition
			if (value == null)
				_oldScene = _scene;
			
			if (_explicitPartition && _oldScene && _oldScene != _scene)
				partition = null;
			
			if (value)
				_oldScene = null;
			// end of stupid partition test code
			
			_scene = value;
			
			if (_scene) {
				if (_scene.hasEventListener(Scene3DEvent.ADDED_TO_SCENE))
					_scene.dispatchEvent(new Scene3DEvent(Scene3DEvent.ADDED_TO_SCENE, this));
			} else if (_oldScene) {
				if (_oldScene.hasEventListener(Scene3DEvent.REMOVED_FROM_SCENE))
					_oldScene.dispatchEvent(new Scene3DEvent(Scene3DEvent.REMOVED_FROM_SCENE, this));
			}
		}
		
		/**
		 * The inverse scene transform object that transforms from world to model space.
		 */
		public function get inverseSceneTransform():Matrix3D
		{
			if (_inverseSceneTransformDirty) {
				_inverseSceneTransform.copyFrom(sceneTransform);
				_inverseSceneTransform.invert();
				_inverseSceneTransformDirty = false;
			}
			
			return _inverseSceneTransform;
		}
		
		/**
		 * Creates a new ObjectContainer3D object.
		 */
		public function ObjectContainer3D()
		{
			super();
		}
		
		public function contains(child:ObjectContainer3D):Boolean
		{
			return _children.indexOf(child) != -1;
		}
		
		/**
		 * Adds a child ObjectContainer3D to the current object. The child's transformation will become relative to the
		 * current object's transformation.
		 * @param child The object to be added as a child.
		 * @return A reference to the added child object.
		 */
		public function addChild(child:ObjectContainer3D):ObjectContainer3D
		{
			return addChildAt(child, _children.length);
		}
		
		public function addChildAt(child:ObjectContainer3D, index:int):ObjectContainer3D {
			if (child == null)
				throw new Error("Parameter child cannot be null.");
			if (child._parent)
				child._parent.removeChild(child);
			if (!child._explicitPartition)
				child.implicitPartition = _implicitPartition;
			child.setParent(this);
			child.scene = _scene;
			child.notifySceneTransformChange();
			child.updateMouseChildren();
			child.updateImplicitVisibility();
			_children.splice(index, 0, child);
			return child;
		}
		
		/**
		 * Adds an array of 3d objects to the scene as children of the container
		 *
		 * @param    ...children        An array of 3d objects to be added
		 */
		public function addChildren(...children):void
		{
			var numOfChildren:int = children.length;
			for (var i:int = 0; i < numOfChildren; i++)
				addChild(children[i]);
		}
		
		/**
		 * Removes a 3d object from the child array of the container
		 *
		 * @param    child    The 3d object to be removed
		 * @throws    Error    ObjectContainer3D.removeChild(null)
		 */
		public function removeChild(child:ObjectContainer3D, dispose:Boolean = false):void
		{
			if (child == null)
				throw new Error("Parameter child cannot be null");
			
			var childIndex:int = _children.indexOf(child);
			if (childIndex == -1)
				throw new Error("Parameter is not a child of the caller");
			
			removeChildInternal(childIndex, child, dispose);
		}
		
		/** 
		 * Removes a range of children from the container (endIndex included). 
         * If no arguments are given, all children will be removed.
		 */
		public function removeChilden(beginIndex:int = 0, endIndex:int = -1, dispose:Boolean = false):void {
			if (endIndex < 0 || endIndex >= numChildren) 
                endIndex = numChildren - 1;
            
            for (var i:int = beginIndex; i <= endIndex; ++i)
                removeChildAt(beginIndex, dispose);
		}
		
		/**
		 * Removes a 3d object from the child array of the container
		 *
		 * @param    index    Index of 3d object to be removed
		 */
		public function removeChildAt(index:int, dispose:Boolean = false):void
		{
			removeChildInternal(index, _children[index], dispose);
		}
		
		private function removeChildInternal(childIndex:int, child:ObjectContainer3D, dispose:Boolean):void
		{
			// index is important because getChildAt needs to be regular.
			_children.splice(childIndex, 1);
			// this needs to be nullified before the callbacks!
			child.setParent(null);
			if (!child._explicitPartition)
				child.implicitPartition = null;
			if(dispose) child.dispose();
		}
		
		/**
		 * Retrieves the child object at the given index.
		 * @param index The index of the object to be retrieved.
		 * @return The child object at the given index.
		 */
		public function getChildAt(index:int):ObjectContainer3D
		{
			return _children[index];
		}
		
		public function getChildIndex(child:ObjectContainer3D):int {
			return _children.indexOf(child);
		}
		
		/**
		 * The amount of child objects of the ObjectContainer3D.
		 */
		public function get numChildren():int
		{
			return _children.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function lookAt(target:Vector3D, upAxis:Vector3D = null):void
		{
			super.lookAt(target, upAxis);
			
			notifySceneTransformChange();
		}
		
		override public function translateLocal(axis:Vector3D, distance:Number):void
		{
			super.translateLocal(axis, distance);
			
			notifySceneTransformChange();
		}
		
		/**
		 * Disposes the current ObjectContainer3D including all of its children. This is a merely a convenience method.
		 */
		public override function dispose():void
		{
			removeChilden(0, -1, true);
		}
		
		/**
		 * Clones this ObjectContainer3D instance along with all it's children, and
		 * returns the result (which will be a copy of this container, containing copies
		 * of all it's children.)
		 */
		override public function clone():Object3D
		{
			var clone:ObjectContainer3D = super.clone() as ObjectContainer3D;
			clone.partition = partition;
			var length:int = _children.length;
			for(var i:int = 0; i < length; ++i)
				clone.addChild(_children[i].clone() as ObjectContainer3D);
			// todo: implement for all subtypes
			return clone;
		}
		
		override public function rotate(axis:Vector3D, angle:Number):void
		{
			super.rotate(axis, angle);
			
			notifySceneTransformChange();
		}
		
		public function updateImplicitVisibility():void
		{
			_implicitVisibility = _parent._explicitVisibility && _parent._implicitVisibility;
			
			var length:int = _children.length;
			for(var i:int = 0; i < length; ++i)
				_children[i].updateImplicitVisibility();
		}
		
		override public function set zOffset(value:int):void
		{
			if (_zOffset == value)
				return;
				
			_zOffset = value;
			
			var length:int = _children.length;
			for (var i:int = 0; i < length; i++)
				_children[i].zOffset = value;
		}
	}
}
