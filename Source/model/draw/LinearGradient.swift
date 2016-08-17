import Foundation
import RxSwift

public class LinearGradient: Gradient {

	public let x1: Double
	public let y1: Double
	public let x2: Double
	public let y2: Double

	public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0, userSpace: Bool = false, stops: [Stop] = []) {
		self.x1 = x1
		self.y1 = y1
		self.x2 = x2
		self.y2 = y2
		super.init(
			userSpace: userSpace,
			stops: stops
		)
	}

}
