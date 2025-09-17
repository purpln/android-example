import Android
import AndroidAssets
import AndroidEntry
import AndroidLog
import NativeActivity

@MainActor
@main
class Application: @preconcurrency NativeActivityDelegate {
    let activity: NativeActivity
    
    init(activity: NativeActivity) {
        self.activity = activity
    }
    
    func launch() {
        print("app is launched")
    }
    
    func destroy() {
        print("app is destroying")
    }
    
    func back() {
        Task { @MainActor [weak self] in
            do {
                let asset = try Asset(name: "document.txt").bytes
                let string = String(decoding: asset, as: UTF8.self)
                print(string)
            } catch {
                print(error)
            }
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            self?.activity.destroy()
        }
    }
}

extension Application {
    static func main() async throws {
        try LogRedirector.shared.redirectPrint()
        
        let activity = NativeActivity()
        let application = Application(activity: activity)
        activity.delegate = application
        activity.run()
        
        exit(0)
    }
}

public extension AssetManager {
    static var bundle: AssetManager {
        AssetManager(application.pointee.activity.pointee.assetManager)
    }
}

public extension Asset {
    init(name: String) {
        self.init(.bundle, name: name)
    }
}
