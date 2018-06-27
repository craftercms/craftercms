@Grapes([
		@Grab(group='org.slf4j', module='slf4j-nop', version='1.7.25'),
		@Grab(group='org.apache.commons', module='commons-lang3', version='3.7'),
		@Grab(group='org.apache.commons', module='commons-collections4', version='4.1'),
		@Grab(group='commons-codec', module='commons-codec', version='1.11'),
		@Grab(group='commons-io', module='commons-io', version='2.6'),
		@Grab(group='net.lingala.zip4j', module='zip4j', version='1.3.2')
])

import groovy.transform.Field

import java.nio.file.Files
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.StringUtils
import org.apache.commons.lang3.SystemUtils
import org.apache.commons.io.FilenameUtils

import net.lingala.zip4j.core.ZipFile

import utils.NioUtils

import static java.nio.file.StandardCopyOption.*
import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

@Field final DOWNLOADS_BASE_URL = "https://downloads.craftercms.org"
@Field final ENVIRONMENT_NAME = "@ENV@"
@Field final UNZIPPED_CRAFTER_FOLDER_NAME = "crafter"

/**
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
	cli.h(longOpt: 'help', 'Show usage information')
	cli.u(longOpt: 'bundle-url', args: 1, argName: 'url', 'The URL of the Crafter bundle to be used for the upgrade')
	cli.f(longOpt: 'full', 'If a full upgrade should be performed. In a non-full upgrade, only the Tomcat wars and ' +
												 'the Deployer jar are upgraded. In a full upgrade, the entire bin directory is upgraded, ' +
												 'keeping only the Tomcat shared config, Tomcat\'s server.xml, the Solr config, and the ' +
												 'crafter-setenv scripts')
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
 * Executes a command line process.
 */
