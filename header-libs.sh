#!/usr/bin/env bash

# header-libs.sh: a "package manager" for single-file C libraries.
# See https://github.com/pepaslabs/header-libs.sh

# Copyright 2018 Jason Pepas
# Released under the terms of the MIT license.
# See https://opensource.org/licenses/MIT

set -e -o pipefail

test -e header-deps.txt \
    || (echo "Error: header-deps.txt not found." >&2 ; exit 1)

deps_line_count=`wc -l header-deps.txt | awk '{ print $1 }'` 

repo_file=`mktemp`

deps_line_num=1
while test $deps_line_num -le $deps_line_count
do
    deps_line=`head -n$deps_line_num header-deps.txt | tail -n1`

    if [ "$deps_line" == "index" ]
    then
        deps_line_num=$(( $deps_line_num + 1 ))
        dep_url=`head -n$deps_line_num header-deps.txt | tail -n1`
        curl -s $dep_url >> $repo_file
    else
        dep_pkg=$deps_line

        deps_line_num=$(( $deps_line_num + 1 ))
        test $deps_line_num -le $deps_line_count \
            || (echo "Error: malformed header-deps.txt." >&2 ; exit 1)
        dep_version=`head -n$deps_line_num header-deps.txt | tail -n1`
        
        repo_line_num=1
        repo_line_count=`wc -l $repo_file | awk '{ print $1 }'`
        while test $repo_line_num -le $repo_line_count
        do
            repo_pkg=`head -n$repo_line_num $repo_file | tail -n1`

            repo_line_num=$(( $repo_line_num + 1 ))
            test $repo_line_num -le $repo_line_count \
                || (echo "Error: malformed repo file." >&2 ; exit 1)
            repo_version=`head -n$repo_line_num $repo_file | tail -n1`

            repo_line_num=$(( $repo_line_num + 1 ))
            test $repo_line_num -le $repo_line_count \
                || (echo "Error: malformed repo file." >&2 ; exit 1)
            repo_url=`head -n$repo_line_num $repo_file | tail -n1`

            if [ "$dep_pkg" == "$repo_pkg" -a "$dep_version" == "$repo_version" ]
            then
                echo "GET $repo_url"
                curl -s -O $repo_url
            fi
            
            repo_line_num=$(( $repo_line_num + 1 ))
        done
    fi

    deps_line_num=$(( $deps_line_num + 1 ))
done

rm -f $repo_file
