package away3d.animators.states {
	import away3d.animators.AnimatorBase;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import org.flexunit.asserts.assertNull;
	
	/**
	 * @author					SlavaRa
	 * @langversion				3.0
	 * @date					23.10.2015 17:16
	 */
	public class AnimationStateBaseTest {
		
		[Test]
		public function dispose():void {
			var state:MockAnimationStateBase = new MockAnimationStateBase(new SkeletonAnimator(new SkeletonAnimationSet(), new Skeleton()), new AnimationNodeBase());
			state.dispose();
			assertNull(state.animator);
			assertNull(state.animationNode);
		}
	}
}

import away3d.animators.IAnimator;
import away3d.animators.nodes.AnimationNodeBase;
import away3d.animators.states.AnimationStateBase;
class MockAnimationStateBase extends AnimationStateBase {
	public function MockAnimationStateBase(animator:IAnimator, animationNode:AnimationNodeBase) {
		super(animator, animationNode);
	}
	
	public function get animator():IAnimator {
		return _animator;
	}
	
	public function get animationNode():AnimationNodeBase {
		return _animationNode;
	}
}