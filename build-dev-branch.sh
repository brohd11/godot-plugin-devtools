#!/bin/bash
set -e

git checkout main
git checkout -b main-dev

git branch --set-upstream-to=origin/main-dev main-dev

git cherry-pick origin/icon-cast
git cherry-pick origin/tree-item-count
git cherry-pick origin/update-dock-4.6
git cherry-pick origin/add-multi-win
git cherry-pick origin/rm-tscn-print