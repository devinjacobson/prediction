from twisted.web import soap, xmlrpc, resource
from twisted.internet import reactor

class InfomaxXMLRPC( xmlrpc.XMLRPC ):

    def __init__( self ):
        pass

    def xmlrpc_test( self ):
        return "test!"

    def fail( self ):
        return "failed!"

    def render( self, request ):
        if request.method == 'POST':
            xmlrpc.XMLRPC.render( self, request )
        else:
            return self.fail( )

class InfomaxSOAP( soap.SOAPPublisher ):

    def __init__( self ):
        pass

    def soap_test( self ):
        return "soap test!"

    def fail( self ):
        return "soap failed!"


    def render( self, request ):
        print dir( request )
        if request.method == 'POST':
            try:
                soap.SOAPPublisher.render( self, request )
            except:
                return """<head>%s</head>""" % (self.fail())
        else:
            return self.fail()



