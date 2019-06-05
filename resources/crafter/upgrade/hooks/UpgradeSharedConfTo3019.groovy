/*
 * Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package upgrade.hooks

import java.nio.file.Files
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
        if (Files.exists(studioConfigOverride)) {
            def studioConfigOverrideStr = fileToString(studioConfigOverride)

            println "Upgrading ${studioConfigOverride} to 3.0.19 version..."

            studioConfigOverrideStr = studioConfigOverrideStr.replace('../data', '${sys:crafter.data.dir}')

            stringToFile(studioConfigOverrideStr, studioConfigOverride)
        }
    }

}
