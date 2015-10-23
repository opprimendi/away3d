package away3d.animators {
	import away3d.animators.AnimatorBase;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.events.AnimatorEvent;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	
	/**
	 * @author SlavaRa
	 */
	public class AnimatorBaseTest {
		
		[Test(async)]
		public function dispatchAnimatorEventSTART():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.START);
			animator.start();
			animator.stop();
		}
		
		[Test(async)]
		public function dispatchAnimatorEventSTOP():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.STOP);
			animator.start();
			animator.stop();
		}
		
		[Test(async)]
		public function asyncMethod():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			Async.proceedOnEvent(this, animator, AnimatorEvent.CYCLE_COMPLETE);
			animator.dispatchCycleEvent();
		}
		
		[Test]
		public function isPlauing():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			assertFalse(animator.isPlaying);
			animator.start();
			assertTrue(animator.isPlaying);
			animator.stop();
			assertFalse(animator.isPlaying);
		}
		
		[Test]
		public function dispose():void {
			var animator:AnimatorBase = new AnimatorBase(new SkeletonAnimationSet());
			animator.start();
			animator.dispose();
			assertFalse(animator.isPlaying);
			assertNull(animator.animationSet);
		}
	}
}