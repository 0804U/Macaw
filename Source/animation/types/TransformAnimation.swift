import RxSwift

public class TransformAnimation: Animation<Transform> {

	public convenience init(animatedShape: Group, observableValue: Variable<Transform>, startValue: Transform, finalValue: Transform, animationDuration: Double) {
//		self.init(observableValue: observableValue, startValue: startValue, finalValue: finalValue, animationDuration: animationDuration)
//		type = .AffineTransformation
//		shape = animatedShape

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedShape: animatedShape, observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration)
	}

	public init(animatedShape: Group, observableValue: Variable<Transform>, valueFunc: (Double) -> Transform, animationDuration: Double) {
		super.init(observableValue: observableValue, valueFunc: valueFunc, animationDuration: animationDuration)
		type = .AffineTransformation
		shape = animatedShape
	}
}