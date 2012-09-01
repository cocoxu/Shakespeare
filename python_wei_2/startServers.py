#!/usr/bin/python

import sys
import re
import time
from subprocess import Popen

for line in open(sys.argv[1]):
    line = line.rstrip('\n')
    (old, name, iniFile, port) = re.split(r'\s+', line)
    if old == "0":
        #pid = Popen(["nohup", "/homes/gws/aritter/mt/moses-web/bin/daemon.pl", "milkhog.cs.washington.edu", port, iniFile]).pid
        pid = Popen(["/homes/gws/aritter/mt/moses-web/bin/daemon.pl", "milkhog.cs.washington.edu", port, iniFile]).pid
    elif old == "2":
        #pid = Popen(["nohup", "/homes/gws/aritter/mt/moses-web/bin/daemon_n13.pl", "rv-n13.cs.washington.edu", port, iniFile]).pid
        pid = Popen(["/homes/gws/aritter/mt/moses-web/bin/daemon_n13.pl", "rv-n13.cs.washington.edu", port, iniFile]).pid
    else:
        pid = Popen(["nohup", "/homes/gws/aritter/mt/moses-web/bin/daemon_old.pl", "milkhog.cs.washington.edu", port, iniFile]).pid
        #pid = Popen(["/homes/gws/aritter/mt/moses-web/bin/daemon_old.pl", "milkhog.cs.washington.edu", port, iniFile]).pid
    #Sleep for a minute between starting up each version of the decoder (it takes a while to load files into memory)
    time.sleep(60 * 4)
