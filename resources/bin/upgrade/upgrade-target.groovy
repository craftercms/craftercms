/*
 * Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import upgrade.hooks.UpgradeHooks

@Grapes([
        @Grab(group = 'org.slf4j', module = 'slf4j-nop', version = '1.7.25'),
        @Grab(group = 'org.apache.commons', module = 'commons-lang3', version = '3.7'),
        @Grab(group = 'org.apache.commons', module = 'commons-collections4', version = '4.1'),
        @Grab(group = 'commons-codec', module = 'commons-codec', version = '1.11'),
        @Grab(group = 'commons-io', module = 'commons-io', version = '2.6'),
])

import groovy.transform.Field

import java.nio.file.Files
import java.nio.file.Paths
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.lang3.StringUtils
import org.apache.commons.lang3.SystemUtils

import static java.nio.file.StandardCopyOption.*
import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

// Files that should not be overwritten automatically
@Field def configFilePatterns = [
    'crafter-setenv\\.sh',
    'apache-tomcat/conf/.+',
    'apache-tomcat/shared/classes/.+',
    'crafter-deployer/config/.+',
    'crafter-deployer/logging\\.xml',
    'elasticsearch/config/.+',
    'solr/server/resources/.+',
    'solr/server/solr/.+'
]

/**
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
    cli.h(longOpt: 'help', 'Show usage information')
}

/**
 * Prints the help info
 */
def printHelp(cli) {
    cli.usage()
}

/**
 * Exits the script with an error message, the usage and an error status.
 */
def exitWithError(cli, msg) {
    println msg
    println ''

    printHelp(cli)

    System.exit(1)
}

/**
 * Backups the data.
 */
def backupData(binFolder) {
    println "========================================================================"
    println "Backing up data"
    println "========================================================================"

    def setupCallback = { pb ->
        def env = pb.environment()
            env.remove("CRAFTER_HOME")
            env.remove("DEPLOYER_HOME")
            env.remove("CRAFTER_BIN_DIR")
            env.remove("CRAFTER_DATA_DIR")
            env.remove("CRAFTER_LOGS_DIR")
    }

    executeCommand(["./crafter.sh", "backup"], binFolder, setupCallback)
}

/**
 * Backups the bin folder.
 */
def backupBin(binFolder, backupsFolder, environmentName) {
    println "========================================================================"
    println "Backing up bin"
    println "========================================================================"

    def timestamp = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(new Date())

    if (!Files.exists(backupsFolder)) {
        Files.createDirectories(backupsFolder)
    }

    def backupBinFolder = backupsFolder.resolve("crafter-${environmentName}-bin.${timestamp}")

    println "Backing up bin directory to ${backupBinFolder}"

    FileUtils.copyDirectory(binFolder.toFile(), backupBinFolder.toFile())
}

/**
 * Shutdowns Crafter.
 */
def shutdownCrafter(binFolder) {
    println "========================================================================"
    println "Shutting down Crafter"
    println "========================================================================"

    def setupCallback = { pb ->
        def env = pb.environment()
            env.remove("CRAFTER_HOME")
            env.remove("DEPLOYER_HOME")
            env.remove("CRAFTER_BIN_DIR")
            env.remove("CRAFTER_DATA_DIR")
            env.remove("CRAFTER_LOGS_DIR")
    }

    executeCommand(["./shutdown.sh"], binFolder, setupCallback)
}

def isConfigFile(path) {
    return configFilePatterns.any { path.toString().matches(it) }
}

def getSyncUserInput(filePath) {
    println '-----------------------------------------------------------------------'
    println "File ${filePath} differs in old and new bin folders. Choose whether to:"
    println '- (D)iff files'
    println '- (E)dit old file (with $EDITOR or /usr/bin/editor)'
    println '- (R)eplace old file with new file'
    println '- (B)ackup old and copy new file'
    println '- (C)ontinue'
    println '- (A)bort and stop upgrade'   

    def option = System.console().readLine '> Enter your choice: '
        option = StringUtils.lowerCase(option)

    return option
}

def diffFiles(oldFile, newFile) {
    executeCommand(["diff", "\"${oldFile}\"".toString(), "\"${newFile}\"".toString()], null, null, [ 0, 1 ])
}

def openEditor(path) {
    def command = System.getenv('EDITOR')
    if (!command) {
        command = 'editor'
    }

    executeCommand([command, "${path}".toString()])
}

def backupAndReplaceFile(binFolder, oldFile, newFile, filePath) {
    def now = new Date()
    def backupTimestamp = now.format("yyyyMMddHHmmss")
    def backupFilePath = "${filePath}.bak.${backupTimestamp}"
    def backupFile = binFolder.resolve(backupFilePath)

    Files.move(oldFile, backupFile)
    Files.copy(newFile, oldFile)

    println "Backed up ${filePath} to ${backupFilePath} and copied over new version"
}

