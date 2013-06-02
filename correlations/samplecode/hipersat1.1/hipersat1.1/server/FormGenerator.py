
class Form:
    def __init__( self, formClass ):
        self.items = []
        self.formClass = formClass

    def addItem( self, item ):
        self.items.append( item )

    def renderForm( self ):
        form = [ """
<form enctype="multipart/form-data" method="post">
    <table class="%s">""" % ( self.formClass ) ]

        for item in self.items:
            form.append( item.itemHtml )

        form.append( """
        <tr>
            <td class="submit" colspan="3"><input type="submit" value="Send" /></td>
        </tr>
    </table>
</form>""" )

        return "".join( form )

class FormTextItem:
    def __init__( self, name, description, value, help ):
        self.name = name
        self.description = description
        self.value = value
        self.help = help

        self.itemHtml = """
    <tr>
        <td class="formName">%s</td>
        <td><input type="text" name="%s" value="%s" /></td>
        <td></td>
    </tr>""" % ( self.description, self.name, self.value )

class FormRadioItem:
    def __init__( self, name, description, value, help, isChecked ):
        self.name = name
        self.description = description
        self.value = value
        self.help = help
        self.checked = ""
        if isChecked:
            self.checked = 'checked="checked"'

        self.itemHtml = """
    <tr>
        <td></td>
        <td><input type="radio" name="%s" value="%s" %s />%s</td>
        <td></td>
    </tr>""" % ( self.name, self.value, self.checked, self.description )

class FormCheckBox:
    def __init__( self, name, description, value, help, isChecked ):
        self.name = name
        self.description = description
        self.value = value
        self.help = help
        self.checked = ""
        if isChecked:
            self.checked = 'checked="checked"'

        self.itemHtml = """
    <tr>
        <td class="formName">%s</td>
        <td><input type="checkbox" name="%s" value="%s" %s /></td>
        <td></td>
    </tr>""" % ( self.description, self.name, self.value, self.checked )

class FormRadioGroup:
    def __init__( self, name, help ):
        self.name = name
        self.help = help

        self.itemHtml = """
    <tr>
        <td class="formName">%s</td>
        <td></td>
        <td></td>
    </tr>""" % ( self.name )

class FormHeader:
    def __init__( self, name ):
        self.name = name

        self.itemHtml = """
    <tr>
        <td class="formHeader" colspan="3">%s</td>
    </tr>""" % ( name )

class FormFileItem:
    def __init__( self, name, description, help ):
        self.name = name
        self.description = description
        self.help = help

        self.itemHtml = """
    <tr>
        <td class="formName">%s</td>
        <td><input type="file" name="%s" /></td>
        <td></td>
    </tr>""" % ( self.description, self.name )

class FormMenuItem:
    def __init__( self, name, description, help, selections ):
        self.name = name
        self.description = description
        self.selections = selections
        self.renderHtml()

    def renderHtml( self ):
        html = []
        html.append( """
    <tr>
        <td class="formName">%s</td>
        <td>
            <select name="%s"> """ % (self.description, self.name) )
        count = 0;
        for item in self.selections:
            html.append("""
                <option value="%s">%s</option> """ % ( count, item ) )
            count = count + 1
        html.append( """
            </select>
        </td>
        <td></td>
    </tr>""")
        self.itemHtml = "".join( html )

    def setSelections( self, selections ):
        self.selections = selections
        self.renderHtml()

