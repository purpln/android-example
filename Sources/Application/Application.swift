import Android
import AndroidAssets
import AndroidLog
import Instance
import NativeActivity
import ndk.native_window

@main
final class Application: NativeActivityDelegate {
    var keyboardActive: Bool = false
    var backTap: Int = 0
    
    init() {
        ignoreDisplayCutout()
        do {
            let asset = try Asset(name: "document.txt").bytes
            let string = String(decoding: asset, as: UTF8.self)
            print("document form assets:", string)
        } catch {
            print(error)
        }
        Task { @MainActor in
            print("main thread works!")
        }
    }
    
    func launch() {
        print("app is launched")
    }
    
    func destroy() {
        print("app is destroying")
    }
    
    func back() {
        toggleKeyboard()
        
        backAction()
    }
    
    func initialize(window: OpaquePointer?) {
        print("initialize window")
        dummyRender(window: window)
    }
    
    func terminate(window: OpaquePointer?) {
        print("terminate window")
    }
    
    func layout(window: OpaquePointer?, width: CInt, height: CInt) {
        print("layout window: \(width)x\(height)")
    }
    
    func animate() {
        //draw frame
    }
    
    func touchesBegan(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {
        if let touch = touches.first {
            print("tapped at \(Int(touch.x))x\(Int(touch.y))")
        }
        toggleKeyboard()
    }
    
    func backAction() {
        backTap += 1
        
        if backTap < 10 {
            print("finishing after \(10 - backTap) tap")
        } else {
            _instance?.finish()
        }
    }
    
    func dummyRender(window: OpaquePointer?) {
        ANativeWindow_setBuffersGeometry(window, 1, 1, HardwareBufferFormat.r8g8b8a8Unorm.rawValue)
        
        var buffer = ANativeWindow_Buffer()
        var rect = ARect()
        
        let result = ANativeWindow_lock(window, &buffer, &rect)
        guard result == 0 else {
            android_log(priority: .error, tag: "swift", message: "renderer error: \(result)")
            return
        }
        fill(pointer: buffer.bits, width: buffer.width, height: buffer.height)
        ANativeWindow_unlockAndPost(window)
    }
    
    func fill(pointer: UnsafeMutableRawPointer, width: CInt, height: CInt) {
        
        let pointer = pointer.assumingMemoryBound(to: UInt8.self)
        let count = Int(width * height) * 4
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: count)
        
        buffer[0] = 0xff //red
        buffer[1] = 0x00 //green
        buffer[2] = 0x00 //blue
        buffer[3] = 0x00 //alpha
    }
}

extension Application {
    @MainActor
    static func main() throws {
        try LogRedirector.shared.redirectPrint()
        
        let application = Application()
        _instance?.delegate = application
        _instance?.run()
    }
}

public extension AssetManager {
    static var bundle: AssetManager {
        AssetManager(_activity.pointee.assetManager)
    }
}

public extension Asset {
    init(name: String) {
        self.init(.bundle, name: name)
    }
}
