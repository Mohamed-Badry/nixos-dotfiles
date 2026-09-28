#!/usr/bin/env bash
# Suppress stderr
exec 2>/dev/null

if ! command -v jj >/dev/null 2>&1; then
    exit 0
fi

if ! jj root >/dev/null; then
    exit 0
fi

jj --no-pager log -r @ --no-graph --ignore-working-copy -T 'coalesce(bookmarks, change_id.shortest(8)) ++ if(empty, "", "*") ++ if(conflict, "!")' 2>/dev/null