def executeCommand(workingDir, command) {
	if (SystemUtils.IS_OS_WINDOWS) {
		command  = ["cmd", "/c"] + command
	}

	def processBuilder = new ProcessBuilder(command)

	if (workingDir) {
		processBuilder.directory(workingDir.toFile())
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

/**
 * Downloads the file from the URL into the target folder.
 */
def downloadFile(sourceUrl, targetFolder) {
	def url = sourceUrl.toURL()
	def filename = FilenameUtils.getName(url.path)
	def targetFile = targetFolder.resolve(filename)

	url.withInputStream { is ->
    Files.copy(is, targetFile)
	}

	return targetFile
}

/**
 * Computes an md5sum and compares it against an md5sum file.
 */
def checksum(file, downloadedMd5SumFile) {
	def computedMd5Sum = DigestUtils.md5Hex(Files.newInputStream(file))
	def downloadedMd5SumFileContent = new String(Files.readAllBytes(downloadedMd5SumFile), "UTF-8")
	def downloadedMd5Sum = StringUtils.substringBefore(downloadedMd5SumFileContent, " ")

	if (!computedMd5Sum.equals(downloadedMd5Sum)) {
		throw new RuntimeException("The md5sum for file ${file} doesn't match the downloaded md5sum")
	}
}

/**
 * Extract the bundle file into the target folder.
 */
def extractBundle(bundleFile, targetFolder) {
	println "Extracting bundle..."

	if (FilenameUtils.getExtension(bundleFile.fileName.toString()).equalsIgnoreCase("zip")) {
		// Extract as zip
		def zipFile = new ZipFile(bundleFile.toAbsolutePath().toString())
				zipFile.extractAll(targetFolder.toAbsolutePath().toString())
	} else {
		// Extract as tar.gz
		executeCommand(targetFolder, ["tar", "xzf", bundleFile.toAbsolutePath().toString()])
	}

	return targetFolder.resolve(UNZIPPED_CRAFTER_FOLDER_NAME)
}

/**
 * Downloads a Crafter Authoring/Delivery bundle, performs an md5sum to check if it was downloaded correctly, and
 * unzips the bundle
 */
def downloadCrafterBundle(version, bundleUrl, envSuffix) {
	println "============================================================"
	println "Downloading Crafter ${version}"
	println "============================================================"

	if (!bundleUrl) {
		bundleUrl = "${DOWNLOADS_BASE_URL}/${version}/crafter-cms-${envSuffix}"

		if (SystemUtils.IS_OS_WINDOWS) {
			bundleUrl += ".zip"
		} else {
			bundleUrl += ".tar.gz"
		}
	}

	def md5SumUrl = "${bundleUrl}.md5"
	def targetFolder = getUpgradeTmpFolder()

	println "Downloading bundle @ ${bundleUrl}..."
	def bundleFile = downloadFile(bundleUrl, targetFolder)

	println "Downloading md5sum @ ${md5SumUrl}..."
	def md5SumFile = downloadFile(md5SumUrl, targetFolder)

	println "Doing checksum..."
	checksum(bundleFile, md5SumFile)

	return extractBundle(bundleFile, targetFolder)
}

/**
 * Backups data.
 */
def backupData() {
	println "============================================================"
	println "Backing up data"
	println "============================================================"

	if (Files.exists(getCrafterDataFolder().resolve("repos"))) {
		executeCommand(getCrafterBinFolder(), [SystemUtils.IS_OS_WINDOWS ? "crafter.bat" : "./crafter.sh", "backup"])
	} else {
		println "No repos folder found. Skipping data backup"
	}
}

/**
 * Backups the bin folder.
 */
def backupBin() {
	println "============================================================"
	println "Backing up bin"
	println "============================================================"

	def timestamp = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(new Date())
	def backupsFolder = getCrafterBackupsFolder()

	if (!Files.exists(backupsFolder)) {
		Files.createDirectories(backupsFolder)
	}

	def backupBinFolder = backupsFolder.resolve("crafter-${ENVIRONMENT_NAME}-bin.${timestamp}")

	println "Backing up bin directory to ${backupBinFolder}"

	NioUtils.copyDirectory(getCrafterBinFolder(), backupBinFolder)
}

/**
 * Shutdowns Crafter.
 */
def shutdownCrafter() {
	println "============================================================"
	println "Shutting down Crafter"
	println "============================================================"

	executeCommand(getCrafterBinFolder(), [SystemUtils.IS_OS_WINDOWS ? "shutdown.bat" : "./shutdown.sh"])
}

/**
 * Does the actual upgrade
 */
def doUpgrade(newVersion, newBinFolder, fullUpgrade) {
	def binFolder = getCrafterBinFolder()

	if (fullUpgrade) {
		println "============================================================"
		println "Upgrading Crafter to ${newVersion} (full upgrade)"
		println "============================================================"

		println "Copying original Tomcat shared folder to new bin folder..."

		def sharedFolder = binFolder.resolve("apache-tomcat/shared")
		def newSharedFolder = newBinFolder.resolve("apache-tomcat/shared")

		NioUtils.deleteDirectory(newSharedFolder)
		NioUtils.copyDirectory(sharedFolder, newSharedFolder)

		println "Copying original Tomcat server.xml to new bin folder..."

		def serverXmlFile = binFolder.resolve("apache-tomcat/conf/server.xml")
		def newServerXmlFile = newBinFolder.resolve("apache-tomcat/conf/server.xml")

		Files.delete(newServerXmlFile)
		Files.copy(serverXmlFile, newServerXmlFile, COPY_ATTRIBUTES)

		println "Copying original Deployer config to new bin folder..."

		def deployerConfigFolder = binFolder.resolve("crafter-deployer/config")
		def newDeployerConfigFolder = newBinFolder.resolve("crafter-deployer/config")

		NioUtils.deleteDirectory(newDeployerConfigFolder)
		NioUtils.copyDirectory(deployerConfigFolder, newDeployerConfigFolder)

		println "Copying original Crafter Solr configset to new bin folder..."

		def solrConfigset = binFolder.resolve("solr/server/solr/configsets/crafter_configs")
		def newSolrConfigset = newBinFolder.resolve("solr/server/solr/configsets/crafter_configs")

		NioUtils.deleteDirectory(newSolrConfigset)
		NioUtils.copyDirectory(solrConfigset, newSolrConfigset)

		println "Copying original crafter-setenv.sh and crafter-setenv.bat to new bin folder..."

		def setenvFile = binFolder.resolve("crafter-setenv.sh")
		def newSetenvFile = newBinFolder.resolve("crafter-setenv.sh")

		Files.delete(newSetenvFile)
		Files.copy(setenvFile, newSetenvFile, COPY_ATTRIBUTES)

		setenvFile = binFolder.resolve("crafter-setenv.bat")
		newSetenvFile = newBinFolder.resolve("crafter-setenv.bat")

		Files.delete(newSetenvFile)
		Files.copy(setenvFile, newSetenvFile, COPY_ATTRIBUTES)

		println "Replacing original bin folder with new bin folder..."

		NioUtils.deleteDirectory(binFolder)
		Files.move(newBinFolder, binFolder)
	} else {
		println "============================================================"
		println "Upgrading Crafter to ${newVersion} (war/jar upgrade only)"
		println "============================================================"

		println "Copying new Tomcat wars..."

		def webappsFolder = binFolder.resolve("apache-tomcat/webapps")
		def newWebappsFolder = newBinFolder.resolve("apache-tomcat/webapps")

		NioUtils.deleteDirectory(webappsFolder)
		Files.move(newWebappsFolder, webappsFolder)

		println "Copying new Deployer jar..."

		def deployerJar = binFolder.resolve("crafter-deployer/crafter-deployer.jar")
		def newDeployerJar = newBinFolder.resolve("crafter-deployer/crafter-deployer.jar")

		Files.delete(deployerJar)
		Files.move(newDeployerJar, deployerJar)
	}
}

/**
 * Starts Crafter.
 */
def startCrafter() {
	println "============================================================"
	println "Starting Crafter"
	println "============================================================"

	executeCommand(getCrafterBinFolder(), [SystemUtils.IS_OS_WINDOWS ? "startup.bat" : "./startup.sh"])
}

/**
 * Executes the upgrade.
 */
def upgradeCrafter(version, bundleUrl, fullUpgrade) {
	def newVersionFolder = downloadCrafterBundle(version, bundleUrl, ENVIRONMENT_NAME)
	def newBinFolder = newVersionFolder.resolve("bin")

	backupData()
	shutdownCrafter()
	backupBin()
	doUpgrade(version, newBinFolder, fullUpgrade)
	startCrafter()

	println "============================================================"
	println "Upgrade complete"
	println "============================================================"
}

checkDownloadGrapesOnlyMode(getClass())

def cli = new CliBuilder(usage: 'upgrade [options] <version>')
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
		def version = extraArguments[0]

		upgradeCrafter(version, options.'bundle-url', options.full)
	} else {
		exitWithError(cli, 'No <version> was specified')
	}
}
