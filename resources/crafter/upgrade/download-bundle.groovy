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

import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.StringUtils
import org.apache.commons.lang3.SystemUtils
import org.apache.commons.io.FilenameUtils

import net.lingala.zip4j.core.ZipFile

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
	cli.v(longOpt: 'version', args: 1, argName: 'version', 'The community version of the Crafter bundle to download')
	cli.u(longOpt: 'bundle-url', args: 1, argName: 'url', 'The URL of the Crafter bundle to download. If you specify ' +
																												'this URL the version parameter will be ignored')
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
 * Downloads the file from the URL into the target folder.
 */
def downloadFile(sourceUrl, targetFolder) {
	if (!Files.exists(targetFolder)) {
		Files.createDirectories(targetFolder)
	}

	def url = sourceUrl.toURL()
	def filename = FilenameUtils.getName(url.path)
	def targetFile = targetFolder.resolve(filename)

	Files.deleteIfExists(targetFile)

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
def downloadBundle(targetFolder, version, bundleUrl, envSuffix) {
	println "============================================================"
	println "Downloading Bundle"
	println "============================================================"

	if (!bundleUrl) {
		if (version) {
			bundleUrl = "${DOWNLOADS_BASE_URL}/${version}/crafter-cms-${envSuffix}"

			if (SystemUtils.IS_OS_WINDOWS) {
				bundleUrl += ".zip"
			} else {
				bundleUrl += ".tar.gz"
			}
		} else {
			exitWithError(cli, 'No [version] or [bundle-url] specified')
		}
	}

	def md5SumUrl = "${bundleUrl}.md5"

	println "Downloading bundle @ ${bundleUrl}..."
	def bundleFile = downloadFile(bundleUrl, targetFolder)

	println "Downloading md5sum @ ${md5SumUrl}..."
	def md5SumFile = downloadFile(md5SumUrl, targetFolder)

	println "Doing checksum..."
	checksum(bundleFile, md5SumFile)

	extractBundle(bundleFile, targetFolder)

	println "============================================================"
	println "Download complete"
	println "============================================================"
}

checkDownloadGrapesOnlyMode(getClass())

def cli = new CliBuilder(usage: 'download-bundle [options]')
buildCli(cli)

def options = cli.parse(args)
if (options) {
	// Show usage text when -h or --help option is used.
	if (options.help) {
		printHelp(cli)
		return
	}

	// Parse the options and arguments
	downloadBundle(getUpgradeTmpFolder(), options.version, options.'bundle-url', ENVIRONMENT_NAME)
}
