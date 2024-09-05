#!/bin/bash

sub_module_path=$1
echo "Removing .git/modules/${sub_module_path}"
git submodule deinit -f $sub_module_path
rm -rf ".git/modules/${sub_module_path}"
git rm -f $sub_module_path

