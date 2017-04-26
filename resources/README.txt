----------
Crafter CMS
-----------

Crafter CMS is an open-source, Java-based, Web content management system for
Web sites, mobile apps, VR and more, designed for ease of development and scaling.

Requirements
------------
To run this bundle you must have Java 1.8 installed.


Starting Crafter CMS Server
---------------------------
From the command line, navigate to the INSTALL_PATH/crafter directory, and execute the startup script:

    On Linux/Unix:

        $ ./startup.sh

    On Windows:

        $ startup.bat


You can find detailed log information from the server in: INSTALL_FOLDER/apache-tomcat/logs/catalina.out.


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
From the command line, navigate to the INSTALL_PATH/crafter directory, and execute the startup script:

    On Linux/Unix:

        $ ./shutdown.sh

    On Windows:

        $ shutdown.bat


Going Further
-------------
To learn more about content modeling, publishing, personalization, configuration and other topics
please visit: http://docs.craftercms.org/en/latest/index.html

Additional Resources:
* http://craftersoftware.com/resources/white-papers
* http://craftersoftware.com/resources/e-books
* http://craftersoftware.com/resources/webcasts