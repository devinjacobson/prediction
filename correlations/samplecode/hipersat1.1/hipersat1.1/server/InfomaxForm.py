from FormGenerator import Form, FormTextItem, FormRadioItem, FormRadioGroup
from FormGenerator import FormCheckBox, FormHeader, FormFileItem
from FileDatabase import fileDatabase
from Infomax import Infomax

from time import time

infomaxForm = Form( "infomax ")

class InfomaxForm:
    def __init__( self, name  ):
        self.form = Form( name )

        self.items = [
            FormHeader( "Data Fields" ),
            fileDatabase.formMenu,
            FormHeader( "Preprocessor Settings" ),
            FormCheckBox( "sphering", "Compute sphering", "sphering", "", True ),

            FormHeader( "Infomax Settings" ),
            FormTextItem( "annealing", "Annealing Constant", "0.9", "" ),
            FormTextItem( "annealingDegree", "AnnealingDegree", "70", "" ),
            FormTextItem( "blockSize", "Block Size", "heuristic", "" ),
            FormTextItem( "learningRate", "Learning Rate", "heuristic", "" ),
            FormTextItem( "maxSteps", "Max Learning Steps", "1000", "" ),
            FormTextItem( "stopCondition", "Stop step size", "heuristic", "" ),
            FormTextItem( "seed", "Seed", "123456", "" )
            ]

        for item in self.items:
            self.form.addItem( item )

    def renderForm( self ):
        return self.form.renderForm()

    def validateForm( self, args ):
        print "validating form"
        errors = []
        for key in args:
            value = args[key]
            try:
                if key == "annealing" or key == "annealingDegree":
                    value = float( args[key] )
                elif key == "blockSize":
                    if value != "heuristic":
                        value = int( args[key] )
                elif key == "learningRate":
                    if value != "heuristic":
                        value = float( args[key] )
                elif key == "maxSteps":
                    value = int( args[key] )
                elif key == "stopCondition":
                    if value != "heuristic":
                        value = float( args[key] )
                elif key == "seed":
                    value = int( args[key] )
            except:
                errors.append( key )

        return errors

    def createInfomax( self, args ):
        timestamp = int( time() * 100000 )
        infomax = Infomax( "../bin/hInfomax", timestamp )

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
                infomax.setArgument( "inputFile", value )
            if value != "heuristic" and key != "file":
                infomax.setArgument( key, value )

        return infomax

if __name__ == "__main__":
    infomaxForm = InfomaxForm()

    print infomaxForm.renderForm()
