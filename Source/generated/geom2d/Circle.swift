import Foundation

public class Circle: Locus  {

	var cx: NSNumber = 0
	var cy: NSNumber = 0
	var r: NSNumber = 0

	public init(cx: NSNumber = 0, cy: NSNumber = 0, r: NSNumber = 0) {
		self.cx = cx	
		self.cy = cy	
		self.r = r	
	}

}
