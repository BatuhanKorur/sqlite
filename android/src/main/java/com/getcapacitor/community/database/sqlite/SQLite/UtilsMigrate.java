package com.getcapacitor.community.database.sqlite.SQLite;

import android.content.Context;
import com.getcapacitor.community.database.sqlite.SQLite.UtilsFile;
import java.io.File;

public class UtilsMigrate {

    private static final String TAG = UtilsMigrate.class.getName();
    private UtilsFile uFile = new UtilsFile();

    public void addSQLiteSuffix(Context context, String folderPath) throws Exception {
        String pathDB = new File(context.getFilesDir().getParentFile(), "databases").getAbsolutePath();
        String pathFiles = this.getFolder(context, folderPath);
        // check if the path exists
        File dir = new File(pathFiles);
        if (!dir.exists()) {
            throw new Exception("Folder " + dir + " does not exist");
        }
        String[] listFiles = dir.list();
        for (String file : listFiles) {
            if (uFile.getFileExtension((file)).equals("db")) {
                if (!file.contains("SQLite.db")) {
                    String fromFile = file;
                    String toFile = file.replace(".db", "SQLite.db");
                    boolean ret = uFile.copyFromNames(context, pathFiles, fromFile, pathDB, toFile);
                    if (!ret) {
                        String msg = "Failed in copy " + fromFile + " to " + file;
                        throw new Exception(msg);
                    }
                }
            }
        }
        return;
    }

    public String getFolder(Context context, String folderPath) throws Exception {
        String pathFiles = context.getFilesDir().getAbsolutePath();
        String pathDB = new File(context.getFilesDir().getParentFile(), "databases").getAbsolutePath();
        if (!folderPath.equals("default")) {
            String[] arr = folderPath.split("/", 2);
            if (arr.length == 2) {
                if (arr[0].equals("files")) {
                    pathFiles = pathFiles.concat("/").concat(arr[1]);
                } else if (arr[0].equals("databases")) {
                    pathFiles = pathDB.concat("/").concat(arr[1]);
                } else {
                    throw new Exception("Folder " + folderPath + " not allowed");
                }
            }
        } else {
            pathFiles = pathDB;
        }
        return pathFiles;
    }

    public void deleteOldDatabases(Context context, String folderPath) throws Exception {
        String pathFiles = this.getFolder(context, folderPath);
        // check if the path exists
        File dir = new File(pathFiles);
        if (!dir.exists()) {
            throw new Exception("Folder " + dir + " does not exist");
        }
        String[] listFiles = dir.list();
        for (String file : listFiles) {
            if (uFile.getFileExtension((file)).equals("db")) {
                if (!file.contains("SQLite.db")) {
                    boolean ret = uFile.deleteFile(pathFiles, file);
                    if (!ret) {
                        String msg = "Failed in delete " + file;
                        throw new Exception(msg);
                    }
                }
            }
        }
        return;
    }
}
