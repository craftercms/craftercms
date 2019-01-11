package upgrade.hooks

import java.nio.file.Path

import static utils.NioUtils.*

class UpgradeSharedConfTo3019 implements UpgradeHook {

    void preUpgrade(Path binFolder, Path newBinFolder) {
    }

    void postUpgrade(Path binFolder) {
        def crafterSharedClassesFolder = binFolder.resolve('apache-tomcat/shared/classes/crafter')

        upgradeEngineServerConfig(crafterSharedClassesFolder)
        upgradeStudioConfigOverride(crafterSharedClassesFolder)
    }

    void upgradeEngineServerConfig(Path crafterSharedClassesFolder) {
        def engineServerConfig = crafterSharedClassesFolder.resolve('engine/extension/server-config.properties')
        def enginServerConfigStr = fileToString(engineServerConfig)

        println "Upgrading ${engineServerConfig} to 3.0.19 version..."

        enginServerConfigStr = enginServerConfigStr.replace('../data', '${crafter.data.dir}')

        stringToFile(enginServerConfigStr, engineServerConfig)
    }

    void upgradeStudioConfigOverride(Path crafterSharedClassesFolder) {
        def studioConfigOverride = crafterSharedClassesFolder.resolve('studio/extension/studio-config-override.yaml')
        def studioConfigOverrideStr = fileToString(studioConfigOverride)

        println "Upgrading ${studioConfigOverride} to 3.0.19 version..."

        studioConfigOverrideStr = studioConfigOverrideStr.replace('../data', '${sys:crafter.data.dir}')

        stringToFile(studioConfigOverrideStr, studioConfigOverride)
    }

}
