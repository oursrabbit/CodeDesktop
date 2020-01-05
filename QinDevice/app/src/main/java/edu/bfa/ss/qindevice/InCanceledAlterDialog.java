package edu.bfa.ss.qindevice;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.KeyEvent;

public class InCanceledAlterDialog {
    public static class Builder extends AlertDialog.Builder {

        public Builder(Context context) {
            super(context);
            setCancelable(false);
            setOnKeyListener(new DialogInterface.OnKeyListener() {
                @Override
                public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                    return keyCode == KeyEvent.KEYCODE_BACK;
                }
            });
        }
    }
}
