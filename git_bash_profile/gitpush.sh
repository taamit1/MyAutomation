#!/bin/bash

echo "Starting git pull and then commit, push"

git pull
git add --all
git commit -m "$*"
git push
