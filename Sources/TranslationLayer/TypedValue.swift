import Java

public class TypedValue: JavaObject {
    override public class var javaClassName: String {
        "android.util.TypedValue"
    }
}

public extension TypedValue {
    static func applyDimension(
        in environment: JNIEnvironment, _ unit: CInt, _ value: Float, _ metrics: DisplayMetrics
    ) throws -> Float {
        try call(in: environment, method: "applyDimension", arguments: unit, value, metrics)
    }
}
