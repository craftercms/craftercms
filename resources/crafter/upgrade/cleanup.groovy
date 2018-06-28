import utils.NioUtils

import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

checkDownloadGrapesOnlyMode(getClass())

NioUtils.deleteDirectory(getUpgradeTmpFolder())
