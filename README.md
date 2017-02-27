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
git clone https://github.com/craftercms/craftercms.git
```

#2. Build a Deployable Bundle
To build a deployable and distributable bundle of Crafter CMS, use the Gradle task `bundle`. This task will generate `.zip` and `.tar.gz` files ready to be deployed to any system.

Archives will named `crafter-cms.tar.gz` and `crafter-cms.zip` and can be found in the `bundles` folder.

```bash
./grablew bundle
```

To run Crafter CMS from the bundle, unzip and follow the instructions in the bundle's `README.txt`.

##2.1. Build an Environment Specific Bundle
Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

To build a bundle for a specific environment:

```bash
    ./gradlew bundle -Penv=authoring
```
Archives will named `crafter-cms-authoring.tar.gz` and `crafter-cms-authoring.zip` and can be found in the `bundles` folder.

For the `delivery` environment, simply substitute the `env=authoring` with `env=delivery`.

#3. Build a Developer's Environment
Crafter CMS is built along a microservices architecture, and as such, comprises a number of head-less, RESTful, modules that work together to provide the final solution. In this section, we'll start with the simple case of _build everything_/_run everything_, and then move on to building/hacking individual modules.

##3.1. Build, Start and Stop All 
###3.1.1. Build All
Build all Crafter CMS modules

```bash
    ./gradlew init build deploy
```

###3.1.2. Start All
Start Crafter CMS,
 
 ```bash
    ./gradlew start
```

You can now point your browser to [http://localhost:8080/studio](http://localhost:8080/studio) and start using Crafter CMS. To get started with your first Crafter CMS experience, you can follow this guide: [http://docs.craftercms.org/en/latest/content-authors/index.html](http://docs.craftercms.org/en/latest/content-authors/index.html).

#####Note
* The authoring environment runs on port `8080`, a great place to start, while the delivery environment runs on port 
`9080`.

###3.1.3. Stop All
Stop Crafter CMS,

```bash
    ./gradlew stop
```

##3.2. Two Environments: Authoring vs Delivery
You might have noticed that you essentially have two environments built and running: `authoring` and `delivery`. Crafter CMS is a decoupled CMS, and that means you have an `authoring` environment that caters to content creators, and a different environment, `delivery`, that handles the end-users that use the experience created by the former.

As a developer, you can use an `authoring` environment for most tasks without the need to run a `delivery` environment. It's important to note that `delivery` essentially runs the same software that's in `authoring` except Crafter Studio (the authoring tools).

By default, this project will build both environments unless instructed otherwise. The `authoring` environment runs at [http://localhost:8080/studio](http://localhost:8080/studio), whereas the `delivery` environment runs at [http://localhost:8080/studio](http://localhost:9080/).

###3.1.1. Build, Start, and Stop a Specific Environment
Much like building/starting/stopping All, to perform the same for one of the two environments.

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
    ./gradlew build -PmoduleName=studio
    ./gradlew deploy -PmoduleName=studio -Penv=authoring
    ./gradlew start -PmoduleName=studio -Penv=authoring
    ./gradlew stop -PmoduleName=studio -Penv=authoring
```

#####Note
* If you don't specify the `env` parameter, it means all environments (where applicable).
* In the current version of Crafter CMS, some services run in the same Web container, and that implies the stopping/starting of one of these services will cause other services to stop/start as well.

#4. Advanced Topics
For more detailed information and advanced topic, please visit the [detailed documentation](http://docs.craftercms.org/en/latest/developers/projects/craftercms).
