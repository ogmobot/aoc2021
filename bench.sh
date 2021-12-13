#!/usr/bin/bash
/usr/bin/time -v $@ 2>&1 |
    grep -e "Maximum resident set size" \
         -e "User time" \
         -e "System time" \
         -e "Elapsed (wall clock) time"
