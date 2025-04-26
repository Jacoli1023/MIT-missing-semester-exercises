#!/bin/sh
# This fixes the first error about iterating over ls output
for f in *.m3u
do
    [ -e "$f" ] || break  # this handles the case if there are no *.m3u files
    # Adding quotes ensures the shell doesn't try to interpret the grep pattern, and to prevent globbing and word splitting of $f 
    grep -qi "hq.*mp3" "$f" \
        && echo "Playlist $f contains a HQ file in mp3 format"  # -e simply enables the interpretation of backslash escapes, which is unneeded 
done

