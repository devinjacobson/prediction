
class Infomax:

    def __init__( self, command, timestamp ):
        self.command = command
        self.timestamp = timestamp
        self.settings = {}
        self.settings[ "inputFile" ] = "-i"
        self.settings[ "format" ] = "-if"
        self.settings[ "blockSize" ] = "-block"
        self.settings[ "channels" ] = "-c"
        self.settings[ "samples" ] = "-s"
        self.settings[ "learningRate" ] = "-lrate"
        self.settings[ "maxSteps" ] = "-maxsteps"
        self.settings[ "seed" ] = "-seed"
        self.settings[ "precision" ] = "-single"
        self.settings[ "sphering" ] = "-sphering"
        self.settings[ "annealing" ] = "-anneal"
        self.settings[ "annealingDegree" ] = "-annealdeg"
        self.settings[ "stopCondition" ] = "-stop"
        self.settings[ "outputFormat" ] = "-of"
        self.settings[ "weightMatrix" ] = "-og"
        self.settings[ "mixingMatrix" ] = "-om"
        self.settings[ "spheringMatrix" ] = "-os"
        self.settings[ "unmixingMatrix" ] = "-ow"

        self.argValues = {}
        self.argValues[ "-i" ] = None
        self.argValues[ "-if" ] = None
        self.argValues[ "-block" ] = None
        self.argValues[ "-c" ] = None
        self.argValues[ "-s" ] = None
        self.argValues[ "-lrate" ] = None
        self.argValues[ "-maxsteps" ] = None
        self.argValues[ "-seed" ] = None
        self.argValues[ "-single" ] = None
        self.argValues[ "-sphering" ] = None
        self.argValues[ "-stop" ] = None
        self.argValues[ "-of" ] = None
        self.argValues[ "-og" ] = None
        self.argValues[ "-om" ] = None
        self.argValues[ "-os" ] = None
        self.argValues[ "-ow" ] = None
        self.argValues[ "-annealdeg" ] = None
        self.argValues[ "-anneal" ] = None

    def getCommand( self ):
        return self.command

    # we could do more to validate the arguments
    def getArgs( self ):
        args = [ self.command ]
        for key in self.argValues:
            value = self.argValues[key]
            if key == "-single":
                if value == "single":
                    args.append( key )
            elif key == "-sphering":
                if value == "sphering":
                    args.append( key )
            elif value:
                args.append( key )
                args.append( value )
        return args

    def setArgument( self, key, value ):
        realkey = self.settings[ key ]
        if self.argValues.has_key( realkey ):
            self.argValues[ realkey ] = value

