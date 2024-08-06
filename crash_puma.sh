#!/bin/sh

set -e

puma -C puma.rb config.ru &

sleep 3
echo 'About to do a wget which will crash puma...'
sleep 1

curl http://localhost:9292
