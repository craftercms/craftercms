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
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.craftercms.bundle.utils.Action;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Zips a folder into a specified path, excluding files with .DS_Store, .lock and .pid extensions.
 *
 * @author avasquez
 * @author jross
 */
public class Zip implements Action {

    private static List<String> excludedExtensions = Arrays.asList("DS_Store", "lock", "pid");

    @Override
    public void execute(final String[] args) {
        if (args.length < 2) {
            help();
        } else {
            Path folder = Paths.get(args[0]);
            Path output = Paths.get(args[1]);
            boolean useCompression = args.length < 3;

            try (ZipOutputStream zout = new ZipOutputStream(FileUtils.openOutputStream(output.toFile()))) {
                if (!useCompression) {
                    zout.setLevel(ZipOutputStream.STORED);

                    System.out.println("[ZIP] Creating zip file " + output + " (no compression)");
                } else {
                    System.out.println("[ZIP] Creating zip file " + output);
                }


                try (Stream<Path> files = Files.walk(folder)) {
                    files
                            .filter(file -> {
                                try {
                                    String ext = FilenameUtils.getExtension(file.getFileName().toString());
                                    if (StringUtils.isNotEmpty(ext) && excludedExtensions.contains(ext)) {
                                        String filename = file.toString().replace(File.separatorChar, '/');
                                        System.out.println("[ZIP] Skipping " + filename);

                                        return false;
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }

                                return true;
                            })
                            .forEach(file -> {
                                try {
                                    if (Files.isDirectory(file)) {
                                        String filename = file.toString().replace(File.separatorChar, '/') + "/";

                                        System.out.println("[ZIP] Adding " + filename);

                                        zout.putNextEntry(new ZipEntry(filename));
                                        zout.closeEntry();
                                    } else {
                                        String filename = file.toString().replace(File.separatorChar, '/');

                                        System.out.println("[ZIP] Adding " + filename);

                                        zout.putNextEntry(new ZipEntry(filename));
                                        try (InputStream fileIn = Files.newInputStream(file)) {
                                            IOUtils.copy(fileIn, zout);
                                        }
                                        zout.closeEntry();
                                    }
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            });
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void help() {
        System.out.println("Zip a folder");
        System.out.println("Usage zip {folder} {path} [no-compression]");
        System.out.println("\t folder: folder to zip");
        System.out.println("\t path: full path for the zipped file");
        System.out.println("\t no-compression: if present files will not be compressed");
    }

}
