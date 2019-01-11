package upgrade.hooks

import java.nio.file.Path

interface UpgradeHook {

	void preUpgrade(Path binFolder, Path newBinFolder)

	void postUpgrade(Path binFolder)

}
