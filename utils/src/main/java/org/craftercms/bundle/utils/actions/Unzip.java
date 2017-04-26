package org.craftercms.bundle.utils.actions;

import org.craftercms.bundle.utils.Action;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Created by cortiz on 4/27/17.
 */
public class Unzip implements Action{
    private static PrintStream out = System.out;
    private static final int BUFFER=1024;
    @Override
    public void execute(String[] args) {
        if(args.length<=0){
            help();
        }else{
            String file=args[0];
            String location=".";
            boolean stripRootFolder=false;
            if(args.length>=2) {
                location = args[1];
                new File(location).mkdirs();
            }
            if(args.length>=3){
                stripRootFolder=Boolean.parseBoolean(args[2].toLowerCase());
            }

            try( ZipInputStream zipFile = new ZipInputStream(new BufferedInputStream(new FileInputStream(new File(file))))) {
                ZipEntry entry = zipFile.getNextEntry();
                byte[] readBuffer=new byte[BUFFER];
                out.println("Extracting Files");
                while (entry!=null){
                     File entryFile = Paths.get(location, stripRootFolder?new File(entry.getName()).getName():entry.getName()).toFile();
                    if(entry.isDirectory()) {
                        if (!entryFile.exists()) {
                            entryFile.mkdir();
                        }
                    }else {
                        if(!entryFile.getParentFile().exists()){
                            entryFile.getParentFile().mkdir();
                        }
                        int n=0;
                        try (BufferedOutputStream entryOut = new BufferedOutputStream(new FileOutputStream(entryFile))) {
                            while ((n = zipFile.read(readBuffer)) != -1) {
                                entryOut.write(readBuffer);
                            }
                        }catch (IOException e){
                            e.printStackTrace();
                        }
                    }
                    out.println(entryFile.getAbsolutePath());
                    entry=zipFile.getNextEntry();
                }
            } catch (FileNotFoundException e) {
                out.printf("File %n not found",file);
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
