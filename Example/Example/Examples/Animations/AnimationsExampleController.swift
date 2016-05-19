import UIKit

class AnimationsExampleController: UIViewController {

	@IBOutlet var animView: AnimationsView?

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		animView?.testAnimation()
	}
}
