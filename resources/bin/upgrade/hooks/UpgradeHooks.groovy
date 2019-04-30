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

class UpgradeHooks {

    private static final def ALL_HOOKS = [
    ]

    private def binFolder
    private def newBinFolder
    private def previousVersion
    private def upgradeVersion
    private def hooks = []

    UpgradeHooks(binFolder, newBinFolder, previousVersion, upgradeVersion) {
        this.binFolder = binFolder
        this.newBinFolder = newBinFolder
        this.previousVersion = previousVersion
        this.upgradeVersion = upgradeVersion

        resolveHooks()
    }

	def preUpgrade() {
		hooks.each { hook ->
			hook.preUpgrade(binFolder, newBinFolder)
		}
	}

	def postUpgrade() {
        hooks.each { hook ->
            hook.postUpgrade(binFolder)
        }
    }

    private def resolveHooks() {
        def currentVersion = previousVersion
        def allHooksKeys = ALL_HOOKS.keySet().iterator()

        while (allHooksKeys.hasNext() && currentVersion != upgradeVersion) {
            currentVersion = allHooksKeys.next()

            hooks += ALL_HOOKS[currentVersion]
        }
    }

}
