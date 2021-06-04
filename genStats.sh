#!/bin/bash

conf_dir=$(dirname "$(readlink -f "$0")")
parent_dir="$(dirname "$conf_dir")"
logs_dir="$parent_dir/working_logs"
sss_dir="$parent_dir/superseriousstats"
website_dir="$(dirname "$parent_dir")/www"

source_log="$1"

if [ -f "$conf_dir/stats-gen.lock" ]; then
    echo "!!! Stats generation is already in progress !!!"
    echo "### If you're sure that's not the case, delete the stats-gen.lock file"
    exit
fi

touch "$conf_dir/stats-gen.lock"

echo "### Splitting single .weechatlog into daily logs..."
python2 "$conf_dir/splitLogs.py" -f "$source_log" -p "$logs_dir/newserver.desertbus." -s .weechatlog -c

echo "### Importing daily logs and generating stats page..."
php -d memory_limit=1024M "$sss_dir/sss.php" -c "$conf_dir/desertbus.conf" -i "$logs_dir" -o "$website_dir/index.html" &>> "$conf_dir/sss.log"

rm "$conf_dir/stats-gen.lock"

echo "### Done!"
