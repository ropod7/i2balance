#!/usr/bin/env python

import sys, os
_root = "/".join(os.path.realpath(__file__).split("/")[:-1]) + "/"
filename = _root + "solcstd"

boldTag = "\x1b[1m"
std = "$(tput %s %s)"
stdColor = std % ("setaf", "%d")
closeTag = std % ("sgr", "0")

echo = 'echo -e "%s"'

redTag    = stdColor % 1
greenTag  = stdColor % 2
orangeTag = stdColor % 3
blueTag   = stdColor % 4
purpleTag = stdColor % 5

warning = "Warning:"
err = "Error:"

def setTags(line, notice, color):
    stdout = []
    out = line.split(notice)

    path = out[0].split("/")
    filen = path[-1]
    path = "/".join(path[:-1])
    toColor = filen.split(":")[:-1]
    filen = "%s%s%s%s" % (boldTag, blueTag, toColor[0], closeTag)
    joiner = "%s:" % closeTag
    linen = "%s%s" % (purpleTag, joiner.join(toColor[1:]))
    out[0] = "%s/%s:%s" % (path, filen, linen)

    stdout.append(out[0])
    addition = boldTag + color + notice + closeTag
    stdout.append(addition)
    out = ".\n".join(out[1][1:].split(". "))
    stdout.append(out)
    return "\n".join(stdout)

output = []

with open(filename, "r") as f:
    output = f.readlines()

if not len(output):
    success = "%s%s" % (boldTag, "Success!")
    os.system(echo % success)

for line in output:
    out = ""
    if warning in line:
        out = setTags(line, warning, orangeTag)
    elif err in line:
        out = setTags(line, err, redTag)
    elif "^-" in line:
        out = "%s%s%s" % (redTag, line, closeTag)
    elif line == "":
        continue
    else:
        out = line.replace("\n", "")
    os.system(echo % out)
