import AndroidLog
import NativeActivity
import ndk.native_activity

protocol InputEventDelegate: AnyObject {
    var state: ControllerState { get set }
    
    func back(pressed: Bool)
    func delete(pressed: Bool)
    
    func touchesBegan(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesMoved(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesEnded(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesCancelled(_ touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    
    func mouseMoved(x: Float, y: Float)
    func mouseDown(x: Float, y: Float, index: Int)
    func mouseUp(x: Float, y: Float, index: Int)
    func mouseDragged(x: Float, y: Float, index: Int)
    func mouseScroll(x: Float, y: Float, vertical: Float, horizontal: Float)
    
    func toggle(key: KeyEventCode, value: Bool)
    func dpad(x: Float, y: Float)
    func leftThumbstick(x: Float, y: Float)
    func rightThumbstick(x: Float, y: Float)
    func leftTrigger(value: Float)
    func rightTrigger(value: Float)
}

func map(event: OpaquePointer?, delegate: any InputEventDelegate) throws {
    guard let type = InputEventType(event: event),
          let source = InputEventSource(event: event) else {
        throw InputEventError.unhandledEvent
    }
    
    switch source {
    case .keyboard:
        try keyboard(type: type, event: event, delegate: delegate)
    case .joystick:
        try joystick(type: type, event: event, delegate: delegate)
    case .touchscreen:
        try touchscreen(type: type, event: event, delegate: delegate)
    case .mouse:
        try mouse(type: type, event: event, delegate: delegate)
    case .dpad, .gamepad, .stylus, .bluetoothStylus, .trackball, .mouseRelative,
            .touchpad, .touchNavigation, .hdmi, .sensor, .rotaryEncoder:
        throw InputEventError.unspecifiedSource
    case .unknown:
        try unknown(type: type, event: event, delegate: delegate)
    case .none:
        throw InputEventError.unhandledEvent
    }
}

private func keyboard(
    type: InputEventType,
    event: OpaquePointer?,
    delegate: any InputEventDelegate
) throws {
    guard type == .key else {
        throw InputEventError.keyboardType
    }
    guard let action = KeyEventAction(event: event), let key = KeyEventCode(event: event) else {
        throw InputEventError.keyboardValue
    }
    guard key != .unknown else {
        android_log(priority: .info, tag: "swift", message: "unknown key")
        return
    }
    let flags = KeyEventFlags(event: event)
    
    if key == .back, flags.contains(.fromSystem) {
        delegate.back(pressed: action == .down)
    } else {
        let value = action == .down
        
        func state(_ keyPath: WritableKeyPath<ControllerState, Bool>) {
            guard delegate.state[keyPath: keyPath] != value else { return }
            delegate.toggle(key: key, value: value)
            delegate.state[keyPath: keyPath] = value
        }
        
        switch key {
        case .buttonA:
            state(\.a)
        case .buttonB:
            state(\.b)
        case .buttonX:
            state(\.x)
        case .buttonY:
            state(\.y)
            
        case .buttonL1:
            state(\.l1)
        case .buttonR1:
            state(\.r1)
        case .buttonL2:
            state(\.l2)
        case .buttonR2:
            state(\.r2)
        case .buttonThumbL:
            state(\.l3)
        case .buttonThumbR:
            state(\.r3)
            
        case .buttonSelect:
            state(\.select)
        case .buttonStart:
            state(\.start)
        case .buttonMode:
            state(\.mode)
            
        default:
            let state = KeyEventMetaState(event: event)
            let message = "keyboard: \(key) \(state) \(flags) \(action)"
            android_log(priority: .info, tag: "swift", message: message)
        }
    }
}

private func joystick(
    type: InputEventType,
    event: OpaquePointer?,
    delegate: any InputEventDelegate
) throws {
    guard type == .motion else {
        throw InputEventError.joystickType
    }
    let action = AMotionEvent_getAction(event)
    let pointer = pointer(action: action)
    guard let action = MotionEventAction(action: action) else {
        throw InputEventError.joystickMotion
    }
    guard action == .move else {
        android_log(priority: .info, tag: "swift", message: "some other action \(action)")
        return
    }
    
    let lTrigger = value(axis: .lTrigger, event: event, pointer: pointer)
    let rTrigger = value(axis: .rTrigger, event: event, pointer: pointer)
    
    if delegate.state.lTrigger != lTrigger {
        delegate.leftTrigger(value: lTrigger)
        delegate.state.lTrigger = lTrigger
    }
    
    if delegate.state.rTrigger != rTrigger {
        delegate.rightTrigger(value: rTrigger)
        delegate.state.rTrigger = rTrigger
    }
    
    let dpadX = value(axis: .hatX, event: event, pointer: pointer)
    let dpadY = value(axis: .hatY, event: event, pointer: pointer)
    
    if delegate.state.dpadX != dpadX || delegate.state.dpadY != dpadY {
        let up = dpadY < 0
        let down = dpadY > 0
        let left = dpadX < 0
        let right = dpadX > 0
        
        if delegate.state.up != up {
            delegate.toggle(key: .dpadUp, value: up)
            delegate.state.up = up
        }
        
        if delegate.state.down != down {
            delegate.toggle(key: .dpadDown, value: down)
            delegate.state.down = down
        }
        
        if delegate.state.left != left {
            delegate.toggle(key: .dpadLeft, value: left)
            delegate.state.left = left
        }
        
        if delegate.state.right != right {
            delegate.toggle(key: .dpadRight, value: right)
            delegate.state.right = right
        }
        
        delegate.dpad(x: dpadX, y: dpadY)
        delegate.state.dpadX = dpadX
        delegate.state.dpadY = dpadY
    }
    
    let lThumbstickX = value(axis: .x, event: event, pointer: pointer)
    let lThumbstickY = value(axis: .y, event: event, pointer: pointer)
    
    let rThumbstickX = value(axis: .z, event: event, pointer: pointer)
    let rThumbstickY = value(axis: .rz, event: event, pointer: pointer)
    
    if delegate.state.lThumbstickX != lThumbstickX || delegate.state.lThumbstickY != lThumbstickY {
        delegate.leftThumbstick(x: lThumbstickX, y: lThumbstickY)
        delegate.state.lThumbstickX = lThumbstickX
        delegate.state.lThumbstickY = lThumbstickY
    }
    
    if delegate.state.rThumbstickX != rThumbstickX || delegate.state.rThumbstickY != rThumbstickY {
        delegate.rightThumbstick(x: rThumbstickX, y: rThumbstickY)
        delegate.state.rThumbstickX = rThumbstickX
        delegate.state.rThumbstickY = rThumbstickY
    }
}

private func touchscreen(
    type: InputEventType,
    event: OpaquePointer?,
    delegate: any InputEventDelegate
) throws {
    guard type == .motion else {
        throw InputEventError.touchscreenType
    }
    guard let action = MotionEventAction(event: event) else {
        throw InputEventError.touchscreenValue
    }
    let count = AMotionEvent_getPointerCount(event)
    let touches: [(id: CInt, x: Float, y: Float, pressure: Float)] = (0..<count).map({ i in
        let id = AMotionEvent_getPointerId(event, i)
        let x = AMotionEvent_getX(event, i)
        let y = AMotionEvent_getY(event, i)
        let pressure = AMotionEvent_getPressure(event, i)
        return (id, x, y, pressure)
    })
    
    switch action {
    case .down:
        delegate.touchesBegan(touches)
    case .up:
        delegate.touchesEnded(touches)
    case .move:
        delegate.touchesMoved(touches)
    case .cancel:
        delegate.touchesCancelled(touches)
    default: break
    }
}

private func mouse(
    type: InputEventType,
    event: OpaquePointer?,
    delegate: any InputEventDelegate
) throws {
    switch type {
    case .key:
        guard KeyEventAction(event: event) != nil,
              KeyEventCode(event: event) != nil else {
            throw InputEventError.mouseKey
        }
        
        throw InputEventError.unspecifiedSource
        
    case .motion:
        let action = AMotionEvent_getAction(event)
        let pointer = pointer(action: action)
        guard let action = MotionEventAction(action: action) else {
            throw InputEventError.mouseMotion
        }
        
        let x = AMotionEvent_getX(event, pointer)
        let y = AMotionEvent_getY(event, pointer)
        
        switch action {
        case .buttonPress:
            let button = MotionEventButton(event: event)
            guard let index = index(for: button) else { break }
            delegate.mouseDown(x: x, y: y, index: index)
        case .buttonRelease, .cancel:
            let button = MotionEventButton(event: event)
            guard let index = index(for: button) else { break }
            delegate.mouseUp(x: x, y: y, index: index)
        case .move:
            let button = MotionEventButton(state: event)
            guard let index = index(for: button) else { break }
            delegate.mouseDragged(x: x, y: y, index: index)
        case .hoverMove:
            delegate.mouseMoved(x: x, y: y)
        case .scroll:
            let horizontal = value(axis: .hScroll, event: event, pointer: pointer)
            let vertical = value(axis: .vScroll, event: event, pointer: pointer)
            delegate.mouseScroll(x: x, y: y, vertical: vertical, horizontal: horizontal)
        case .down, .up, .hoverEnter, .hoverExit:
            break
        default:
            throw InputEventError.unspecifiedSource
        }
    default: break
    }
}

private func unknown(
    type: InputEventType,
    event: OpaquePointer?,
    delegate: any InputEventDelegate
) throws {
    guard type == .key,
          let action = KeyEventAction(event: event), let key = KeyEventCode(event: event) else {
        throw InputEventError.unspecifiedSource
    }
    let flags = KeyEventFlags(event: event)
    
    if key == .del, flags.contains(.softKeyboard) {
        delegate.delete(pressed: action == .down)
    } else {
        let state = KeyEventMetaState(event: event)
        android_log(priority: .error, tag: "swift", message: "\(action) \(key) \(flags) \(state)")
    }
}

private func index(for button: MotionEventButton) -> Int? {
    switch button {
    case .primary: return 0
    case .secondary: return 1
    case .tertiary: return 2
    default: return nil
    }
}

private func value(axis: MotionEventAxis, event: OpaquePointer?, pointer: Int) -> Float {
    AMotionEvent_getAxisValue(event, axis.rawValue, pointer)
}

private func pointer(action: CInt) -> Int {
    (Int(action) & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT
}

private enum InputEventError: String, Error {
    //unexpected behaviour
    case keyboardType
    case keyboardValue
    case touchscreenType
    case touchscreenValue
    case mouseKey
    case mouseMotion
    case joystickType
    case joystickMotion
    
    //consciously ignored
    case unspecifiedSource
    
    //unavailable source
    case unhandledEvent
}
