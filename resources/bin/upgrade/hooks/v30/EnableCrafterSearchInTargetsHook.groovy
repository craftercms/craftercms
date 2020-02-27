/*
 * Copyright (C) 2007-2020 Crafter Software Corporation. All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package upgrade.hooks.v30

import org.apache.commons.configuration2.YAMLConfiguration
import upgrade.hooks.AbstractTargetConfigUpdatingHook

import java.nio.file.Path

class EnableCrafterSearchInTargetsHook extends AbstractTargetConfigUpdatingHook {

    @Override
    void execute(Path binFolder, Path dataFolder, String environment) {
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        println "Enabling Crafter Search in Deployer Targets"
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        super.execute(binFolder, dataFolder, environment)
    }

    @Override
    protected shouldBeUpdated(Path configFile) {
        def filename = configFile.fileName.toString()

        return filename.endsWith("-preview.yaml") || filename.endsWith("-default.yaml")
    }

    @Override
    protected void doTargetConfigUpdate(YAMLConfiguration config) {
        config.setProperty("target.crafterSearchEnabled", true)
    }

}
