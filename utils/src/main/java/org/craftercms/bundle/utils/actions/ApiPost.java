package org.craftercms.bundle.utils.actions;

import java.io.Console;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.text.StringEscapeUtils;

import org.craftercms.bundle.utils.Action;

/**
 * Created by joseross on 7/18/17.
 */
public class ApiPost implements Action {

    protected void addXsrfToken(HttpURLConnection connection) {
        String uuid = UUID.randomUUID().toString();
        connection.setRequestProperty("Cookie", "XSRF-TOKEN=" + uuid);
        connection.setRequestProperty("X-XSRF-TOKEN", uuid);
    }

    protected HttpURLConnection openConnection(String... args) throws Exception {
        String body = StringEscapeUtils.escapeJava(args[1]).replace("\\\"","\"");//All but quotes
        URL url = new URL(args[0]);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setDoInput(true);

        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

        addXsrfToken(conn);

        try (OutputStream out = conn.getOutputStream()) {
            out.write(body.getBytes());
        }

        return conn;
    }

    protected void doLogin(String url) throws Exception {
        String host = "http://localhost:8080";
        Pattern pattern = Pattern.compile("https?:\\/\\/\\w+(:\\d+)?");
        Matcher matcher = pattern.matcher(url);
        if(matcher.find()) {
            host = matcher.group();
        }
        CookieHandler.setDefault(new CookieManager());
        Console console = System.console();
        String username = console.readLine("Username: ");
        String password = new String(console.readPassword("Password: "));
        String body = "{\"username\":\"" + username + "\",\"password\":\"" + password + "\"}";
        HttpURLConnection conn =
            openConnection(host + "/studio/api/1/services/api/1/security/login.json", body);

        int code = conn.getResponseCode();
        if(code != 200) {
            System.err.println("Code: " + code);
            System.err.println("Message: " + conn.getResponseMessage());
            throw new RuntimeException("Login failed");
        }

    }

    @Override
    public void execute(final String[] args) {
        if(args.length < 2) {
            help();
        } else {
            try {
                System.out.println("Calling '" + args[0] + "' with body: " + args[1]);
                if(args.length == 3) {
                    doLogin(args[0]);
                }
                HttpURLConnection conn = openConnection(args);

                try (InputStream in = conn.getInputStream()) {
                    byte[] buffer = new byte[1024];
                    while (in.read(buffer) != -1) {
                        System.out.write(buffer);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void help() {
        System.out.println("Executes a HTTP POST request");
        System.out.println("Usage post {url} {body} [login]");
        System.out.println("\t url: full HTTP url");
        System.out.println("\t body: JSON string to include as body of the request");
        System.out.println("\t login: if present login to studio first (optional)");
    }

}
