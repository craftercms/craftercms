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

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.craftercms.bundle.utils.Action;

import java.io.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Unzips a zip file into a destination folder.
 *
 * @author avasquez
 * @author cortiz
 */
public class Unzip implements Action {

    public void execute(final String[] args) {
        if (args.length <= 0){
            help();
        } else {
            String file = args[0];
            String dest = args.length >= 2 ? args[1] : ".";
            boolean ignoreRoot = args.length >= 3;

            System.out.println("[ZIP] Unzipping file " + file);

            try (ZipInputStream zin = new ZipInputStream(new BufferedInputStream(new FileInputStream(file)))) {
                ZipEntry entry = zin.getNextEntry();

                while (entry != null) {
                    String filename = ignoreRoot ? removeRootFolder(entry.getName()) : entry.getName();
                    if (StringUtils.isNotEmpty(filename)) {
                        System.out.println("[ZIP] Extracting " + filename);

                        File entryFile = new File(dest, filename.replace('/', File.separatorChar));

                        if (entry.isDirectory()) {
                            if (!entryFile.exists()) {
                                entryFile.mkdirs();
                            }
                        } else {
                            try {
                                FileUtils.copyToFile(zin, entryFile);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    entry = zin.getNextEntry();
                }
            } catch (FileNotFoundException e) {
                System.out.println("Zip file not found: " + file);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void help() {
        System.out.println("Unzip a file");
        System.out.println("Usage unzip {file} {dest} [ignore-root]");
        System.out.println("\t file: File to unzip");
        System.out.println("\t dest: Where to unzip the content");
        System.out.println("\t ignore-root: if the root folder should be ignored when extracting");
    }

    private String removeRootFolder(String zipPath) {
        return StringUtils.substringAfter(StringUtils.stripStart(zipPath, "/"), "/");
    }

}
