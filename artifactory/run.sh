#!/bin/bash
docker-compose -f artifactory-oss-postgresql.yml -p af stop
docker-compose -f artifactory-oss-postgresql.yml -p af rm
docker-compose -f artifactory-oss-postgresql.yml -p af build
docker-compose -f artifactory-oss-postgresql.yml -p af up 
