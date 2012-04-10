import re
import urllib
import time

for line in open('urls.txt'):
    url = line.rstrip('\n') + "/page_%s.html" % 2    
    for i in range(2,10000):
        print url
        urlobject = urllib.urlopen(url)
        print urlobject.code
        if urlobject.code == 404:
            break
        lines = urllib.urlopen(url).readlines()

        fOut = open('plays/%s_%s' % (url.split('/')[-2], url.split('/')[-1]), 'w')
        fOut.write("\n".join(lines))
        fOut.close()
        time.sleep(1)

        #Get the next URL
        url = None
        for line in lines:
            m = re.match(r'<div class="next"><a href="(.+)">Next Section', line)
            if m:
                url = m.group(1)
                print url
                break

        if not url:
            break
