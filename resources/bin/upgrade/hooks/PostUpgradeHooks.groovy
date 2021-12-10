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
package upgrade.hooks

import java.nio.file.Path

class PostUpgradeHooks {

    private static final List<PostUpgradeHooks> AUTHORING_3_1_X_NO_DB_HOOKS = [
            new StartCrafterHook(),
            new RecreateIndexesHook(),
            new PostUpgradeCompletedHook(true)
    ]

    private static final List<PostUpgradeHooks> AUTHORING_3_1_X_WITH_DB_HOOKS = [
            new UpgradeEmbeddedDbHook(),
            new StartCrafterHook(),
            new RecreateIndexesHook(),
            new PostUpgradeCompletedHook(true)
    ]

    private static final List<PostUpgradeHooks> DELIVERY_3_1_X_HOOKS = [
            new StartCrafterHook(),
            new RecreateIndexesHook(),
            new PostUpgradeCompletedHook(true)
    ]

    private static final Map<String, List<PostUpgradeHook>> ALL_HOOKS = [

            'authoring 3.1.9' : AUTHORING_3_1_X_WITH_DB_HOOKS,
            'authoring 3.1.12': AUTHORING_3_1_X_WITH_DB_HOOKS,
            'authoring 3.1.13': AUTHORING_3_1_X_WITH_DB_HOOKS,
            'authoring 3.1.17': AUTHORING_3_1_X_NO_DB_HOOKS,
            'authoring 3.1.18': AUTHORING_3_1_X_NO_DB_HOOKS,

            'delivery 3.1.9' : DELIVERY_3_1_X_HOOKS,
            'delivery 3.1.12': DELIVERY_3_1_X_HOOKS,
            'delivery 3.1.13': DELIVERY_3_1_X_HOOKS,
            'delivery 3.1.17': DELIVERY_3_1_X_HOOKS,
            'delivery 3.1.18': DELIVERY_3_1_X_HOOKS,

            '*': [
                    new PostUpgradeCompletedHook(false)
            ]
    ]

    private Path binFolder
    private Path dataFolder
    private String oldVersion
    private String newVersion
    private String environment

    private List<PostUpgradeHook> hooks = []

    PostUpgradeHooks(Path binFolder, Path dataFolder, String oldVersion, String newVersion, String environment) {
        this.binFolder = binFolder
        this.dataFolder = dataFolder
        this.oldVersion = oldVersion
        this.newVersion = newVersion
        this.environment = environment

        resolveHooks()
    }

    def execute() {
        if (hooks) {
            hooks.each { hook ->
                hook.execute(binFolder, dataFolder, environment)
            }
        } else {
            println "No post upgrades to execute after upgrade from ${oldVersion} -> ${newVersion}"
        }
    }

    private def resolveHooks() {
        hooks = ALL_HOOKS["${environment} ${oldVersion} -> ${newVersion}".toString()]
        if (!hooks) {
            hooks = ALL_HOOKS["${environment} ${oldVersion}".toString()]
            if (!hooks) {
                hooks = ALL_HOOKS["${oldVersion}".toString()]
                if (!hooks) {
                    hooks = ALL_HOOKS['*']
                }
            }
        }
    }

}
