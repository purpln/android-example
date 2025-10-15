package org.company.app;

import android.app.NativeActivity;
import android.view.KeyEvent;
import android.os.Build;
import android.util.Log;

public class Activity extends NativeActivity {
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_UNKNOWN && event.getCharacters() != null && getWindow() != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            String string = event.getCharacters();
            for (int offset = 0; offset < string.length(); ) {
                int codepoint = string.codePointAt(offset);
                KeyEvent replacement = new KeyEvent(event.getDownTime(), event.getEventTime(), KeyEvent.ACTION_DOWN, Integer.MAX_VALUE, 0, 0, 0, codepoint);
                getWindow().injectInputEvent(replacement);
                offset += Character.charCount(codepoint);
            }
            return true;
        }
        return super.dispatchKeyEvent(event);
    }
}
