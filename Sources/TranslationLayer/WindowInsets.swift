import Java

public class WindowInsets: JavaObject {
    override public class var javaClassName: String {
        "android.view.WindowInsets"
    }
}

public extension WindowInsets {
    func getSystemWindowInsetTop() throws -> Int32 {
        try call(method: "getSystemWindowInsetTop")
    }
    
    func getSystemWindowInsetRight() throws -> Int32 {
        try call(method: "getSystemWindowInsetRight")
    }
    
    func getSystemWindowInsetBottom() throws -> Int32 {
        try call(method: "getSystemWindowInsetBottom")
    }
    
    func getSystemWindowInsetLeft() throws -> Int32 {
        try call(method: "getSystemWindowInsetLeft")
    }
    
    func getDisplayCutout() throws -> DisplayCutout {
        try call(method: "getDisplayCutout")
    }
}
