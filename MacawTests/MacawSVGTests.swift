import XCTest
@testable import Macaw

class MacawSVGTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSVGSerializeEllipse() {
        let bundle = Bundle(for: type(of: TestUtils()))
        let ellipseReferenceContent = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" id=\"\" width=\"400\" height=\"210\" ><g> <ellipse  cy=\"80\" ry=\"50\" rx=\"100\" cx=\"200\" fill=\"yellow\" stroke=\"purple\" stroke-width=\"2\"/></g></svg>"
        
        
        let name = "ellipse"
        do {
            let rootNode = try SVGParser.parse(bundle:bundle, path: name)
            let svg = SVGSerializer.serialize(node: rootNode)
            print(svg)
            XCTAssertTrue(svg == ellipseReferenceContent)
        } catch _ {}
    }
    
}
