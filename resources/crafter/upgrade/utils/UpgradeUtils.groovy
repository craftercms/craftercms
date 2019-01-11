package upgrade.utils

@Grapes([
        @Grab(group = 'org.apache.commons', module = 'commons-lang3', version = '3.7'),
])

import org.apache.commons.lang3.StringUtils

import utils.NioUtils

import java.nio.file.Files
import java.nio.file.Path

class UpgradeUtils {

    public static final def VERSION_FILENAME = 'version.txt'
    public static final def SH_SETENV_FILENAME = 'crafter-setenv.sh'
    public static final def BAT_SETENV_FILENAME = 'crafter-setenv.bat'

    /**
     * Reads the version file under the specified bin folder.
     */
    static String readVersionFile(Path binFolder) {
        def versionFile = binFolder.resolve(VERSION_FILENAME)
        if (Files.exists(versionFile)) {
            def version = NioUtils.fileToString(versionFile)
                version = version.trim()
                // Remove any unnecessary suffixes
                version = StringUtils.substringBefore(version, '-')
                version = StringUtils.substringBefore(version, 'E')

            return version
        } else {
            return ''
        }
    }

}
