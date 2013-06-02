from FormGenerator import Form, FormTextItem, FormRadioItem, FormRadioGroup
from FormGenerator import FormCheckBox, FormHeader, FormFileItem
from FileDatabase import fileDatabase
from FastICA import FastICA

from time import time

fasticaForm = Form( "fastica" )

class FastICAForm:
    def __init__( self, name ):
        self.form = Form( name )

        self.items = [
            FormHeader( "Data Fields" ),
            fileDatabase.formMenu,
            FormHeader( "Preprocessor Settings" ),
            FormCheckBox( "sphering", "Compute sphering", "sphering", "", True ),

            FormHeader( "FastICA Settings" ),
            FormRadioGroup( "Initialization Type", "" ),
            FormRadioItem( "initializationType", "Identity Matrix", "identity", "", True ),
            FormRadioItem( "initializationType", "Random Matrix", "random", "", False ),
            FormRadioGroup( "Contrast Function", "" ),
            FormRadioItem( "contrastFunction", "Cubic", "cubic", "", True),
            FormRadioItem( "contrastFunction", "Hyperbolic Tangent", "hyptan", "", False),
            FormRadioItem( "contrastFunction", "Gaussian", "gaussian", "", False),
            FormTextItem( "maxIterations", "Maximum Iterations", "1000", "" ),
            FormTextItem( "maximumRetries", "Maximum Retries", "5", "" ),
            FormTextItem( "convergenceTolerance", "Convergence Tolerance", "1e-6", "" )
            
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


    def createFastICA( self, args ):
        timestamp = int( time() * 100000 )
        fastica = FastICA( "../bin/hFastICA", timestamp )

        id = args[ "file" ]
        fileItem = fileDatabase.fd[ int( id ) ]
        args[ "samples" ] = fileItem[ "samples" ]
        args[ "channels" ] = fileItem[ "channels" ]
        args[ "precision" ] = fileItem[ "precision" ]
        args[ "format" ] = fileItem[ "format" ]

        for key in args:
            value = args[key]
            if key == "file":
                filename = fileItem[ "file" ]
                value = filename
                fastica.setArgument( "inputFile", value )
            if value != "heuristic" and key != "file":
                fastica.setArgument( key, value )

        fastica.setArgument( "outputFormat", "text" )
        return fastica

