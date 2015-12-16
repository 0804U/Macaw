import Foundation

class Stroke {

	var fill: Fill
	var width: Float = 1
	var cap: LineCap
	var join: LineJoin
	var dashes: [NSNumber]

	init(fill: Fill, width: Float = 1, cap: LineCap, join: LineJoin, dashes: [NSNumber]) {
		self.fill = fill	
		self.width = width	
		self.cap = cap	
		self.join = join	
		self.dashes = dashes	
	}

}
