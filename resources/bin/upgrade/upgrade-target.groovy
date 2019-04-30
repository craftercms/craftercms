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
        @Grab(group = 'commons-io', module = 'commons-io', version = '2.6'),
])

import java.nio.file.Files
import java.nio.file.Paths
import java.text.SimpleDateFormat

import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.SystemUtils

import utils.NioUtils

import static java.nio.file.StandardCopyOption.*
import static upgrade.utils.UpgradeUtils.*
import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

/**
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
    cli.h(longOpt: 'help', 'Show usage information')
    cli.f(longOpt: 'full', 'Deprecated option. Since 3.0.19, a full upgrade is always executed')
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

    executeCommand([SystemUtils.IS_OS_WINDOWS ? "crafter.bat" : "./crafter.sh", "backup"], binFolder, setupCallback)
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

    NioUtils.copyDirectory(binFolder, backupBinFolder)
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

    executeCommand([SystemUtils.IS_OS_WINDOWS ? "shutdown.bat" : "./shutdown.sh"], binFolder, setupCallback)

    if (SystemUtils.IS_OS_WINDOWS) {
        print 'Please make sure Crafter has stopped and all Crafter process windows are closed, then press enter to continue '
        System.in.read()
    }
}

/**
 * Does the actual upgrade
 */
def doUpgrade(binFolder, newBinFolder, previousVersion, upgradeVersion) {
    def upgradeHooks = new UpgradeHooks(binFolder, newBinFolder, previousVersion, upgradeVersion)
        upgradeHooks.preUpgrade()

    println "========================================================================"
    println "Upgrading Crafter"
    println "========================================================================"

    def sharedFolder = binFolder.resolve("apache-tomcat/shared")
    def newSharedFolder = newBinFolder.resolve("apache-tomcat/shared")

    println "Copying ${sharedFolder} to ${newSharedFolder}..."

    NioUtils.deleteDirectory(newSharedFolder)
    NioUtils.copyDirectory(sharedFolder, newSharedFolder)

    def confFolder = binFolder.resolve("apache-tomcat/conf")
    def newConfFolder = newBinFolder.resolve("apache-tomcat/conf")

    println "Copying ${confFolder} to ${newConfFolder}..."

    NioUtils.deleteDirectory(newConfFolder)
    NioUtils.copyDirectory(confFolder, newConfFolder)

    def deployerConfigFolder = binFolder.resolve("crafter-deployer/config")
    def newDeployerConfigFolder = newBinFolder.resolve("crafter-deployer/config")

    println "Copying ${deployerConfigFolder} to ${newDeployerConfigFolder}..."

    NioUtils.deleteDirectory(newDeployerConfigFolder)
    NioUtils.copyDirectory(deployerConfigFolder, newDeployerConfigFolder)

    def solrConfigset = binFolder.resolve("solr/server/solr/configsets/crafter_configs")
    def newSolrConfigset = newBinFolder.resolve("solr/server/solr/configsets/crafter_configs")

    println "Copying ${solrConfigset} to ${newSolrConfigset}..."

    NioUtils.deleteDirectory(newSolrConfigset)
    NioUtils.copyDirectory(solrConfigset, newSolrConfigset)

    def setenvFile = binFolder.resolve("crafter-setenv.sh")
    def newSetenvFile = newBinFolder.resolve("crafter-setenv.sh")

    println "Copying ${setenvFile} to ${newSetenvFile}..."

    Files.delete(newSetenvFile)
    Files.copy(setenvFile, newSetenvFile, COPY_ATTRIBUTES)

    setenvFile = binFolder.resolve("crafter-setenv.bat")
    newSetenvFile = newBinFolder.resolve("crafter-setenv.bat")

    println "Copying ${setenvFile} to ${newSetenvFile}..."

    Files.delete(newSetenvFile)
    Files.copy(setenvFile, newSetenvFile, COPY_ATTRIBUTES)

    println "Replacing ${binFolder} with ${newBinFolder}..."

    NioUtils.deleteDirectory(binFolder)
    NioUtils.copyDirectory(newBinFolder, binFolder)

    upgradeHooks.postUpgrade()
}

/**
 * Executes the upgrade.
 */
def upgrade(targetFolder, environmentName) {
    def binFolder = targetFolder.resolve("bin")
    def backupsFolder = targetFolder.resolve("backups")
    def newBinFolder = getCrafterBinFolder()
    def previousVersion = readVersionFile(binFolder)
    def upgradeVersion = readVersionFile(newBinFolder)

    if (previousVersion != upgradeVersion) {
        shutdownCrafter(binFolder)
        backupBin(binFolder, backupsFolder, environmentName)
        doUpgrade(binFolder, newBinFolder, previousVersion, upgradeVersion)
        backupData(binFolder)

        println "========================================================================"
        println "Upgrade complete"
        println "========================================================================"
        println "Please read the release notes before starting Crafter again for any additional changes you need to " +
                "manually apply"
    } else {
        println "Trying to upgrade an installation in version ${previousVersion} to same version ${upgradeVersion}. " +
                "Upgrade cancelled"
    }
}

checkDownloadGrapesOnlyMode(getClass())

// TODO: Remove this message after upgrade scripts are fixed and uncomment the rest of the code
println "The upgrade scripts have been disabled in 3.1.0, while they're being refactored. For now, please follow " +
        "the upgrade instructions in " +
        "https://docs.craftercms.org/en/3.1/system-administrators/upgrade/upgrading-to-craftercms-3-1-0.html" 

// def cli = new CliBuilder(usage: 'upgrade-target [options] <target-installation-path>')
// buildCli(cli)

// def options = cli.parse(args)
// if (options) {
//     // Show usage text when -h or --help option is used.
//     if (options.help) {
//         printHelp(cli)
//         return
//     }    

//     // Parse the options and arguments
//     def extraArguments = options.arguments()
//     if (CollectionUtils.isNotEmpty(extraArguments)) {
//         def targetPath = extraArguments[0]
//         def targetFolder = Paths.get(targetPath)

//         upgrade(targetFolder, getEnvironmentName())
//     } else {
//         exitWithError(cli, 'No <target-installation-path> was specified')
//     }
// }
