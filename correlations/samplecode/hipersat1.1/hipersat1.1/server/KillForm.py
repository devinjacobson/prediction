from FormGenerator import Form, FormCheckBox, FormHeader, FormRadioItem

class KillForm:
    def __init__( self, name ):
        self.form = Form( name )

        self.items = [
            FormHeader( "Stop Queue (and kill current process)" ),
            FormCheckBox( "kill", "Stop Queue", "kill", "", False )
            ]

        for item in self.items:
            self.form.addItem( item )

    def renderForm( self ):
        return self.form.renderForm()

class StartForm:
    def __init__( self, name ):
        self.form = Form( name )

        self.items = [ 
            FormHeader( "Start Queue" ),
            FormRadioItem( "start", "StartQueue", "start", "", True )
            ]

        for item in self.items:
            self.form.addItem( item )

    def renderForm( self ):
        return self.form.renderForm()
