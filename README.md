Vagrant box for Koha RESTful docker container
================

This repo contains a git fork of Biblibre's Koha-restful API.

Upstream: http://git.biblibre.com/biblibre/koha-restful.git

Origin:   http://github.com/digibib/koha-restful.git

## Installation

`make` : will setup box, pull images and setup koha and koha restful

for development (editing code inline), you will need 

`make run_restful_dev`

## Environment variables

`KOHA_INSTANCE=name of instance`
`KOHA_SRC=path_to_koha_installation`

## Local Volumes

Exposed volumes are:

```
/etc/koha/sites/$KOHA_INSTANCE/rest
$KOHA_SRC/lib/Koha/REST
$KOHA_SRC/t/rest
```

`make upgrade` upgrade koha image

`make run` setup koha restful container and koha container with link

`make logs-f` watch koha installation logs

You should now enjoy access to Koha RESTful inside koha container

## Development and Testing

`make run_restful_dev` : setup koha restful from local source tree and start koha kontainer

`make test` : validate koha restful sanity and run tests

Running tests inside koha_container:

`sudo docker exec koha_docker 'cd /usr/share/koha && \
  KOHA_CONF=/etc/koha/sites/name/koha-conf.xml \
  prove -Ilib t/rest'`

