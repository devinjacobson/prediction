from nevow import inevow
from zope.interface import implements

header = open( "templates/header.template" ).read()

class StatusPage:
    implements( inevow.IResource )

    def __init__( self, process ):
        self.process = process

    def locateChild( self, ctx, segments ):
        print "locating child"
        return None, ()

    def renderHTTP( self, ctx ):
        print "rendering HTTP"
        page = [ "" ]
        page.append( header )
        page.append("""
        <title>
            %s-%s
        </title>
    </head>
    <body>
        <div class="content">
            <h1>
                <a href="/">
                    <img src="/images/HipersatLogo.png" />
                </a>
            </h1>
            <pre>
                %s
                %s
            </pre>
        </div>
    </body>
</html>""" % ( self.process.id, self.process.command, self.process.err, self.process.out ) )
        return "".join( page )
