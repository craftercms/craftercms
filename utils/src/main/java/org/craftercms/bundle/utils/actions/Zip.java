package org.craftercms.bundle.utils.actions;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.craftercms.bundle.utils.Action;

/**
 * Created by joseross on 7/18/17.
 */
public class Zip implements Action {

    @Override
    public void execute(final String[] args) {
        if(args.length < 2) {
            help();
        } else {
            Path folder = Paths.get(args[0]);
            Path output = Paths.get(args[1]);
            boolean useCompression = args.length != 3;
            System.out.println("Writing file: " + output);
            try(ZipOutputStream zout = new ZipOutputStream(new FileOutputStream(output.toFile()))) {
                if(!useCompression) {
                    zout.setLevel(ZipOutputStream.STORED);
                }
                try (Stream<Path> files = Files.walk(folder)) {
                    files.forEach(file -> {
                        if(!Files.isDirectory(file)) {
                            try {
                                System.out.println("Adding " + file);
                                zout.putNextEntry(new ZipEntry(file.toString().replace(File.separatorChar, '/')));
                                copy(zout, file.toFile());
                                zout.closeEntry();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
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

    protected void copy(OutputStream out, File file) {
        try(BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file))) {
            byte[] buffer = new byte[1024];
            int len;
            while((len = bis.read(buffer)) > 0) {
                out.write(buffer, 0, len);
            }
        } catch (FileNotFoundException e) {
            System.out.println("File not found: " + file);
        } catch (IOException e) {
            e.printStackTrace();
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
