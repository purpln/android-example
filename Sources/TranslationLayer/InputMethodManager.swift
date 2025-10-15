import Java

public class InputMethodManager: JavaObject {
    override public class var javaClassName: String {
        "android.view.inputmethod.InputMethodManager"
    }
}

public extension InputMethodManager {
    @discardableResult
    func showSoftInput(_ view: View) throws -> Bool {
        try call(method: "showSoftInput", arguments: view, 0 as Int32)
    }
    
    @discardableResult
    func hideSoftInputFromWindow(_ binder: Binder) throws -> Bool {
        try call(method: "hideSoftInputFromWindow", arguments: binder, 0 as Int32)
    }
}
