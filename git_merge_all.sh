#!/bin/bash

git checkout kimura
git add *
git commit -m "`date`"
git push
git checkout master
git merge kimura -m "`date`"
git checkout kimura
