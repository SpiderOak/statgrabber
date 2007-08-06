import socket
import re
import time

# Some config
port = 9119
iaddr = '127.1'

def ignore_socket_error(fn):
	def tryit(*args, **kwargs):
		try:
			fn(*args, **kwargs)
		except socket.error, e:
			pass
	return tryit

def fix_tag(fn):
	def fix(tag, *args):
		return fn(re.sub('\s+','_',tag), *args)
	return fix
		

@ignore_socket_error
def set_up_socket():
	global sock
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.connect((iaddr,port));

set_up_socket()

@ignore_socket_error
@fix_tag
def count(tag):
	sock.send(tag)

@ignore_socket_error
@fix_tag
def average(tag,val):
	sock.send("%s %s" % (tag,val))

@ignore_socket_error
@fix_tag
def accumulate(tag,val):
	sock.send("%s +%s" % (tag,val))

# Now for some fun stuff... elapsed time statistics!
class sgtimer:
	@fix_tag
	def __init__(self,tag):
		self.tag = tag
		self.t0 = time.time()
	
	@ignore_socket_error
	def finish(self):
		average(self.tag, time.time() - self.t0)

def start(tag):
	return sgtimer(tag)
