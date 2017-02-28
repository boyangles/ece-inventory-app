## Deployment Guide

This file will guide you through the steps of deploying your own inventory system. Currently, this guide assumes you have Git configured and know how to clone a remote repository. 

Our inventory system now runs on Duke Colab VM!

#### Prerequisites:
 - This application is being built with Ruby on Rails. The current deployment was built with Ruby version 2.3.3 and Rails 5.0.1. 
 - Git version 2.8.1 used
 - Brew: Homebrew version 1.1.9
 - PostgreSQL: version 9.6.1
 - Bundler version 1.13.7

#### Cloning the repository:
 - To begin, select Clone or Download on GitHub, then copy the URL to your terminal git the command: ```git clone the_url```
 - Ensure that your Gemfile is updated accordingly and installed by running ```bundle install```. This should install all frameworks and dependencies correctly. 


#### Testing locally:
 - To seed your database with dummy users, run ```rails db:migrate:reset``` then ```rails db:seed``` to drop your database and seed it with fake users and items. 
 - Run ```rails server``` to start an instance of your local server over port 3000. 
 - Open your browser and go to localhost:3000
 
 
#### Deploying over Duke Colab Server
 - Spicy Software Inventory System is officially running on an nginx web server on a Colab server. 
 - In order to update and deploy over your remote server, follow the Colab guides to set up your environment. http://docs.colab.duke.edu/guides/ssh.html. Install the necessary versions of ruby, rails, etc.
 - Updating:
    - Sign on to the remote server. Currently, we are using 114. To update, git pull from our remote repository here, run ```rails assets:precompile``` to compile your css, then run necessary migrations with ```rails db:migrate``` and update Swagger with ```rails swagger:docs```. A simple ```rails server``` will then start your server and you should be able to access spicysoftware.colab.duke.edu through your local browser. 

#### Swagger API Debugger
 - You may need to install the submodule Swagger UI. 
   -  Run the command ```git submodule add https://github.com/swagger-api/swagger-ui.git swagger```
   -  If the git submodule is already present, run ```git submodule update --init --recursive```
   -  Swagger UI should now be enabled.
 - To test the API, run ```rails swagger:docs```. This will generate the .json files that Swagger builds to generate its UI. 
 - Anytime changes are done to swagger API elements, run ```rails swagger:docs``` to update
 
