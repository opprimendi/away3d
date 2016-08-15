package away3d.audio
{
	import away3d.containers.ObjectContainer3D;
	import flash.geom.Vector3D;
	
	/**
	 * SoundTransform3D is a convinience class that helps adjust a Soundtransform's volume and pan according
	 * position and distance of a listener and emitter object. See SimplePanVolumeDriver for the limitations
	 * of this method.
	 */
	public class SoundTransform3D extends AbstractSoundTransform3D implements ISoundTransform3D
	{

		/**
		 * Creates a new SoundTransform3D.
		 * @param emitter the ObjectContainer3D from which the sound originates.
		 * @param listener the ObjectContainer3D considered to be to position of the listener (usually, the camera)
		 * @param volume the maximum volume used.
		 * @param scale the distance that the sound covers.
		 *
		 */
		public function SoundTransform3D(emitter:ObjectContainer3D = null, listener:ObjectContainer3D = null, volume:Number = 1, scale:Number = 1000)
		{
			super(emitter, listener, volume, scale);
		}
		
		override public function updateFromVector3D(v:Vector3D):void
		{
			
			_azimuth = Math.atan2(v.x, v.z);
			if (_azimuth < -1.5707963)
				_azimuth = -(1.5707963 + (_azimuth%1.5707963));
			else if (_azimuth > 1.5707963)
				_azimuth = 1.5707963 - (_azimuth%1.5707963);
			
			// Divide by a number larger than pi/2, to make sure
			// that pan is never full +/-1.0, muting one channel
			// completely, which feels very unnatural. 
			_soundTransform.pan = (_azimuth/1.7);
			
			// Offset radius so that max value for volume curve is 1,
			// (i.e. y~=1 for r=0.) Also scale according to configured
			// driver scale value.
			_r = (v.length/_scale) + 0.28209479;
			_r2 = _r*_r;
			
			// Volume is calculated according to the formula for
			// sound intensity, I = P / (4 * pi * r^2)
			// Avoid division by zero.
			if (_r2 > 0)
				_soundTransform.volume = (1/(12.566*_r2)); // 1 / 4pi * r^2
			else
				_soundTransform.volume = 1;
			
			// Alter according to user-specified volume
			_soundTransform.volume *= _volume;
		
		}
		
	}
}
