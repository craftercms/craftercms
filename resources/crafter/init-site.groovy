@Grapes([
		@Grab(group='org.slf4j', module='slf4j-nop', version='1.7.25'),
		@Grab(group='org.apache.commons', module='commons-lang3', version='3.7'),
		@Grab(group='org.apache.commons', module='commons-collections4', version='4.1'),
		@Grab(group='commons-io', module='commons-io', version='2.6'),
		@Grab(group='io.github.http-builder-ng', module='http-builder-ng-core', version='1.0.3')
])

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

import org.apache.commons.collections4.CollectionUtils
import org.apache.commons.lang3.StringUtils
import org.apache.commons.io.FilenameUtils

import static groovyx.net.http.HttpBuilder.configure

import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

/**
 * Infers the repo path assuming a developer installation of Crafter CMS (both Crafter Authoring and Delivery at the
 * same location).
 */
def getDefaultRepoPath(siteName) {
	def deliveryHome = getEnv('DELIVERY_HOME')
	def authoringRoot = FilenameUtils.normalize("${deliveryHome}/../../crafter-authoring")
	def repoPath = "${authoringRoot}/data/repos/sites/${siteName}/published"

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
	cli.b(longOpt: 'branch', args: 1, argName: 'branch', 'The name of the branch to clone (live by default)')
	cli.u(longOpt: 'username', args: 1, argName: 'username', 'The username for the remote Git repo, when using basic ' +
			'authentication')
	cli.p(longOpt: 'password', args: 1, argName: 'password', 'The password for the remote Git repo, when using basic ' +
			'authentication')
	cli.k(longOpt: 'private-key', args: 1, argName: 'path', 'The path to the private key, if it\'s not under the ' +
			'default path (~/.ssh/id_rsa), when authenticating ' +
			'through SSH to the remote Git repo')
	cli.f(longOpt: 'passphrase', args: 1, argName: 'passphrase', 'The passphrase of the private key (when the key is ' +
			'passphrase protected)')
	cli.a(longOpt: 'notification-addresses', args: 1, argName: 'addresses', 'A comma-separated list of email ' +
			'addresses that should receive deployment notifications')
}

/**
 * Prints the help info
 */
def printHelp(cli) {
	cli.usage()

	println 'EXAMPLES:'
	println ' Init a site from the default repo path (../../crafter-authoring/data/repos/sites/{sitename}/published)'
	println '     init-site mysite'
	println ' Init a site from a specific local repo path'
	println '     init-site mysite /opt/crafter/authoring/data/repos/sites/mysite/published'
	println ' Init a site from a specific local repo path, cloning a specific branch of the repo'
	println '     init-site -b master mysite /opt/crafter/authoring/data/repos/sites/mysite/published'
	println ' Init a site that is in a remote HTTPS repo with username/password authentication'
	println '     init-site -u jdoe -p jdoe1234 mysite https://github.com/jdoe/mysite.git'
	println ' Init a site that is in a remote SSH repo with public/private key authentication (default private key path '
	println ' with no passphrase)'
	println '     init-site mysite ssh://myserver/opt/crater/sites/mysite'
	println ' Init a site that is in a remote SSH repo with public/private key authentication (specific private key path '
	println ' with no passphrase)'
	println '     init-site -k ~/.ssh/jdoe_key mysite ssh://myserver/opt/crater/sites/mysite'
	println ' Init a site that is in a remote SSH repo with public/private key authentication (specific private key path '
	println ' with passphrase)'
	println '     init-site -k ~/.ssh/jdoe_key -f jdoe123 mysite ssh://myserver/opt/crater/sites/mysite'
}

/**
 * Calls the Search API to create the Solr Core.
 */
def createSolrCore(siteName) {
	println 'Creating Solr Core...'

	def httpClient = configure {
		request.uri = getTomcatUrl()
	}

	httpClient.post {
		request.uri.path = '/crafter-search/api/2/admin/index/create'
		request.contentType = 'application/json'
		request.body = [ id: siteName ]
		response.success { fs ->
			println "Core created successfully"
		}
		response.failure { fs, body ->
			println "Error while creating Core: ${body.message}"
		}
	}
}

/**
 * Validate repo path
 */
def validateRepoPath(cli, repoPath) {
	if (!repoPath.matches('^((git|http|https|ssh)://.+)|([a-zA-Z0-9._-]+.+@)$')) {
		Path localPath

		if (repoPath.startsWith('file://')) {
			localPath = Paths.get(StringUtils.substringAfter(repoPath, 'file://'))
		} else {
			localPath = Paths.get(repoPath);
		}

		if (!Files.exists(localPath)) {
			exitWithError(cli, "Repository path ${repoPath} is supposed to be a local filesystem path but it does not exist");
		}
	}
}

/**
 * Calls the Deployer API to create the Deployer Target.
 */
def createDeployerTarget(siteName, repoPath, targetParams) {
	println 'Creating Deployer Target...'

	def httpClient = configure {
		request.uri = getDeployerUrl()
	}

	httpClient.post {
		request.uri.path = '/api/1/target/create'
		request.contentType = 'application/json'
		request.body = targetParams
		response.success { fs ->
			println "Target created successfully"
		}
		response.failure { fs, body ->
			println "Error while creating Target: ${body.message}"
		}
	}
}

/**
 * Initializes the delivery site
 */
def initSite(siteName, repoPath, targetParams) {
	createSolrCore(siteName)
	createDeployerTarget(siteName, repoPath, targetParams)
}

checkDownloadGrapesOnlyMode(getClass())

def cli = new CliBuilder(usage: 'init-site [options] <site> [repo-path]')
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
		def repoPath

		if (extraArguments.size() >= 2) {
			repoPath = extraArguments[1]
		} else {
			repoPath = getDefaultRepoPath(siteName)
		}

		validateRepoPath(cli, repoPath)

		def targetParams = [
			env: 'default',
			site_name: siteName,
			template_name: 'remote',
			repo_url: repoPath,
			repo_branch: 'live',
			engine_url: getTomcatUrl()
		];

		if (options.branch) {
			targetParams.repo_branch = options.branch
		}

		if (options.username) {
			targetParams.repo_username = options.username
			if (options.password) {
				targetParams.repo_password = options.password
			} else {
				exitWithError(cli, 'When specifying the [username] please include a [password] also')
			}
		} else if (repoPath.startsWith('ssh:') || repoPath.matches('[a-zA-Z0-9._-]+@.+')) {
			if (options.'private-key') {
				targetParams.ssh_private_key_path = options.'private-key'
			}
			if (options.passphrase) {
				targetParams.ssh_private_key_passphrase = options.passphrase
			}
		}

		if (options.'notification-addresses') {
			targetParams.notification_addresses = StringUtils.split(options.'notification-addresses', ',')
		}

		initSite(siteName, repoPath, targetParams)
	} else {
		exitWithError(cli, 'Neither <site> nor [repo-path] where specified')
	}
}
