----------
Crafter CMS
-----------

Crafter CMS is an open-source, Java-based, Web content management system for
Web sites, mobile apps, VR and more, designed for ease of development and scaling.

Requirements
------------
To run this bundle you must have Java 1.8 installed.

**note for Linux users:
    Some of the scripts uses `lsof`.  Please note that some Linux distributions does not come with `lsof` pre-installed and so, may need to be installed.

    To install `lsof` for Debian-based Linux distros: `apt-get install lsof`
    To install `lsof` for RedHat-based Linux distros: `yum install lsof`


Starting Crafter CMS Server
---------------------------
From the command line, navigate to the INSTALL_PATH/ directory, and execute the startup script:

    On Linux/Unix:

        $ bin/startup.sh

    On Windows:

        $ bin\startup.bat


You can find detailed log information from the server in: INSTALL_FOLDER/logs/catalina.out.


Logging In
----------
Open a web browser and go to the URL: http://localhost:8080/studio

Login with the following:

    username: admin
    password: admin

After logging in, you should be redirected to the MySites screen, and you’re now ready to create your first website!


Create a New Site
-----------------
Once logged in:
    1. Click on `Create Site` 
    2. Give the site a friendly name for the Site Id 
    3. Choose a blueprint (a site template) 
    4. and click `Create`  

Studio will create your new site and redirect you to a preview where you can preview and edit your site. 


Stopping Crafter CMS Server
---------------------------
From the command line, navigate to the INSTALL_PATH/ directory, and execute the startup script:

    On Linux/Unix:

        $ bin/shutdown.sh

    On Windows:

        $ bin\shutdown.bat


Going Further
-------------
To learn more about content modeling, publishing, personalization, configuration and other topics
please visit: http://docs.craftercms.org

Additional Resources:
* http://craftersoftware.com/resources/white-papers
* http://craftersoftware.com/resources/e-books
* http://craftersoftware.com/resources/webcasts
