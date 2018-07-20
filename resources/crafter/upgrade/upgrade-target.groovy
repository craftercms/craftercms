@Grapes([
    @Grab(group='org.slf4j', module='slf4j-nop', version='1.7.25'),
    @Grab(group='org.apache.commons', module='commons-lang3', version='3.7'),
    @Grab(group='org.apache.commons', module='commons-collections4', version='4.1'),
    @Grab(group='commons-io', module='commons-io', version='2.6'),
])

import java.nio.file.Files
import java.nio.file.Paths
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.SystemUtils

import utils.NioUtils

import static java.nio.file.StandardCopyOption.*
import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

/**
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
  cli.h(longOpt: 'help', 'Show usage information')
  cli.f(longOpt: 'full', 'Perform a full upgrade. During a non-full upgrade, only the Tomcat wars and the ' +
                         'Deployer jar are upgraded. During a full upgrade, the entire bin directory is upgraded, ' +
                         'keeping only Tomcat\'s shared folder, Tomcat\'s conf folder, the Crafter Solr config, ' +
                         'the Deployer config folder, and the crafter-setenv scripts')
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
def backupData(binFolder, dataFolder) {
  println "============================================================"
  println "Backing up data"
  println "============================================================"

  if (Files.exists(dataFolder.resolve("repos"))) {
    def setupCallback = { pb ->
      def env = pb.environment()
          env.remove("CRAFTER_ROOT")
          env.remove("CRAFTER_HOME")
    }

    executeCommand([SystemUtils.IS_OS_WINDOWS ? "crafter.bat" : "./crafter.sh", "backup"], binFolder, setupCallback)
  } else {
    println "No repos folder found @ ${dataFolder}. Skipping data backup"
  }
}

/**
 * Backups the bin folder.
 */
def backupBin(binFolder, backupsFolder, environmentName) {
  println "============================================================"
  println "Backing up bin"
  println "============================================================"

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
  println "============================================================"
  println "Shutting down Crafter"
  println "============================================================"

  def setupCallback = { pb ->
    def env = pb.environment()
        env.remove("CRAFTER_ROOT")
        env.remove("CRAFTER_HOME")
  }

  executeCommand([SystemUtils.IS_OS_WINDOWS ? "shutdown.bat" : "./shutdown.sh"], binFolder, setupCallback)
}

/**
 * Does the actual upgrade
 */
def doUpgrade(binFolder, newBinFolder, fullUpgrade) {
  if (fullUpgrade) {
    println "============================================================"
    println "Upgrading Crafter (full upgrade)"
    println "============================================================"

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
  } else {
    println "============================================================"
    println "Upgrading Crafter (copying war/jar and upgrade scripts)"
    println "============================================================"

    def webappsFolder = binFolder.resolve("apache-tomcat/webapps")
    def newWebappsFolder = newBinFolder.resolve("apache-tomcat/webapps")

    println "Copying ${newWebappsFolder} to ${webappsFolder}..."

    NioUtils.deleteDirectory(webappsFolder)
    NioUtils.copyDirectory(newWebappsFolder, webappsFolder)

    def deployerJar = binFolder.resolve("crafter-deployer/crafter-deployer.jar")
    def newDeployerJar = newBinFolder.resolve("crafter-deployer/crafter-deployer.jar")

    println "Copying ${newDeployerJar} to ${deployerJar}..."

    Files.delete(deployerJar)
    Files.copy(newDeployerJar, deployerJar)

    def groovyFolder = binFolder.resolve("groovy")
    def newGroovyFolder = newBinFolder.resolve("groovy")

    println "Copying ${newGroovyFolder} to ${groovyFolder}..."

    NioUtils.deleteDirectory(groovyFolder)
    NioUtils.copyDirectory(newGroovyFolder, groovyFolder)

    def grapesFolder = binFolder.resolve("grapes")
    def newGrapesFolder = newBinFolder.resolve("grapes")

    println "Copying ${newGrapesFolder} to ${grapesFolder}..."

    NioUtils.deleteDirectory(grapesFolder)
    NioUtils.copyDirectory(newGrapesFolder, grapesFolder)

    def grapeConfigFile = binFolder.resolve("grapeConfig.xml")
    def newGrapeConfigFile = newBinFolder.resolve("grapeConfig.xml")

    println "Copying ${newGrapeConfigFile} to ${grapeConfigFile}..."

    Files.deleteIfExists(grapeConfigFile)
    Files.copy(newGrapeConfigFile, grapeConfigFile)

    def utilsFolder = binFolder.resolve("utils")
    def newUtilsFolder = newBinFolder.resolve("utils")

    println "Copying ${newUtilsFolder} to ${utilsFolder}..."

    NioUtils.deleteDirectory(utilsFolder)
    NioUtils.copyDirectory(newUtilsFolder, utilsFolder)

    def upgradeFolder = binFolder.resolve("upgrade")
    def newUpgradeFolder = newBinFolder.resolve("upgrade")

    println "Copying ${newUpgradeFolder} to ${upgradeFolder}..."

    NioUtils.deleteDirectory(upgradeFolder)
    NioUtils.copyDirectory(newUpgradeFolder, upgradeFolder)
  }
}

/**
 * Starts Crafter.
 */
def startCrafter(binFolder) {
  println "============================================================"
  println "Starting Crafter"
  println "============================================================"

  def setupCallback = { pb ->
    def env = pb.environment()
        env.remove("CRAFTER_ROOT")
        env.remove("CRAFTER_HOME")
  }

  executeCommand([SystemUtils.IS_OS_WINDOWS ? "startup.bat" : "./startup.sh"], binFolder, setupCallback)
}

/**
 * Executes the upgrade.
 */
def upgrade(targetFolder, fullUpgrade, environmentName) {
  def binFolder = targetFolder.resolve("bin")
  def dataFolder = targetFolder.resolve("data")
  def backupsFolder = targetFolder.resolve("backups")
  def newBinFolder = getCrafterBinFolder()

  backupData(binFolder, dataFolder)
  shutdownCrafter(binFolder)
  backupBin(binFolder, backupsFolder, environmentName)
  doUpgrade(binFolder, newBinFolder, fullUpgrade)
  startCrafter(binFolder)

  println "============================================================"
  println "Upgrade complete"
  println "============================================================"
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
  def extraArguments = options.arguments();
  if (CollectionUtils.isNotEmpty(extraArguments)) {
    def targetPath = extraArguments[0]
    def targetFolder = Paths.get(targetPath)

    upgrade(targetFolder, options.full, getEnvironmentName())
  } else {
    exitWithError(cli, 'No <target-installation-path> was specified')
  }
}
