@Grapes([
		@Grab(group='org.slf4j', module='slf4j-nop', version='1.7.25'),
		@Grab(group='org.apache.commons', module='commons-lang3', version='3.7'),
		@Grab(group='org.apache.commons', module='commons-collections4', version='4.1'),
		@Grab(group='commons-codec', module='commons-codec', version='1.11'),
		@Grab(group='commons-io', module='commons-io', version='2.6'),
		@Grab(group='net.lingala.zip4j', module='zip4j', version='1.3.2')
])

import groovy.transform.Field;

import java.io.File
import java.net.URL
import java.nio.file.Files
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.StringUtils
import org.apache.commons.lang3.SystemUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils

import net.lingala.zip4j.core.ZipFile

@Field final DOWNLOADS_BASE_URL = "https://downloads.craftercms.org"
@Field final ENVIRONMENT_NAME = "authoring"
@Field final UNZIPPED_CRAFTER_FOLDER_NAME = "crafter"

/**
 * Returns the value of an environment variable.
 */
def getEnv(varName) {
	def env = System.getenv()

	return env[varName]
}

/**
 * Returns the root folder for the Crafter installation.
 */
def getCrafterRootFolder() {
	return new File(getEnv("CRAFTER_ROOT"))
}

/**
 * Returns the bin folder for the Crafter installation.
 */
def getCrafterBinFolder() {
	return new File(getCrafterRootFolder(), "bin")
}

/**
 * Returns the backups folder for the Crafter installation.
 */
def getCrafterBackupsFolder() {
	return new File(getCrafterRootFolder(), "backups")
}

/**
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
	cli.h(longOpt: 'help', 'Show usage information')
	cli.f(longOpt: 'full', 'If a full upgrade should be performed. In a non-full upgrade, only the Tomcat wars and ' +
												 'the Deployer jar are upgraded. In a full upgrade, the entire bin directory is upgraded, ' +
												 'keeping only the Tomcat shared config and the Solr config')
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
	def processBuilder = new ProcessBuilder(command)

	if (workingDir) {
		processBuilder.directory(workingDir)
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
	def url = new URL(sourceUrl)
	def filename = FilenameUtils.getName(url.path)
	def targetFile = new File(targetFolder, filename)

	FileUtils.copyURLToFile(url, targetFile)

	return targetFile
}

/**
 * Computes an md5sum and compares it against an md5sum file.
 */
def checksum(file, downloadedMd5SumFile) {
	def computedMd5Sum = DigestUtils.md5Hex(file.newInputStream())
	def downloadedMd5Sum = StringUtils.substringBefore(FileUtils.readFileToString(downloadedMd5SumFile, "UTF-8"), " ")

	if (!computedMd5Sum.equals(downloadedMd5Sum)) {
		throw new RuntimeException("The md5sum for file ${file} doesn't match the downloaded md5sum")
	}
}

/**
 * Extract the bundle file into the target folder.
 */
def extractBundle(bundleFile, targetFolder) {
	println "Extracting bundle..."

	if (FilenameUtils.getExtension(bundleFile.name).equalsIgnoreCase("zip")) {
		// Extract as zip
		def zipFile = new ZipFile(bundleFile)
				zipFile.extractAll(targetFolder.absolutePath)
	} else {
		// Extract as tar.gz
		executeCommand(targetFolder, ["tar", "xzf", bundleFile.absolutePath])
	}

	return new File(targetFolder, UNZIPPED_CRAFTER_FOLDER_NAME)
}

/**
 * Downloads a Crafter Authoring/Delivery bundle, performs an md5sum to check if it was downloaded correctly, and
 * unzips the bundle
 */
def downloadCrafterBundle(version, envSuffix, targetFolder) {
	println "============================================================"
	println "Downloading Crafter ${version}"
	println "============================================================"

	def bundleUrl = "${DOWNLOADS_BASE_URL}/${version}/crafter-cms-${envSuffix}"

	if (SystemUtils.IS_OS_WINDOWS) {
		bundleUrl += ".zip"
	} else {
		bundleUrl += ".tar.gz"
	}

	def md5SumUrl = "${bundleUrl}.md5"

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

	executeCommand(getCrafterBinFolder(), [SystemUtils.IS_OS_WINDOWS ? "crafter.bat" : "./crafter.sh", "backup"])
}

/**
 * Backups the bin folder.
 */
def backupBin() {
	println "============================================================"
	println "Backing up bin"
	println "============================================================"

	def timestamp = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(new Date())
	def backupBinFolder = new File(getCrafterBackupsFolder(), "crafter-${ENVIRONMENT_NAME}-bin.${timestamp}")

	FileUtils.copyDirectory(getCrafterBinFolder(), backupBinFolder)
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

		def sharedFolder = new File(binFolder, "apache-tomcat/shared")
		def newSharedFolder = new File(newBinFolder, "apache-tomcat/shared")

		FileUtils.deleteDirectory(newSharedFolder)
		FileUtils.copyDirectory(sharedFolder, newSharedFolder)

		println "Copying original Deployer config to new bin folder..."

		def deployerConfigFolder = new File(binFolder, "crafter-deployer/config")
		def newDeployerConfigFolder = new File(newBinFolder, "crafter-deployer/config")

		FileUtils.deleteDirectory(newDeployerConfigFolder)
		FileUtils.copyDirectory(deployerConfigFolder, newDeployerConfigFolder)

		println "Copying original Crafter Solr configset to new bin folder..."

		def solrConfigset = new File(binFolder, "solr/server/solr/configsets/crafter_configs")
		def newSolrConfigset = new File(newBinFolder, "solr/server/solr/configsets/crafter_configs")

		FileUtils.deleteDirectory(newSolrConfigset)
		FileUtils.copyDirectory(solrConfigset, newSolrConfigset)

		println "Replacing original bin folder with new bin folder..."

		FileUtils.deleteDirectory(binFolder)
		FileUtils.moveDirectory(newBinFolder, binFolder)
	} else {
		println "============================================================"
		println "Upgrading Crafter to ${newVersion} (war/jar upgrade only)"
		println "============================================================"

		println "Copying new Tomcat wars..."

		def webappsFolder = new File(binFolder, "apache-tomcat/webapps")
		def newWebappsFolder = new File(newBinFolder, "apache-tomcat/webapps")

		FileUtils.deleteDirectory(webappsFolder)
		FileUtils.moveDirectory(newWebappsFolder, webappsFolder)

		println "Copying new Deployer jar..."

		def deployerJar = new File(binFolder, "crafter-deployer/crafter-deployer.jar")
		def newDeployerJar = new File(newBinFolder, "crafter-deployer/crafter-deployer.jar")

		FileUtils.forceDelete(deployerJar)
		FileUtils.moveFile(newDeployerJar, deployerJar)
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
def upgradeCrafter(version, fullUpgrade) {
	def tmpFolder = Files.createTempDirectory("crafter-upgrade").toFile()

	try {
		def newVersionFolder = downloadCrafterBundle(version, ENVIRONMENT_NAME, tmpFolder)
		def newBinFolder = new File(newVersionFolder, "bin")

		backupData()
		shutdownCrafter()
		backupBin()
		doUpgrade(version, newBinFolder, fullUpgrade)
		startCrafter()

		println "============================================================"
		println "Upgrade complete"
		println "============================================================"
	} finally {
		FileUtils.deleteQuietly(tmpFolder)
	}
}

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

		upgradeCrafter(version, options.full)
	} else {
		exitWithError(cli, 'No <version> was specified')
	}
}
