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

import upgrade.exceptions.UpgradeException
import upgrade.hooks.PostUpgradeHook

import java.nio.file.Files
import java.nio.file.Path

import static groovyx.net.http.HttpBuilder.configure
import static utils.EnvironmentUtils.getDeployerUrl

class CreateAuthoringTargetsHook implements PostUpgradeHook {

    @Override
    void execute(Path binFolder, Path dataFolder, String environment) {
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        println "Creating Authoring Deployer Targets"
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        Path sitesFolder = dataFolder.resolve("repos/sites")

        if (Files.exists(sitesFolder)) {
            Files.list(sitesFolder).withCloseable { files ->
                files.each { file -> createAuthoringTargetForSite(file) }
            }
        }
    }

    private void createAuthoringTargetForSite(Path siteFolder) {
        def siteName = siteFolder.fileName.toString()
        def sandboxFolder = siteFolder.resolve("sandbox").toAbsolutePath()

        def httpClient = configure {
            request.uri = getDeployerUrl()
        }

        httpClient.post {
            request.uri.path = '/api/1/target/create_if_not_exists'
            request.contentType = 'application/json'
            request.body = [
                    env: 'authoring',
                    site_name: siteName,
                    template_name: 'authoring',
                    repo_url: sandboxFolder.toString()
            ]
            response.success { fs ->
                println "Authoring target for site '${siteName}' created successfully"
            }
            response.failure { fs, body ->
                throw new UpgradeException("Error while creating target for site '${siteName}': ${body.message}")
            }
        }
    }

}
