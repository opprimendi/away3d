package away3d.animators {
	import away3d.animators.AnimatorBase;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.events.AnimatorEvent;
	import org.flexunit.async.Async;
	
	/**
	 * @author SlavaRa
	 */
	public class AnimatorBaseTest {
		
		[Before]
		public function initialize():void {}
		
		[After]
		public function cleanup():void {}
		
		[Test(async)]
		public function testDispatchAnimatorEventSTART():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.START);
			animator.start();
			animator.stop();
		}
		
		[Test(async)]
		public function testDispatchAnimatorEventSTOP():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.STOP);
			animator.start();
			animator.stop();
		}
		
		[Test(async)]
		public function testAsyncMethod():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.CYCLE_COMPLETE);
			animator.dispatchCycleEvent();
		}
	}
}