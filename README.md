# Crafter CMS

Crafter CMS is an open source content management system for Web sites, mobile apps, VR and more. You can learn more about Crafter here: http://docs.craftercms.org/en/latest/index.html

This repository is the parent project that builds everything and helps you build one of two things:
1. Deployable Crafter CMS bundle, or
2. Developer's environment so you can compile and contribute to Crafter CMS

#1. Initial Setup
You must have these prerequisites on your system before you begin:
* Java 8
* Git 2.x+
* Maven 3.3.x+

Let's begin :)

```bash
git clone --recursive  https://github.com/craftercms/craftercms.git
```

** Note the `--recursive` required to clone all the git submodules. If you missed `--recursive`, just run `git submodule init` to fix that.

#2. Build a Deployable Bundle
To build a deployable and distributable bundle of Crafter CMS, use the Gradle task `bundle`. This task will generate `.zip` and `.tar.gz` files ready to be deployed to any system.

Archives will named `crafter-cms.tar.gz` and `crafter-cms.zip` and can be found in the `bundles` folder. [Check the Gradle Tasks section for more details.](#4-gradle-tasks)

```bash
./grablew bundle
```

To run Crafter CMS from the bundle, unzip and follow the instructions in the bundle's `README.txt`.

##2.1. Build an Environment Specific Bundle
Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

To build a bundle for a specific environment:

```bash
    ./gradlew bundle -Denv=authoring
```
Archives will named `crafter-cms-authoring.tar.gz` and `crafter-cms-authoring.zip` and can be found in the `bundles` folder.

For the `delivery` environment, simply substitute the `env=authoring` with `env=delivery`.

#3. Build a Developer's Environment
Crafter CMS is built along a microservices architecture, and as such, comprises a number of head-less, RESTful, modules that work together to provide the final solution. In this section, we'll start with the simple case of _build everything_/_run everything_, and then move on to building/hacking individual modules.

##3.1. Build, Start and Stop All 
###3.1.1. Build All
Build all Crafter CMS modules, run

```bash
    ./gradlew build
```

###3.1.2. Start All
Start Crafter CMS,
 
 ```bash
    ./gradlew start
```

You can now point your browser to [http://localhost:8080/studio](http://localhost:8080/studio) and start using Crafter CMS. To get started with your first Crafter CMS experience, you can follow this guide: [http://docs.craftercms.org/en/latest/content-authors/index.html](http://docs.craftercms.org/en/latest/content-authors/index.html).

###3.1.3. Stop All
Stop Crafter CMS,

```bash
    ./gradlew stop
```

##3.2. Two Environments: Authoring vs Delivery
You might have noticed that you essentially have two environments built and running: `authoring` and `delivery`. Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

As a developer, you can an `authoring` environment only for most tasks without the need to run a `delivery` environment. It's important to note that `delivery` essentially runs the same software that's in `authoring` except Crafter Studio (the authoring tools).

By default, this project will build both environments unless instructed otherwise.

###3.1.1. Build, Start, and Stop a Specific Environment
Much like building/starting/stopping All, to perform the same for one of the two environments.

#### Authoring
```bash
    ./gradlew build -Denv=authoring
    ./gradlew start -Denv=authoring
    ./gradlew stop -Denv=authoring
```

#### Delivery
```bash
    ./gradlew build -Denv=delivery
        ./gradlew start -Denv=delivery
        ./gradlew stop -Denv=delivery
```

##3.3. Crafter Modules
The mechanics for working with a single module are similar to working with _all_, with one exception: You can deploy a module to one or both environments (`authoring`/`delivery`).

Crafter CMS comprises the modules:
* [`core`](http://docs.craftercms.org/en/latest/developers/projects/core/index.html)
* [`commons`](http://docs.craftercms.org/en/latest/developers/projects/commons/index.html)
* [`engine`](http://docs.craftercms.org/en/latest/developers/projects/engine/index.html)
* [`studio`](http://docs.craftercms.org/en/latest/developers/projects/studio/index.html)
* [`search`](http://docs.craftercms.org/en/latest/developers/projects/search/index.html)
* [`profile`](http://docs.craftercms.org/en/latest/developers/projects/profile/index.html)
* [`social`](http://docs.craftercms.org/en/latest/developers/projects/social/index.html)
* [`deployer`](http://docs.craftercms.org/en/latest/developers/projects/deployer/index.html)

You'll find these projects checked out and ready for you to contribute to in the folder `src/{moduleName}`.

###3.3.1. Forking a Module
Start by forking the module you want to work on. You can follow the [GitHub instructions](https://help.github.com/articles/fork-a-repo/).
The next step is to switch the upstream repository from the main `craftercms` repo to your own. To make this happen, edit the file `.gitmodules` and change the module's URL to point to your fork. Now, let's force an update:

```bash
    git submodule sync --recursive
```

You can now work in on your local system, and build/deploy and ultimately push to your fork. We welcome code contributions, so please do send us pull-requests.

###3.3.2. Build, Deploy, Start, and Stop a Module
You can build, deploy, start or stop a module by:

```bash
    ./gradlew build -DmoduleName=studio
    ./gradlew deploy -DmoduleName=studio -Denv=authoring
```

Note: If you don't specify the `env` parameter, it means all environments (where applicable).

---




2 Create a Development Environment
======

The following steps will guide you on the creation of an authoring of Crafter CMS.

### 2.1 Building a Crafter CMS Authoring environment 

*_An Authoring environment is where an Author can safely create and manage content without impacting the end-user's live system_*.

Once all he sources had been download you can run
```bash
    ./gradlew authEnv
```
The Gradle task above will:

1. Delete any existing _Authoring environment_ in `crafter-auth-env` folder. *It will always make a clean Authoring environment*

2. Download Apache Tomcat and Solr. (Check the Gradle section on how to specified a version of Apache Tomcat an Solr)

3. Build all Crafter CMS modules from the source (check the Git section on how to update the source).

4. Create a folder name `crafter-auth-env` and copy all needed resources for a *clean* and functional Authoring environment.


### 2.2 Run

To run the _Authoring environment_ you can:
* Run the gradle task 

```bash
./gradlew runAuth
```
or
 
* Run it manually 

```bash
cd crafter-auth-env
./startup.sh
```

Both of those options will:

* Start Apache tomcat on default ports (8080,8009,8005) [See Gradle task on how to change default ports](#gradle-tasks)

* Start Solr server on port 8984

* Start Crafter Deployer on port 

### 2.2.1 Authoring Environment Scripts

The Crafter CMS Authoring scripts will help you on the basic startup shutdown of the services needed to run a healthy _Authoring environment_
with

#### crafter(.sh/bat)

Main Script to start,and stop all needed Services to have a functional Crafter CMS _Authoring Environment_

##### Synopsis

`crafter.(sh/bat) start|stop|debug|tail|help`

##### Arguments

* _start_ Starts all Crafter CMS services in this order Crafter Deployer,Solr,Apache Tomcat

* _stop_ Stops all Crafter CMS services in the same order as they start.

* _debug_ Start all Crafter CMS services with the JAVA remote debug port 5005 for Crafter Deployer, 1044 for Solr and 8000 for Apache Tomcat

* _help_  Prints script help
 
##### Used Environment Variables

| Variable Name            | Description                                    | Default Value  |
| ------------------------ |:---------------------------------------------:| -----:|
| CRAFTER_HOME             | Path in which Crafter CMS is installed | _Current Working directory_ |
| DEPLOYER_JAVA_OPTS       | Java Options to be passed to Crafter Deployer | empty |
| CRAFTER_DEPLOYER_HOME    | Path in which Crafter Deployer jar file is    |  _Current Working directory_/crafter-deployer   |
| CATALINA_HOME           |  Path in which Apache Tomcat files are        |  _Current Working directory_/apache-tomcat | 
| CATALINA_PID | Path of the file where Tomcat process id will be save  |  CATALINA_HOME/tomcat.pid|
| CRAFTER_DEPLOYER_SDOUT   |  Path of the file where Crafter Deployer SDOUT will be written |  _Current Working directory_/crafter-deployer/crafter-deployer.log | 
| DEPLOYER_PID | Path of the file where Crafter Deployer process id will be save       |  _Current Working directory_/crafter-deployer/crafter-deployer.pid|


#### startup(.sh|bat)

Starts all needed Services to have a functional Crafter CMS _Authoring Environment_

##### Synopsis

`startup.(sh|bat)`

#### shutdown(.sh|bat)

Stops all needed Services to have a functional Crafter CMS _Authoring Environment_

##### Synopsis

`shutdown.(sh|bat)`

#### debug(.sh|bat)

Starts all needed Services to have a functional Crafter CMS _Authoring Environment_ with the JAVA remote debug ports open and 
listing port 5005 for Crafter Deployer, 1044 for Solr and 8000 for Apache Tomcat

##### Synopsis

`debug.(sh|bat)`

#### deployer(.sh/bat)

Script located in `crafter-auth-env/crafter-deployer` which will start,stop Crafter Deployer

##### Synopsis

`deployer.(sh/bat) start|stop|debug|tail`

##### Arguments

* _start_ Starts all Crafter CMS services in this order Crafter Deployer,Solr,Apache Tomcat

* _stop_ Stops all Crafter CMS services in the same order as they start.

* _debug_ Start all Crafter CMS services with the JAVA remote debug port 5005 for Crafter Deployer, 1044 for Solr and 8000 for Apache Tomcat

* _help_  Prints script help

##### Used Environment Variables

**Note** If any of this variables are set using the `crafter.(sh|bat)` script the *default value of `crafter.(sh|bat)`  
is the one will be use.*

| Variable Name            | Description                                    | Default Value  |
| ------------------------ |:---------------------------------------------:| -----:|
| DEPLOYER_JAVA_OPTS       | Java Options to be passed to Crafter Deployer   | empty |
| CRAFTER_DEPLOYER_HOME    | Path in which Crafter Deployer jar file is      |  _Current Working directory_   |
| CRAFTER_DEPLOYER_SDOUT   |  Path of the file where Crafter Deployer SDOUT will be written |  _Current Working directory_ | 
| DEPLOYER_PID | Path of the file where Crafter Deployer process id will be save       |  _Current Working directory_/crafter-deployer.pid|

#### Other Scripts

Please refer to [Tomcat Script documentation](https://tomcat.apache.org/tomcat-8.5-doc/RUNNING.txt) and 
                [Solr Script documentation](https://cwiki.apache.org/confluence/display/solr/Running+Solr) 
                for more information about Apache Tomcat and SOLR
                
### 2.3 Distribute Crater CMS Live Environment

To Distribute a Crafter CMS Environment there is a task `livePack` that will generate a Zip and a Tar file with 
a **Clean** Live environment this means that it will trigger the `liveEnv` task and make sure that your distributable 
files are clean and ready to be un archive.

Archives will be saved in as `crafter-live-env.tar` and `crafter-live-env.zip` in the `distributables` folder
[Check the Gradle Tasks for more information about the livePack task](#4-gradle-tasks)


```bash
./grablew livePack

```
                
                
3 Create a Live Environment
======

### 3.1 Building a Crafter CMS Live environment 

**TBA: Live Environment Definition**

Once all he sources had been download you can run
```bash
    ./gradlew liveEnv
```
The Gradle task above will:

1. Delete any existing _Live environment_ in `crafter-live-env` folder. *It will always make a clean Live environment*

2. Download Apache Tomcat and Solr. (Check the Gradle section on how to specified a version of Apache Tomcat an Solr) 

3. Build all Crafter CMS modules from the source (check the Git section on how to update the source).

4. Create a folder name `crafter-live-env` and copy all needed resources for a *clean* and functional Live environment.


### 3.2.1 Running a Crafter CMS Live environment

To run the _Live environment_ you can:
* Run the gradle task 

```bash
./gradlew runLive
```
or
 
* Run it manually 

```bash
cd crafter-live-env
./startup.sh
```

Both of those options will:

* Start Apache tomcat on default ports (9080,9009,9005) [See Gradle task on how to change default ports](#gradle-tasks)

* Start Solr server on port 8985

* Start Crafter Deployer on port 

### 3.2.2 Authoring Environment Scripts
The Crafter CMS Live scripts will help you on the basic startup shutdown of the services needed to run a healthy _Live environment_
with

#### crafter(.sh/bat)
Main Script to start,and stop all needed Services to have a functional Crafter CMS _Live Environment_

##### Synopsis
`crafter.(sh/bat) start|stop|debug|tail|help`
##### Arguments

* _start_ Starts all Crafter CMS services in this order Crafter Deployer,Solr,Apache Tomcat

* _stop_ Stops all Crafter CMS services in the same order as they start.

* _debug_ Start all Crafter CMS services with the JAVA remote debug port 6005 for Crafter Deployer, 2044 for Solr and 9000 for Apache Tomcat

* _tail_ **OSX or Linux only** Tails Apache Tomcat log,Crafter Deployer Log and Solr log.

* _help_  Prints script help
 
##### Used Environment Variables

| Variable Name            | Description                                    | Default Value  |
| ------------------------ |:---------------------------------------------:| -----:|
| CRAFTER_HOME             | Path in which Crafter CMS is installed | _Current Working directory_ |
| DEPLOYER_JAVA_OPTS       | Java Options to be passed to Crafter Deployer | empty |
| CRAFTER_DEPLOYER_HOME    | Path in which Crafter Deployer jar file is    |  _Current Working directory_/crafter-deployer   |
| CATALINA_HOME           |  Path in which Apache Tomcat files are        |  _Current Working directory_/apache-tomcat | 
| CATALINA_PID | Path of the file where Tomcat process id will be save  |  CATALINA_HOME/tomcat.pid|
| CRAFTER_DEPLOYER_SDOUT   |  Path of the file where Crafter Deployer SDOUT will be written |  _Current Working directory_/crafter-deployer/crafter-deployer.log | 
| DEPLOYER_PID | Path of the file where Crafter Deployer process id will be save       |  _Current Working directory_/crafter-deployer/crafter-deployer.pid|


#### startup(.sh|bat)
Starts all needed Services to have a functional Crafter CMS _Live Environment_

##### Synopsis
`startup.(sh|bat)`

#### shutdown(.sh|bat)
Stops all needed Services to have a functional Crafter CMS _Live Environment_

##### Synopsis
`shutdown.(sh|bat)`

#### debug(.sh|bat)
Starts all needed Services to have a functional Crafter CMS _Live Environment_ with the JAVA remote debug ports open and 
listing port 6005 for Crafter Deployer, 2044 for Solr and 9000 for Apache Tomcat

##### Synopsis
`debug.(sh|bat)`

#### deployer(.sh/bat)
Script located in `crafter-live-env/crafter-deployer` which will start,stop Crafter Deployer

##### Synopsis
`deployer.(sh/bat) start|stop|debug|tail`

##### Arguments

* _start_ Starts all Crafter CMS services in this order Crafter Deployer,Solr,Apache Tomcat

* _stop_ Stops all Crafter CMS services in the same order as they start.

* _debug_ Start all Crafter CMS services with the JAVA remote debug port 6005 for Crafter Deployer, 2044 for Solr and 9000 for Apache Tomcat

* _tail_ **OSX or Linux only** Tails Apache Tomcat log,Crafter Deployer Log and Solr log.

* _help_  Prints script help


##### Used Environment Variables

**Note**  If any of this variables are set using the `crafter.(sh|bat)` script the *default value of `crafter.(sh|bat)`  
is the one will be use.*

| Variable Name            | Description                                    | Default Value  |
| ------------------------ |:---------------------------------------------:| -----:|
| DEPLOYER_JAVA_OPTS       | Java Options to be passed to Crafter Deployer   | empty |
| CRAFTER_DEPLOYER_HOME    | Path in which Crafter Deployer jar file is      |  _Current Working directory_   |
| CRAFTER_DEPLOYER_SDOUT   |  Path of the file where Crafter Deployer SDOUT will be written |  _Current Working directory_ | 
| DEPLOYER_PID | Path of the file where Crafter Deployer process id will be save       |  _Current Working directory_/crafter-deployer.pid|

#### Other Scripts

Please refer to [Tomcat Script documentation](https://tomcat.apache.org/tomcat-8.5-doc/RUNNING.txt) and 
                [Solr Script documentation](https://cwiki.apache.org/confluence/display/solr/Running+Solr) 
                for more information about Apache Tomcat and SOLR
                

4 Gradle Tasks
==============

#### 4.1 Common task properties.
* tomcatVersion: Sets the tomcat version to be download used by *downloadTomcat* task

* solrVersion: Sets the Solr version to be download used by *downloadSolr* task.

* downloadDir: Path were all downloads will be save.used by *downloadTomat* and *downloadSolr*. Default value is *./target/dowloads*

* authEnv: Path were a development environment will be generated. Default value is *./crafter-auth-env/*

* liveEnv: Path were a development environment will be generated. Default value is *./crafter-live-env/*

* includeProfile: Includes profile in the generation of the development environment. Default value is false. **If true,mongodb is require**

* includeSocial: Includes Social in the generation of the development environment. Default value is false, **If true, *includeProfile* will be set to true**

* authTomcatPort: Authoring Tomcat Http port. Default value is 8080

* authTomcatShutdownPort: Authoring Tomcat Shutdown port. Default value is 8005

* authTomcatAJPPort: Authoring Tomcat AJP port. Default value is 8009

* authTomcatSSLPort: Authoring Tomcat SSL(https) port. Default value is 8443
   
* liveTomcatPort: Live Tomcat Http port. Default value is 9080

* liveTomcatShutdownPort: Live Tomcat Shutdown port. Default value is 9005

* liveTomcatAJPPort: Live Tomcat AJP port. Default value is 9009

* liveTomcatSSLPort: Live Tomcat SSL(https) port. Default value is 9443

#### 4.2 Tasks

To check more information about all tasks use:

```bash
.gradlew tasks --all
```

##### 4.2.1 build

Builds all the projects from source.
```bash
./gradlew build
```

##### 4.2.2 build+ProjectName

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

##### 4.2.3 clean

Cleans all projects build results
```bash
gradlew.bat clean
```

##### 4.2.4 clean+ProjectName
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

##### 4.2.5 downloadSolr

Downloads the given configure Solr version also verifies that the war file is ok agains a sha1 signature.
```bat
gradlew.bat downloadSolr
```

##### 4.2.6 downloadTomcat

Downloads the given configure Tomcat version also verifies that the zip file is ok agains a sha1 signature.
```bash
./gradlew downloadTomcat
```

##### 4.2.7 authEnv

Builds a **Clean** (Delete all the contents of *authEnv* defaults to crafter-auth-env folder) authoring environment for Studio, uses the build results of *build*,*downloadSolr* and *downloadTomcat*
uses the *authEnv* property as the output of the it.
**Note:**
This task will delete the *authEnv* folder.

```bat
gradlew.bat buildEnv
```


##### 4.2.8 liveEnv
Builds a **Clean** (Delete all the contents of *liveEnv* defaults to crafter-live-env folder) live environment for Studio, uses the build results of *build*,*downloadSolr* and *downloadTomcat*
uses the *liveEnv* property as the output of the it.
**Note:**
This task will delete the *liveEnv* folder.

```bat
gradlew.bat buildEnv
```

##### 4.2.9 authPack
Packages the *authEnv* in a zip and tar files to be distribute.


5 Git
========

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
3  [Run Update submodules](#update-submodules)

#6. Troubleshooting
<aside class="warning">
TODO:
List the error you get, then the fix
</aside>

```bash
git clone https://github.com/craftercms/craftercms.git
cd craftercms
git submodule init
```




*[See more information git usage here](#5-git)*

### 1.3 Gradle Usage
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
[See more on gradle tasks and usage](#GradleTasks)
