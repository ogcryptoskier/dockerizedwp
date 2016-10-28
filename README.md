# dockerizedwp
## This is a dockerized installation of wordpress, mysql, nginx, redis, and supervisord.  Many thanks to Tomaž Zaman at https://codeable.io for his awesome Docker + WordPress series.  Many features herein are borrowed from articles.

## Dependencies

You need Docker to build and run the containers configured in this repo.

## Installation

If you would like to update this template installation of WordPress and related software components, simply clone or download this repo and have at it.

If you would like to use this repository as the template for your personal dockerized WordPress environment, first download it, then optionally copy it's contents into a new, appropriately named repository or directory, and finally build your WordPress environment by running these `docker-compose` commands from the base of the new repository or directory:

```
$ docker-compose build
# some time passes
$ docker-compose up
```
