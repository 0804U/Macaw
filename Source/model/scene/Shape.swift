import Foundation
import RxSwift

public class Shape: Node  {

	public let formVar: Variable<Locus>
	public var form: Locus {
		get { return formVar.value }
		set(val) { formVar.value = val }
	}

	public let fillVar: Variable<Fill?>
	public var fill: Fill? {
		get { return fillVar.value }
		set(val) { fillVar.value = val }
	}

	public let strokeVar: Variable<Stroke?>
	public var stroke: Stroke? {
		get { return strokeVar.value }
		set(val) { strokeVar.value = val }
	}

	public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, pos: Transform = Transform(), opaque: NSObject = true, opacity: Double = 1, clip: Locus? = nil, visible: NSObject = true, tag: [String] = [], bounds: Rect? = nil) {
		self.formVar = Variable<Locus>(form)
		self.fillVar = Variable<Fill?>(fill)
		self.strokeVar = Variable<Stroke?>(stroke)
		super.init(
			pos: pos,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			visible: visible,
			tag: tag,
			bounds: bounds
		)
	}


	// GENERATED NOT
	override public func bounds() -> Rect? {

		// TODO: Implement more form types

		if let path = form as? Path {
			return pathBounds(path)
		}

		if let circle = form as? Circle {
			return Rect(
				x: circle.cx - circle.r,
				y: circle.cy - circle.r,
				w: circle.r * 2.0,
				h: circle.r * 2.0)
		}

		if let ellipse = form as? Ellipse {
			return Rect(
				x: ellipse.cx - ellipse.rx,
				y: ellipse.cy - ellipse.ry,
				w: ellipse.rx * 2.0,
				h: ellipse.ry * 2.0)
		}

		return form.bounds()
	}
}