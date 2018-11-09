#!/usr/bin/env bash

# header-deps.sh: a "package manager" for single-file C libraries.
# See https://github.com/pepaslabs/header-deps.sh

# Copyright 2018 Jason Pepas
# Released under the terms of the MIT license.
# See https://opensource.org/licenses/MIT

repo_url=https://raw.githubusercontent.com/pepaslabs/header-deps.sh/master/header-libs.txt

set -e -o pipefail

test -e header-deps.txt \
    || (echo "Error: header-deps.txt not found." >&2 ; exit 1)

deps_line_count=`wc -l header-deps.txt | awk '{ print $1 }'` 

repo_file=`mktemp`
curl -s $repo_url >> $repo_file

deps_line_num=1
while test $deps_line_num -le $deps_line_count
do
    deps_pkg=`head -n$deps_line_num header-deps.txt | tail -n1`

    repo_line_num=1
    repo_line_count=`wc -l $repo_file | awk '{ print $1 }'`
    while test $repo_line_num -le $repo_line_count
    do
        repo_pkg=`head -n$repo_line_num $repo_file | tail -n1`

        repo_line_num=$(( $repo_line_num + 1 ))
        test $repo_line_num -le $repo_line_count \
            || (echo "Error: malformed repo file." >&2 ; exit 1)
        repo_pkg_url=`head -n$repo_line_num $repo_file | tail -n1`

        if [ "$dep_pkg" == "$repo_pkg" ]
        then
            echo "GET $repo_pkg_url"
            curl -s -O $repo_pkg_url
        fi
        
        repo_line_num=$(( $repo_line_num + 1 ))
    done

    deps_line_num=$(( $deps_line_num + 1 ))
done

rm -f $repo_file
