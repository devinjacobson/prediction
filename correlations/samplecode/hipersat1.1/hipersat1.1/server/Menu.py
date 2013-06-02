from snakeOil import *

class Menu:
    def __init__( self, name ):
        self.name = name
        self.items = []

    def addItem( self, name, url ):
        self.items.append( (name, url ) )

    def renderMenu( self ):
        list = []
        menu = ul( 'class="%s"' % ( self.name ), list )
        for item in self.items:
            list.append(
                li( '',
                    a( 'href="%s"' % ( item[1] ),
                        text( '%s' % ( item[0] ) )
                    )
                )
            )

        return menu


serverMenu = Menu( "hmenu" )

serverMenu.addItem( "HiPerSAT Server Home", "/" )
serverMenu.addItem( "Infomax", "/infomax" )
serverMenu.addItem( "FastICA", "/fastica" )
serverMenu.addItem( "Sobi", "/sobi" )
serverMenu.addItem( "Job Queue", "/queue" )
serverMenu.addItem( "File Database", "/file" )
