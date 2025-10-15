import Java

public class Intent: JavaObject {
    override public class var javaClassName: String {
        "android.content.Intent"
    }
}

public extension Intent {
    static let ACTION_VIEW = "android.intent.action.VIEW"
}

public extension Intent {
    func setData(_ data: Uri) throws -> Intent {
        try call(method: "setData", arguments: data)
    }
}
