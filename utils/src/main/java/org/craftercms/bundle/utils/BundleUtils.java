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

package org.craftercms.bundle.utils;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

import org.craftercms.bundle.utils.actions.*;

/**
 * Created by cortiz on 4/27/17.
 */
public class BundleUtils {

    /**
     * Registered Actions.
     */
    private static Map<String, Action> actions = new LinkedHashMap<>();

    static {
        actions.put("download", new Download());
        actions.put("unzip", new Unzip());
        actions.put("zip", new Zip());
        actions.put("post", new ApiPost());
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
            if (actions.containsKey(actionToHelp)) {
                actions.get(actionToHelp).help();
            } else {
                helpAndExit();
            }
        } else if (actions.containsKey(actionToDo)) {
            actions.get(actionToDo).execute(Arrays.copyOfRange(args, 1, args.length));
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
        System.out.printf("Crafter CMS Bundle Utils %s-%s \n",
                          org.craftercms.bundle.utils.Version.BUILD,
                          org.craftercms.bundle.utils.Version.BUILD_ID.substring(0, 6));
        System.out.println("Usage: java -jar craftercms-utils.jar {action} {params}");
        System.out.println("Current actions: " + actions.keySet());
        System.out.println("Use help {action} for more info about the action");
        System.out.println();
    }

}
