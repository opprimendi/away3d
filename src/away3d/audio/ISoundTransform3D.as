package away3d.audio {
	import away3d.containers.ObjectContainer3D;
	import flash.geom.Vector3D;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author Shatalov Andrey
	 */
	public interface ISoundTransform3D 
	{
		/**
		 * updates the SoundTransform based on the emitter and listener.
		 */
		function update():void;
		
		/**
		 * udpates the SoundTransform based on the vector representing the distance and
		 * angle between the emitter and listener.
		 *
		 * @param v Vector3D
		 *
		 */
		function updateFromVector3D(v:Vector3D):void;
		
		function get soundTransform():SoundTransform;
		
		function set soundTransform(value:SoundTransform):void;
		
		function get scale():Number;
		
		function set scale(value:Number):void;
		
		function get volume():Number;
		
		function set volume(value:Number):void;
		
		function get emitter():ObjectContainer3D;
		
		function set emitter(value:ObjectContainer3D):void;
		
		function get listener():ObjectContainer3D;
		
		function set listener(value:ObjectContainer3D):void;
	}
	
}