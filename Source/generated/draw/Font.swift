import Foundation

public class Font {

	let name: String
	let size: Int
	let bold: NSObject
	let italic: NSObject
	let underline: NSObject
	let strike: NSObject

	public init(name: String = "Serif", size: Int = 12, bold: NSObject = false, italic: NSObject = false, underline: NSObject = false, strike: NSObject = false) {
		self.name = name	
		self.size = size	
		self.bold = bold	
		self.italic = italic	
		self.underline = underline	
		self.strike = strike	
	}

}
