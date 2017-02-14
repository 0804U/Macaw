import Foundation
import UIKit

///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
open class MacawView: UIView {
    
    /// Scene root node
    open var node: Node = Group() {
        willSet {
            nodesMap.remove(node)
        }
        
        didSet {
            nodesMap.add(node, view: self)
            self.renderer?.dispose()
            if let cache = animationCache {
                self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
            }
            
            if let _ = superview {
                animationProducer.addStoredAnimations(node)
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override open var frame: CGRect {
        didSet {
            super.frame = frame
            
            frameSetFirstTime = true
            
            guard let _ = superview else {
                return
            }
            
            animationProducer.addStoredAnimations(node)
        }
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !frameSetFirstTime {
            return
            
        }
        
        animationProducer.addStoredAnimations(node)
    }
    
    private var touched: Node? = nil
    var touchEvents = [TouchEvent: UITouch]()
    
    var context: RenderContext!
    var renderer: NodeRenderer?
    
    var toRender = true
    var frameSetFirstTime = false
    
    internal var animationCache: AnimationCache?
    
    public init?(node: Node, coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initializeView()
        
        self.node = node
        nodesMap.add(node, view: self)
        if let cache = self.animationCache {
            self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
        }
    }
    
    public convenience init(node: Node, frame: CGRect) {
        self.init(frame:frame)
        
        self.node = node
        nodesMap.add(node, view: self)
        if let cache = self.animationCache {
            self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(node: Group(), coder: aDecoder)
    }
    
    fileprivate func initializeView() {
        self.context = RenderContext(view: self)
        self.animationCache = AnimationCache(sceneLayer: self.layer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))
        self.addGestureRecognizer(panRecognizer)
        self.addGestureRecognizer(rotationRecognizer)
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    override open func draw(_ rect: CGRect) {
        self.context.cgContext = UIGraphicsGetCurrentContext()
        renderer?.render(force: false, opacity: node.opacity)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = renderer else {
            return
        }
        
        self.touched = nil
        for touch in touches {
            let location = touch.location(in: self)
            self.touched = renderer.findNodeAt(location: location)
            if let node = self.touched {
                let inverted = renderer.node().place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                
				let tapEvent = TapEvent(node: node, location: Point(x: Double(loc.x), y: Double(loc.y)))
                let touchEvent = TouchEvent(node: node, location: Point(x: Double(loc.x), y: Double(loc.y)), state: .began)
                
                touchEvents[touchEvent] = touch
                
                var parent: Node? = node
                while parent != .none {
                    
                    parent!.handleTap(tapEvent)
                    parent!.handleTouch(touchEvent)
                    
					if (tapEvent.consumed && touchEvent.consumed) {
						break;
					}
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = renderer else {
            return
        }
        
        for (touchEvent, uiTouch) in touchEvents {
            if touches.contains(uiTouch) {
        
                var location = uiTouch.location(in: self)
                if let inverted = renderer.node().place.invert() {
                    location = location.applying(RenderUtils.mapTransform(inverted))
                }
                
                touchEvent.location = Point(x: Double(location.x), y: Double(location.y))
                
                touchEvent.state = .moved
                
                if let node = self.touched {
                    var parent: Node? = node
                    while parent != .none {
                        parent!.handleTouch(touchEvent)
                        
                        if (touchEvent.consumed) {
                            break;
                        }
                        
                        parent = nodesMap.parents(parent!).first
                    }
                }
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    private func touchesEnded(touches: Set<UITouch>, event: UIEvent?) {
        guard let renderer = renderer else {
            return
        }
        
        var eventsToRemove = [TouchEvent]()
        
        for (touchEvent, uiTouch) in touchEvents {
            if touches.contains(uiTouch) {
                eventsToRemove.append(touchEvent)
                
                touchEvent.state = .ended
                
                var location = uiTouch.location(in: self)
                if let inverted = renderer.node().place.invert() {
                    location = location.applying(RenderUtils.mapTransform(inverted))
                }
                
                touchEvent.location = Point(x: Double(location.x), y: Double(location.y))
                
                
                if let node = self.touched {
                    var parent: Node? = node
                    while parent != .none {
                        parent!.handleTouch(touchEvent)
                        
                        if (touchEvent.consumed) {
                            break;
                        }
                        
                        parent = nodesMap.parents(parent!).first
                    }
                }
            }
        }
        
        eventsToRemove.forEach { touchEvent in
            touchEvents.removeValue(forKey: touchEvent)
        }
        
        self.touched = nil
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        recognizer.setTranslation(CGPoint.zero, in: self)
        if let node = self.touched {
            // get the rotation and scale of the shape and apply to the translation
            let transform = node.place
            let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
            let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
            let translatedLocation = translation.applying(CGAffineTransform(rotationAngle: rotation))
			let event = PanEvent(node: node, dx: Double(translatedLocation.x / scale), dy: Double(translatedLocation.y / scale))
			var parent: Node? = node
			while parent != .none {
				parent!.handlePan(event)
				if (event.consumed) {
					break;
				}
				parent = nodesMap.parents(parent!).first
			}
        }
    }
    
    func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        let rotation = Double(recognizer.rotation)
        recognizer.rotation = 0
        if let node = self.touched {
			let event = RotateEvent(node: node, angle: rotation)
			var parent: Node? = node
			while parent != .none {
				parent!.handleRotate(event)
				if (event.consumed) {
					break;
				}
				parent = nodesMap.parents(parent!).first
			}
        }
    }
	
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = Double(recognizer.scale)
        recognizer.scale = 1
        if let node = self.touched {
			let event = PinchEvent(node: node, scale: scale)
			var parent: Node? = node
			while parent != .none {
				parent!.handlePinch(event)
				if (event.consumed) {
					break;
				}
				parent = nodesMap.parents(parent!).first
			}
        }
    }
    
    deinit {
        nodesMap.remove(node)
    }
    
}
