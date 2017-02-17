# Crafter CMS
Parent project that builds everything.
## Prerequisites

* Java 8
* Git 2.0.
* Maven 3.3.x.

## Step 0
1. Clone this repo.

```bash
        git clone --recursive  https://github.com/cortiz/crafter-installer-gem.git
```

or

```bash
    git clone https://github.com/cortiz/crafter-installer-gem.git
    cd crafter-installer-gem
    git submodule init
```
*[See more information git usage here]#Git*

## Gradle Usage
Linux/OSX
```bash
./gradlew TASK -DProperty -DProperty2
```
Windows
```bat
gradlew.bat TASK -DProperty -DProperty2
```
### GUI
```bash
./gradlew --gui -DProperty -DProperty2
```
Windows
```bat
gradlew.bat --gui -DProperty -DProperty2
```

### Build and Developer Environment
```bash
    ./gradlew buildEnv
    cd .. crafter-env
    ./startup.sh | startup.bat
```

### Tasks
#### Common task properties.
* tomcatVersion: Sets the tomcat version to be download used by *downloadTomat* task
* solrVersion: Sets the Solr version to be download used by *downloadSolr* task.
* downloadDir: Path were all downloads will be save.used by *downloadTomat* and *downloadSolr*. Default value is *./target/dowloads*
* devEnv: Path were a development environment will be generated. Default value is *./crafter-env/*
* includeProfile: Includes profile in the generation of the development environment. Default value is false. ** If true,mongodb is require**
* includeSocial: Includes Social in the generation of the development environment. Default value is false, ** If true, *includeProfile* will be set to true**

#### build
Builds all the projects
```bash
./gradlew build
```
#### build+ProjectName
Builds the given project possible values are:
* commons
* core
* search
* profile
* social
* studio
* deployer
* engine

Example:
```bash
./gradlew buildStudio
```

#### clean
Cleans all projects build results
```bash
gradlew.bat clean
```
#### clean+ProjectName
Clean the build results of the given project possible values are:
* Commons
* Core
* Search
* Profile
* Social
* Studio
* Deployer
* Engine

Example:
```bat
gradlew.bat cleanCore
```

#### downloadSolr
Downloads the given configure Solr version also verifies that the war file is ok agains a sha1 signature.
```bat
gradlew.bat downloadSolr
```

#### dowloadTomcat
Downloads the given configure Tomcat version also verifies that the zip file is ok agains a sha1 signature.
```bash
./gradlew downloadTomcat
```

#### buildEnv
Builds a **Clean** (Delete all the contents of *devEnv* defaults to crafter-env folder) development environment for Studio, uses the build results of *build*,*downloadSolr* and *downloadTomcat*
uses the *devEnv* property as the output of the it.
Note:
This task will delete the *devEnv* folder.
```bat
gradlew.bat buildEnv
```

#### pack
Packages the *devEnv* in a zip and tar files to be distribute.

## Git

### Update submodules
1. Run

```bash
git submodule update --force --recursive --remote
```

### Change Project URL to a fork

1. Change the url on the _.gitmodules_ file
2. Run
```bash
git submodule sync --recursive
```

### Change the branch/tag of a project (manual way)

1. Change the `branch` value in the desire project to valid branch,tag or commit id
2. Run
```bash
git submodule sync --recursive
```
3  [Run Update submodules]#updateSubmodules
