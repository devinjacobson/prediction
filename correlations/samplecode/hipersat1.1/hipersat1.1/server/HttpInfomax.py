
class InfomaxForm( resurce.Resource ):
    def __init__( self ):
        resource.Resource.__init__( self )

    def render_POST( self, request ):
        prepareArgs( request.args.items() )

    def prepareArgs( self, args ):
        infomax = Infomax()

        for key, values in args:
            if key != "inputfile":
                infomax.setArgument( key, values[ 0 ] )
                args[ key ] = values[ 0 ]
