# The QA Network
## By Shaunak Pagnis and Sumeet Menon

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

~~~shell
foreman start
~~~

This command will start the following processes:

1. A service discovery app on port 4567
2. A load balancer app on port 9292
3. A question service app on port 3003
4. An answer service app on port 3002

Note: For the demo we will be setting up these on separate machines, but by using `foreman` you can quickly set up on one machine.


Please email spagnis1@umbc.edu in case you have any difficulty in installing. Thank you!
