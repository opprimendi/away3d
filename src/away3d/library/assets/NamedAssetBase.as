package away3d.library.assets
{
	import away3d.events.AssetEvent;
	import flash.events.EventDispatcher;
	
	[Event(name = 'assetRename', type = 'away3d.events.AssetEvent')]
	
	public class NamedAssetBase extends EventDispatcher
	{
		public static const DEFAULT_NAMESPACE:String = 'default';
		
		private var _originalName:String;
		private var _namespace:String;
		private var _name:String;
		private var _id:String;
		private var _full_path:Array;
		
		public function NamedAssetBase(name:String = "")
		{
			_name = name;
			_originalName = name;
		}
		
		/**
		 * The original name used for this asset in the resource (e.g. file) in which
		 * it was found. This may not be the same as <code>name</code>, which may
		 * have changed due to of a name conflict.
		 */
		public function get originalName():String
		{
			return _originalName;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			var prev:String = _name;
			_name = value;
			updateFullPath();
			if (hasEventListener(AssetEvent.ASSET_RENAME))
				dispatchEvent(new AssetEvent(AssetEvent.ASSET_RENAME, IAsset(this), prev));
		}
		
		public function get assetNamespace():String
		{
			return _namespace;
		}
		
		public function get assetFullPath():Array
		{
			if(_full_path == null) _full_path = [_namespace, _name];
			return _full_path;
		}
		
		public function assetPathEquals(name:String, ns:String):Boolean
		{
			return _name == name && (!ns || _namespace == ns);
		}
		
		public function resetAssetPath(name:String, ns:String = null, overrideOriginal:Boolean = true):void
		{
			_name = name || "";
			_namespace = ns ? ns : DEFAULT_NAMESPACE;
			if (overrideOriginal)
				_originalName = _name;
			
			updateFullPath();
		}
		
		private function updateFullPath():void
		{
			var parts:Array = assetFullPath;
			parts[0] = _namespace;
			parts[1] = _name;
		}
	}
}