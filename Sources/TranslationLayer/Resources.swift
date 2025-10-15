import Java

public class Resources: JavaObject {
    override public class var javaClassName: String {
        "android.content.res.Resources"
    }
}

public extension Resources {
    func getDisplayMetrics() throws -> DisplayMetrics {
        try call(method: "getDisplayMetrics")
    }
}
