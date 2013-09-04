from twisted.web import soap, resource
from ProcessQueue import q
from zope.interface import implements
from nevow import inevow
from time import time
from FileDatabase import fileDatabase
from Infomax import Infomax

class SoapInterface( soap.SOAPPublisher ):
    implements( inevow.IResource )

    def __init__( self ):
        pass

    def renderHTTP( self, ctx ):
        return self.render( inevow.IRequest( ctx ) )

    def soap_test( self ):
        return { "return": "Welcome to the HiPerSAT SOAP Server!" }

    def fail( self ):
        return """
<head>
    The server received a request it couldn't understand
</head>"""

    def soap_queue( self ):
        print "in queue"
        rvalue = [ 'queue' ]
        count = 0
        print q
        print q.q
        for process in q.q:
            rvalue.append( "%s, %s, %s" % 
                ( count, process.command, process.state ) )
            count += 1
        print rvalue
        return { "return":rvalue }

    def soap_jobOutput( self, in0 ):
        print in0
        try:
            in0 = int( in0 )
            process = q.getProcess( in0 )
            return { "return": process.out }
        except:
            print q.q
            return { "jobStatusReturn": "opps!" }

    def soap_jobStatus( self, in0 ):
        print in0
        in0 = int( in0 )
        process = q.getProcess( in0 )
        print process
        return { "return": process.state }

    def soap_infomax( self, fileid, sphering, annealing, annealingDegree, blockSize, learningRate, maxSteps, stopCondition, seed ):
        #print fileid, sphering, annealing, annealingDegree, blockSize, learningRate, maxSteps, stopCondition, seed
        print 'here i am' 
        timestamp = int( time() * 100000 )
        infomax = Infomax( "../bin/hInfomax", timestamp )

        fileItem = []
        for fi in fileDatabase.fd:
            print str( fileid )
            print fi["file"]
            if fi["file"] == ("file/" + str(fileid)):
                fileItem = fi
        print fileItem

        settings = {}
        settings[ "inputFile" ] = fileItem[ "file" ]
        settings[ "samples" ] = fileItem[ "samples" ]
        settings[ "channels" ] = fileItem[ "channels" ]
        settings[ "precision" ] = fileItem[ "precision" ]
        settings[ "format" ] = fileItem[ "format" ]

        settings[ "sphering" ] = sphering
        settings[ "annealing" ] = annealing
        settings[ "annealingDegree" ] = annealingDegree 
        settings[ "blockSize" ] = blockSize
        settings[ "learningRate" ]= learningRate
        settings[ "maxSteps" ]= maxSteps
        settings[ "stopCondition" ]= stopCondition
        settings[ "seed" ] = seed
        print settings

        for key in settings:
            value = settings[key]
            print value, key
            if value != "heuristic":
                infomax.setArgument( key, value )

        id = q.addProcess( infomax.getCommand(), infomax.getArgs(), infomax.timestamp )
        print 'got to the return'
        return { 'infomaxReturn': id }

    def soap_createFileEntry( self, name, description, channels, samples, format, precision ):
        timestamp = int( time() * 100000 )
        fileObject = {}
        fileObject[ "name" ] = name
        fileObject[ "description" ] = description
        fileObject[ "channels" ] = channels
        fileObject[ "samples" ] = samples
        fileObject[ "format" ] = format 
        fileObject[ "precision" ] = precision
        fileObject[ "file" ] = "file/%s" % (timestamp)
        fileObject[ "id" ] = timestamp
        id = fileDatabase.append( fileObject )
        return { "createFileEntryReturn" : 'rubato.nic.uoregon.edu\n3604\n' + str(timestamp) }

    def render( self, request ):
        if request.method == 'POST':
            try:
                soap.SOAPPublisher.render( self, request )
            except:
                return "<head>%s</head>" % (self.fail())
        else:
            return self.fail()
        return ""
