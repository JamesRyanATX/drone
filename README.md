# Drone

A web capture and export microservice built around the PhantomJS headless browser.

<a href="doc/drone.targets.png"><img src="doc/drone.targets.png" width="150"></a>
<a href="doc/drone.console.png"><img src="doc/drone.console.png" width="150"></a>

#### Features

* PNG and PDF support
* Multithreaded design for fast horizontal scaling
* Oodles of configuration parameters
* CSS, HTML and JavaScript injection for fine tuning
* A nice admin interface

#### Stack

* Ruby 2.1
* Grape
* Rack
* PhantomJS 2.0
* Redis

## Setup

The following applies to Ubuntu 14.04 Server, but can be extrapolated to other Linux distros.

#### 1. Install Dependencies

``` sh
sudo apt-get install git redis-server imagemagick
```

[RVM](https://rvm.io/rvm/install) is recommended, although any installation of Ruby 2.1 will suffice.

#### 2. Install Drone

``` sh
git clone https://github.com/JamesRyanATX/drone.git
cd drone
rvm install ruby-2.1.5
bundle install

DRONE_ENV=development bin/drone install
```

#### 3. Install PhantomJS

Drone requires **PhantomJS 2.0.0 or higher**.  Binaries for Ubuntu 14.04 and OS X are included in this repo, but if  `bin/drone install` fails, you will need to compile PhantomJS yourself (or find the correct package online).

After building PhantomJS, copy or symlink the resulting binary to the `bin/phantomjs`:

``` sh
ln -s /path/to/phantomjs bin/phantomjs
```

#### 4. Start the App

``` sh
foreman start -f Procfile.dev
```

The admin UI should now be available at [http://localhost:9000/](http://localhost:9000/).

Copy Procfile.dev to Procfile.local if you'd like to make changes to Foreman locally.
