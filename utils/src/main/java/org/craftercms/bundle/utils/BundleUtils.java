package org.craftercms.bundle.utils;

import java.util.Arrays;
import java.util.HashMap;

import org.craftercms.bundle.utils.actions.ApiPost;
import org.craftercms.bundle.utils.actions.Download;
import org.craftercms.bundle.utils.actions.Unzip;
import org.craftercms.bundle.utils.actions.Zip;

/**
 * Created by cortiz on 4/27/17.
 */
public class BundleUtils {

    /**
     * Registered Actions.
     */
    private static HashMap<String, Action> action = new HashMap<>();

    static {
        action.put("download", new Download());
        action.put("unzip", new Unzip());
        action.put("zip", new Zip());
        action.put("post", new ApiPost());
    }

    /**
     * All start's here.
     *
     * @param args arguments.
     */
    public static void main(final String[] args) {
        if (args.length <= 0) {
            helpAndExit();
        }
        String actionToDo = args[0].toLowerCase();
        if ("help".equals(actionToDo) && args.length >= 1) {
            String actionToHelp = args[1].toLowerCase();
            if (action.containsKey(actionToHelp)) {
                action.get(actionToHelp).help();
            } else {
                helpAndExit();
            }
        } else if (action.containsKey(actionToDo)) {
            action.get(actionToDo).execute(Arrays.copyOfRange(args, 1, args.length));
        } else {
            helpAndExit(); //NOPMD
        }
    }

    /**
     * Print help message and exit.
     */
    private static void helpAndExit() {
        help();
        System.exit(-1); //NOPMD
    }

    /**
     * Print the error message.
     */
    private static void help() {
        System.out.printf("Crafter CMS bundle Utils %s-%s \n", org.craftercms.bundle.utils.Version.BUILD, org
            .craftercms.bundle.utils.Version.BUILD_ID.substring(0, 6));
        System.out.println("Usage: java -jar craftercms-utils.jar {Action} {Action Params}");
        System.out.println("Current actions: download help unzip");
        System.out.println("Use help {Action} for more info about the action");
        System.out.println();
    }

}
