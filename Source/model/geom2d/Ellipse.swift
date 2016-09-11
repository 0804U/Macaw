import Foundation
import RxSwift

public class Ellipse: Locus {

	public let cx: Double
	public let cy: Double
	public let rx: Double
	public let ry: Double

	public init(cx: Double = 0, cy: Double = 0, rx: Double = 0, ry: Double = 0) {
		self.cx = cx
		self.cy = cy
		self.rx = rx
		self.ry = ry
	}

	// GENERATED NOT
	public func arc(shift shift: Double, extent: Double) -> Arc {
		return Arc(ellipse: self, shift: shift, extent: extent)
	}

}
