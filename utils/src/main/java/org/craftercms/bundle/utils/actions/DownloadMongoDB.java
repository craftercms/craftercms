/*
 * Copyright (C) 2007-2020 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
public class DownloadMongoDB implements Action {

    public static final int BUFFER_SIZE = 1024;

    @Override
    public void execute(String[] args) {
        OsCheck.OSType os = OsCheck.getOperatingSystemType();
        String builder = "http://downloads.mongodb.org/@OS/mongodb-@OS-x86_64-@VERSION.@EXT";
        switch (os) {
            case Windows:
                builder = builder.replaceAll("@OS", "win32").replaceAll("@VERSION",
                    "2008plus-ssl-v3.4-latest").replaceAll("@EXT", "zip");
                break;
            case MacOS:
                builder = builder.replaceAll("@OS", "osx").replaceAll("@VERSION", "3.4.4").replaceAll("@EXT", "tgz");
                break;
            case Linux:
                builder = builder.replaceAll("@OS", "linux").replaceAll("@VERSION", "3.4.4").replaceAll("@EXT", "tgz");
                break;
            default:
                System.out.println("Current OS not supported, please check documentation for installing manually "
                    + "mongodb");
                break;
        }

        try {
            URL downloadUrl = new URL((builder));
            try {
                URLConnection connection = downloadUrl.openConnection();
                InputStream input = connection.getInputStream();
                File output = null;
                if (OsCheck.getOperatingSystemType() == OsCheck.OSType.Windows) {
                    output = Paths.get(".", "mongodb.zip").toFile();
                } else {
                    output = Paths.get(".", "mongodb.tgz").toFile();
                }
                OutputStream out = new FileOutputStream(output);
                byte[] buffer = new byte[BUFFER_SIZE];
                int n;
                long total = 0;
                System.out.println("Downloading Mongodb " + builder + " please wait.");
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
