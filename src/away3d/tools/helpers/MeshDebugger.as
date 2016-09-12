package away3d.tools.helpers
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.tools.helpers.data.MeshDebug;
	
	/**
	 * Helper Class for Mesh objects <code>MeshDebugger</code>
	 * Displays the normals, tangents and vertexNormals of a given mesh.
	 */
	public class MeshDebugger
	{
		
		private var _meshesData:Vector.<MeshDebugData> = new Vector.<MeshDebugData>();
		private var _colorNormals:uint = 0xFF3399;
		private var _colorVertexNormals:uint = 0x66CCFF;
		private var _colorTangents:uint = 0xFFCC00;
		private var _lengthNormals:Number = 50;
		private var _lengthTangents:Number = 50;
		private var _lengthVertexNormals:Number = 50;
		private var _dirty:Boolean;
		
		public function MeshDebugger()
		{
		}
		
		/*
		 * To set a mesh into debug state
		 *@param	mesh							Mesh. The mesh to debug.
		 *@param	scene							Scene3D. The scene where the mesh is addChilded.
		 *@param	displayNormals			Boolean. If true the mesh normals are displayed (calculated, not from mesh vector normals).
		 *@param	displayVertexNormals	Boolean. If true the mesh vertexnormals are displayed.
		 *@param	displayTangents			Boolean. If true the mesh tangents are displayed.
		 */
		public function debug(mesh:Mesh, scene:Scene3D, displayNormals:Boolean = true, displayVertexNormals:Boolean = false, displayTangents:Boolean = false):MeshDebugData
		{
			var meshDebugData:MeshDebugData = isMeshDebug(mesh);
			
			if (!meshDebugData) {
				meshDebugData = new MeshDebugData();
				meshDebugData.meshDebug = new MeshDebug();
				meshDebugData.mesh = mesh;
				meshDebugData.scene = scene;
				meshDebugData.displayNormals = displayNormals;
				meshDebugData.displayVertexNormals = displayVertexNormals;
				meshDebugData.displayTangents = displayTangents;
				
				if (displayNormals)
					meshDebugData.meshDebug.displayNormals(mesh, _colorNormals, _lengthNormals);
				if (displayVertexNormals)
					meshDebugData.meshDebug.displayVertexNormals(mesh, _colorVertexNormals, _lengthVertexNormals);
				if (displayTangents)
					meshDebugData.meshDebug.displayTangents(mesh, _colorTangents, _lengthTangents);
				
				if (displayNormals || displayVertexNormals || displayTangents) {
					meshDebugData.addChilded = true;
					scene.addChild(meshDebugData.meshDebug);
				}
				
				meshDebugData.meshDebug.transform = meshDebugData.mesh.transform;
				
				_meshesData[_meshesData.length] = meshDebugData;
			}
			
			return meshDebugData;
		}
		
		/*
		 * To set an ObjectContainer3D into debug state. All its children Meshes are then debugged
		 *@param	object						Mesh. The ObjectContainer3D to debug.
		 *@param	scene							Scene3D. The scene where the mesh is addChilded.
		 *@param	displayNormals			Boolean. If true the mesh normals are displayed (calculated, not from mesh vector normals).
		 *@param	displayVertexNormals	Boolean. If true the mesh vertexnormals are displayed.
		 *@param	displayTangents			Boolean. If true the mesh tangents are displayed.
		 */
		public function debugContainer(object:ObjectContainer3D, scene:Scene3D, displayNormals:Boolean = true, displayVertexNormals:Boolean = false, displayTangents:Boolean = false):void
		{
			parse(object, scene, displayNormals, displayVertexNormals, displayTangents);
		}
		
		/*
		 * To set a the color of the normals display. Default is 0xFF3399.
		 */
		public function set colorNormals(value:uint):void
		{
			_colorNormals = value;
			invalidate();
		}
		
		public function get colorNormals():uint
		{
			return _colorNormals;
		}
		
		/*
		 * To set a the color of the vertexnormals display. Default is 0x66CCFF.
		 */
		public function set colorVertexNormals(value:uint):void
		{
			_colorVertexNormals = value;
			invalidate();
		}
		
		public function get colorVertexNormals():uint
		{
			return _colorVertexNormals;
		}
		
		/*
		 * To set a the color of the tangent display. Default is 0xFFCC00.
		 */
		public function set colorTangents(value:uint):void
		{
			_colorTangents = value;
			invalidate();
		}
		
		public function get colorTangents():uint
		{
			return _colorTangents;
		}
		
		/*
		 * To set a the length of the vertexnormals segments. Default is 50.
		 */
		public function set lengthVertexNormals(value:Number):void
		{
			value = value < 0 ? 1 : value;
			_lengthVertexNormals = value;
			invalidate();
		}
		
		public function get lengthVertexNormals():Number
		{
			return _lengthVertexNormals;
		}
		
		/*
		 * To set a the length of the normals segments. Default is 50.
		 */
		public function set lengthNormals(value:Number):void
		{
			value = value < 0 ? 1 : value;
			_lengthNormals = value;
			invalidate();
		}
		
		public function get lengthNormals():Number
		{
			return _lengthNormals;
		}
		
		/*
		 * To set a the length of the tangents segments. Default is 50.
		 */
		public function set lengthTangents(value:Number):void
		{
			value = value < 0 ? 1 : value;
			_lengthTangents = value;
			invalidate();
		}
		
		public function get lengthTangents():Number
		{
			return _lengthTangents;
		}
		
		/*
		 * To hide temporary the debug of a mesh
		 */
		public function hideDebug(mesh:Mesh):void
		{
			var length:int = _meshesData.length;
			for(var i:int = 0; i < length; ++i) {
				if (_meshesData[i].mesh == mesh && _meshesData[i].addChilded) {
					_meshesData[i].addChilded = false;
					_meshesData[i].scene.removeChild(_meshesData[i].meshDebug);
					break;
				}
			}
		}
		
		/*
		 * To show the debug of a mesh if it was hidded
		 */
		public function showDebug(mesh:Mesh):void
		{
			var length:int = _meshesData.length;
			for(var i:int = 0; i < length; ++i) {
				if (_meshesData[i].mesh == mesh && !_meshesData[i].addChilded) {
					_meshesData[i].addChilded = true;
					_meshesData[i].scene.addChild(_meshesData[i].meshDebug);
					break;
				}
			}
		}
		
		/*
		 * To remove totally the debug state of a mesh
		 */
		public function removeDebug(mesh:Mesh):void
		{
			var length:int = _meshesData.length;
			for(var i:int = 0; i < length; ++i) {
				var meshDebugData:MeshDebugData = _meshesData[i];
				if (meshDebugData.mesh == mesh) {
					
					if (meshDebugData.addChilded)
						meshDebugData.scene.removeChild(meshDebugData.meshDebug);
					
					meshDebugData.meshDebug.clearAll();
					meshDebugData.meshDebug = null;
					meshDebugData = null;
					_meshesData.splice(i, 1);
					break;
				}
			}
		}
		
		public function hasDebug(mesh:Mesh):Boolean
		{
			return isMeshDebug(mesh) != null;
		}
		
		/*
		 * To update the debug geometry to the updated transforms of a mesh
		 */
		public function update():void
		{
			var tmpMDD:MeshDebugData;
			var length:int = _meshesData.length;
			for(var i:int = 0; i < length; ++i) {
				var meshDebugData:MeshDebugData = _meshesData[i];
				if (!meshDebugData.addChilded)
					continue;
				if (_dirty) {
					
					if (!tmpMDD)
						tmpMDD = new MeshDebugData();
					
					tmpMDD.mesh = meshDebugData.mesh;
					tmpMDD.scene = meshDebugData.scene;
					tmpMDD.displayNormals = meshDebugData.displayNormals;
					tmpMDD.displayVertexNormals = meshDebugData.displayVertexNormals;
					tmpMDD.displayTangents = meshDebugData.displayTangents;
					tmpMDD.addChilded = meshDebugData.addChilded;
					
					removeDebug(meshDebugData.mesh);
					meshDebugData = debug(tmpMDD.mesh, tmpMDD.scene, tmpMDD.displayNormals, tmpMDD.displayVertexNormals, tmpMDD.displayTangents);
					
					if (!tmpMDD.addChilded)
						hideDebug(meshDebugData.mesh);
				}
				
				meshDebugData.meshDebug.transform = meshDebugData.mesh.transform;
			}
			
			_dirty = false;
		}
		
		private function isMeshDebug(mesh:Mesh):MeshDebugData
		{
			var length:int = _meshesData.length;
			for(var i:int = 0; i < length; ++i) {
				var meshDebugData:MeshDebugData = _meshesData[i];
				if (meshDebugData.mesh == mesh)
					return meshDebugData;
			}
			return null;
		}
		
		private function invalidate():void
		{
			if (_dirty || _meshesData.length == 0)
				return;
			_dirty = true;
		}
		
		private function parse(object:ObjectContainer3D, scene:Scene3D, displayNormals:Boolean, displayVertexNormals:Boolean, displayTangents:Boolean):void
		{
			var child:ObjectContainer3D;
			if (object is Mesh && object.numChildren == 0)
				debug(Mesh(object), scene, displayNormals, displayVertexNormals, displayTangents);
			
			for(var i:int = 0; i < object.numChildren; ++i) {
				child = object.getChildAt(i);
				parse(child, scene, displayNormals, displayVertexNormals, displayTangents);
			}
		}
	
	}
}

import away3d.containers.Scene3D;
import away3d.entities.Mesh;
import away3d.tools.helpers.data.MeshDebug;
class MeshDebugData
{
	public var mesh:Mesh;
	public var meshDebug:MeshDebug;
	public var scene:Scene3D;
	public var displayNormals:Boolean;
	public var displayVertexNormals:Boolean;
	public var displayTangents:Boolean;
	public var addChilded:Boolean;
}