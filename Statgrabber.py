import socket
import re
import time

# Some config
port = 9119
iaddr = '127.1'

# Connect to server
try:
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.connect((iaddr,port));
except socket.error(e):
	print 'Error creating socket: ' + e.string

def verify_tag(tag):
	return re.sub('\s+','_',tag)

def count(tag):
	tag = verify_tag(tag)
	sock.send(tag)

def average(tag,val):
	tag = verify_tag(tag)
	sock.send("%s %s" % (tag,val))

def accumulate(tag,val):
	tag = verify_tag(tag)
	sock.send("%s +%s" % (tag,val))

# Now for some fun stuff... elapsed time statistics!
class sgtimer:
	t0 = 0
	tag = None
	def __init__(self,tag):
		self.tag = tag
		self.t0 = time.time()
	
	def finish(self):
		average(self.tag, time.time() - self.t0)

def start(tag):
	return sgtimer(tag)
