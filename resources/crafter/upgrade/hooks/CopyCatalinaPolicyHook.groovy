package upgrade.hooks

import java.nio.file.Files
import java.nio.file.Path

import static java.nio.file.StandardCopyOption.REPLACE_EXISTING

class CopyCatalinaPolicyHook implements UpgradeHook {

    private Path catalinaPolicy
    private Path newCatalinaPolicy
    private Path tmpCatalinaPolicy

    void preUpgrade(Path binFolder, Path newBinFolder) {
        catalinaPolicy = binFolder.resolve("apache-tomcat/conf/catalina.policy")
        newCatalinaPolicy = newBinFolder.resolve("apache-tomcat/conf/catalina.policy")
        tmpCatalinaPolicy = Files.createTempFile("catalina", ".policy")

        Files.move(newCatalinaPolicy, tmpCatalinaPolicy, REPLACE_EXISTING)
    }

    void postUpgrade(Path binFolder) {
        println "Copying new catalina.policy to ${catalinaPolicy}..."

        Files.move(tmpCatalinaPolicy, catalinaPolicy, REPLACE_EXISTING)
    }

}
