package utils

import java.nio.file.Paths

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
   * Returns the environment name (either authoring or delivery).
   */
  static def getEnvironmentName() {
    return getEnv("ENVIRONMENT_NAME")
  }

  /**
   * Returns the root folder for the Crafter installation.
   */
  static def getCrafterRootFolder() {
    return Paths.get(getEnv("CRAFTER_ROOT"))
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
   * Returns the upgrade folder inside the bin.
   */
  static def getUpgradeBinFolder() {
    return Paths.get(getEnv("UPGRADE_HOME"))
  }

  /**
   * Returns the tmp folder used for the upgrade
   */
  static def getUpgradeTmpFolder() {
    return Paths.get(getEnv("UPGRADE_TMP_DIR"))
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
