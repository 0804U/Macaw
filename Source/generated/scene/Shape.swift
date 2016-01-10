import Foundation

public class Shape: Node  {

	var form: Locus
	var fill: Fill
	var stroke: Stroke

	public init(form: Locus, fill: Fill, stroke: Stroke, pos: Transform, opaque: NSNumber = true, visible: NSNumber = true, clip: Locus, tag: [String] = []) {
		self.form = form	
		self.fill = fill	
		self.stroke = stroke	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
