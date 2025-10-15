import Java

public class Uri: JavaObject {
    override public class var javaClassName: String {
        "android.net.Uri"
    }
}

public extension Uri {
    static func parse(in environment: JNIEnvironment, _ uriString: String) throws -> Uri {
        try call(in: environment, method: "parse", arguments: uriString)
    }
}
