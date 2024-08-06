#!/bin/sh

puma -C puma.rb config.ru &
PUMA_PID=$!

sleep 3
echo 'About to do a curl which will crash puma...'
sleep 1

curl http://localhost:9292

kill $PUMA_PID