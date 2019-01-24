#!/bin/bash

git checkout master
git pull
git merge kimura -m "`date`"
git commit -m "`date`"
git push
git checkout kimura
git merge master
