import TranslationLayer

func ignoreDisplayCutout() {
    guard sdk >= 28 else { return }
    
    do {
        let environment = try java.environment()
        let activity = try activity(environment: environment)
        let attributes = try activity.getWindow().getAttributes()
        attributes["layoutInDisplayCutoutMode"] = 0x00000001 as CInt
    } catch {
        print(error)
    }
}

func toggleKeyboard() {
    Task { @MainActor in
        do {
            let environment = try java.environment()
            let activity = try activity(environment: environment)
            
            if try activity.isKeyboardActive() {
                try activity.hideKeyboard()
            } else {
                try activity.showKeyboard()
            }
        } catch {
            print(error)
        }
    }
}

func showKeyboard() {
    Task { @MainActor in
        do {
            let environment = try java.environment()
            let activity = try activity(environment: environment)
            try activity.showKeyboard()
        } catch {
            print(error)
        }
    }
}

func hideKeyboard() {
    Task { @MainActor in
        do {
            let environment = try java.environment()
            let activity = try activity(environment: environment)
            try activity.hideKeyboard()
        } catch {
            print(error)
        }
    }
}

private extension NativeActivity {
    func isKeyboardActive() throws -> Bool {
        let view = try getWindow().getDecorView()
        let rect = try Rect(in: environment)
        try view.getWindowVisibleDisplayFrame(rect)
        let difference = try view.getRootView().getHeight() - rect.bottom
        
        let unit = TypedValue[environment, "COMPLEX_UNIT_DIP"] as CInt
        let metrics = try view.getResources().getDisplayMetrics()
        let threshold = try TypedValue.applyDimension(in: environment, unit, 200, metrics)
        
        return Float(difference) > threshold
    }
    
    func showKeyboard() throws {
        let view = try getWindow().getDecorView()
        
        let service = Context[environment, "INPUT_METHOD_SERVICE"] as String
        
        try getSystemService(service).as(InputMethodManager.self)!.showSoftInput(view)
    }
    
    func hideKeyboard() throws {
        let binder = try getWindow().getDecorView().getWindowToken()
        
        let service = Context[environment, "INPUT_METHOD_SERVICE"] as String
        
        try getSystemService(service).as(InputMethodManager.self)!.hideSoftInputFromWindow(binder)
    }
}
