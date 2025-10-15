import AndroidLog
import NativeActivity
import ndk.native_activity

struct State {
    
}

@MainActor
public class Instance {
    private let activity: UnsafeMutablePointer<ANativeActivity>?
    private let looper: ALooper = ALooper_forThread()
    private let configuration = Configuration()
    private var queue: AInputQueue?
    private var window: ANativeWindow?
    private var running: Bool = true
    public var delegate: NativeActivityDelegate?
    
    var state = ControllerState()
    
    var animating: Bool {
        window != nil
    }
    
    public init(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
        self.activity = activity
        self.configuration.configure(with: activity?.pointee.assetManager)
    }
    
    deinit {
        
    }
    
    public func run() {
        Task.detached { [weak self] in
            self?.launched()
            ALooper_prepare(CInt(ALOOPER_PREPARE_ALLOW_NON_CALLBACKS))
            
            var pointer: UnsafeMutableRawPointer?
            var events: CInt = 0
            
            repeat {
                let timeout: CInt = await self?.animating ?? false ? 0 : -1
                ALooper_pollOnce(timeout, nil, &events, &pointer)
            } while await self?.running ?? false
            self?.destroyed()
        }
    }
    
    private nonisolated func launched() {
        Task { @MainActor [weak self] in
            self?.delegate?.launch()
        }
    }
    
    private nonisolated func destroyed() {
        Task { @MainActor [weak self] in
            self?.delegate?.destroy()
        }
    }
    
    public func finish() {
        ANativeActivity_finish(activity)
    }
}

private extension Instance {
    func update(_ queue: AInputQueue?) {
        if let queue = self.queue {
            AInputQueue_detachLooper(queue)
            self.queue = nil
        }
        if let queue = queue {
            let pointer = Unmanaged.passUnretained(self).toOpaque()
            let callback: ALooper_callbackFunc = { port, _, pointer in
                guard let pointer = pointer else { return 0 }
                let instance = Unmanaged<Instance>.fromOpaque(pointer).takeUnretainedValue()
                MainActor.assumeIsolated({
                    instance.input()
                })
                return 1
            }
            AInputQueue_attachLooper(queue, looper, 0, callback, pointer)
            self.queue = queue
        }
    }
    
    func input() {
        var event: AInputEvent? = nil
        while AInputQueue_getEvent(queue, &event) >= 0 {
            guard AInputQueue_preDispatchEvent(queue, event) == 0 else { continue }
            
            let handled: Bool
            
            do {
                try map(event: event, delegate: self)
                handled = true
            } catch {
                android_log(priority: .error, tag: "swift", message: "\(error)")
                handled = false
            }
            
            AInputQueue_finishEvent(queue, event, handled ? 1 : 0)
        }
    }
}

extension Instance {
    func onStart() {
        
    }
    
    func onResume() {
        delegate?.foreground(window: window)
    }
    
    func onSaveInstanceState() -> State? {
        nil
    }
    
    func onPause() {
        delegate?.background(window: window)
    }
    
    func onStop() {
        
    }
    
    func onDestroy() {
        running = false
    }
    
    func onWindowFocusChanged(_ focused: CInt) {
        if focused != 0 {
            delegate?.active(window: window)
        } else {
            delegate?.resign(window: window)
        }
    }
    
    func onNativeWindowCreated(_ window: ANativeWindow?) {
        self.window = window
        
        ANativeWindow_acquire(window)
        delegate?.initialize(window: window)
    }
    
    func onNativeWindowResized(_ window: ANativeWindow?) {
        
    }
    
    func onNativeWindowRedrawNeeded(_ window: ANativeWindow?) {
        
    }
    
    func onNativeWindowDestroyed(_ window: ANativeWindow?) {
        ANativeWindow_release(window)
        delegate?.terminate(window: window)
    }
    
    func onInputQueueCreated(_ queue: AInputQueue?) {
        update(queue)
    }
    
    func onInputQueueDestroyed(_ queue: AInputQueue?) {
        update(nil)
    }
    
    func onContentRectChanged(_ rect: ARect?) {
        let width = ANativeWindow_getWidth(window)
        let height = ANativeWindow_getHeight(window)
        
        delegate?.layout(window: window, width: width, height: height)
    }
    
    func onConfigurationChanged() {
        configuration.configure(with: activity?.pointee.assetManager)
    }
    
    func onLowMemory() {
        
    }
}

extension Instance: @MainActor InputEventDelegate {
    func back(pressed: Bool) {
        guard !pressed else { return }
        delegate?.back()
    }
    
    func delete(pressed: Bool) {
        
    }
    
    func touchesBegan(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {
        delegate?.touchesBegan(window: window, touches: touches)
    }
    func touchesMoved(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {
        delegate?.touchesMoved(window: window, touches: touches)
    }
    func touchesEnded(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {
        delegate?.touchesEnded(window: window, touches: touches)
    }
    func touchesCancelled(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {
        delegate?.touchesCancelled(window: window, touches: touches)
    }
        
    func mouseMoved(x: Float, y: Float) {
        delegate?.mouseMoved(window: window, x: x, y: y)
    }
    func mouseDown(x: Float, y: Float, index: Int) {
        delegate?.mouseDown(window: window, x: x, y: y, index: index)
    }
    func mouseUp(x: Float, y: Float, index: Int) {
        delegate?.mouseUp(window: window, x: x, y: y, index: index)
    }
    func mouseDragged(x: Float, y: Float, index: Int) {
        delegate?.mouseDragged(window: window, x: x, y: y, index: index)
    }
    func mouseScroll(x: Float, y: Float, vertical: Float, horizontal: Float) {
        delegate?.mouseScroll(window: window, x: x, y: y, vertical: vertical, horizontal: horizontal)
    }
    
    func toggle(key: KeyEventCode, value: Bool) {
        delegate?.toggle(key: key, value: value)
    }
    func dpad(x: Float, y: Float) {
        delegate?.dpad(x: x, y: y)
    }
    func leftThumbstick(x: Float, y: Float) {
        delegate?.leftThumbstick(x: x, y: y)
    }
    func rightThumbstick(x: Float, y: Float) {
        delegate?.rightThumbstick(x: x, y: y)
    }
    func leftTrigger(value: Float) {
        delegate?.leftTrigger(value: value)
    }
    func rightTrigger(value: Float) {
        delegate?.rightTrigger(value: value)
    }
}
