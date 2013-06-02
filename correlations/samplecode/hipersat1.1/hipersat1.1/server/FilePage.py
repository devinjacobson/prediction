from nevow import inevow
from zope.interface import implements
from FileForm import FileForm
from FileDatabase import fileDatabase
from twisted.internet import reactor
from ProcessQueue import ProcessQueue, q
from Menu import serverMenu
from snakeOil import *

header = open( "templates/header.template" ).read()

class FilePage:

    implements( inevow.IResource )

    def __init__( self ):
        self.form = FileForm( "infomax" )

    def locateChile( self, ctx, segments ):
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
            head( "File Upload", "Neuroinformatics Center", "/styles/style.css" ),
            body( '',
                div( 'class="content"',
                    h1( '',
                        a( 'href="/"',
                            img( 'src="images/HipersatLogo.png"',
                                text("")))),
                    divContent )))
        divContent.append(
            p( '',
                text( 'The following services are currently available' ),
                serverMenu.renderMenu() ) )
        return ( newpage, divContent )


    def renderPOST( self, ctx ):
        ( newpage, divcontent ) = self.generalContent()

        args = inevow.IRequest(ctx).args
        arguments = {}
        print "making argument list"
        for key in args:
            arguments[key] = args[key][0]
        errors = self.form.validateForm( arguments )
        if len(errors) > 0:
            errorList = []
            errorContent = p( '',
                text( 'There was an error in your submission. It appears'),
                text( 'that the following entries were invalid:' ),
                ul( '', errorList ) )
            for error in errors:
                errorList.append(
                    li( '',
                        text( "%s" % (error) ) ) )
            divcontent.append( errorContent )
        else:
            divcontent.append(
                p( '',
                    text( 'Your file has been added to the database' ) ) )
            fileObject = self.form.createFile( arguments )
            fileDatabase.append( fileObject )

        divcontent.append( text(fileDatabase.renderdb()) )

        divcontent.append( text(self.form.renderForm()) )

        return apply( newpage )

    def renderGET( self, ctx ):
        page = [ header ]
        page.append( """
            <title>File Upload</title>
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
        page.append( apply(serverMenu.renderMenu() ))
        page.append( """
                </p>
                <p>
                    Welcome to the HiPerSAT Infomax testbed. Here you can
                    try out the latest version of our Infomax implementation.
                </p>""")
        page.append( fileDatabase.renderdb() )
        page.append( self.form.renderForm() )
        return "".join( page )
