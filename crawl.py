import urllib
import time

for line in open('urls.txt'):
    for page in range(2,10000):
        url = line.rstrip('\n') + "/page_%s.html" % page
        print url
        urlobject = urllib.urlopen(url)
        if urlobject.code == 404:
            break
        lines = urllib.urlopen(url).readlines()

        fOut = open('plays/%s_%s' % (url.split('/')[-2], url.split('/')[-1]), 'w')
        fOut.write("\n".join(lines))
        fOut.close()
        time.sleep(1)
