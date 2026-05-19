#!/bin/bash
spawn-fcgi -n -a 127.0.0.1 -p 8080 -- ./server &
nginx -g "daemon off;"