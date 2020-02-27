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

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.craftercms.bundle.utils.Action;

/**
 * Created by cortiz on 4/27/17.
 */
public class Download implements Action {
    private static final int BUFFER_SIZE = 1024;
    /**
     * Output.
     */
    private static PrintStream out = System.out;

    @Override
    public void execute(final String[] args) {
        if (args.length <= 0) {
            help();
        } else {
            switch (args[0].toLowerCase()) {
                case "mongodb":
                    new DownloadMongoDB().execute(args);
                    break;
                case "mongodbmsi":
                    new DownloadMongoMSIDB().execute(args);
                    break;
                default:
                    URL downloadUrl = null;
                    try {
                        downloadUrl = new URL((args[0]));
                        downloadUrl(downloadUrl, Paths.get(".", downloadUrl.getFile()));
                    } catch (MalformedURLException e) {
                        System.out.println(args[0] + " is not a valid url");
                    }
                    break;
            }
        }
    }


    protected void downloadUrl(final URL downloadUrl, final Path saveTo) {
        try {
            URLConnection connection = downloadUrl.openConnection();
            InputStream input = connection.getInputStream();
            OutputStream out = new FileOutputStream(saveTo.toFile());
            byte[] buffer = new byte[BUFFER_SIZE];
            int n;
            long total = 0;
            System.out.println("Downloading " + downloadUrl.toString() + " please wait.");
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
    }

    @Override
    public void help() {
        out.println("Downloads a System Dependant Module");
        out.println("Usage download {module}");
        out.println("Current Modules: mongodb");
        out.println();
    }
}
