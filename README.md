# Crafter CMS

Crafter CMS is an open source content management system for Web sites, mobile apps, VR and more. You can learn more about Crafter here: http://docs.craftercms.org/en/3.0/index.html

This repository is the parent project that builds everything and helps you build one of two things:

1. Deployable Crafter CMS bundle

2. Developer's environment so you can compile and contribute to Crafter CMS

# 1. Initial Setup
You must have these prerequisites on your system before you begin:
* Java 8
* Git 2.x+
* Maven 3.3.x+

**OS X extra prerequisite**

* If you're on OS X, then using  [`brew`](http://brew.sh) install the latest `openssl` formula, like this: `brew install openssl`

**Linux prerequisite**

* Some of the scripts uses `lsof`.  Please note that some Linux distributions does not come with `lsof` pre-installed and so, may need to be installed.  To install `lsof` for Debian-based Linux distros: `apt-get install lsof`.  To install `lsof` for RedHat-based Linux distros: `yum install lsof`

Let's begin :)

If you're building a deployable Crafter CMS bundle, we'll clone the master branch:

```bash
git clone https://github.com/craftercms/craftercms.git
```

OR

If you would like to contribute to Crafter CMS, to build a developer's environment, we'll need to clone the develop branch:

```bash
git clone https://github.com/craftercms/craftercms.git -b develop
```

# 2. Build a Deployable Bundle

To build a deployable and distributable bundle of Crafter CMS, use the Gradle task `bundle`. This task will generate `.zip` and `.tar.gz` files ready to be deployed to any system.

Before using `bundle` task make sure that the enviroment have been created and deployed gradle tasks `build` and `deploy`

Archives will be named `crafter-cms-${environment}.tar.gz` and `crafter-cms-${environment}.zip` and can be found in the `bundles` folder.

```bash
./gradlew init build deploy bundle
```

To run Crafter CMS from the bundle, unzip and follow the instructions in the bundle's `README.txt`.

## 2.1. Build an Environment Specific Bundle
Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

To build a bundle for a specific environment:

```bash
    ./gradlew bundle -Penv=authoring
```
Archives will be named `crafter-cms-authoring.tar.gz` and `crafter-cms-authoring.zip` and can be found in the `bundles` folder.

For the `delivery` environment, simply substitute the `env=authoring` with `env=delivery`.

## 2.2 Init/Update, Build and Bundle from a Tag/Branch

To download, build and generate a bundle from a given tag or branch of the source code,

1. Clone the branch/tag of craftercms that you want to work with
```bash
    git clone -b<branch> https://github.com/craftercms/craftercms/
```
2. Download, build and bundle the branch that you want to work with
```bash
    ./gradlew init build deploy bundle -Pcrafter.git.branch={BRANCH}/{TAG NAME}
```

Replace {BRANCH} or {TAG NAME} or \<branch\> with the branch and tag you'd like to build.

**Note**:
When using a tag-based build, you're essentially cloning a point in time to build that specific version of Crafter CMS. That implies that you won't be able to update/nor push changes back.

# 3. Build a Developer's Environment
Crafter CMS is built along a microservices architecture, and as such, comprises a number of head-less, RESTful, modules that work together to provide the final solution. In this section, we'll start with the simple case of _build everything_/_run everything_, and then move on to building/hacking individual modules.


## 3.1. Build, Start and Stop All 
### 3.1.1. Build All
Build all Crafter CMS modules

```bash
    ./gradlew init build deploy
```

### 3.1.2. Start All
Start Crafter CMS,
 
 ```bash
    ./gradlew start
```

You can now point your browser to [http://localhost:8080/studio](http://localhost:8080/studio) and start using Crafter CMS. To get started with your first Crafter CMS experience, you can follow this guide: [http://docs.craftercms.org/en/3.0/content-authors/index.html](http://docs.craftercms.org/en/3.0/content-authors/index.html).

##### Note
* The authoring environment runs on port `8080`, a great place to start, while the delivery environment runs on port 
`9080`.

### 3.1.3. Stop All
Stop Crafter CMS,

```bash
    ./gradlew stop
```

### 3.2. Two Environments: Authoring vs Delivery
You might have noticed that you essentially have two environments built and running: `authoring` and `delivery`. Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

As a developer, you can use an `authoring` environment for most tasks without the need to run a `delivery` environment. It's important to note that `delivery` essentially runs the same software that's in `authoring` except Crafter Studio (the authoring tools).
By default, this project will build both environments unless instructed otherwise. The `authoring` environment runs at [http://localhost:8080/studio](http://localhost:8080/studio), whereas the `delivery` environment runs at [http://localhost:9080/studio](http://localhost:9080/).

### 3.2.1. Build, Start, and Stop a Specific Environment
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

### 3.3. Crafter Modules
The mechanics for working with a single module are similar to working with _all_, with one exception: You can deploy a module to one or both environments (`authoring`/`delivery`).

Crafter CMS comprises the modules:
* [`core`](http://docs.craftercms.org/en/3.0/developers/projects/core/index.html)
* [`commons`](http://docs.craftercms.org/en/3.0/developers/projects/commons/index.html)
* [`engine`](http://docs.craftercms.org/en/3.0/developers/projects/engine/index.html)
* [`studio`](http://docs.craftercms.org/en/3.0/developers/projects/studio/index.html)
* [`search`](http://docs.craftercms.org/en/3.0/developers/projects/search/index.html)
* [`profile`](http://docs.craftercms.org/en/3.0/developers/projects/profile/index.html)
* [`social`](http://docs.craftercms.org/en/3.0/developers/projects/social/index.html)
* [`deployer`](http://docs.craftercms.org/en/3.0/developers/projects/deployer/index.html)

You'll find these projects checked out and ready for you to contribute to in the folder `src/{moduleName}`.

### 3.3.1. Forking a Module
Start by forking the module you want to work on. You can follow the [GitHub instructions](https://help.github.com/articles/fork-a-repo/).
The next step is to switch the origin url location to be the one just forked, to do so you can use [these GitHub instructions](https://help.github.com/articles/changing-a-remote-s-url/).
The last step will be to add an upstream repository from the main `craftercms` repo to your own. Follow [these steps](https://help.github.com/articles/fork-a-repo/#step-3-configure-git-to-sync-your-fork-with-the-original-spoon-knife-repository)
to make it happen.
You can now work in your local system, and build/deploy and ultimately push to your fork. We welcome code contributions, so please do send us pull-requests.

To update your project with the latest from your repo:

```bash
    ./gradlew update
```

To get the latest code from `craftercms`, in order to have the latest updates from the community:

```bash
    ./gradlew update -Pcrafter.git.remote=upstream
```

### 3.3.2. Update, Build, Deploy, Start, and Stop a Module
You can update, build, deploy, start or stop a module by:

```bash
    ./gradlew update -PmoduleName=studio
    ./gradlew build -PmoduleName=studio
    ./gradlew deploy -PmoduleName=studio -Penv=authoring
    ./gradlew start -PmoduleName=studio -Penv=authoring
    ./gradlew stop -PmoduleName=studio -Penv=authoring
```

##### Note
* If you don't specify the `env` parameter, it means all environments (where applicable).
* In the current version of Crafter CMS, some services run in the same Web container, and that implies the stopping/starting of one of these services will cause other services to stop/start as well.

# 4. Advanced Topics
For more detailed information and advanced topic, please visit the [detailed documentation](http://docs.craftercms.org/en/3.0/developers/projects/craftercms/index.html).
