import RxSwift

public class TransformAnimation: Animation<Transform> {

	public required init(animatedShape: Group, observableValue: Variable<Transform>, startValue: Transform, finalValue: Transform, animationDuration: Double) {
		super.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
		type = .AffineTransformation
		shape = animatedShape
	}
}