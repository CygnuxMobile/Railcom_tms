package com.example.tms_newui;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.File;
import java.util.ArrayList;

public class ImageUtils {

    public static ArrayList<Bitmap> getBitmapsFromCacheFolder(Context context, String folderName) {
        ArrayList<Bitmap> bitmaps = new ArrayList<>();

        File cacheDir = new File(context.getCacheDir(), folderName);
        File[] files = cacheDir.listFiles();

        if (files != null) {
            for (File file : files) {
                Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
                if (bitmap != null) {
                    bitmaps.add(bitmap);
                }
            }
        }

        return bitmaps;
    }

    public static boolean deleteCacheFolder(String folderPath) {
        File cacheDir = new File(folderPath);

        // Check if the folder exists
        if (cacheDir.exists()) {
            // Check if it's a directory
            if (cacheDir.isDirectory()) {
                // Delete all files and subdirectories within the directory
                for (File file : cacheDir.listFiles()) {
                    if (file.isDirectory()) {
                        deleteCacheFolder(file.getAbsolutePath());
                    } else {
                        file.delete();
                    }
                }
            }

            // Delete the empty directory
            return cacheDir.delete();
        }

        // Folder does not exist, return false
        return false;
    }
}
