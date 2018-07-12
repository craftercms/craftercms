import utils.NioUtils

import static utils.EnvironmentUtils.*
import static utils.ScriptUtils.*

checkDownloadGrapesOnlyMode(getClass())

println "============================================================"
println "Deleting temp upgrade folder"
println "============================================================"

NioUtils.deleteDirectory(getUpgradeTmpFolder())
