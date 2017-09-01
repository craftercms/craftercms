package org.craftercms.bundle.utils.actions;


import org.craftercms.bundle.utils.Action;
import org.craftercms.bundle.utils.OsCheck;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Paths;

/**
 * Created by cortiz on 4/27/17.
 */
public class DownloadMongoMSIDB implements Action {

    public static final int BUFFER_SIZE = 1024;

    @Override
    public void execute(String[] args) {
        OsCheck.OSType os = OsCheck.getOperatingSystemType();
        String builder = "http://downloads.mongodb.org/@OS/mongodb-@OS-x86_64-@VERSION.@EXT";
        builder = builder.replaceAll("@OS", "win32").replaceAll("@VERSION",
                    "2008plus-ssl-v3.4-latest-signed").replaceAll("@EXT", "msi");

        try {
            URL downloadUrl = new URL((builder));
            try {
                URLConnection connection = downloadUrl.openConnection();
                InputStream input = connection.getInputStream();
                File output = null;
                output = Paths.get(".", "mongodb.msi").toFile();
                OutputStream out = new FileOutputStream(output);
                byte[] buffer = new byte[BUFFER_SIZE];
                int n;
                long total = 0;
                System.out.println("Downloading Mongodb "+builder.toString()+" please wait.");
                while ((n = input.read(buffer)) != -1) {
                    out.write(buffer, 0, n);
                    total += n;
                }
                out.flush();
                out.close();
                input.close();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void help() {
        //Does nothing.
    }
}
