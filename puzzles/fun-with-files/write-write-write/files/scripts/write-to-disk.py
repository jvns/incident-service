from time import sleep
import os

x = "yougotme \n" * 6000
with open('/tmp/blah.txt', 'w', buffering=1) as f:
    while True:
        f.write(x)
        os.fsync(f)
        sleep(0.01)
