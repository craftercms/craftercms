package upgrade.hooks


import static upgrade.utils.UpgradeUtils.*

class UpgradeHooks {

    private static final def ALL_HOOKS = [
            '3.0.19' : [
                    new UpgradeSetEnvTo3019(),
                    new UpgradeSharedConfTo3019(),
                    new CopyCatalinaPolicyHook()
            ]
    ]

    private def binFolder
    private def newBinFolder
    private def previousVersion
    private def upgradeVersion
    private def hooks = []

    UpgradeHooks(binFolder, newBinFolder) {
        this.binFolder = binFolder
        this.newBinFolder = newBinFolder
        this.previousVersion = readVersionFile(binFolder)
        this.upgradeVersion = readVersionFile(newBinFolder)

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
