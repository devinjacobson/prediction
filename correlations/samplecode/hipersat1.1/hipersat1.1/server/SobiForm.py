from FormGenerator import Form, FormTextItem, FormRadioItem, FormRadioGroup
from FormGenerator import FormCheckBox, FormHeader, FormFileItem
from FileDatabase import fileDatabase
from Sobi import Sobi

from time import time

sobiForm = Form( "sobi" )

class SobiForm:
    def __init__( self, name ):
        self.form = Form( name )

        self.items = [
            FormHeader( "Data Fields" ),
            fileDatabase.formMenu,
            FormHeader( "Preprocessor Settings" ),
            FormCheckBox( "sphering", "Compute sphering", "sphering", "", True ),
            ]

        for item in self.items:
            self.form.addItem( item )

    def renderForm( self ):
        return self.form.renderForm()

    def validateForm( self, args ):
        errors = []
        for key in args:
            value = args[ key ]
            try:
                if key == "channels" or key == "samples":
                    value = int( args[key] )
            except:
                errors.append( key )

        return errors


    def createSobi( self, args ):
        timestamp = int( time() * 100000 )
        sobi = Sobi( "../bin/hSobi", timestamp )

        id = args[ "file" ]
        fileItem = fileDatabase.fd[ int( id ) ]
        args[ "samples" ] = fileItem[ "samples" ]
        args[ "channels" ] = fileItem[ "channels" ]
        args[ "precision" ] = fileItem[ "precision" ]
        args[ "format" ] = fileItem[ "format" ]

        for key in args:
            value = args[key]
            if key == "file":
                filename = fileItem["file"]
                value = filename
                sobi.setArgument( "inputFile", value )
            if value != "heuristic" and key != "file":
                sobi.setArgument( key, value )

        sobi.setArgument( "outputFormat", "text" )
        return sobi

