/*
 * Copyright (C) 2007-2023 Crafter Software Corporation. All Rights Reserved.
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
package upgrade.hooks

import java.nio.file.Path
import static groovyx.net.http.HttpBuilder.configure
import static utils.EnvironmentUtils.getDeployerUrl
import upgrade.exceptions.UpgradeException

class ReindexAllTargetsHook implements PostUpgradeHook {

    def getAllTargets() {
        def httpClient = configure {
            request.uri = getDeployerUrl()
        }
        return httpClient.get {
            request.uri.path = '/api/1/target/get-all'
            response.failure { fs, body ->
                throw new UpgradeException("Error while listing targets: ${body.message}")
            }
        }
    }

    void deployAll() {
        def httpClient = configure {
            request.uri = getDeployerUrl()
        }

        def deployAllParams = [
                'reprocess_all_files': true,
                'deployment_mode'    : 'SEARCH_INDEX'
        ]
        httpClient.post {
            request.uri.path = '/api/1/target/deploy-all'
            request.contentType = 'application/json'
            request.body = deployAllParams
            response.success { fs ->
                println "'deploy-all' API triggered successfully"
            }
            response.failure { fs, body ->
                println "Failed to trigger 'deploy-all' API: ${body.message}"
            }
        }
    }

    @Override
    void execute(Path binFolder, Path dataFolder, String environment) {
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        println "Reindex all targets"
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        def targets = getAllTargets()
        if (!targets) {
            println "No target found. Nothing to reindex"
        }

        println "${targets.size()} targets were found. Calling deployer 'deploy-all' API"
        deployAll()
    }

}
