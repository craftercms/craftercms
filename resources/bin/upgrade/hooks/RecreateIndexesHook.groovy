/*
 * Copyright (C) 2007-2021 Crafter Software Corporation. All Rights Reserved.
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

import org.apache.commons.lang3.BooleanUtils
import upgrade.exceptions.UpgradeException
import upgrade.hooks.PostUpgradeHook

import java.nio.file.Path

import static groovyx.net.http.HttpBuilder.configure
import static utils.EnvironmentUtils.getDeployerUrl
import static utils.EnvironmentUtils.getEnv

class RecreateIndexesHook implements PostUpgradeHook {

    @Override
    void execute(Path binFolder, Path dataFolder, String environment) {
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        println "Re-creating Elasticsearch indexes for sites"
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        println "WARNING: This will delete the current Elasticsearch site indexes and recreate them."
        println "This is necessary because of a major Elasticsearch upgrade. Don't proceed "
        println "if you can't have any search downtime."

        def cont = System.console().readLine '> Proceed? [(Y)es/(N)o]: '
        cont = BooleanUtils.toBoolean(cont)

        if (cont) {
            def targets = getAllTargets()
            targets.each { target ->
                recreateIndex(target.site_name, target.env)
            }
        }
    }

    protected def getAllTargets() {
        def httpClient = configure {
            request.uri = getDeployerUrl()
        }

        return httpClient.get {
            request.uri.path = "/api/1/target/get-all"
            request.contentType = 'application/json'
            response.failure { fs, body ->
                throw new UpgradeException("Error while listing targets: ${body.message}")
            }
        }
    }

    protected void recreateIndex(String siteName, String environment) {
        def httpClient = configure {
            request.uri = getDeployerUrl()
        }

        httpClient.post {
            request.uri.path = "/api/1/target/recreate/${environment}/${siteName}"
            request.uri.query = [
                token: getEnv("DEPLOYER_MANAGEMENT_TOKEN")
            ]
            request.contentType = 'application/json'
            response.success { fs ->
                println "Re-index succesfully triggered for '${siteName}-${environment}'"
            }
            response.failure { fs, body ->
                throw new UpgradeException("Error while triggering re-index for '${siteName}-${environment}': ${body.message}")
            }
        }
    }

}
