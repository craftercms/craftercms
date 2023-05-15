![build status](https://travis-ci.com/craftercms/craftercms.svg?branch=develop)

# CrafterCMS

CrafterCMS is a modern content management platform for building digital experience applications including:

* Single Page Applications (SPAs) using frameworks like React, Vue, and Angular
* Native mobile apps and headless applications (IOT, digital signage, wearables, etc.)
* e-commerce front-ends
* OTT video experiences on AWS Elemental Media Services
* AR/VR applications using A-Frame

You can learn more about CrafterCMS here: https://craftercms.org

Try CrafterCMS using a pre-built AMI (use the `authoring` AMI): https://aws.amazon.com/marketplace/seller-profile?id=6d75ffca-9630-44bd-90b4-ac0e99058995

Download a pre-built binary archive here: https://craftercms.org/downloads

Read the docs here: https://docs.craftercms.org/current

This repository is for developers interested in contributing to CrafterCMS, customizing their own release, or building the latest. This parent project helps you build the following: 

1. Deployable CrafterCMS binaries
2. Docker images
3. Developer's environment so you can compile and contribute to CrafterCMS

**WARNING:** CrafterCMS source code development and building is 
_only_ supported on Unix based systems. If you want to use CrafterCMS in Windows, install Windows Subsystem for Linux (WSL) by following the instructions [here](https://docs.microsoft.com/en-us/windows/wsl/install) then use the WSL 2 terminal for all the commands below.  Please refer to the documentation
in [Installing CrafterCMS on WSL 2](https://docs.craftercms.org/current/system-administrators/activities/installing-craftercms-on-wsl2.html).

# 1. Initial Setup
Please make sure your system meets the prerequisites:
https://docs.craftercms.org/current/system-administrators/requirements-supported-platforms.html

Let's begin :)

If you're building deployable CrafterCMS binaries, we'll clone the master branch:

```bash
git clone -b master https://github.com/craftercms/craftercms.git
```

OR

If you would like to contribute to CrafterCMS, to build a developer's environment, we'll need to clone the develop branch (default):

```bash
git clone -b develop https://github.com/craftercms/craftercms.git
```

For more information on CrafterCMS Git Workflow, please review: https://github.com/craftercms/craftercms/blob/master/GIT_WORKFLOW.md


# 2. Summary of Commands and Options
## 2.1 Commands

* `download` Download dependencies
* `clone` Clone CrafterCMS modules
* `selfUpdate` Update the parent project (`craftercms`)
* `update` Update modules
* `clean` Clean modules
* `build` Build modules
* `deploy` Deploy modules
* `upgrade` Upgrade modules (same as `update`, `clean`, `build`, `deploy`)
* `start` Start CrafterCMS
* `stop` Stop CrafterCMS
* `status` Report status on running environments if any
* `bundle` Create deployable binaries

## 2.2 Options

* `overwriteChangedFiles`: Update and overwrite the deployed environment (authoring or delivery) files (binaries, configuration, etc.), default `true` 
* `refreshEnv`: Update the deployed environment (authoring or delivery) with any changes to the scripts, default `false` 
* `overwriteArtifact`: Update and overwrite the downloaded artifacts (example: OpenSearch, Tomcat, ...) that's cached in the downloads folder by downloading it again, default `false` 
* `gitRemote`: Git remote name to use in cloned modules, default `origin`
* `gitBranch`: Git branch to use when cloning modules, default `develop` (for develop branch)
* `gitUrl`: Which Git URL to use, default `https://github.com/craftercms/`
* `socialRequired`: Include Social in the build, default `false`
* `profileRequired`: Include Profile in the build, default `false`
* `startElasticsearch` or `withElasticsearch`: start Elasticsearch, default `true`
* `startMongoDB`: start MongoDB, default `false` unless Profile or Social are enabled. This is automatic.
* `unitTest`: Run unit tests during build, default `false`
* `shallowClone`: Clone only the latest commits and not the entire history (faster, but you lose history), default `false`
* `bundlesDir`: Where to deposit binaries, default `./bundles`
* `downloadGrapes`: Download Grapes ahead of time (useful when no public Internet is available), default `false`
* `downloadDir`: Where to store downloads, default `./downloads`
* `authoringEnvDir`: Where to store the authoring environment, default `./crafter-authoring`
* `deliveryEnvDir`: Where to store the delivery environment, default `./crafter-delivery`
* `currentPlatform`: What platform to build to (`linux` or `darwin`), default is the build machine's OS

# 3. Build Deployable Binaries

To build deployable and distributable binaries of CrafterCMS, use the Gradle task `bundle`. This task will generate `.tar.gz` files ready to be deployed to any system.

Before using `bundle` task make sure that the environment has been created and deployed using gradle tasks `build` and `deploy`

Archives will be named `crafter-cms-${environment}-VERSION.tar.gz` and can be found in the `bundles` folder.

```bash
./gradlew build deploy bundle
```

To run CrafterCMS from the binary archive, unzip and follow the instructions in the binary archive's `README.txt`.

## 3.1. Build Environment Specific Binaries
CrafterCMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

To build a binary archive for a specific environment:

```bash
    ./gradlew bundle -Penv=authoring
```
Archive will be named `crafter-cms-authoring-${version}.tar.gz` and can be found in the `bundles` folder.

For the `delivery` environment, simply substitute the `env=authoring` with `env=delivery`.

## 3.2 Update, Build and Bundle from a Tag/Branch

To download, build and generate a binary archive from a given tag or branch of the source code,

1. Clone the branch/tag of craftercms that you want to work with
```bash
    git clone -b <tag or branch> https://github.com/craftercms/craftercms/
```
2. Download, build and bundle the tag/branch that you want to work with
```bash
    ./gradlew build deploy bundle
```

> **_NOTE:_**
When using a tag-based build, you're essentially cloning a point in time to build that specific version of CrafterCMS. That implies that you won't be able to update/nor push changes back.

# 4. Build a Developer's Environment
CrafterCMS comprises a number of headless API-first (GraphQL, REST, in-process)  modules that work together to provide the final solution. In this section, we'll start with the simple case of _build everything_/_run everything_, and then move on to building/hacking individual modules.


## 4.1. Build, Start and Stop All 
### 4.1.1. Build All
Build all CrafterCMS modules

```bash
    ./gradlew build deploy
```

### 4.1.2. Start All
Start CrafterCMS,
 
 ```bash
    ./gradlew start
```

You can now point your browser to [http://localhost:8080/studio](http://localhost:8080/studio) and start using CrafterCMS. To get started with your first CrafterCMS experience, you can follow this guide: [https://docs.craftercms.org/current/content-authors/index.html](https://docs.craftercms.org/current/content-authors/index.html).

> **_NOTE:_**
    * The authoring environment runs on port `8080`, a great place to start, while the delivery environment runs on port `9080`.

### 4.1.3. Stop All
Stop CrafterCMS,

```bash
    ./gradlew stop
```

### 4.2. Two Environments: Authoring vs Delivery
You might have noticed that you essentially have two environments built and running: `authoring` and `delivery`. CrafterCMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

As a developer, you can use an `authoring` environment for most tasks without the need to run a `delivery` environment. It's important to note that `delivery` essentially runs the same software that's in `authoring` except Crafter Studio (the authoring tools).
By default, this project will build both environments unless instructed otherwise. The `authoring` environment runs at [http://localhost:8080/studio](http://localhost:8080/studio), whereas the `delivery` environment runs at [http://localhost:9080/](http://localhost:9080/).

### 4.2.1. Build, Start, and Stop a Specific Environment
To build, start and stop one of the two environments is similar to building/starting/stopping All.

#### Authoring
```bash
    ./gradlew build deploy -Penv=authoring
    ./gradlew start -Penv=authoring
    ./gradlew stop -Penv=authoring
```

#### Delivery
```bash
    ./gradlew build deploy -Penv=delivery
    ./gradlew start -Penv=delivery
    ./gradlew stop -Penv=delivery
```

### 4.3. Crafter Modules
The mechanics for working with a single module are similar to working with _all_, with one exception: You can deploy a module to one or both environments (`authoring`/`delivery`).

CrafterCMS comprises the following modules:
* [`core`](https://docs.craftercms.org/current/developers/projects/core/index.html)
* [`commons`](https://docs.craftercms.org/current/developers/projects/commons/index.html)
* [`engine`](https://docs.craftercms.org/current/developers/projects/engine/index.html)
* [`studio`](https://docs.craftercms.org/current/developers/projects/studio/index.html)
* [`search`](https://docs.craftercms.org/current/developers/projects/search/index.html)
* [`profile`](https://docs.craftercms.org/current/developers/projects/profile/index.html)
* [`social`](https://docs.craftercms.org/current/developers/projects/social/index.html)
* [`deployer`](https://docs.craftercms.org/current/developers/projects/deployer/index.html)

You'll find these projects checked out and ready for you to contribute to in the folder `src/{modules}`.

### 4.3.1. Forking a Module
Start by forking the module you want to work on. You can follow the [GitHub instructions](https://help.github.com/articles/fork-a-repo/).
The next step is to switch the origin url location to be the one just forked, to do so you can use [these GitHub instructions](https://help.github.com/articles/changing-a-remote-s-url/).
The last step will be to add an upstream repository from the main `craftercms` repo to your own. Follow [these steps](https://help.github.com/articles/fork-a-repo/#step-3-configure-git-to-sync-your-fork-with-the-original-spoon-knife-repository)
to make it happen.
You can now work in your local system, and build/deploy and ultimately push to your fork. We welcome code contributions, so please do send us pull-requests.

To update your project with the latest:

```bash
    ./gradlew update
```

### 4.3.2. Update, Build, Deploy, Start, and Stop a Module
You can update, build, deploy, start or stop a module by:

```bash
    ./gradlew update -Pmodules=studio
    ./gradlew build -Pmodules=studio
    ./gradlew deploy -Pmodules=studio -Penv=authoring
    ./gradlew start -Pmodules=studio -Penv=authoring
    ./gradlew stop -Pmodules=studio -Penv=authoring
```

> **_NOTE:_**
    * If you don't specify the `env` parameter, it means all environments (where applicable).
    * In the current version of CrafterCMS, some services run in the same Web container, and that implies the stopping/starting of one of these services will cause other services to stop/start as well.

# 5. Advanced Topics
For more detailed information and advanced topic, please visit the [detailed documentation](https://docs.craftercms.org/current/developers/projects/craftercms/index.html).

CrafterCMS has two environments, the Authoring Environment and the Delivery Environment.

The authoring environment provides all the content management services, enabling authoring, managing and publishing of all content.  It provides a comprehensive set of user-friendly features for managing and optimizing your experiences.

The delivery environment provides content delivery services.  It consumes content published from your authoring environment and provides developers with the foundation for quickly building high-performance, flexible experiences.

In this section we will be discussing the scripts for the authoring and delivery environments.

## 5.1 Authoring and Delivery Environment Scripts

The CrafterCMS Authoring and Delivery scripts will help you on the basic startup and shutdown of the services needed to run a healthy *Authoring environment* and *Delivery environment* with the following scripts:

| **Script**|``crafter.sh``|
|-----------|--------------|
|**Description**|Main Script to start and stop all needed Services to have a functional CrafterCMS *Authoring/Delivery Environment* <br>To log the output of the script to a file, set the environment variable CRAFTER_SCRIPT_LOG to point to a log file|
|**Synopsis**|``crafter.sh start``\|``stop``\|``debug``\|``help``|
|**Arguments**|``start [withMongoDB] [skipSearch] [skipMongoDB] [tailTomcat]``<br>Starts all CrafterCMS services in this order: Crafter Deployer, OpenSearch, Apache Tomcat<br>&nbsp;&nbsp;&nbsp;&nbsp;If `withMongoDB` is specified MongoDB will be started.<br>&nbsp;&nbsp;&nbsp;&nbsp;If `skipSearch` is specified OpenSearch will not be started.<br>&nbsp;&nbsp;&nbsp;&nbsp;If `skipMongoDB` is specified MongoDB will not be started even if the Crafter Profile war is present.<br>&nbsp;&nbsp;&nbsp;&nbsp;If `tailTomcat` is specified, Tomcat will be tailed and Crafter will shutdown when the script terminates.<br><br>``stop``  Stops all CrafterCMS services in the same order as they start.<br><br>``debug [withMongoDB] [skipSearch] [skipMongoDB]``<br>Starts all CrafterCMS services with the JAVA remote debug port 5000 for Crafter Deployer, and 8000 for Apache Tomcat for the *Authoring Environment*<br>Starts all CrafterCMS services with the JAVA remote debug port 5001 for Crafter Deployer, and 9000 for Apache Tomcat for the *Delivery Environment*<br>&nbsp;&nbsp;&nbsp;&nbsp;If `withMongoDB` is specified MongoDB will be started.<br>&nbsp;&nbsp;&nbsp;&nbsp;If `skipSearch` is specified Elasticsearch will not be started.<br>&nbsp;&nbsp;&nbsp;&nbsp;If `skipMongoDB` is specified MongoDB will not be started even if the Crafter Profile war is present.<br><br>``start_deployer``  Starts Deployer<br><br>``stop_deployer``  Stops Deployer<br><br>    ``debug_deployer``  Starts Deployer in debug mode<br><br>``restart_deployer``  Restarts Deployer<br><br>``start_search``  Starts OpenSearch<br><br>``stop_search``  Stops OpenSearch<br><br>``debug_search``  Starts OpenSearch in debug mode<br><br>``restart_search``  Restarts OpenSearch<br><br>``start_tomcat``  Starts Apache Tomcat<br><br>``stop_tomcat``  Stops Apache Tomcat<br><br>``debug_tomcat``  Starts Apache Tomcat in debug mode<br><br>``restart_tomcat`` Restarts Apache Tomcat<br><br>``restart_debug_tomcat``  Restarts Apache Tomcat in debug mode<br><br>``start_mongodb``  Starts MongoDB<br><br>``stop_mongodb``  Stops MongoDB<br><br>``restart_mongodb``  Restarts MongoDB<br><br>``status``  Prints the status of all CrafterCMS subsystems<br><br>``status_engine``  Prints the status of Crafter Engine<br><br>``status_studio``  Prints the status of Crafter Studio<br><br>``status_profile``  Prints the status of Crafter Profile<br><br>``status_social``  Prints the status of Crafter Social<br><br>``status_deployer``  Prints the status of Crafter Deployer<br><br>``status_search``  Prints the status of OpenSearch<br><br>``status_mariadb``  Prints the status of MariaDb<br><br>``status_mongodb``  Prints the status of MongoDB<br><br>``backup <name>``  Perform a backup of all data<br><br>``restore <file>``  Perform a restore of all data<br><br>``upgradedb``  Perform database upgrade (mysql_upgrade)|

| **Synopsis**| ``startup.sh``|
|-----|-----|
|**Description**| Starts all needed Services to have a functional CrafterCMS *Authoring/Delivery Environment*|

|**Synopsis**|``shutdown.sh``|
|-----|-----|
|**Description**| Stops all needed Services to have a functional CrafterCMS *Authoring/Delivery Environment*|

|**Synopsis**| ``debug.sh`` |
|-----|-----|
|**Description**| Starts all needed Services to have a functional CrafterCMS *Authoring/Delivery Environment* with the JAVA remote debug ports open and listening port 5000/5001 for Crafter Deployer, and 8000/9000 for Apache Tomcat |

|**Script**|``deployer.sh``|
|-----|------|
|**Description**|Script located in *$CRAFTER_HOME/bin/crafter-deployer* which will start,stop Crafter Deployer for the *Authoring/Delivery* environment|
|**Synopsis**|``deployer.sh start``\|``stop``\|``debug``\|``help`` |
|**Arguments**|``start`` Starts all CrafterCMS services in this order Crafter Deployer OpenSearch, Apache Tomcat<br><br>``stop``  Stops all CrafterCMS services in the same order as they start.<br><br>``debug`` Start all CrafterCMS services with the JAVA remote debug port 5000 for Crafter Deployer, and 8000 for Apache Tomcat for the *Authoring Environment* <br>Starts all CrafterCMS services with the JAVA remote debug port 5001 for Crafter Deployer, and 9000 for Apache Tomcat for the *Delivery Environment*<br><br>``help``  Prints script help|

<br><br>
Here are the location environment variables used by ``crafter.sh``:


| Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CRAFTER_HOME  | CrafterCMS *Authoring/Delivery* path <hr> {CrafterCMS-install-directory}/crafter-{env}/|
| CRAFTER_LOGS_DIR | CrafterCMS logs file path <hr>$CRAFTER_HOME/logs |
| CRAFTER_DATA_DIR | CrafterCMS data file path <hr>$CRAFTER_HOME/data |
| CRAFTER_TEMP_DIR | CrafterCMS temporary directory path <hr> $CRAFTER_HOME/temp |
| CRAFTER_BACKUPS_DIR | CrafterCMS backup directory path <hr> $CRAFTER_HOME/backups |

<br><br>
Here are the environment variables used for hosts and ports in ``crafter.sh``:

| Hosts and Ports<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| MAIL_HOST | CrafterCMS mail host <hr>localhost |
| MAIL_PORT | CrafterCMS mail port <hr>25|
| SEARCH_HOST   | Search host <hr>localhost |
| SEARCH_PORT   | Search port <hr>9201|
| DEPLOYER_HOST | Deployer host <hr>localhost|
| DEPLOYER_PORT | Deployer port <hr> 9201 |
| MONGODB_HOST  | MongoDB host <hr> localhost |
| MONGODB_PORT  | MongoDB port <hr>27020 |
| MARIADB_HOST  | MariaDb host <hr> 127.0.0.1 |
| MARIADB_PORT  | MariaDb port <hr> 33306 |
| TOMCAT_HOST   | Tomcat host <hr> localhost |
| TOMCAT_HTTP_PORT | Tomcat Http port <hr> 8080 |
| TOMCAT_HTTPS_PORT | Tomcat SSL (https) port <hr> 8443 |
| TOMCAT_AJP_PORT | Tomcat AJP port <hr> 8009 |
| TOMCAT_SHUTDOWN_PORT | Tomcat shutdown port <hr> 8005 |
| TOMCAT_DEBUG_PORT | Tomcat debug port <hr> 8000 |

<br><br>
Here are the environment variables used for URLs in ``crafter.sh``:

| URLs<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| SEARCH_URL | Search URL <hr> http://\$SEARCH_HOST:\$SEARCH_PORT|
| DEPLOYER_URL | Crafter Deployer URL <hr> http://\$DEPLOYER_HOST:\$DEPLOYER_PORT |
| STUDIO_URL | Crafter Studio URL <hr> http://\$TOMCAT_HOST:\$TOMCAT_HTTP_PORT/studio |
| ENGINE_URL | Crafter Engine URL <hr> http://\$TOMCAT_HOST:\$TOMCAT_HTTP_PORT/studio |
| PROFILE_URL | Crafter Profile URL <hr> http://\$TOMCAT_HOST:\$TOMCAT_HTTP_PORT/crafter-profile |
| SOCIAL_URL | Crafter Social URL <hr> http://\$TOMCAT_HOST:\$TOMCAT_HTTP_PORT/crafter-social |

<br><br>
Here are the environment variables used for Java options in ``crafter.sh``:

| Java options<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| OPENSEARCH_JAVA_OPTS | OpenSearch Java options <hr>"-server -Xss1024K -Xmx1G"|
| DEPLOYER_JAVA_OPTS | Deployer Java options <hr> "-server -Xss1024K -Xmx1G"|
| CATALINA_OPTS | Tomcat options <hr> "-server -Xss1024K -Xms1G -Xmx4G"|

<br><br>
Here are the environment variables used for Tomcat in ``crafter.sh``:

| Tomcat<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CATALINA_HOME | Apache Tomcat files path <hr> $CRAFTER_HOME/bin/apache-tomcat |
| CATALINA_PID | Tomcat process id file save path <hr> $CATALINA_HOME/bin/tomcat.pid |
| CATALINA_LOGS_DIR | Tomcat file logs path <hr>$CRAFTER_LOGS_DIR/tomcat |
| CATALINA_OUT | Tomcat main log file <hr> $CATALINA_LOGS_DIR/catalina.out |
| CATALINA_TMPDIR | Tomcat temporary directory <hr>$CRAFTER_TEMP_DIR/tomcat |

<br><br>
Here are the environment variables used for OpenSearch in ``crafter.sh``:

| OpenSearch<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| OPENSEARCH_JAVA_HOME | OpenSearch Java home directory <hr>$JAVA_HOME |
| OPENSEARCH_HOME | OpenSearch home directory <hr> $CRAFTER_BIN_DIR/opensearch |
| OPENSEARCH_INDEXES_DIR | OpenSearch indexes directory <hr>$CRAFTER_DATA_DIR/indexes-es |
| OPENSEARCH_LOGS_DIR | OpenSearch log files directory <hr>$CRAFTER_LOGS_DIR/logs/search |
| OPENSEARCH_PID | OpenSearch process Id <hr>$OPENSEARCH_HOME/opensearch.pid |
| OPENSEARCH_USERNAME | OpenSearch username <hr> |
| OPENSEARCH_PASSWORD | OpenSearch password <hr> |
| SEARCH_DOCKER_NAME | OpenSearch Docker name <hr> {env}-search |

<br><br>
Here are the environment variables used for the Deployer in ``crafter.sh``:

| Deployer<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| DEPLOYER_HOME | Crafter Deployer jar files path <hr> $CRAFTER_HOME/bin/crafter-deployer |
| DEPLOYER_DATA_DIR | Deployer data files directory <hr> $CRAFTER_DATA_DIR/deployer |
| DEPLOYER_LOGS_DIR | Deployer log files directory <hr> $CRAFTER_LOGS_DIR/deployer |
| DEPLOYER_DEPLOYMENTS_DIR | Deployer deployments files directory <hr> $CRAFTER_DATA_DIR/repos/sites |
| DEPLOYER_SDOUT | Deployer SDOUT path <hr>$DEPLOYER_LOGS_DIR/crafter-deployer.out |
| DEPLOYER_PID | Deployer process id file <hr> $DEPLOYER_HOME/crafter-deployer.pid |

<br><br>
Here are the environment variables used for MongoDB in ``crafter.sh``:

| MongoDB<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| MONGODB_HOME | MongoDB files path <hr> $CRAFTER_BIN_DIR/mongodb |
| MONGODB_PID | MongoDB process id file save path <hr> $MONGODB_DATA_DIR/mongod.lock |
| MONGODB_DATA_DIR | MongoDB data directory <hr> $CRAFTER_DATA_DIR/mongodb |
| MONGODB_LOGS_DIR | MongoDB log files directory <hr> $CRAFTER_LOGS_DIR/mongodb |

<br><br>
Here are the environment variables used for MariaDb in ``crafter.sh``:

| MariaDB<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| MARIADB_SCHEMA | MariaDb schema <hr>crafter |
| MARIADB_HOME | MariaDb files path <hr>$CRAFTER_BIN_DIR/dbms |
| MARIADB_DATA_DIR | MariaDb data directory <hr> $CRAFTER_DATA_DIR/db |
| MARIADB_ROOT_USER | MariaDb root username <hr> |
| MARIADB_ROOT_PASSWD | MariaDb root password <hr> |
| MARIADB_USER | MariaDb username <hr>crafter |
| MARIADB_PASSWD | MariaDb user password <hr>crafter |
| MARIADB_SOCKET_TIMEOUT | MariaDB socket timeout <hr> 60000 |
| MARIADB_TCP_TIMEOUT | MariaDB TCP timeout <hr>120 |
| MARIADB_PID | MariaDB process id file <hr> $MARIADB_HOME/$HOSTNAME.pid |

<br><br>
Here are the environment variables used for Git in ``crafter.sh``:

| Git<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| GIT_CONFIG_NOSYSTEM | Ignore Git system wide configuration file <hr>true |

<br><br>
Here are the environment variables used for Management Tokens.
Remember to update these per installation and provide these tokens to the status monitors:

| Management Token<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| STUDIO_MANAGEMENT_TOKEN | Authorization token for Studio <hr>defaultManagementToken |
| ENGINE_MANAGEMENT_TOKEN | Authorization token for Engine <hr>defaultManagementToken |
| DEPLOYER_MANAGEMENT_TOKEN | Authorization token for Deployer <hr>defaultManagementToken |
| PROFILE_MANAGEMENT_TOKEN | Authorization token for Profile <hr>defaultManagementToken |
| SOCIAL_MANAGEMENT_TOKEN | Authorization token for Social <hr>defaultManagementToken |

<br><br>
Here are the environment variables used to encrypt and decrypt values inside configuration files:

| Encryption<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CRAFTER_ENCRYPTION_KEY | Key used for encrypting properties <hr> default_encryption_key |
| CRAFTER_ENCRYPTION_SALT | Salt used for encrypting properties <hr> default_encryption_salt |

<br><br>
Here are the environment variables used to encrypt and decrypt values in the database:

| Encryption<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CRAFTER_SYSTEM_ENCRYPTION_KEY | Key used for encrypting database values <hr> \<someDefaultKeyValue\> |
| CRAFTER_SYSTEM_ENCRYPTION_SALT | Salt used for encrypting database values <hr> \<someDefaultSaltValue\> |

<br><br>
Here are the configuration variables used in CrafterCMS:

| Configuration<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CRAFTER_ENVIRONMENT | Name used for environment specific configurations in Studio, Engine and Deployer <hr> default |

<br><br>
Here are the SSH variables used in CrafterCMS:

| Configuration<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| CRAFTER_SSH_CONFIG | CrafterCMS folder path for the SSH configuration <hr> $CRAFTER_DATA_DIR/ssh |

<br><br>
Here are the environment variables used for Studio's access tokens for API's:

| Configuration<br> Variable Name | Description <hr> Default Value |
|---------------|---------------|
| STUDIO_TOKEN_ISSUER | Issuer for generated tokens <hr> Crafter Studio |
| STUDIO_TOKEN_VALID_ISSUERS | Issuer for generated tokens <hr> Crafter Studio |
| STUDIO_TOKEN_AUDIENCE | Audience for generation and validation of access tokens <hr> |
| STUDIO_TOKEN_TIMEOUT | Expiration time of access tokens in minutes <hr>5 |
| STUDIO_TOKEN_SIGN_PASSWORD | Password for signing the access tokens <hr> |
| STUDIO_TOKEN_ENCRYPT_PASSWORD | Password for encrypting the access tokens <hr> |
| STUDIO_REFRESH_TOKEN_NAME | Name of the cookie to store the refresh token <hr> refresh_token |
| STUDIO_REFRESH_TOKEN_MAX | Expiration time of the refresh token cookie in seconds <hr> 300 |
| STUDIO_REFRESH_TOKEN_SECURE | Indicates if refresh token cookie should be secure <hr> false |

<br><br>
Let's look at an example on how to start an authoring environment using the scripts we discussed above.  To start the authoring environment, go to your CrafterCMS install folder then run the following:

```bash
   cd crafter-authoring
   ./startup.sh
```

What the above does is go to your authoring environment folder, then run the startup script.

To stop the authoring environment:

```bash
   ./shutdown.sh
```

### 5.1.1 Other Scripts

For more information about Apache Tomcat, and Elasticsearch please refer to the following:

 * [Tomcat Script documentation](https://tomcat.apache.org/tomcat-9.0-doc/RUNNING.txt)
 * [Elasticsearch Script documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/starting-elasticsearch.html)


## 5.2 Gradle Authoring and Delivery Environment Scripts

As we have seen in the getting started section above, to run a gradle task, we run the following from the root of the project:

```bash
   ./gradlew command [-Penv={env}] [-PmoduleName={module}]
```       


Here's a list of commands (Gradle tasks) available:

| Command<br>``command`` | Description | Env Options<br>``env`` | Module Options<br>``module`` |
|-----|-----|-----|-----|
| clone | Clones CrafterCMS | <ul><li>None</li></ul> | <ul><li>None</li></ul> |
| build | Build a module or an entire environment | authoring<br><br><br><br><br><br><br><br><br><br><br><br><hr> delivery | <ul><li>None</li><li>studio</li><li>deployer</li><li>engine</li><li>search</li><li>social</li><li>profile</li><li>core</li><li>commons</li><li>studio-ui</li><li>plugin-maker</li><hr>|
| deploy | Deploy a module or an entire environment | authoring<br><br><br><br><br><br><br><hr>delivery | <ul><li>None</li><li>studio</li><li>deployer</li><li>engine</li><li>search</li><li>social</li><li>profile</li><hr><ul><li>None</li><li>deployer</li><li>engine</li><li>search</li><li>social</li><li>profile</li> |
| bundle | Build deployable and distributable binaries | authoring <hr> delivery | <ul><li>None</li></ul> |
| start | Start CrafterCMS | authoring <hr> delivery | <ul><li>None</li></ul> |
| stop | Stop CrafterCMS | authoring <hr> delivery | <ul><li>None</li></ul> |
| update | Update a module or modules | <ul><li>None</li></ul> | <ul><li>None</li><li>studio</li><li>deployer</li><li>engine</li><li>search</li><li>social</li><li>profile</li><li>core</li><li>commons</li><li>studio-ui</li><li>plugin-maker</li> |
| upgrade | Upgrades the installed Tomcat version, etc, without deleting your data then builds and deploys | <ul><li>None</li></ul> | <ul><li>None</li></ul> |
| selfupdate | Updates the CrafterCMS project (gradle) | <ul><li>None</li></ul> | <ul><li>None</li></ul> |
| clean | Delete all compiled objects | <ul><li>None</li></ul> | <ul><li>None</li></ul> |

> **_NOTE:_**
    * If you don't specify the ``env`` parameter, it means all environments (where applicable).
    * In the current version of CrafterCMS, some services run in the same Web container, and that implies the stopping/starting of one of these services will cause other services to stop/start as well.
    * The Gradle task property ``moduleName`` accepts one or multiple module/s, separated by commas like this: ``./gradlew build -PmoduleName=search,studio``
    * The ``clean`` command does not delete previously built environment folders ``crafter-authoring`` and ``crafter-delivery``. To build a fresh copy of these two, backup your custom data and delete both folders manually.

<br><br>
Let's see some examples of running Gradle tasks here.

### 5.2.1 BUILD

To build the authoring and delivery environments, run the following:

```bash
   ./gradlew build
```

The Gradle task above will:

1. Delete any existing environments/module
2. Download Apache Tomcat, Elasticsearch, and MongoDB (check the Gradle section on how to specify a version for each component)
3. Build all CrafterCMS modules from the source (check the [section](#git) on how to update the source)
4. Create the environment folders and copy all needed resources

    - ``crafter-authoring``
    - ``crafter-delivery``

To build a module (all module options for task ``build`` are listed in the table above), run the following (we'll build the module *studio* in the example below):

```bash
   ./gradlew build -PmoduleName=studio
```

To build an environment, run the following (we'll build the authoring environment in the example below:

```bash
   ./gradlew build -Penv=authoring
```

### 5.2.2 START

To start an environment, run the following:

```bash
   ./gradlew start [-Penv={env}]
```

What this does under the hood is:

```bash
   cd crafter-{env}
   ./startup.sh
```

The options above will:

For the *Authoring Environment*:

* Start Apache tomcat on default ports (8080, 8009, 8005) [See [here](#gradle-tasks) on how to change default ports]
* Start Elasticsearch on port 9201
* Start Crafter Deployer on port 9191

For the *Delivery Environment*:

* Start Apache tomcat on default ports (9080, 9009, 9005) [See [here](#gradle-tasks) on how to change default ports]
* Start ElasticSEarch server on port 9202
* Start Crafter Deployer on port 9192

Here's an example starting an authoring environment:

```bash
   ./gradlew start -Penv=authoring
```

### 5.2.3 STOP

To stop an environment, run the following:

```bash
   ./gradlew stop [-Penv={env}]
```

What this does under the hood is:

```bash
   cd crafter-{env}
   ./shutdown.sh
```

### 5.2.4 BUNDLE

The Gradle task ``bundle`` will build deployable and distributable binaries of CrafterCMS for the authoring and/or delivery environments.  This will generate tar files ready to be unarchived and run.

```bash
   ./gradlew bundle [-Penv={env}]
```

Binaries will be saved as ``crafter-cms-authoring-VERSION.tar`` for the *Authoring Environment* and ``crafter-cms-delivery-VERSION.tar`` for the *Delivery Environment* in the ``bundles`` folder

Using the common task property ``env`` lets you select what environment (authoring or delivery) will be generated.

Let's look at an example using the task property mentioned above:

```bash
    ./gradlew bundle -Penv=authoring
```

The command above will generate an authoring binary archive in the bundles folder named ``crafter-cms-authoring-VERSION.tar.gz``.

### <a id="gradle-tasks"></a>5.2.5 Gradle Tasks

In the section above, we discussed some of the Gradle tasks used for building, starting, stopping and bundling our authoring and delivery environments.  To get more information about all tasks used, run the following:

```bash
   ./gradlew tasks --all
```

Let's take a look at some examples of running a task.

#### 5.2.5.1 downloadTomcat

Downloads the configured Tomcat version and also verifies that the zip file is ok against a sha1 signature.

```bash
   ./gradlew downloadTomcat
```


#### <a id="common-task-properties"></a>5.2.5.2 Common Task Properties

Aside from the tasks that we can run, there are also some properties defined in CrafterCMS that allows us to configure our environment.  Below are the available task properties

**Download Properties**
| Property | Description |
|-----|-----|
| ``tomcat.version`` | Sets the tomcat version to be downloaded |
| ``groovy.version`` | Sets the groovy version to be downloaded |
| ``opensearch.version``| Sets the OpenSearch version to be downloaded |
| ``mariadb4j.version`` | Sets the MariaDb version to be downloaded |
| ``downloadDir`` | Path were all downloads will be saved. Default value is ``./target/downloads`` |

**Environment Building Properties**
| Property | Description |
|-----|-----|
| ``authoring.root`` | Path were a development environment will be generated. <br> Default value is ``./crafter-authoring/`` |
| ``delivery.root`` | Path were a delivery environment will be generated. <br> Default value is ``./crafter-delivery/`` |
| ``crafter.profile`` | Includes Profile in the generation of the development environment. <br>  Default value is false. <br> **If true, MongoDB is required** |
| ``crafter.social`` | Includes Social in the generation of the development environment. <br> Default value is false, <br> **If true, *includeProfile* will be set to true** |

**Authoring Environment Properties** 
| Property | Description |
|-----|-----|
| ``authoring.tomcat.http.port`` | Authoring Tomcat Http port. Default value is 8080 |
| ``authoring.tomcat.shutdown.port`` | Authoring Tomcat shutdown port. Default value is 8005 |
| ``authoring.tomcat.ajp.port`` | Authoring Tomcat AJP port. Default value is 8009 |
| ``authoring.tomcat.https.port`` | Authoring Tomcat SSL(https) port. Default value is 8443 |
| ``authoring.tomcat.debug.port`` | Authoring Tomcat debug port. Default value is 8000 |
| ``authoring.mongo.port`` | Authoring MongoDb port. Default value is 27020 |
| ``authoring.elasticsearch.port`` | Authoring Elasticsearch port. Default value is 9201 |
| ``authoring.smtp.port`` | Authoring SMTP port. Default value is 25 |
| ``authoring.mariadb.port`` | Authoring MariaDb port. Default value is 33306 |
| ``authoring.deployer.port`` | Authoring Deployer port. Default value is 9191 |
| ``authoring.deployer.debug.port`` | Authoring Deployer debug port. Default value is 5000 |
| ``authoring.deployment.dir`` | Authoring deployment directory. <br> Default value is "data/repos/sites" |

**Delivery Environment Properties**
| Property | Description |
|-----|-----|
| ``delivery.tomcat.http.port`` | Delivery Tomcat Http port. Default value is 9080 |
| ``delivery.tomcat.shutdown.port`` | Delivery Tomcat Shutdown port. Default value is 9005 |
| ``delivery.tomcat.ajp.port`` | Delivery Tomcat AJP port. Default value is 9009 |
| ``delivery.tomcat.https.port`` | Delivery Tomcat SSL(https) port. Default value is 9443 |
| ``delivery.tomcat.debug.port`` | Delivery Tomcat debug port. Default value is 9000 |
| ``delivery.mongodb.port`` | Delivery Mongo DB port. Default value is 28020 |
| ``delivery.elasticsearch.port`` | Delivery Elasticsearch port. Default value is 9202 |
| ``delivery.deployer.port`` | Delivery Deployer port. Default value is 9192 |
| ``delivery.deployer.debug.port`` | Delivery Deployer debug port. Default value is 5001 |
| ``delivery.deployment.dir`` | Delivery Deployment directory. <br> Default value is "data/repos/sites" |
| ``delivery.smtp.port`` | Delivery SMTP port. Default value is 25 |


**Other Properties**
| Property | Description |
|-----|-----|
| ``overwriteConfig`` | Overwrite configurations. Default value is false |
| ``backupAndReplaceConfig`` | Backup and replace configurations. Default value is false |

<a id="git-properties" style="font-weight:bold">Git Properties</a> 
| Property | Description |
|-----|-----|
| ``crafter.git.url`` | Git URL <br> Default value is "https://github.com/craftercms/" |
| ``crafter.git.branch`` | Git source branch. Default value is "master" |
| ``crafter.git.remote`` | Git repository. Default value is "origin" |
| ``crafter.git.shallowClone`` | Perform a shallow clone. Default value is false |
| ``crafter.ui.repo`` | Is Studio UI from repository? Default value is false |

Here's an example using one of the task properties, ``gitRepo``,  to get the latest code from CrafterCMS, in order to have the latest updates from the community:

```bash
   ./gradlew update -Pcrafter.git.remote=upstream
```

Here's another example on how to clone, build and bundle from a given tag/branch.  Remember to clone the desired branch/tag of craftercms (As described in the [next section](#git) ),  before running the command below:

```bash
   ./gradlew clone build deploy bundle -Pcrafter.git.branch={BRANCH}/{TAG NAME}
```

Replace {BRANCH} or {TAG NAME} with the branch and tag you'd like to build.

Here's yet another example of building and deploying the authoring environment of CrafterCMS with Crafter Profile included:

```bash
   ./gradlew build deploy -Pcrafter.profile=true -Penv=authoring
```

## <a id="git"></a>5.3 Useful Git Commands

Here are some useful Git commands for setting up our CrafterCMS project.

>**_NOTE:_**
You may notice a few ``.keep`` files in your repository.  Those ``.keep`` files are automatically generated by Studio when empty folders are created, since Git doesn't keep track of folders (and Studio does). It's best if you just leave them there and don't add them to ``.gitignore``


### 5.3.1 Copy CrafterCMS repository and clone submodules

```bash
       git clone https://github.com/craftercms/craftercms.git
       cd craftercms
       git submodule clone
```

### <a id="update-submodules"></a>5.3.2Update Submodules

1. Run

```bash
   git submodule update --force --recursive --remote
```

### 5.3.3 Change Project URL to a fork

1. Change the url on the _.gitmodules_ file
2. Run

```bash
   git submodule sync --recursive
```

### 5.3.4 Change the branch/tag of a project (manual way)

1. Change the `branch` value in the desire project to valid branch,tag or commit id
2. Run

```bash
   git submodule sync --recursive
```

3. Run [update-submodules](#update-submodules)

### 5.3.5 Clone a branch/tag

To clone the branch/tag of craftercms that you want to work with, run:

```bash
    git clone -b<branch> https://github.com/craftercms/craftercms/
```

Replace {BRANCH} or {TAG NAME} with the branch and tag you'd like to build.  After cloning the desired branch, you can now clone, build and bundle from a given tag/branch using the property `crafter.git.branch` as described in an earlier section [Git Properties](#git-properties)

