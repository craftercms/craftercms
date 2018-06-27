package utils

@Grab(group='commons-io', module='commons-io', version='2.6')
import org.apache.commons.io.FilenameUtils

import static utils.EnvironmentUtils.*

class ScriptUtils {

	/**
	 * Returns the filename of the current script
	 */
	static def getScriptName(scriptClass) {
		return FilenameUtils.getName(scriptClass.protectionDomain.codeSource.location.path)
	}

	/**
	 * Checks if the current script is currently in download grapes only mode. If it is, it prints a message and exits.
	 */
	static def checkDownloadGrapesOnlyMode(scriptClass) {
		if (isDownloadGrapesOnlyMode()) {
			println "Downloading grapes for ${getScriptName(scriptClass)}..."

			System.exit(0)
		}
	}

}
