package utils

@Grapes([
        @Grab(group = 'org.apache.commons', module = 'commons-lang3', version = '3.7'),
        @Grab(group = 'commons-io', module = 'commons-io', version = '2.6')
])

import org.apache.commons.lang3.SystemUtils
import org.apache.commons.io.FilenameUtils

import java.nio.file.Path

import static utils.EnvironmentUtils.*

class ScriptUtils {

    /**
     * Returns the filename of the current script
     */
    static String getScriptName(Class<?> scriptClass) {
        return FilenameUtils.getName(scriptClass.protectionDomain.codeSource.location.path)
    }

    /**
     * Checks if the current script is currently in download grapes only mode. If it is, it prints a message and exits.
     */
    static void checkDownloadGrapesOnlyMode(Class<?> scriptClass) {
        if (isDownloadGrapesOnlyMode()) {
            println "Downloading grapes for ${getScriptName(scriptClass)}..."

            System.exit(0)
        }
    }

    /**
     * Executes a command line process.
     */
    static void executeCommand(List<String> command, Path workingDir = null, Closure<?> setupCallback = null) {
        if (SystemUtils.IS_OS_WINDOWS) {
            command = ["cmd", "/c"] + command
        }

        def processBuilder = new ProcessBuilder(command)

        if (workingDir) {
            processBuilder.directory(workingDir.toFile())
        }

        if (setupCallback) {
            setupCallback(processBuilder)
        }

        processBuilder.redirectOutput(ProcessBuilder.Redirect.INHERIT)
        processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT)

        def process = processBuilder.start()
        process.waitFor()

        def exitValue = process.exitValue()

        if (exitValue != 0) {
            throw new RuntimeException("Process '${command}' exited with non-successful value ${exitValue}")
        }
    }

}
