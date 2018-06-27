package utils

import java.nio.file.Paths

@Grab(group='commons-io', module='commons-io', version='2.6')
import org.apache.commons.io.FilenameUtils

class EnvironmentUtils {

	/**
	 * Returns the value of an environment variable.
	 */
	static def getEnv(varName) {
		def env = System.getenv()

		return env[varName]
	}

	/**
	 * Returns the URL of the Tomcat.
	 */
	static def getTomcatUrl() {
		def port = getEnv('TOMCAT_HTTP_PORT')
		def url = "http://localhost:${port}"

		return url;
	}

	/**
	 * Returns the URL of the Deployer.
	 */
	static def getDeployerUrl() {
		def port = getEnv('DEPLOYER_PORT')
		def url = "http://localhost:${port}"

		return url;
	}

	/**
	 * Returns the root folder for the Crafter installation.
	 */
	static def getCrafterRootFolder() {
		return Paths.get(FilenameUtils.normalize(getEnv("CRAFTER_ROOT")))
	}

	/**
	 * Returns the bin folder for the Crafter installation.
	 */
	static def getCrafterBinFolder() {
		return getCrafterRootFolder().resolve("bin")
	}

	/**
	 * Returns the data folder for the Crafter installation.
	 */
	static def getCrafterDataFolder() {
		return getCrafterRootFolder().resolve("data")
	}

	/**
	 * Returns the backups folder for the Crafter installation.
	 */
	static def getCrafterBackupsFolder() {
		return getCrafterRootFolder().resolve("backups")
	}

	/**
	 * Returns the tmp folder used for the upgrade
	 */
	static def getUpgradeTmpFolder() {
		return Paths.get(FilenameUtils.normalize(getEnv("UPGRADE_TMP_DIR")))
	}

	/**
	 * Return true if the script should run in download grapes only mode.
	 */
	static def isDownloadGrapesOnlyMode() {
		def downloadGrapesOnly = System.getProperty("mode.downloadGrapesOnly")
		if (downloadGrapesOnly) {
			return Boolean.parseBoolean(downloadGrapesOnly)
		} else {
			return false
		}
	}

}
