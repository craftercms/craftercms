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

import org.apache.commons.lang3.BooleanUtils
import upgrade.exceptions.UpgradeException
import upgrade.hooks.PostUpgradeHook

import java.nio.file.Files
import java.nio.file.Path

import static groovyx.net.http.HttpBuilder.configure
import static utils.EnvironmentUtils.getDeployerUrl
import static utils.EnvironmentUtils.getTomcatUrl

class RecreateSolrCoresHook implements PostUpgradeHook {

    @Override
    void execute(Path binFolder, Path dataFolder, String environment) {
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        println "Re-creating Solr cores for sites"
        println "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        println "WARNING: This will delete the current Solr site cores, recreate them, and trigger a content "
        println "re-index to re-populate them. This is necessary because of a major Solr upgrade. Don't proceed "
        println "if you can't have any search downtime."

        def cont = System.console().readLine '> Proceed? [(Y)es/(N)o]: '
            cont = BooleanUtils.toBoolean(cont)

        if (cont) {
            Path sitesFolder = dataFolder.resolve("repos/sites")

            if (Files.exists(sitesFolder)) {
                Files.list(sitesFolder).withCloseable { files ->
                    files.each { file ->
                        def siteName = file.fileName.toString()
                        recreateCore(siteName, environment)
                    }
                }
            }
        }
    }

    protected void recreateCore(String siteName, String environment) {
        def oldCoreName = siteName
        def newCoreName = environment == "authoring" ? "${siteName}-preview" : siteName
        def deployerEnv = environment == "authoring" ? 'preview' : 'default'

        deleteCore(oldCoreName)
        createCore(newCoreName)
        reindexContent(siteName, deployerEnv)
    }

    private void deleteCore(String coreName) {
        def httpClient = configure {
            request.uri = getTomcatUrl()
        }

        httpClient.post {
            request.uri.path = "/crafter-search/api/2/admin/index/delete/${coreName}"
            request.contentType = 'application/json'
            response.success { fs ->
                println "Solr core '${coreName}' deleted successfully"
            }
            response.failure { fs, body ->
                throw new UpgradeException("Error while deleting Solr core '${coreName}': ${body.message}")
            }
        }
    }

    private void createCore(String coreName) {
        def httpClient = configure {
            request.uri = getTomcatUrl()
        }

        httpClient.post {
            request.uri.path = "/crafter-search/api/2/admin/index/create"
            request.contentType = 'application/json'
            request.body = [
                    id: coreName
            ]
            response.success { fs ->
                println "Solr core '${coreName}' created successfully"
            }
            response.failure { fs, body ->
                throw new UpgradeException("Error while creating Solr core '${coreName}': ${body.message}")
            }
        }
    }


    private void reindexContent(String siteName, String deployerEnv) {
        def httpClient = configure {
            request.uri = getDeployerUrl()
        }

        httpClient.post {
            request.uri.path = "/api/1/target/deploy/${deployerEnv}/${siteName}"
            request.contentType = 'application/json'
            request.body = [
                    reprocess_all_files: true
            ]
            response.success { fs ->
                println "Re-index succesfully triggered for '${siteName}-${deployerEnv}'"
            }
            response.failure { fs, body ->
                throw new UpgradeException("Error while triggering re-index for '${siteName}-${deployerEnv}': ${body.message}")
            }
        }
    }

}
