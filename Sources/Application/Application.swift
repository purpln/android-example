import AndroidAssets
import AndroidEntry
import AndroidLog
import NativeActivity

@main
class Application: NativeActivityDelegate {
    let activity: NativeActivity
    
    init(activity: NativeActivity) {
        self.activity = activity
    }
    
    func launched() {
        print("app is launched")
    }
    
    func destroying() {
        print("app is destroying")
    }
    
    func back() {
        Task { @MainActor [weak self] in
            do {
                let asset = try Asset(name: "asset.txt").bytes
                print(String(decoding: asset, as: UTF8.self))
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
