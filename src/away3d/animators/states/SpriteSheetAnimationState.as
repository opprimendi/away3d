package away3d.animators.states
{
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.arcane;
	
	use namespace arcane;
	
	public class SpriteSheetAnimationState extends AnimationClipState implements ISpriteSheetAnimationState
	{
		private var _frames:Vector.<SpriteSheetAnimationFrame>;
		private var _clipNode:SpriteSheetClipNode;
		private var _currentFrameID:uint;
		private var _reverse:Boolean;
		private var _back:Boolean;
		private var _backAndForth:Boolean;
		private var _forcedFrame:Boolean;
		
		public function SpriteSheetAnimationState(animator:IAnimator, clipNode:SpriteSheetClipNode)
		{
			super(animator, clipNode);
			
			_clipNode = clipNode;
			_frames = _clipNode.frames;
		}
		
		public function set reverse(value:Boolean):void
		{
			_back = false;
			_reverse = value;
		}
		
		public function set backAndForth(value:Boolean):void
		{
			if (value)
				_reverse = false;
			_back = false;
			_backAndForth = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get currentFrameData():SpriteSheetAnimationFrame
		{
			if (_framesDirty)
				updateFrames();
			
			return _frames[_currentFrameID];
		}
		
		/**
		 * returns current frame index of the animation.
		 * The index is zero based and counts from first frame of the defined animation.
		 */
		public function get currentFrameNumber():uint
		{
			return _currentFrameID;
		}
		
		public function set currentFrameNumber(value:uint):void
		{
			_currentFrameID = (value > _frames.length - 1 )? _frames.length - 1 : value;
			_forcedFrame = true;
		}
		
		/**
		 * returns the total frames for the current animation.
		 */
		arcane function get totalFrames():uint
		{
			return _frames != null ? _frames.length : 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateFrames():void
		{
			if (_forcedFrame) {
				_forcedFrame = false;
				return;
			}
			
			super.updateFrames();
			
			if (_reverse) {
				
				if (_currentFrameID - 1 > -1)
					_currentFrameID--;
				
				else {
					
					if (_clipNode.looping) {
						
						if (_backAndForth) {
							_reverse = false;
							_currentFrameID++;
						} else
							_currentFrameID = _frames.length - 1;
					}
					
					(_animator as SpriteSheetAnimator).dispatchCycleEvent();
				}
				
			} else {
				
				if (_currentFrameID < _frames.length - 1)
					_currentFrameID++;
				
				else {
					
					if (_clipNode.looping) {
						
						if (_backAndForth) {
							_reverse = true;
							_currentFrameID--;
						} else
							_currentFrameID = 0;
					}
					
					(_animator as SpriteSheetAnimator).dispatchCycleEvent();
				}
			}
		
		}
	}
}