import Foundation

public class HLine: PathSegment  {

	var x: NSNumber = 0

	init(x: NSNumber = 0, absolute: Bool = false) {
		self.x = x	
		super.init(
			absolute: absolute
		)
	}

}
