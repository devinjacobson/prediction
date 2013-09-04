from twisted.internet import reactor
from ProcessQueue import ProcessQueue

q = ProcessQueue()

q.addProcess( "ps", ["ps"], 1000 )

reactor.run()
