"""
Validate that doing statsgrabber transmission using direct socket IO works,
even while the twisted reactor is running.
"""

import sys

from twisted.internet import reactor
from twisted.python import log

from statgrabber import Statgrabber

def send_test_stats():
    log.msg("sending test stats")
    for x in range(0,5):
            Statgrabber.count('foo')

    for x in range(0,5):
            Statgrabber.average('bar',x)

    for x in range(0,5):
            # Test spaces, also
            Statgrabber.accumulate('b a z',x)
    log.msg("done sending test stats")

def shutdown():
    log.msg("shutting down")
    reactor.stop()

if __name__ == "__main__":
    flo = log.FileLogObserver(sys.stdout)
    log.startLoggingWithObserver(flo.emit)

    reactor.callLater(0.0, send_test_stats)
    reactor.callLater(2.0, shutdown)
    reactor.run()

