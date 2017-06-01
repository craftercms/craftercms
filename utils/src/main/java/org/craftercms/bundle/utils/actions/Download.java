package org.craftercms.bundle.utils.actions;

import java.io.PrintStream;

import org.craftercms.bundle.utils.Action;

/**
 * Created by cortiz on 4/27/17.
 */
public class Download implements Action{
    /**
     * Output.
     */
    private static PrintStream out = System.out;

    @Override
    public void execute(final String[] args) {
        if (args.length <=0 ) {
            help();
        } else{
            if (args[0].equalsIgnoreCase("mongodb")){
                new DownloadMongoDB().execute(args);
            }
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
