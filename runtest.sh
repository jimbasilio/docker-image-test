#!/bin/bash

function waitforenter() {
    echo
    echo "Press ENTER key to continue"
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

echo "Curl base image 2999, should return BASE"
sleep 1
curl localhost:2999

waitforenter

echo "Building middle image which uses base as foundation and run on port 3000"
docker build -t jim:middle -f Dockerfile.middle .
docker run -d -p 3000:3000 --name jim-middle jim:middle

echo "Curl middle image 3000, should return BASE"
sleep 1
curl localhost:3000

waitforenter

echo "Building last image which uses middle as foundation and run on port 3001"
docker build -t jim:last -f Dockerfile.last .
docker run -d -p 3001:3000 --name jim-last jim:last

echo "Curl base image 3001, should return BASE"
sleep 1
curl localhost:3001

waitforenter

echo "Stopping jim-base containers"
docker stop jim-base
docker rm jim-base
echo "Build new base image with 'bugfix' (new app.bugfix.base.js in CMD, changes return string)"
docker build -t jim:base -f Dockerfile.base.bugfix .
docker run -d -p 2999:3000 --name jim-base jim:base

echo "Curl base image 2999, should show BASE PATCHED"
sleep 1
curl localhost:2999

waitforenter

echo "Stopping jim-last containers"
docker stop jim-last
docker rm jim-last
echo "Build new last image which uses middle as foundation and run on port 3001"
docker build -t jim:last -f Dockerfile.last .
docker run -d -p 3001:3000 --name jim-last jim:last

echo "Curl last image 3001, BASE means it took the original image (not what that base tag is pointing to). BASE PATCHED means it took most recent tag"
sleep 1
curl localhost:3001

waitforenter

echo "Stopping jim-middle containers"
docker stop jim-middle
docker rm jim-middle

echo "Building middle image which uses base as foundation and run on port 3000"
docker build -t jim:middle -f Dockerfile.middle .
docker run -d -p 3000:3000 --name jim-middle jim:middle

echo "Curl middle image 3000, should return BASE PATCHED"
sleep 1
curl localhost:3000

waitforenter

echo "Stopping jim-last containers"
docker stop jim-last
docker rm jim-last
echo "Build new last image which uses middle as foundation and run on port 3001"
docker build -t jim:last -f Dockerfile.last .
docker run -d -p 3001:3000 --name jim-last jim:last

echo "Curl last image 3001, BASE means it took the original image (not what that base tag is pointing to). BASE PATCHED means it took most recent tag"
sleep 1
curl localhost:3001

waitforenter

echo "Cleaning up"
cleanup