def syncFile(binFolder, newBinFolder, filePath) {
    def oldFile = binFolder.resolve(filePath)
    def newFile = newBinFolder.resolve(filePath)

    if (!Files.isHidden(newFile)) {
        if (Files.exists(oldFile)) {
            if (isConfigFile(filePath)) {
                def newMd5 = DigestUtils.md5Hex(Files.newInputStream(newFile))
                def oldMd5 = DigestUtils.md5Hex(Files.newInputStream(oldFile))

                def options = ['d', 'e', 'r', 'b', 'c', 'a']
                def finalOptions = ['r', 'b', 'c', 'a']

                if (newMd5 != oldMd5) {
                    def option = ''

                    while (!finalOptions.contains(option)) {
                        option = getSyncUserInput(filePath)
                        switch (option) {
                            case 'd':
                                diffFiles(oldFile, newFile)
                                break
                            case 'e':
                                openEditor(oldFile)
                                break
                            case 'r':
                                Files.copy(newFile, oldFile, REPLACE_EXISTING)
                                println "Replaced ${oldFile} with ${newFile}"
                                break
                            case 'b':
                                backupAndReplaceFile(binFolder, oldFile, newFile, filePath)
                                break
                            case 'c':
                                break
                            case 'a':
                                println 'Aborting upgrade...'
                                System.exit(0)
                            default:
                                println "Unrecognized option '${option}'"
                                break                       
                        }
                    }
                }
            } else {
                println "Copying over new version of ${filePath} (replacing non-config file)"

                Files.copy(newFile, oldFile, REPLACE_EXISTING)
            }
        } else {
            println "Copying over ${filePath} (new file)"

            def parent = oldFile.parent
            if (!Files.exists(parent)) {
                Files.createDirectories(parent)
            }

            Files.copy(newFile, oldFile)
        }
    }
}

/**
 * Does the actual upgrade
 */
def doUpgrade(binFolder, newBinFolder) {
    println "========================================================================"
    println "Upgrading Crafter"
    println "========================================================================"

    println "Synching files from ${newBinFolder} to ${binFolder}..."

    // Clearing temp folders and exploded webapps in newBinFolder
    def tomcatTempFolder = newBinFolder.resolve("apache-tomcat/temp")
    def tomcatWorkFolder = newBinFolder.resolve("apache-tomcat/work")
    def tomcatLogsFolder = newBinFolder.resolve("apache-tomcat/logs")
    def tomcatWebAppsFolder = newBinFolder.resolve("apache-tomcat/webapps")

    if (Files.exists(tomcatTempFolder)) {
        FileUtils.cleanDirectory(tomcatTempFolder.toFile())
    }
    if (Files.exists(tomcatWorkFolder)) {
        FileUtils.cleanDirectory(tomcatWorkFolder.toFile())
    }
    if (Files.exists(tomcatLogsFolder)) {
        FileUtils.cleanDirectory(tomcatLogsFolder.toFile())
    }
    if (Files.exists(tomcatWebAppsFolder)) {
        Files.walk(tomcatWebAppsFolder).withCloseable { files ->
            files
                .filter { file -> return file != tomcatWebAppsFolder && Files.isDirectory(file) }
                .each { file -> FileUtils.deleteDirectory(file.toFile()) }
        }
    }

    Files.walk(newBinFolder).withCloseable { files ->
        files
            .filter { file -> return !Files.isDirectory(file) }
            .each { file ->
                syncFile(binFolder, newBinFolder, newBinFolder.relativize(file))
            }
    }
}

/**
 * Executes the upgrade.
 */
def upgrade(targetFolder, environmentName) {
    def binFolder = targetFolder.resolve("bin")
    def backupsFolder = targetFolder.resolve("backups")
    def newBinFolder = getCrafterBinFolder()

    //shutdownCrafter(binFolder)
    //backupBin(binFolder, backupsFolder, environmentName)
    //backupData(binFolder)
    doUpgrade(binFolder, newBinFolder)

    println "========================================================================"
    println "Upgrade complete"
    println "========================================================================"
    println "Please read the release notes before starting Crafter again for any additional changes you need to " +
            "manually apply"
}

checkDownloadGrapesOnlyMode(getClass())

def cli = new CliBuilder(usage: 'upgrade-target [options] <target-installation-path>')
buildCli(cli)

def options = cli.parse(args)
if (options) {
    // Show usage text when -h or --help option is used.
    if (options.help) {
        printHelp(cli)
        return
    }    

    // Parse the options and arguments
    def extraArguments = options.arguments()
    if (CollectionUtils.isNotEmpty(extraArguments)) {
        def targetPath = extraArguments[0]
        def targetFolder = Paths.get(targetPath)

        upgrade(targetFolder, getEnvironmentName())
    } else {
        exitWithError(cli, 'No <target-installation-path> was specified')
    }
}
