import Java

public class Rect: JavaObject {
    override public class var javaClassName: String {
        "android.graphics.Rect"
    }
}

public extension Rect {
    var bottom: CInt {
        get {
            self["bottom"]
        }
    }
    
    var left: CInt {
        get {
            self["left"]
        }
    }
    
    var right: CInt {
        get {
            self["right"]
        }
    }
    
    var top: CInt {
        get {
            self["top"]
        }
    }
}
