# Crafter CMS

Crafter CMS is an open source content management system for web, mobile apps, VR and more. You can learn more about Crafter here: http://docs.craftercms.org/en/latest/index.html

This repository is the parent project that builds everything and prepares a deployable bundle and a developer's environment.


1 Getting ready 
==

### 1.1 Prerequisites

* Java 8
* Git 2.0
* Maven 3.3.x.

### 1.2 Clone this repo.

```bash
git clone --recursive  https://github.com/craftercms/craftercms.git
```

or

```bash
git clone https://github.com/craftercms/craftercms.git
cd craftercms
git submodule init
```

*[See more information git usage here](#Git)*

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
_[See more on gradle tasks and usage](#GradleTasks)

2 Create a Development Environment
======

The following steps will guide you on the creation of a authoring and live environments of Crafter CMS.

### 2.1 Building a Crafter CMS Authoring environment 
*_An Authoring environment is where an Author can safely create and manage content without impacting the end-user's live system_*
Once all he sources had been download you can run
```bash
    ./gradlew authEnv
```
The Gradle task above will:
1. Delete any existing _Authoring environment_in `crafter-auth-env` folder. *It will always make a clean Authoring environment*
2. Download Apache Tomcat and Solr. (Check the Gradle section on how to spesifed a version of tomcat an solr)
3. Build all Crafter CMS components from the source (check the Git section on how to update the source).
4. Create a folder name `crafter-auth-env` and copy all needed resources for a *clean* and functional Authoring environment.

### 2.1.2. Run
To run the _Authoring environment_ you can:
* Run the gradle task 

```bash
./gradlew runAuth
```
or
 
* Run it manually 

```bash
cd `crafter-auth-env`
./startup.sh
```

Both of those options will:

* Start Apache tomcat on default ports (8080,8009,8005) [See Gradle task on how to change default ports]#GradleTasks
* Start Solr server on port 8984
* Start Crafter Deployer on port 

### 2.1.3 Authoring Environment Scripts
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
| CRAFTER_HOME             | P | empty |
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
*Note* that if any of this variables are set using the `crafter.(sh|bat)` script the *default value of `crafter.(sh|bat)`  
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
   
X Git
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
3  [Run Update submodules]#updateSubmodules
