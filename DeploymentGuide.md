## Deployment Guide

This file will guide you through the steps of deploying your own inventory system. Currently, this guide assumes you have Git configured and know how to clone a remote repository. 

Our inventory system currently runs on Heroku, which is Cloud Platform As A Service (PaaS) that serves as a web application deployment model. 

#### Prerequisites:
 - This application is being built with Ruby on Rails. The current deployment was built with Ruby version 2.3.3 and Rails 5.0.1. 
 - Git version 2.8.1 used
 - Brew: Homebrew version 1.1.9
 - PostgreSQL: version 9.6.1
 - Bundler version 1.13.7
 - Recommended browser is Chrome, version 55.0.2883.95+
 - Ensure your wifi does not block the heroku domain with firewalls 

#### Cloning the repository:
 - To begin, select Clone or Download on GitHub, then copy the URL to your terminal git the command: <git clone the_url>
 - Ensure that your Gemfile is updated accordingly and installed by running <bundle install>. This should install all frameworks and dependencies correctly. 


#### Testing locally:
 - To seed your database with dummy users, run <rails db:migrate:reset> then <rails db:seed>
 - Run <rails server> to start an instance of your local server over port 3000. 
 - Open Chrome and go to localhost:3000
 - You should see a working instance of the application running. 

#### Deploy over Heroku:
 - Create a free Heroku Account and set up a new app. 
 - I recommend consulting this Heroku tutorial to set up your first app - https://devcenter.heroku.com/articles/getting-started-with-rails5. Most sections are already taken care of. Being at "Deploy your application to Heroku" to see how to deploy on a remote server.

