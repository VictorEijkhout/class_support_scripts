#!/bin/bash

echo "==== $(pwd) : $1 ===="
git log -p -- "$1" | grep Date


