import Java

public class Activity: Context {
    override public class var javaClassName: String {
        "android.app.Activity"
    }
}

public extension Activity {
    func getSystemService(_ name: String) throws -> JavaObject {
        try call(method: "getSystemService", arguments: name)
    }
    
    func getWindow() throws -> Window {
        try call(method: "getWindow")
    }
}
