from nevow import inevow
from zope.interface import implements
from FastICAForm import FastICAForm
from twisted.internet import reactor
from ProcessQueue import ProcessQueue, q
from Menu import serverMenu

header = open( "templates/header.template" ).read()

class FastICAPage:
    implements( inevow.IResource )

    def __init__( self ):
        self.form = FastICAForm( "infomax" )

    def locateChild( self, ctx, segments ):
        return None, ()

    def renderHTTP( self, ctx ):
        request = inevow.IRequest( ctx )
        if request.method == 'POST':
            return self.renderPOST( ctx )
        else:
            return self.renderGET( ctx )

    def renderPOST( self, ctx ):
        page = [""]
        page.append( header )
        page.append( """
            <title>FastICA</title>
        </head>
        <body>
            <div class="content">
            <h1>
                <a href="/">
                    <img src="/images/HipersatLogo.png" />
                </a>
            </h1> 
            <p>
                The following services are currently available
""" )
        page.append( apply(serverMenu.renderMenu()) )
        page.append( """
            </p>""")

        args = inevow.IRequest(ctx).args
        arguments = {}
        print "making argument list"
        for key in args:
            arguments[key] = args[key][0]
        errors = self.form.validateForm( arguments )
        if len(errors) > 0:
            page.append( """
                <p>
                    There was an error in your submission.
                    It appears that the following entries were invalid:
                    <ul>""")
            for error in errors:
                page.append("""
                        <li>%s</li>""" % ( error ) )
            page.append( """
                    </ul>
                </p>""")
        else:
            page.append( """
                <p>
                    Your request was submitted to the HiPerSAT job queue.
                </p>""")
            fastica = self.form.createFastICA( arguments )
            q.addProcess( fastica.getCommand(), fastica.getArgs(), fastica.timestamp )
        page.append( self.form.renderForm() )

        page.append( """
            </div>
        </body>
    </html>""")

        return "".join( page )

    def renderGET( self, ctx ):
        page = [ header ]
        page.append( """
            <title>FastICA</title>
        </head>
        <body>
            <div class="content">
                <h1>
                    <a href="/">
                        <img src="/images/HipersatLogo.png"/>
                    </a>
                </h1>
                <p>
                    The following services are currently available
""")
        page.append( apply(serverMenu.renderMenu()) )
        page.append( """
                </p>
                <p>
                    Welcome to the HiPerSAT FastICA testbed. Here you can
                    try out the latest version of our FastICA implementation.
                </p>""")
        page.append( self.form.renderForm() )
        page.append( """
        </body>
    </html>""")
        return "".join( page )

