import Swift_CAAnimation_Closure

let animationProducer = AnimationProducer()
class AnimationProducer {

	public func addAnimation(animation: Animatable) {

		if animation.type == .Empty {
			executeCompletion(animation)
			return
		}

		guard let node = animation.node else {
			return
		}

		guard let macawView = nodesMap.getView(node) else {
			return
		}

		guard let cache = macawView.animationCache else {
			return
		}

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation, sceneLayer: macawView.layer, animationCache: cache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})

		case .Opacity:
			addOpacityAnimation(animation, sceneLayer: macawView.layer, animationCache: cache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})
		case .Sequence:
			addAnimationSequence(animation)
		case .Combine:
			addCombineAnimation(animation)
		case .Empty:
			executeCompletion(animation)
		}
	}
	private func addAnimationSequence(animationSequnce: Animatable) {
		guard let sequence = animationSequnce as? AnimationSequence else {
			return
		}
		// reversing
		if sequence.autoreverses {
			sequence.animations.forEach { animation in
				animation.autoreverses = !animation.autoreverses
			}
		}

		// Generating sequence
		var sequenceAnimations = [Animatable]()
		if sequence.repeatCount > 0.0001 {
			for i in 0..<Int(sequence.repeatCount) {
				sequenceAnimations.appendContentsOf(sequence.animations)
			}
		} else {
			sequenceAnimations.appendContentsOf(sequence.animations)
		}

		if sequence.autoreverses {
			sequenceAnimations = sequenceAnimations.reverse()
		}

		// Connecting animations
		for i in 0..<(sequenceAnimations.count - 1) {
			let animation = sequenceAnimations[i]
			animation.next = sequenceAnimations[i + 1]
		}

		// Completion
		if let completion = sequence.completion {
			let completionAnimation = EmptyAnimation(completion: completion)

			if let next = sequence.next {
				completionAnimation.next = next
			}

			sequenceAnimations.last?.next = completionAnimation
		} else {
			if let next = sequence.next {
				sequenceAnimations.last?.next = next
			}
		}

		// Launching
		if let firstAnimation = sequence.animations.first {
			self.addAnimation(firstAnimation)
		}
	}

	private func addCombineAnimation(combineAnimation: Animatable) {
		guard let combine = combineAnimation as? CombineAnimation else {
			return
		}

		// Reversing
		if combine.autoreverses {
			combine.animations.forEach { animation in
				animation.autoreverses = !animation.autoreverses
			}
		}

		// repeat count
		if combine.repeatCount > 0.00001 {
			var sequence = [Animatable]()

			for i in 0..<Int(combine.repeatCount) {
				sequence.append(combine)
			}

			combine.repeatCount = 0.0
			addAnimationSequence(sequence.sequence())
			return
		}

		// Looking for longest animation
		var longestAnimation: Animatable?
		combine.animations.forEach { animation in
			guard let longest = longestAnimation else {
				longestAnimation = animation
				return
			}

			if longest.getDuration() < animation.getDuration() {
				longestAnimation = animation
			}
		}

		// Attaching completion empty animation and potential next animation
		if let completion = combine.completion {
			let completionAnimation = EmptyAnimation(completion: completion)
			if let next = combine.next {
				completionAnimation.next = next
			}

			longestAnimation?.next = completionAnimation

		} else {
			if let next = combine.next {
				longestAnimation?.next = next
			}

		}

		combine.removeFunc = {
			combine.animations.forEach { animation in
				animation.removeFunc?()
			}
		}

		// Launching
		combine.animations.forEach { animation in
			self.addAnimation(animation)
		}
	}

	private func executeCompletion(emptyAnimation: Animatable) {
		emptyAnimation.completion?()
	}
}
