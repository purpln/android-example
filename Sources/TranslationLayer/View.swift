import Java

public class View: JavaObject {
    override public class var javaClassName: String {
        "android.view.View"
    }
}

public extension View {
    func getWindowToken() throws -> Binder {
        try call(method: "getWindowToken")
    }
    
    func getRootWindowInsets() throws -> WindowInsets {
        try call(method: "getRootWindowInsets")
    }
    
    func getWindowVisibleDisplayFrame(_ rect: Rect) throws {
        try call(method: "getWindowVisibleDisplayFrame", arguments: rect)
    }
    
    func getRootView() throws -> View {
        try call(method: "getRootView")
    }
    
    func getResources() throws -> Resources {
        try call(method: "getResources")
    }
    
    func getWidth() throws -> CInt {
        try call(method: "getWidth")
    }
    
    func getHeight() throws -> CInt {
        try call(method: "getHeight")
    }
}
