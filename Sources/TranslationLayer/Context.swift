import Java

public class Context: JavaObject {
    override public class var javaClassName: String {
        "android.content.Context"
    }
}

public extension Context {
    func startActivity(_ intent: Intent) throws {
        try call(method: "startActivity", arguments: intent)
    }
}
