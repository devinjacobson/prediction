from twisted.internet import reactor
from LocalProcess import LocalProcess

# a class to handle the launching of processes
# such that only one process runs at a time
class ProcessQueue:

    def __init__( self ):
        self.q = []
        self.running = False
        self.stopped = False
        self.location = -1

    def addProcess( self, command, arguments, id ):
        process = LocalProcess( command, arguments, "queued", id, self.done )
        self.q.append( process )
        l = len(self.q)
        self.startQueue()
        return l

    def startStoppedQueue( self ):
        self.stopped = False
        print self.location
        if self.location >= 0:
            self.startQueue()

    def startQueue( self ):
        if self.running == False and self.stopped == False:
            if self.location < 0:
                self.location += 1
                self.launchNext()
            elif self.location < ( len( self.q ) ):
                self.launchNext()

    def stopQueue( self ):
        print self.running
        self.stopped = True
        if self.running:
            process = self.q[ self.location ]
            process.kill()
            self.running = False

    def launchNext( self ):
        if not self.stopped:
            process = self.q[ self.location ]
            process.launch()
            self.running = True

    def done( self ):
        self.location += 1
        if self.location < len( self.q ):
            self.launchNext()
        else:
            self.running = False

    def getProcess( self, id ):
        process = None
        try:
            process = self.q[ id ]
        except:
            process = None
        return process

    def getCurrentProcess( self ):
        return getProcess( self.location )

    def getLength( self ):
        return len( self.q )

q = ProcessQueue()

