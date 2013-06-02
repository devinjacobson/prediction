from FormGenerator import FormMenuItem

class FileDatabase:
    def __init__( self ):
        self.fd = []
        self.formMenu = FormMenuItem( "file", "File Selection", "", [] )

    def append( self, item ):
        self.fd.append( item )
        # race condition here, danger, danger!
        l = len( self.fd )
        self.updateMenu()
        return (l-1)

    def renderdb( self ):
        table = []
        table.append( """<table class="filedb">""" )
        table.append( """
            <tr>
                <th>
                    Id
                </th>
                <th>
                    Name
                </th>
                <th>
                    Channels
                </th>
                <th>
                    Samples
                </th>
                <th>
                    Description
                </th>
            </tr>""")

        count = 0
        for item in self.fd:
            table.append( """
                <tr>
                    <td>
                        %s
                    </td>
                    <td>
                        %s
                    </td>
                    <td>
                        %s
                    </td>
                    <td>
                        %s
                    </td>
                    <td>
                        %s
                    </td>
                </tr>""" % ( count, item["name"], item["channels"], item["samples"], item["description"] ) )
            count = count + 1

        table.append( """</table>""" )
        
        return "".join( table )

    def updateMenu( self ):
        selections = []
        for item in self.fd:
            selections.append( item["name"] )
        self.formMenu.setSelections( selections )

fileDatabase = FileDatabase()
