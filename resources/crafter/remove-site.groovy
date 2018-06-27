@Grapes([
		@Grab(group='org.slf4j', module='slf4j-nop', version='1.7.25'),
		@Grab(group='org.apache.commons', module='commons-lang3', version='3.7'),
		@Grab(group='org.apache.commons', module='commons-collections4', version='4.1'),
		@Grab(group='commons-io', module='commons-io', version='2.6'),
		@Grab(group='io.github.http-builder-ng', module='http-builder-ng-core', version='1.0.3')
])

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths

import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils

import static groovyx.net.http.HttpBuilder.configure

import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

/**
 * Returns the delivery repo path.
 */
def getRepoPath(siteName) {
	def deliveryHome = getEnv('DELIVERY_HOME')
	def repoPath = FilenameUtils.normalize("${deliveryHome}/../data/repos/sites/${siteName}")

	// Fix separators in case of being run on Windows
	repoPath = FilenameUtils.separatorsToSystem(repoPath)

	return repoPath
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
 * Builds the CLI and adds the possible options
 */
def buildCli(cli) {
	cli.h(longOpt: 'help', 'Show usage information')
}

/**
 * Prints the help message
 */
def printHelp(cli) {
	cli.usage()
}


/**
 * Calls the Search API to delete the Solr Core.
 */
def deleteSolrCore(siteName) {
	println 'Deleting Solr Core...'

	def httpClient = configure {
		request.uri = getTomcatUrl()
	}

	httpClient.post {
		request.uri.path = "/crafter-search/api/2/admin/index/delete/${siteName}"
		request.contentType = 'application/json'
		request.body = [ delete_mode: 'ALL_DATA_AND_CONFIG' ]
		response.success { fs ->
			println "Core deleted successfully"
		}
		response.failure { fs, body ->
			println "Error while deleting Core: ${body.message}"
		}
	}
}

/**
 * Calls the Deployer API to create the Deployer Target.
 */
def deleteDeployerTarget(siteName) {
	println 'Deleting Deployer Target...'

	def httpClient = configure {
		request.uri = getDeployerUrl()
	}

	httpClient.post {
		request.uri.path = "/api/1/target/delete/default/${siteName}"
		request.contentType = 'application/json'
		request.body = []
		response.success { fs ->
			println "Target deleted successfully"
		}
		response.failure { fs, body ->
			println "Error while deleting Target: ${body.message}"
		}
	}
}

/**
 * Deletes the delivery repository folder
 */
def deleteRepoFolder(repoPath) {
	println "Deleting repo folder ${repoPath}..."

	FileUtils.forceDelete(new File(repoPath))

	println "Repo folder deleted successfully"
}

/**
 * Deletes the delivery site
 */
def deleteSite(siteName, repoPath) {
	deleteDeployerTarget(siteName)
	deleteSolrCore(siteName)
	deleteRepoFolder(repoPath)
}

checkDownloadGrapesOnlyMode(getClass())

def cli = new CliBuilder(usage: 'remove-site [options] <site>')
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
		def siteName = extraArguments[0]
		def repoPath = getRepoPath(siteName)

		if (!Files.exists(Paths.get(repoPath))) {
			exitWithError(cli, "Repository path ${repoPath} does not exist or cannot be read");
		}

		deleteSite(siteName, repoPath)
	} else {
		exitWithError(cli, '<site> was not specified')
	}
}
