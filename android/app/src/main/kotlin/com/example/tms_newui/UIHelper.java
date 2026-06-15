package com.example.tms_newui;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.widget.TextView;

public class UIHelper {
    ProgressDialog loadingDialog;
    Activity activity;

    public UIHelper(Activity activity) {
        this.activity = activity;
    }

    public void showLoadingDialog(final String message) {
        if (activity != null) {
            activity.runOnUiThread(new Runnable() {
                public void run() {
                    loadingDialog = new ProgressDialog(activity, R.style.ButtonAppearance);
                    loadingDialog.setMessage(message);
                    loadingDialog.show();
                    TextView tv1 = (TextView) loadingDialog.findViewById(android.R.id.message);
                    tv1.setTextAppearance(activity, R.style.ButtonAppearance);

                }
            });
        }
    }

    public void showErrorMessage(final String message) {

        if (activity != null) {
            activity.runOnUiThread(new Runnable() {
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(activity, R.style.ErrorButtonAppearance);
                    builder.setMessage(message).setPositiveButton("OK", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                            dismissLoadingDialog();
                        }

                    }).create();
                    Dialog d = builder.show();
                    TextView tv1 = (TextView) d.findViewById(android.R.id.message);
                    tv1.setTextAppearance(activity, R.style.ErrorButtonAppearance);
                }
            });
        }
    }

    public void updateLoadingDialog(final String message) {
        if (activity != null) {
            activity.runOnUiThread(new Runnable() {
                public void run() {
                    loadingDialog.setMessage(message);
                }
            });
        }
    }

    public boolean isDialogActive() {
        if (loadingDialog != null) {
            return loadingDialog.isShowing();
        } else {
            return false;
        }
    }

    public void dismissLoadingDialog() {
        if (activity != null && loadingDialog != null) {
            loadingDialog.dismiss();
        }
    }

    public void showErrorDialog(String errorMessage) {
        new AlertDialog.Builder(activity).setMessage(errorMessage).setTitle("Error").setPositiveButton("OK", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                dialog.dismiss();
            }
        }).create().show();
    }

    public void showErrorDialogOnGuiThread(final String errorMessage) {
        if (activity != null) {
            activity.runOnUiThread(new Runnable() {
                public void run() {
                    new AlertDialog.Builder(activity).setMessage(errorMessage).setTitle("Error").setPositiveButton("OK", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                            dismissLoadingDialog();
                            activity.onBackPressed();
                        }
                    }).create().show();
                }
            });
        }
    }

}
