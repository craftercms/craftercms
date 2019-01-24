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
