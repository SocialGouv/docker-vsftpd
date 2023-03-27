#!/bin/sh
docker-compose up --build -d
exec docker-compose logs -f