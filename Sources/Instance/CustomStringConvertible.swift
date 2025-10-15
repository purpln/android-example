import NativeActivity

extension KeyEventFlags: @retroactive CustomStringConvertible {
    public var description: String {
        var result: [String] = []
        if contains(.wokeHere) {
            result.append("wokeHere")
        }
        if contains(.softKeyboard) {
            result.append("softKeyboard")
        }
        if contains(.keepTouchMode) {
            result.append("keepTouchMode")
        }
        if contains(.fromSystem) {
            result.append("fromSystem")
        }
        if contains(.editorAction) {
            result.append("editorAction")
        }
        if contains(.canceled) {
            result.append("canceled")
        }
        if contains(.virtualHardKey) {
            result.append("virtualHardKey")
        }
        if contains(.longPress) {
            result.append("longPress")
        }
        if contains(.canceledLongPress) {
            result.append("canceledLongPress")
        }
        if contains(.tracking) {
            result.append("tracking")
        }
        if contains(.fallback) {
            result.append("fallback")
        }
        return "\(result)"
    }
}

extension KeyEventMetaState: @retroactive CustomStringConvertible {
    public var description: String {
        var result: [String] = []
        if contains(.alt) {
            result.append("alt")
        }
        if contains(.altLeft) {
            result.append("altLeft")
        }
        if contains(.altRight) {
            result.append("altRight")
        }
        if contains(.shift) {
            result.append("shift")
        }
        if contains(.shiftLeft) {
            result.append("shiftLeft")
        }
        if contains(.shiftRight) {
            result.append("shiftRight")
        }
        if contains(.sym) {
            result.append("sym")
        }
        if contains(.function) {
            result.append("function")
        }
        if contains(.ctrl) {
            result.append("ctrl")
        }
        if contains(.ctrlLeft) {
            result.append("ctrlLeft")
        }
        if contains(.ctrlRight) {
            result.append("ctrlRight")
        }
        if contains(.meta) {
            result.append("meta")
        }
        if contains(.metaLeft) {
            result.append("metaLeft")
        }
        if contains(.metaRight) {
            result.append("metaRight")
        }
        if contains(.capsLock) {
            result.append("capsLock")
        }
        if contains(.numLock) {
            result.append("numLock")
        }
        if contains(.scrollLock) {
            result.append("scrollLock")
        }
        return "\(result)"
    }
}

extension MotionEventButton: @retroactive CustomStringConvertible {
    public var description: String {
        var result: [String] = []
        if contains(.primary) {
            result.append("primary")
        }
        if contains(.secondary) {
            result.append("secondary")
        }
        if contains(.tertiary) {
            result.append("tertiary")
        }
        if contains(.back) {
            result.append("back")
        }
        if contains(.forward) {
            result.append("forward")
        }
        if contains(.stylusPrimary) {
            result.append("stylusPrimary")
        }
        if contains(.stylusSecondary) {
            result.append("stylusSecondary")
        }
        return "\(result)"
    }
}
