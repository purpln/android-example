package org.company.app;

import android.app.NativeActivity;
import android.os.Bundle;
import android.util.Log;

public class Activity extends NativeActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.i("java", "activity");
        super.onCreate(savedInstanceState);
    }
}
