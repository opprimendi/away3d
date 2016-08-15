package away3d.audio 
{
	import away3d.containers.ObjectContainer3D;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author Shatalov Andrey
	 */
	public class AbstractSoundTransform3D implements ISoundTransform3D 
	{
		
		protected var _scale:Number;
		protected var _volume:Number;
		protected var _soundTransform:SoundTransform;
		
		protected var _emitter:ObjectContainer3D;
		protected var _listener:ObjectContainer3D;
		
		protected var _refv:Vector3D;
		protected var _inv_ref_mtx:Matrix3D;
		protected var _r:Number;
		protected var _r2:Number;
		protected var _azimuth:Number;
		
		/**
		 * Creates a new SoundTransform3D.
		 * @param emitter the ObjectContainer3D from which the sound originates.
		 * @param listener the ObjectContainer3D considered to be to position of the listener (usually, the camera)
		 * @param volume the maximum volume used.
		 * @param scale the distance that the sound covers.
		 *
		 */
		public function AbstractSoundTransform3D(emitter:ObjectContainer3D = null, listener:ObjectContainer3D = null, volume:Number = 1, scale:Number = 1000) 
		{
			
			_emitter = emitter;
			_listener = listener;
			_volume = volume;
			_scale = scale;
			
			_inv_ref_mtx = new Matrix3D();
			_refv = new Vector3D();
			_soundTransform = new SoundTransform(volume);
			
			_r = 0;
			_r2 = 0;
			_azimuth = 0;
			
		}
		
		/* INTERFACE away3d.audio.ISoundTransform3D */
		
		public function update():void 
		{
			
			if (_emitter && _listener) {
				_inv_ref_mtx.rawData = _listener.sceneTransform.rawData;
				_inv_ref_mtx.invert();
				_refv = _inv_ref_mtx.deltaTransformVector(_listener.position);
				_refv = _emitter.scenePosition.subtract(_refv);
			}
			
			updateFromVector3D(_refv);
		}
		
		public function updateFromVector3D(v:Vector3D):void 
		{
			throw new IllegalOperationError('Abstract method: must be overridden in a subclass');
		}
		
		public function get soundTransform():SoundTransform
		{
			
			return _soundTransform;
		}
		
		public function set soundTransform(value:SoundTransform):void
		{
			_soundTransform = value;
			update();
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
			update();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			update();
		}
		
		public function get emitter():ObjectContainer3D
		{
			return _emitter;
		}
		
		public function set emitter(value:ObjectContainer3D):void
		{
			_emitter = value;
			update();
		}
		
		public function get listener():ObjectContainer3D
		{
			return _listener;
		}
		
		public function set listener(value:ObjectContainer3D):void
		{
			_listener = value;
			update();
		}
		
	}

}