import Java

public class DisplayCutout: JavaObject {
    override public class var javaClassName: String {
        "android.view.DisplayCutout"
    }
}

public extension DisplayCutout {
    func getSafeInsetBottom() throws -> Int32 {
        try call(method: "getSafeInsetBottom")
    }
    
    func getSafeInsetLeft() throws -> Int32 {
        try call(method: "getSafeInsetLeft")
    }
    
    func getSafeInsetRight() throws -> Int32 {
        try call(method: "getSafeInsetRight")
    }
    
    func getSafeInsetTop() throws -> Int32 {
        try call(method: "getSafeInsetTop")
    }
}
