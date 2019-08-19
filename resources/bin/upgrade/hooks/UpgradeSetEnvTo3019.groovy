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

import java.nio.file.Path

import static upgrade.utils.UpgradeUtils.*
import static utils.NioUtils.*

class UpgradeSetEnvTo3019 implements UpgradeHook {
    
    private static final String lineSep = System.properties['line.separator']

    void preUpgrade(Path binFolder, Path newBinFolder) {
    }

    void postUpgrade(Path binFolder) {
        upgradeSetEnvSh(binFolder)
        upgradeSetEnvBat(binFolder)
    }

    private void upgradeSetEnvSh(Path binFolder) {
        Path setEnvShFile = binFolder.resolve(SH_SETENV_FILENAME)
        String setEnvShStr = fileToString(setEnvShFile)

        println "Upgrading ${setEnvShFile} to 3.0.19 version..."

        setEnvShStr = setEnvShStr.replace('$CRAFTER_HOME', '$CRAFTER_BIN_DIR')
        setEnvShStr = setEnvShStr.replace('$CRAFTER_ROOT', '$CRAFTER_HOME')
        setEnvShStr = setEnvShStr.replace('$CRAFTER_HOME/data', '$CRAFTER_DATA_DIR')
        setEnvShStr = setEnvShStr.replace('$CRAFTER_HOME/logs', '$CRAFTER_LOGS_DIR')

        setEnvShStr = setEnvShStr.replace('#!/usr/bin/env bash',
                '#!/usr/bin/env bash' + lineSep +
                '' + lineSep +
                '# Locations variables' + lineSep +
                'export CRAFTER_LOGS_DIR=${CRAFTER_LOGS_DIR:="$CRAFTER_HOME/logs"}' + lineSep +
                'export CRAFTER_DATA_DIR=${CRAFTER_DATA_DIR:="$CRAFTER_HOME/data"}')

        setEnvShStr = setEnvShStr.replace('export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out',
                'export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out' + lineSep +
                'export CATALINA_TMPDIR=$CRAFTER_HOME/temp/tomcat')

        setEnvShStr = setEnvShStr.replace('-Dcatalina.logs=$CATALINA_LOGS_DIR',
                '-Dcrafter.home=$CRAFTER_HOME -Dcrafter.bin.dir=$CRAFTER_BIN_DIR ' +
                '-Dcrafter.data.dir=$CRAFTER_DATA_DIR -Dcrafter.logs.dir=$CRAFTER_LOGS_DIR ' +
                '-Dcatalina.logs=$CATALINA_LOGS_DIR -Djava.net.preferIPv4Stack=true')

        setEnvShStr = setEnvShStr.replace('case "$(uname -s)" in',
                '# Git variables' + lineSep +
                'export GIT_CONFIG_NOSYSTEM=true' + lineSep +
                '' + lineSep +
                'case "$(uname -s)" in')

        stringToFile(setEnvShStr, setEnvShFile)
    }

    private void upgradeSetEnvBat(Path binFolder) {
        Path setEnvBatFile = binFolder.resolve(BAT_SETENV_FILENAME)
        String setEnvBatStr = fileToString(setEnvBatFile)

        println "Upgrading ${setEnvBatFile} to 3.0.19 version..."

        // Check if bat is prior to 3.0.18, if it is apply 3.0.18 updates
        if (setEnvBatStr.contains('CRAFTER_BIN_FOLDER')) {
            setEnvBatStr = setEnvBatStr.replaceAll('%CRAFTER_HOME%\\\\?', '%CRAFTER_ROOT%\\\\')
            setEnvBatStr = setEnvBatStr.replaceAll('%CRAFTER_BIN_FOLDER%\\\\?', '%CRAFTER_HOME%')
        }

        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_HOME%', '%CRAFTER_BIN_DIR%\\')
        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_ROOT%', '%CRAFTER_HOME%')

        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_HOME%\\logs', '%CRAFTER_LOGS_DIR%')
        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_HOME%\\data', '%CRAFTER_DATA_DIR%')

        setEnvBatStr =
                'REM Locations variables' + lineSep +
                'IF NOT DEFINED CRAFTER_LOGS_DIR SET "CRAFTER_LOGS_DIR=%CRAFTER_HOME%\\logs"' + lineSep +
                'IF NOT DEFINED CRAFTER_DATA_DIR SET "CRAFTER_DATA_DIR=%CRAFTER_HOME%\\data"' + lineSep +
                '' + lineSep + setEnvBatStr

        setEnvBatStr = setEnvBatStr.replace('SET "CATALINA_OUT=%CATALINA_LOGS_DIR%catalina.out"',
                'SET "CATALINA_OUT=%CATALINA_LOGS_DIR%\\catalina.out"' + lineSep +
                'SET "CATALINA_TMPDIR=%CRAFTER_HOME%\\temp\\tomcat"')

        setEnvBatStr = setEnvBatStr.replace('-Dcatalina.logs="%CATALINA_LOGS_DIR%"',
                '-Dcrafter.home="%CRAFTER_HOME%" -Dcrafter.bin.dir="%CRAFTER_BIN_DIR%" ' +
                '-Dcrafter.data.dir="%CRAFTER_DATA_DIR%" -Dcrafter.logs.dir="%CRAFTER_LOGS_DIR%" ' +
                '-Dcatalina.logs="%CATALINA_LOGS_DIR%" -Djava.net.preferIPv4Stack=true')

        setEnvBatStr += '\r\nSET GIT_CONFIG_NOSYSTEM=true'

        stringToFile(setEnvBatStr, setEnvBatFile)
    }

}
