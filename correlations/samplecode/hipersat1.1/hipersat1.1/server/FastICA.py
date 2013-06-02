
class FastICA:
   
    def __init__( self, command, timestamp ):
        self.command = command
        self.timestamp = timestamp

        self.settings = {}
        self.settings[ "inputFile" ] = "-i"
        self.settings[ "format" ] = "-if"
        self.settings[ "channels" ] = "-c"
        self.settings[ "samples" ] = "-s"
        self.settings[ "outputFormat" ] = "-of"
        self.settings[ "weightMatrix" ] = "-og"
        self.settings[ "mixingMatrix" ] = "-om"
        self.settings[ "spheringMatrix" ] = "-os"
        self.settings[ "unmixingMatrix" ] = "-ow"
        self.settings[ "precision" ] = "-single"
        self.settings[ "sphering" ] = "-sphering"
        self.settings[ "maxIterations"] = "-I"
        self.settings[ "initializationType" ] = "-g"
        self.settings[ "maximumRetries" ] = "-r"
        self.settings[ "convergenceTolerance" ] = "-t"
        self.settings[ "contrastFunction" ] = "-C"

        self.argValues = {}
        self.argValues[ "-i" ] = None
        self.argValues[ "-if" ] = None
        self.argValues[ "-c" ] = None
        self.argValues[ "-s" ] = None
        self.argValues[ "-of" ] = None
        self.argValues[ "-og" ] = None
        self.argValues[ "-om" ] = None
        self.argValues[ "-os" ] = None
        self.argValues[ "-ow" ] = None
        self.argValues[ "-single" ] = None
        self.argValues[ "-sphering" ] = None
        self.argValues[ "-I" ] = None
        self.argValues[ "-g" ] = None
        self.argValues[ "-r" ] = None
        self.argValues[ "-t" ] = None
        self.argValues[ "-C" ] = None

    def getCommand( self ) :
        return self.command

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

