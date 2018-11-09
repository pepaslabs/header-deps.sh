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
    dep_header=`head -n$deps_line_num header-deps.txt | tail -n1`
    found_dep="no"

    repo_line_num=1
    repo_line_count=`wc -l $repo_file | awk '{ print $1 }'`
    while test $repo_line_num -le $repo_line_count
    do
        repo_line=`head -n$repo_line_num $repo_file | tail -n1`
        if [ "`echo $repo_line | head -c4`" == "http" ]
        then
            base_url=$repo_line
        else
            repo_header=$repo_line
            if [ "$dep_header" == "$repo_header" ]
            then
                url="${base_url}${dep_header}"
                echo "GET $url"
                curl -s -O $url
                found_dep="yes"
                break
            fi
        fi
        
        repo_line_num=$(( $repo_line_num + 1 ))
    done

    test "$found_dep" == "yes" \
        || (echo "Error: can't find $dep_pkg." >&2 ; exit 1)

    deps_line_num=$(( $deps_line_num + 1 ))
done

rm -f $repo_file
