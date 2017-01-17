# Drone

*this project is no longer under active development and is provided as-is*

A web capture and export microservice built around the PhantomJS headless browser.

<a href="doc/drone.targets.png"><img src="doc/drone.targets.png" width="150"></a>
<a href="doc/drone.console.png"><img src="doc/drone.console.png" width="150"></a>

#### Features

* PNG and PDF support
* Multithreaded design
* Oodles of configuration parameters
* CSS, HTML and JavaScript injection for fine tuning
* A nice admin interface

#### Stack

* Ruby
* Node
* PhantomJS
* Redis


## Usage

### Setup

Use `docker-compose up`.


### Authentication

In textbook scenario, Drone will be responsible for taking pictures of web pages for a specific application.  If the application contains sensitive data, Drone can authenticate via OAuth.


### Command Line

#### Targets (URLs)

List all active targets:

```
docker-compose run web bundle exec bin/drone list
```

Add a target:

```
docker-compose run web bundle exec bin/drone add \
  --url=http://www.google.com
```

Remove a target:

```
docker-compose run web bundle exec bin/drone remove \
  --id=1
```


#### Capturing

Manually capture a target:

```
docker-compose run web bundle exec bin/drone capture \
  --id=1

docker-compose run web bundle exec bin/drone capture \
  --url=http://www.google.com
```

Capture targets via background service:

```
docker-compose run web bundle exec bin/drone work
```

#### Settings

Dump current configuration:

```
docker-compose run web bundle exec bin/drone config
```

Open a console, ala `rails console`:

```
docker-compose run web bundle exec bin/drone console
```

Synchronize and list all authentication credentials:

```
docker-compose run web bundle exec bin/drone credentials
```

Delete everything and start with a clean slate:

```
docker-compose run web bundle exec bin/drone reset
```


### Web Interface

The admin UI is available at [http://localhost:9000/](http://localhost:9000/).
