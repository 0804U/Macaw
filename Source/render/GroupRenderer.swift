import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {
	var ctx: RenderContext
	var node: Node {
		get { return group }
	}

	let group: Group
	let disposeBag = DisposeBag()

	init(group: Group, ctx: RenderContext) {
		self.group = group
		self.ctx = ctx
		hook()
	}

	func hook() {
		func onGroupChange(new: [Node]) {
			ctx.view?.setNeedsDisplay()
		}

		group.contentsVar.rx_elements().subscribeNext { new in
			onGroupChange(new)
		}.addDisposableTo(disposeBag)
	}

	func render(force: Bool, opacity: Double) {

		if !force {

			// Cutting animated content
			if animationCache.isAnimating(group) {
				return
			}
		}

		let staticContents = group.contentsVar.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx) }

		contentRenderers.forEach { renderer in
			if let rendererVal = renderer {
				CGContextSaveGState(ctx.cgContext)
				CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(rendererVal.node.pos))
				setClip(rendererVal.node)
				rendererVal.render(force, opacity: rendererVal.node.opacity * opacity)
				CGContextRestoreGState(ctx.cgContext)
			}
		}
	}

	func detectTouches(location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()
		let staticContents = group.contentsVar.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx) }

		contentRenderers.forEach { renderer in
			if let rendererVal = renderer {
				CGContextSaveGState(ctx.cgContext)
				CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(rendererVal.node.pos))
				let translatedLocation = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(rendererVal.node.pos.invert()))
				setClip(rendererVal.node)
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				touchedShapes.appendContentsOf(rendererVal.detectTouches(offsetLocation))
				CGContextRestoreGState(ctx.cgContext)
			}
		}

		return touchedShapes
	}

	// TODO: extract to NodeRenderer
	// TODO: path support
	func setClip(node: Node) {
		if let rect = node.clip as? Rect {
			CGContextClipToRect(ctx.cgContext, CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
		}
	}
}
