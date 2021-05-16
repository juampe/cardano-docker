#!/bin/bash
#Sorry I have to clear repo files due to Git LFS free quota
#At this moment revenuest does not permit keep a LFS repository
#This is to try to maintain the latest cardano repo release
git filter-branch --tree-filter 'rm -f repo/*' HEAD
git push origin --force --all
git add repo/*
git commit -m "latest version (sorry no budget for Git LFS)"
