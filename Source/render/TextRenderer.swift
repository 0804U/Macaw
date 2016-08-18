import Foundation
import UIKit

class TextRenderer: NodeRenderer {
	var ctx: RenderContext
	let text: Text
	var node: Node {
		get { return text }
	}

	let animationCache: AnimationCache

	init(text: Text, ctx: RenderContext, animationCache: AnimationCache) {
		self.text = text
		self.ctx = ctx
		self.animationCache = animationCache
	}

	func render(force: Bool, opacity: Double) {

		if !force {
			// Cutting animated content
			if animationCache.isAnimating(text) {
				return
			}
		}

		let message = text.text
		var font: UIFont
		if let customFont = UIFont(name: text.font.name, size: CGFloat(text.font.size)) {
			font = customFont
		} else {
			font = UIFont.systemFontOfSize(CGFloat(text.font.size))
		}
		// positive NSBaselineOffsetAttributeName values don't work, couldn't find why
		// for now move the rect itself

		if var color = text.fill as? Color {
			color = RenderUtils.applyOpacity(color, opacity: opacity)
			let textAttributes = [
				NSFontAttributeName: font,
				NSForegroundColorAttributeName: getTextColor(color)]
			let textSize = NSString(string: text.text).sizeWithAttributes(textAttributes)
			message.drawInRect(CGRectMake(calculateAlignmentOffset(text, font: font), calculateBaselineOffset(text, font: font),
				CGFloat(textSize.width), CGFloat(textSize.height)), withAttributes: textAttributes)
		}
	}

	func detectTouches(location: CGPoint) -> [Shape] {
		return []
	}

	private func calculateBaselineOffset(text: Text, font: UIFont) -> CGFloat {
		var baselineOffset = CGFloat(0)
		switch text.baseline {
		case Baseline.alphabetic:
			baselineOffset = font.ascender
		case Baseline.bottom:
			baselineOffset = font.ascender - font.descender
		case Baseline.mid:
			baselineOffset = (font.ascender - font.descender) / 2
		default:
			break
		}
		return -baselineOffset
	}

	private func calculateAlignmentOffset(text: Text, font: UIFont) -> CGFloat {
		let textAttributes = [
			NSFontAttributeName: font
		]
		let textSize = NSString(string: text.text).sizeWithAttributes(textAttributes)
		var alignmentOffset = CGFloat(0)
		switch text.align {
		case Align.mid:
			alignmentOffset = textSize.width / 2
		case Align.max:
			alignmentOffset = textSize.width
		default:
			break
		}
		return -alignmentOffset
	}

	private func getTextColor(fill: Fill) -> UIColor {
		if let color = fill as? Color {
			return UIColor(CGColor: RenderUtils.mapColor(color))
		}
		return UIColor.blackColor()
	}
}