import java.nio.file.Files
import java.nio.file.Path

import utils.NioUtils

import static utils.EnvironmentUtils.*

def binFolder = getCrafterBinFolder()
def tmpFolder = getUpgradeTmpFolder()

if (Files.exists(tmpFolder)) {
	NioUtils.deleteDirectory(tmpFolder)
}

NioUtils.copyDirectory(binFolder.resolve("upgrade"), tmpFolder)
NioUtils.copyDirectory(binFolder.resolve("groovy"), tmpFolder.resolve("groovy"))
NioUtils.copyDirectory(binFolder.resolve("grapes"), tmpFolder.resolve("grapes"))
NioUtils.copyDirectory(binFolder.resolve("utils"), tmpFolder.resolve("utils"))
