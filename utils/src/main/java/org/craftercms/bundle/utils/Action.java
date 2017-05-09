package org.craftercms.bundle.utils;

/**
 * Created by cortiz on 4/27/17.
 */
public interface Action {
    void execute(String[] args);

    void help();
}
