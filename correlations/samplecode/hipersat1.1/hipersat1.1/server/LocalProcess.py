from twisted.internet import protocol, reactor

# provide an interface for a process spawned in the twisted
# reactor to write its output to
#
# requires a callback function to inform its parent
# (generally a ProcessQueue) that it has completed its work
class LocalProcess( protocol.ProcessProtocol ):
    def __init__( self, command, arguments, state, id, callback ):
        self.out = ""
        self.err = ""
        self.command = command
        self.arguments = arguments
        self.state = state
        self.id = id
        self.callback = callback
        self.processTransport = None

    def launch( self ):
        self.processTransport = reactor.spawnProcess( self, self.command, self.arguments )
        print self.arguments
        self.state = "running"

    def kill( self ):
        try:
            self.processTransport.signalProcess( "KILL" )
            self.state = "killed"
        except:
            pass

    def connectionMade( self ):
        print "Process %s Launched" % (self.arguments[0])

    def outReceived( self, data ):
        self.out += data
        print data

    def errReceived( self, data ):
        self.err += data
        print data

    def processEnded( self, reason ):
        print "Process %s Completed" % (self.arguments[0])
        if self.state != "killed":
            self.state = "done"
        self.callback()
