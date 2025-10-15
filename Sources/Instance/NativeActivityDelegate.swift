import Android
import NativeActivity

@MainActor
public protocol NativeActivityDelegate: AnyObject {
    func launch()
    func destroy()
    func back()
    func animate()
    
    func active(window: OpaquePointer?)
    func resign(window: OpaquePointer?)
    func foreground(window: OpaquePointer?)
    func background(window: OpaquePointer?)
    
    func initialize(window: OpaquePointer?)
    func terminate(window: OpaquePointer?)
    func layout(window: OpaquePointer?, width: CInt, height: CInt)
    
    func touchesBegan(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesMoved(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesEnded(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesCancelled(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    
    func mouseMoved(window: OpaquePointer?, x: Float, y: Float)
    func mouseDown(window: OpaquePointer?, x: Float, y: Float, index: Int)
    func mouseUp(window: OpaquePointer?, x: Float, y: Float, index: Int)
    func mouseDragged(window: OpaquePointer?, x: Float, y: Float, index: Int)
    func mouseScroll(window: OpaquePointer?, x: Float, y: Float, vertical: Float, horizontal: Float)
    
    func toggle(key: KeyEventCode, value: Bool)
    func dpad(x: Float, y: Float)
    func leftThumbstick(x: Float, y: Float)
    func rightThumbstick(x: Float, y: Float)
    func leftTrigger(value: Float)
    func rightTrigger(value: Float)
}

public extension NativeActivityDelegate {
    func launch() {}
    func destroy() {}
    func back() {}
    func animate() {
        usleep(1000)
    }
    func active(window: OpaquePointer?) {}
    func resign(window: OpaquePointer?) {}
    func foreground(window: OpaquePointer?) {}
    func background(window: OpaquePointer?) {}
    
    func initialize(window: OpaquePointer?) {}
    func terminate(window: OpaquePointer?) {}
    func layout(window: OpaquePointer?, width: CInt, height: CInt) {}
    
    func touchesBegan(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesMoved(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesEnded(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesCancelled(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    
    func mouseMoved(window: OpaquePointer?, x: Float, y: Float) {}
    func mouseDown(window: OpaquePointer?, x: Float, y: Float, index: Int) {}
    func mouseUp(window: OpaquePointer?, x: Float, y: Float, index: Int) {}
    func mouseDragged(window: OpaquePointer?, x: Float, y: Float, index: Int) {}
    func mouseScroll(window: OpaquePointer?, x: Float, y: Float, vertical: Float, horizontal: Float) {}
    
    func toggle(key: KeyEventCode, value: Bool) {}
    func dpad(x: Float, y: Float) {}
    func leftThumbstick(x: Float, y: Float) {}
    func rightThumbstick(x: Float, y: Float) {}
    func leftTrigger(value: Float) {}
    func rightTrigger(value: Float) {}
}
