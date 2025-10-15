import Java
import JavaRuntime
import TranslationLayer
import Instance

private var clazz: jobject? {
    _read {
        yield _activity.pointee.clazz
    }
    _modify {
        yield &_activity.pointee.clazz
    }
}

private var jvm: JavaVirtualMachinePointer {
    _read {
        yield _activity.pointee.vm
    }
    _modify {
        yield &_activity.pointee.vm
    }
}

public var sdk: CInt {
    _read {
        yield _activity.pointee.sdkVersion
    }
    _modify {
        yield &_activity.pointee.sdkVersion
    }
}

public let java = JavaVirtualMachine(adopting: jvm)

public func activity(environment: JNIEnvironment) throws -> NativeActivity {
    guard let object = clazz else { fatalError("somehow native activity object is nil") }
    let holder = try JavaReference(object: object, in: environment)
    return NativeActivity(holder: holder)
}
