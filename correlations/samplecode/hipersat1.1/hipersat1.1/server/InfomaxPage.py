from nevow import inevow
from zope.interface import implements
from InfomaxForm import InfomaxForm
from twisted.internet import reactor
from ProcessQueue import ProcessQueue, q
from Menu import serverMenu
from snakeOil import *

header = open( "templates/header.template" ).read()

class InfomaxPage:
    implements( inevow.IResource )

    def __init__( self ):
        self.form = InfomaxForm( "infomax" )

    def locateChild( self, ctx, segments ):
        return None, ()

    def renderHTTP( self, ctx ):
        request = inevow.IRequest( ctx )
        if request.method == 'POST':
            return self.renderPOST( ctx )
        else:
            return self.renderGET( ctx )

    def generalContent( self ):
        divContent = []
        newpage = html(
            head( "Infomax", "Neuroinformatics Center", "/styles/style.css" ),
            body( "",
                div( 'class="content"',
                    h1( "",
                        a( 'href="/"', 
                            img( 'src="images/HipersatLogo.png"',
                                text("")))),
                    divContent )))
        divContent.append( 
            p( '',
                text( 'The following services are currently available' ),
                serverMenu.renderMenu()
            )
        )
        # the divContent represents the actual contents of the page, 
        # collected in the top div
        return ( newpage, divContent )
 
    def renderPOST( self, ctx ):
        ( newpage, divContent ) = self.generalContent()
               
        args = inevow.IRequest(ctx).args
        arguments = {}

        for key in args:
            arguments[key] = args[key][0]

        errors = self.form.validateForm( arguments )

        if len(errors) > 0:
            errorContent = []
            divContent.append( p( '', errorContent ) )
            errorContent.append(
                text( """There was an error in your submission.
it appears that the following entries were invalid:""" ))
            listContent = []
            errorContent.append( ul('', listContent ))
            for error in errors:
                listContent.append(
                    li( '', text( '%s' % ( error ) ) ) )
        else:
            divContent.append(
                p('', text( "Your request was submitted to the HiPerSAT job queue." ) ) )
            infomax = self.form.createInfomax( arguments )
            q.addProcess( infomax.getCommand(), infomax.getArgs(), infomax.timestamp )
        divContent.append( text(self.form.renderForm()) )

        return apply( newpage )


    def renderGET( self, ctx ):
        ( newpage, divContent ) = self.generalContent()
        divContent.append(
            p( '',
                text("""Welcome to the HiPerSAT Infomax testbed. Here you can
try out the latest version of our Infomax implementation.""") ) )
        divContent.append(
            p( '',
                text(""" If there are no options available in the file 
selection menu the you will need to upload some files to the server
using the"""),
                a('href="/file"',
                    text( "File Database" ) ) ) )

        divContent.append( text( self.form.renderForm() ) )
        divContent.append( 
            p( '',
                text( "Session id: %s" % (inevow.ISession(ctx).uid ) ) ))
        return apply( newpage )

