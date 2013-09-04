from nevow import inevow
from zope.interface import implements
from ProcessQueue import ProcessQueue
from StatusPage import StatusPage
from KillForm import KillForm, StartForm
from Menu import serverMenu

header = open( "templates/header.template" ).read()

class QueuePage:
    implements( inevow.IResource )
   
    def __init__( self, q ):
        self.q = q
        self.killForm = KillForm( "infomax" )
        self.startForm = StartForm( "infomax" )

    def locateChild( self, ctx, segments ):
        value = -1
        print segments
        try:
            value = int( segments[ 0 ] )
        except:
            return None, ()

        process = self.q.getProcess( value )
        print process

        if process:
            return StatusPage( process ), segments[1:]
        else:
            return None, ()

    def renderHTTP( self, ctx ):
        request = inevow.IRequest( ctx )
        if request.method == 'POST':
            return self.renderPOST( ctx )
        else:
            return self.renderGET( ctx )

    def renderGET( self, ctx ):
        status = "active"
        if self.q.stopped:
            status = "stopped"
        page = [ "" ]
        page.append( header )
        page.append("""
        <title>
            HiPerSAT Queue
        </title>
    </head>
    <body>
        <div class="content">
            <h1>
                <a href="/">
                    <img src="/images/HipersatLogo.png" />
                </a>
            </h1>
            <p>
                The following pages are currently available
""")
        page.append( apply(serverMenu.renderMenu() ))
        page.append( """
            </p>
            <p>
                The queue is %s
            </p>
            <table>
                <tr>
                    <th>Job number</th>
                    <th>Type</th>
                    <th>Status</th>
                </tr>""" % ( status ))
        length = self.q.getLength()
        for i in range( length ):
            process = self.q.getProcess( i )
            if process:
                page.append( """
                    <tr>
                    <td><a href="/queue/%s">%s</a></td>
                    <td>%s</td>
                    <td>%s</td>
                </tr>""" % ( i, i, process.command, process.state ) )
        page.append("""
            </table>""")
        if status == "active":
            page.append( self.killForm.renderForm() )
        else:
            page.append( self.startForm.renderForm() )
        page.append("""
        </div>
    </body>
</html>""")

        return "".join( page )

    def renderPOST( self, ctx ):
        args = inevow.IRequest(ctx).args
        for key in args:
            print key
            if key == "kill":
                self.q.stopQueue()
            if key == "start":
                self.q.startStoppedQueue()

        return self.renderGET( ctx )
