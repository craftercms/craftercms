package upgrade.hooks

import java.nio.file.Path

import static upgrade.utils.UpgradeUtils.*
import static utils.NioUtils.*

class UpgradeSetEnvTo3019 implements UpgradeHook {

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

        setEnvShStr = setEnvShStr.replace('$CRAFTER_ROOT/data', '$CRAFTER_DATA_DIR')
        setEnvShStr = setEnvShStr.replace('$CRAFTER_ROOT/logs', '$CRAFTER_LOGS_DIR')

        setEnvShStr = setEnvShStr.replace('#!/usr/bin/env bash',
                '#!/usr/bin/env bash\n' +
                '\n' +
                '# Locations variables\n' +
                'export CRAFTER_LOGS_DIR=${CRAFTER_LOGS_DIR:="$CRAFTER_ROOT/logs"}\n' +
                'export CRAFTER_DATA_DIR=${CRAFTER_DATA_DIR:="$CRAFTER_ROOT/data"}')

        setEnvShStr = setEnvShStr.replace('export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out',
                'export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out\n' +
                'export CATALINA_TMPDIR=$CRAFTER_ROOT/temp/tomcat')

        setEnvShStr = setEnvShStr.replace('-Dcatalina.logs=$CATALINA_LOGS_DIR',
                '-Dcrafter.root=$CRAFTER_ROOT -Dcrafter.home=$CRAFTER_HOME ' +
                '-Dcrafter.data.dir=$CRAFTER_DATA_DIR -Dcrafter.logs.dir=$CRAFTER_LOGS_DIR ' +
                '-Dcatalina.logs=$CATALINA_LOGS_DIR -Djava.net.preferIPv4Stack=true')

        setEnvShStr = setEnvShStr.replace('case "$(uname -s)" in',
                '# Git variables\n' +
                'export GIT_CONFIG_NOSYSTEM=true\n' +
                '\n' +
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

        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_HOME%', '%CRAFTER_HOME%\\')

        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_ROOT%\\logs', '%CRAFTER_LOGS_DIR%')
        setEnvBatStr = setEnvBatStr.replace('%CRAFTER_ROOT%\\data', '%CRAFTER_DATA_DIR%')

        setEnvBatStr =
                'REM Locations variables\r\n' +
                'IF NOT DEFINED CRAFTER_LOGS_DIR SET CRAFTER_LOGS_DIR="%CRAFTER_ROOT%\\logs"\r\n' +
                'IF NOT DEFINED CRAFTER_DATA_DIR SET CRAFTER_DATA_DIR="%CRAFTER_ROOT%\\data"\r\n' +
                '\r\n' + setEnvBatStr

        setEnvBatStr = setEnvBatStr.replace('SET "CATALINA_OUT=%CATALINA_LOGS_DIR%catalina.out"',
                'SET "CATALINA_OUT=%CATALINA_LOGS_DIR%\\catalina.out"\r\n' +
                'SET "CATALINA_TMPDIR=%CRAFTER_ROOT%\\temp\\tomcat"')

        setEnvBatStr = setEnvBatStr.replace('-Dcatalina.logs="%CATALINA_LOGS_DIR%"',
                '-Dcrafter.root="%CRAFTER_ROOT%" -Dcrafter.home="%CRAFTER_HOME%" ' +
                '-Dcrafter.data.dir="%CRAFTER_DATA_DIR%" -Dcrafter.logs.dir="%CRAFTER_LOGS_DIR%" ' +
                '-Dcatalina.logs="%CATALINA_LOGS_DIR%" -Djava.net.preferIPv4Stack=true')

        setEnvBatStr += '\r\nSET GIT_CONFIG_NOSYSTEM=true'

        // Fix bugs
        setEnvBatStr = setEnvBatStr.replace('SET "DEPLOYER_HOME=%CRAFTER_HOME%\\crafter-deployer"',
                'SET "DEPLOYER_HOME=%CRAFTER_ROOT%\\crafter-deployer"')

        stringToFile(setEnvBatStr, setEnvBatFile)
    }

}
