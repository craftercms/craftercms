/*
 * Copyright (C) 2007-2024 Crafter Software Corporation. All Rights Reserved.
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

@Grapes(
    @Grab(group='com.vdurmont', module='semver4j', version='3.1.0')
)

import java.nio.file.Path
import com.vdurmont.semver4j.Semver
import upgrade.exceptions.UpgradeException

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

    private static final List<PostUpgradeHooks> AUTHORING_4_0_X = [
            new RemoveOldSearchIndexesDirHook(),
            new StartCrafterHook(),
            new ReindexAllTargetsHook(),
            new PostUpgradeCompletedHook(true)
    ]

    private static final List<PostUpgradeHooks> DELIVERY_4_0_X = AUTHORING_4_0_X

    private static final List<PostUpgradeHooks> AUTHORING_4_1_x = [
            new PostUpgradeCompletedHook(false)
    ]

    private static final List<PostUpgradeHooks> DELIVERY_4_1_x = AUTHORING_4_1_x

    private static final Map ALL_HOOKS = [
            'authoring': [
                    '>=4.1.0': AUTHORING_4_1_x,
                    '4.0': AUTHORING_4_0_X,
                    '3.1.9' : AUTHORING_3_1_X_WITH_DB_HOOKS,
                    '3.1.12': AUTHORING_3_1_X_WITH_DB_HOOKS,
                    '3.1.13': AUTHORING_3_1_X_WITH_DB_HOOKS,
                    '3.1 >=3.1.17': AUTHORING_3_1_X_NO_DB_HOOKS
                    ],
            'delivery': [
                    '>=4.1.0': DELIVERY_4_1_x,
                    '4.0': DELIVERY_4_0_X,
                    '3.1.9' : DELIVERY_3_1_X_HOOKS,
                    '3.1.12': DELIVERY_3_1_X_HOOKS,
                    '3.1.13': DELIVERY_3_1_X_HOOKS,
                    '3.1 >=3.1.17': DELIVERY_3_1_X_HOOKS
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

        hooks = resolveHooks()
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

    private List<PostUpgradeHook> resolveHooks() {
        def envHooks = ALL_HOOKS[environment]
        // NPM mode to support ranges
        // withClearedSuffixAndBuild() because only major.minor.patch can be properly compared
        var semverOldVersion = new Semver(oldVersion, Semver.SemverType.NPM).withClearedSuffixAndBuild();
        var hooksEntry = envHooks?.find { version, versionHooks ->
            semverOldVersion.satisfies(version)
        }
        if (hooksEntry) {
            println "Found hooks match for version ${hooksEntry.key}"
            return hooksEntry.value
        }

        throw new UpgradeException("Upgrade path not supported from ${oldVersion} to ${newVersion}")
    }

}
