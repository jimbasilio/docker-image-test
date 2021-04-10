#!/bin/bash

function waitforenter() {
    echo
    echo "Press any key to continue"
    read
}

function cleanup() {
    docker ps -a | grep "jim" | awk '{print $1}' | xargs docker stop
    docker ps -a | grep "jim" | awk '{print $1}' | xargs docker rm
    docker images -a | grep "jim" | awk '{print $3}' | xargs docker rmi
}

echo "Cleaning up (might create errors if never executed before)"
cleanup

echo "Building base image and run on port 2999"
docker build -t jim:base -f Dockerfile.base .
docker run -d -p 2999:3000 --name jim-base jim:base

echo "Curl base image 2999"
sleep 1
curl localhost:2999

waitforenter

echo "Building first image which uses base as foundation and run on port 3000"
docker build -t jim:first -f Dockerfile.first .
docker run -d -p 3000:3000 --name jim-first jim:first

echo "Curl base image 3000"
sleep 1
curl localhost:3000

waitforenter

echo "Build new base image with 'bugfix' (new app.js in CMD)"
docker stop jim-base
docker rm jim-base
docker build -t jim:base -f Dockerfile.base.bugfix .
docker run -d -p 2999:3000 --name jim-base jim:base

echo "Curl base image 2999, should show new message"
sleep 1
curl localhost:2999

waitforenter

echo "Build new first image which uses base as foundation and run on port 3000"
docker stop jim-first
docker rm jim-first
docker build -t jim:first -f Dockerfile.first.bugfix .
docker run -d -p 3000:3000 --name jim-first jim:first

echo "Curl base image 3000, should show new message from new base image even though tag has not changed in FROM for Dockerfile"
sleep 1
curl localhost:3000

waitforenter

echo "Cleaning up"
cleanup
