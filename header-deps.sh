#!/usr/bin/env bash

# header-deps.sh: a "package manager" for single-file C libraries.
# See https://github.com/pepaslabs/header-deps.sh

# Copyright 2018 Jason Pepas
# Released under the terms of the MIT license.
# See https://opensource.org/licenses/MIT

repo_url=https://raw.githubusercontent.com/pepaslabs/header-deps.sh/master/header-libs.txt

set -e -o pipefail

if [ $# -eq 0 ]
then
    cat header-deps.txt | xargs header-deps.sh
    exit 0
fi

repo_file=`mktemp`
curl -s $repo_url >> $repo_file

for dep in $@
do
    found_dep="no"
    while read -r repo_line
    do
        if [ "`echo $repo_line | head -c4`" == "http" ]
        then
            base_url=$repo_line
        else
            if [ "$dep" == "$repo_line" ]
            then
                url="${base_url}${dep}"
                echo "GET $url"
                curl -s -O $url
                found_dep="yes"
                break
            fi
        fi
    done < $repo_file

    test "$found_dep" == "yes" \
        || (echo "Error: can't find $dep." >&2 ; exit 1)
done

rm -f $repo_file
