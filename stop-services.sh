#**********************************************************************
#    Copyright (c) 2017 Henry Seurer
#
#    Permission is hereby granted, free of charge, to any person
#    obtaining a copy of this software and associated documentation
#    files (the "Software"), to deal in the Software without
#    restriction, including without limitation the rights to use,
#    copy, modify, merge, publish, distribute, sublicense, and/or sell
#    copies of the Software, and to permit persons to whom the
#    Software is furnished to do so, subject to the following
#    conditions:
#
#    The above copyright notice and this permission notice shall be
#    included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#    OTHER DEALINGS IN THE SOFTWARE.
#
#**********************************************************************

version: "2"
services:
  consul:
    image: hypriot/rpi-consul:v0.7.0-test1
    ports:
      - "8500:8500"
    command: agent -server -bootstrap -client 0.0.0.0 -advertise $DOCKER_IP -ui -data-dir=/tmp/consul
    network_mode: host

  traefik:
    image: hypriot/rpi-traefik:latest
    ports:
      - "8080:8080"
      - "8081:8081"
    network_mode: host
    extra_hosts:
      - "consul:${DOCKER_IP}"
    volumes:
      - "$PWD/traefik/traefik.toml:/etc/traefik/traefik.toml"
    depends_on:
      - consul

  registrator:
    image: hypriot/rpi-registrator:latest
    volumes:
      - "/var/run/docker.sock:/tmp/docker.sock"
    command: -ip $DOCKER_IP consul://$DOCKER_IP:8500
    network_mode: host
    logging:
      driver: none
    depends_on:
      - consul

#!/usr/bin/env bash
export DOCKER_IP=$(/sbin/ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')

docker-compose stop