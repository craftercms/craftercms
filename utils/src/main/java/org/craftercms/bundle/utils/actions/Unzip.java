package org.craftercms.bundle.utils.actions;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Paths;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.craftercms.bundle.utils.Action;

/**
 * Created by cortiz on 4/27/17.
 */
public class Unzip implements Action{

    private static PrintStream out = System.out;

    private static final int BUFFER = 1024;

    @Override
    public void execute(final String[] args) {
        if (args.length <= 0){
            help();
        } else{
            String file = args[0];
            String location = ".";
            boolean stripRootFolder = false;
            if (args.length >=2 ) {
                location = args[1];
                new File(location).mkdirs();
            }
            if (args.length >= 3){
                stripRootFolder = Boolean.parseBoolean(args[2].toLowerCase());
            }

            try (ZipInputStream zipFile = new ZipInputStream(
                new BufferedInputStream(
                    new FileInputStream(new File(file))))) {
                ZipEntry entry = zipFile.getNextEntry();
                byte[] readBuffer = new byte[BUFFER];
                out.println("Extracting Files");
                while (entry != null){
                    String entryName = entry.getName().replace('/', File.separatorChar);
                    File entryFile = Paths.get(location, stripRootFolder? new File(entryName).getName(): entryName)
                        .toFile();
                    if (entry.isDirectory()) {
                        if (!entryFile.exists()) {
                            entryFile.mkdirs();
                        }
                    } else{
                        if (!entryFile.getParentFile().exists()){
                            entryFile.getParentFile().mkdirs();
                        }
                        try (BufferedOutputStream entryOut = new BufferedOutputStream(new FileOutputStream(entryFile))) {
                            int n;
                            while ((n = zipFile.read(readBuffer)) > 0) {
                                entryOut.write(readBuffer, 0, n);
                            }
                        } catch (IOException e){
                            e.printStackTrace();
                        }
                    }
                    out.println(entryFile.getAbsolutePath());
                    entry = zipFile.getNextEntry();
                }
            } catch (FileNotFoundException e) {
                out.printf("File %n not found", file);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void help() {
        out.println("Unzip a file");
        out.println("Usage unzip {file} {location} {stripFolder}");
        out.println("\t file: File to Unzip");
        out.println("\t location: Where the zip content will be place");
        out.println("\t stripFolder: Should unzip remove all folders for the file (plain fails)");
        out.println();
    }
}
