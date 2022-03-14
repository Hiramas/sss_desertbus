#!/usr/bin/env python3

import argparse
from datetime import datetime, timedelta
import gzip
import os

parser = argparse.ArgumentParser(description='Script to split .weechatlog files by day')
parser.add_argument('-f', '--file',
                    help='file to split up',
                    type=str,
                    required=True)
parser.add_argument('-p', '--prefix',
                    help='prefix for output file',
                    type=str,
                    default='')
parser.add_argument('-s', '--suffix',
                    help='suffix for output file',
                    type=str,
                    default='')
parser.add_argument('-c', '--compress',
                    help='compress the resulting log files with gzip',
                    action='store_true')
args = parser.parse_args()


def writeLog(date, lines):
    fname = "{}{}{}".format(args.prefix, date, args.suffix)

    lines = sorted(lines, key=lambda l: l[:19])  # stable sort lines by timestamp

    if args.compress:
        ago = datetime.utcnow() - timedelta(days=30)
        if os.path.exists(f"{fname}.gz") and date < ago.strftime("%Y-%m-%d"):
            return

        with gzip.open(f"{fname}.gz", mode='wt') as output:
            print(f"# writing {date} ...")
            output.writelines(lines)
    else:
        with open(fname, 'w') as output:
            output.writelines(lines)


with open(args.file, 'r') as wlog:
    oneLogFile = []
    currentDate = ""
    for line in wlog:
        newDate = line.split(" ", 1)[0]
        if currentDate == "":
            currentDate = newDate
        if newDate != currentDate:
            # write file
            writeLog(currentDate, oneLogFile)
            oneLogFile = []
            currentDate = newDate
            pass
        # append to day's log
        oneLogFile.append(line)
    # write out today's log
    if oneLogFile:
        writeLog(currentDate, oneLogFile)
