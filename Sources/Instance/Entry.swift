import Android
import NativeActivity
import ndk.looper

nonisolated(unsafe)
public var _activity: UnsafeMutablePointer<ANativeActivity>!

@MainActor
public var _instance: Instance?

@_silgen_name("main")
private func main(_ argc: CInt, _ unsafeArgv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?)

@_silgen_name("_dispatch_main_queue_callback_4CF")
private func _dispatch_main_queue_callback_4CF(_ msg: UnsafeMutableRawPointer?)

@_silgen_name("_dispatch_get_main_queue_port_4CF")
private func _dispatch_get_main_queue_port_4CF() -> CInt

@_cdecl("android_main")
@MainActor
public func android_main(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ state: UnsafeMutableRawPointer?,
    _ length: UnsafeMutablePointer<size_t>?
) {
    activity?.pointee.callbacks.pointee.onStart = onStart
    activity?.pointee.callbacks.pointee.onResume = onResume
    activity?.pointee.callbacks.pointee.onSaveInstanceState = onSaveInstanceState
    activity?.pointee.callbacks.pointee.onPause = onPause
    activity?.pointee.callbacks.pointee.onStop = onStop
    activity?.pointee.callbacks.pointee.onDestroy = onDestroy
    activity?.pointee.callbacks.pointee.onWindowFocusChanged = onWindowFocusChanged
    activity?.pointee.callbacks.pointee.onNativeWindowCreated = onNativeWindowCreated
    activity?.pointee.callbacks.pointee.onNativeWindowResized = onNativeWindowResized
    activity?.pointee.callbacks.pointee.onNativeWindowRedrawNeeded = onNativeWindowRedrawNeeded
    activity?.pointee.callbacks.pointee.onNativeWindowDestroyed = onNativeWindowDestroyed
    activity?.pointee.callbacks.pointee.onInputQueueCreated = onInputQueueCreated
    activity?.pointee.callbacks.pointee.onInputQueueDestroyed = onInputQueueDestroyed
    activity?.pointee.callbacks.pointee.onContentRectChanged = onContentRectChanged
    activity?.pointee.callbacks.pointee.onConfigurationChanged = onConfigurationChanged
    activity?.pointee.callbacks.pointee.onLowMemory = onLowMemory
    
    let looper: ALooper = ALooper_forThread()
    
    let callback: ALooper_callbackFunc = { port, _, _ in
        _dispatch_main_queue_callback_4CF(nil)
        
        let capacity = 8
        let length = withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, {
            read(port, $0.baseAddress, capacity)
        })
        
        return length != -1 ? 1 : 0
    }
    
    let port = _dispatch_get_main_queue_port_4CF()
    ALooper_addFd(looper, port, 0, CInt(ALOOPER_EVENT_INPUT), callback, nil)
    
    let instance = Instance(activity)
    activity?.pointee.instance = Unmanaged.passUnretained(instance).toOpaque()
    _instance = instance
    _activity = activity
    
    main(0, nil)
}

private func onStart(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onStart()
    })
}

private func onResume(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onResume()
    })
}

private func onSaveInstanceState(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ length: UnsafeMutablePointer<size_t>?
) -> UnsafeMutableRawPointer? {
    guard let length = length, let state = assumeIsolated(with: activity, { application in
        application.onSaveInstanceState()
    }) else {
        return nil
    }
    length.pointee = MemoryLayout<State>.size
    let pointer: UnsafeMutablePointer<State> = .allocate(capacity: 1)
    pointer.initialize(to: state)
    return UnsafeMutableRawPointer(pointer)
}

private func onPause(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onPause()
    })
}

private func onStop(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onStop()
    })
}

private func onDestroy(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onDestroy()
    })
}

private func onWindowFocusChanged(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ focused: CInt
) {
    assumeIsolated(with: activity, { application in
        application.onWindowFocusChanged(focused)
    })
}

private func onNativeWindowCreated(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ window: ANativeWindow?
) {
    nonisolated(unsafe) let window = window
    assumeIsolated(with: activity, { application in
        application.onNativeWindowCreated(window)
    })
}

private func onNativeWindowResized(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ window: ANativeWindow?
) {
    nonisolated(unsafe) let window = window
    assumeIsolated(with: activity, { application in
        application.onNativeWindowResized(window)
    })
}

private func onNativeWindowRedrawNeeded(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ window: ANativeWindow?
) {
    nonisolated(unsafe) let window = window
    assumeIsolated(with: activity, { application in
        application.onNativeWindowRedrawNeeded(window)
    })
}

private func onNativeWindowDestroyed(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ window: ANativeWindow?
) {
    nonisolated(unsafe) let window = window
    assumeIsolated(with: activity, { application in
        application.onNativeWindowDestroyed(window)
    })
}

private func onInputQueueCreated(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ queue: AInputQueue?
) {
    nonisolated(unsafe) let queue = queue
    assumeIsolated(with: activity, { application in
        application.onInputQueueCreated(queue)
    })
}

private func onInputQueueDestroyed(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ queue: AInputQueue?
) {
    nonisolated(unsafe) let queue = queue
    assumeIsolated(with: activity, { application in
        application.onInputQueueDestroyed(queue)
    })
}

private func onContentRectChanged(
    _ activity: UnsafeMutablePointer<ANativeActivity>?,
    _ rect: UnsafePointer<ARect>?
) {
    let rect = rect?.pointee
    assumeIsolated(with: activity, { application in
        application.onContentRectChanged(rect)
    })
}

private func onConfigurationChanged(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onConfigurationChanged()
    })
}

private func onLowMemory(_ activity: UnsafeMutablePointer<ANativeActivity>?) {
    assumeIsolated(with: activity, { application in
        application.onLowMemory()
    })
}

private func assumeIsolated<Result: Sendable>(
    with activity: UnsafeMutablePointer<ANativeActivity>?,
    _ block: @MainActor (Instance) -> Result
) -> Result {
    guard let activity = activity else {
        fatalError("somehow native activity is nil")
    }
    let instance = Unmanaged<Instance>.fromOpaque(activity.pointee.instance).takeUnretainedValue()
    return MainActor.assumeIsolated({
        block(instance)
    })
}
