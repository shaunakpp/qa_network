# The QA Network 
## Project for CMSC 621 Advanced Operating Systems
### By Shaunak Pagnis and Sumeet Menon

A prototype for a distributed Question and Answer based network.

## Installation Instructions

This project is written in the Ruby programming language, please follow the following steps to install ruby.

Note: We're assuming a linux/macOS based machine for running this project

### Installing Ruby

Install RVM

~~~shell
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
~~~

~~~shell
curl -sSL https://get.rvm.io | bash -s stable
~~~

~~~shell
source ~/.rvm/scripts/rvm
~~~

~~~shell
rvm requirements
~~~

Install ruby 2.5.1 using RVM

~~~shell
rvm install ruby 2.5.1
rvm use 2.5.1 --default
~~~

### Installing Redis

We recommend using the following instructions for setting up redis:

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-redis

### Project Setup

After installing Ruby, we will now setup the application itself.
`cd` into the project directory and then run:
~~~shell
gem install bundler
gem install foreman
bundle install
~~~

The above command will install all the necessary libraries required for this project.
Once installation is complete, you can now run this project using following command:

Run the service discovery module:
~~~shell
bundle exec ruby service_discovery/app.rb
~~~
After the above command starts the service discovery server on port 4567
Note: It is imperative that we start the service discovery before running any other service.

Then run this command:
~~~shell
foreman start
~~~

This will start the following processes:

1. A load balancer app on port 9292
2. A question service app on port 3003
3. An answer service app on port 3002
4. A blockchain viewer app on port 3005
5. A client app on port 3000

Note: For the demo we will be setting up these on separate machines, but by using `foreman` you can quickly set up on one machine.


To add questions:

Visit http://localhost:3000 where you can see a create question link, click it and then fill the form to create a question.


To add an answer to a question:

Click on the 'View Answers' link which will direct you to the answers page where you can create a new answer

Please email spagnis1@umbc.edu in case you have any difficulty in installing. Thank you!
