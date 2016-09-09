
import UIKit

func addOpacityAnimation(animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache, completion: (() -> ())) {
	guard let opacityAnimation = animation as? OpacityAnimation else {
		return
	}

	guard let node = animation.node else {
		return
	}

	// Creating proper animation
	let generatedAnimation = opacityAnimationByFunc(opacityAnimation.vFunc, duration: animation.getDuration(), fps: opacityAnimation.logicalFps)
	generatedAnimation.autoreverses = animation.autoreverses
	generatedAnimation.repeatCount = Float(animation.repeatCount)
	generatedAnimation.timingFunction = caTimingFunction(animation.easing)

	generatedAnimation.completion = { finished in

		animationCache.freeLayer(node)

		animation.progress = 1.0
		node.opacityVar.value = opacityAnimation.vFunc(1.0)

		animation.completion?()

		if !finished {
			animationRestorer.addRestoreClosure(completion)
			return
		}

		completion()
	}

	generatedAnimation.progress = { progress in

		let t = Double(progress)
		node.opacityVar.value = opacityAnimation.vFunc(t)

		animation.progress = t
		animation.onProgressUpdate?(t)
	}

	let layer = animationCache.layerForNode(node, animation: animation)
	layer.addAnimation(generatedAnimation, forKey: animation.ID)
	animation.removeFunc = {
		layer.removeAnimationForKey(animation.ID)
	}
}

func opacityAnimationByFunc(valueFunc: (Double) -> Double, duration: Double, fps: UInt) -> CAAnimation {

	var opacityValues = [Double]()
	var timeValues = [Double]()

	let step = 1.0 / (duration * Double(fps))

	var dt = 0.0
	for t in 0.0.stride(to: 1.0, by: step) {

		dt = t
		if 1.0 - dt < step {
			dt = 1.0
		}

		let value = valueFunc(dt)
		opacityValues.append(value)
		timeValues.append(dt)
	}

	let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
	opacityAnimation.fillMode = kCAFillModeForwards
	opacityAnimation.removedOnCompletion = false

	opacityAnimation.duration = duration
	opacityAnimation.values = opacityValues
	opacityAnimation.keyTimes = timeValues

	return opacityAnimation
}
