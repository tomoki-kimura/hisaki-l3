#!/bin/bash

git checkout master
git merge kimura -m "`date`"
git commit -m "`date`"
git push
git checkout kimura
