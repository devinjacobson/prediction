from FormGenerator import Form, FormFileItem, FormRadioItem, FormRadioGroup
from FormGenerator import FormTextItem, FormHeader

from time import time

class FileForm:

    def __init__( self, name ):
        self.form = Form( name )

        self.items = [
            FormHeader( "File Information" ),
            FormFileItem( "file", "File", "" ),
            FormTextItem( "name", "Short Name", "none", "" ),
            FormTextItem( "description", "Description", "", "" ),
            FormTextItem( "channels", "Number of Channels", "", "" ),
            FormTextItem( "samples", "Number of Samples", "", "" ),

            FormRadioGroup( "Data Format", "" ),
            FormRadioItem( "format", "Big Endian", "big", "", True ),
            FormRadioItem( "format", "Little Endian", "little", "", False ),
            FormRadioItem( "format", "Text", "text", "", False ),
            FormRadioItem( "format", "EGI Raw", "raw", "", False ),

            FormRadioGroup( "Precision", "" ),
            FormRadioItem( "precision", "Single", "single", "", True ),
            FormRadioItem( "precision", "Double", "double", "", False ) ]

        for item in self.items:
            self.form.addItem( item )

    def renderForm( self ):
        return self.form.renderForm()

    def validateForm( self, args ):
        errors = []
        hasChannels = False
        hasSamples = False
        for key in args:
            value = args[ key ]
            try:
                if key == "channels":
                    value = int( args[ key ] )
                    hasChannels = True
                if key == "samples":
                    value = int( args[ key ] )
                    hasSamples = True
            except:
                errors.append( key )

        if not hasChannels:
            errors.append( "channels" )
        if not hasSamples:
            errors.append( "samples" )

        return errors

    def createFile( self, args ):
        timestamp = int( time() * 100000 )
        fileObject = {}
        for key in args:
            value = args[ key ]
            if key == "file":
                filename = "file/%s" % ( timestamp )
                file = open( filename, 'wb' )
                file.write( value )
                file.close()
                value = filename
            fileObject[ key ] = value
        return fileObject
