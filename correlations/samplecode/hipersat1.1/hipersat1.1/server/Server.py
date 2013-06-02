from nevow import rend, static, loaders
from InfomaxPage import InfomaxPage
from SobiPage import SobiPage
from FastICAPage import FastICAPage
from QueuePage import QueuePage
from ProcessQueue import q
#from InfomaxSoap import InfomaxXMLRPC, InfomaxSOAP
from SoapInterface import SoapInterface
from FilePage import FilePage

class ServerRoot( rend.Page ):
    child_infomax = InfomaxPage()
    child_sobi = SobiPage()
    child_fastica = FastICAPage()
    child_queue = QueuePage( q )
    child_styles = static.File( 'styles' )
    child_images = static.File( 'images' )
    child_wsdl = static.File( 'wsdl' )
#    child_RPC2 = InfomaxXMLRPC()
    child_SOAP = SoapInterface()
    child_file = FilePage()

    docFactory = loaders.xmlfile( 'html/root.html' )
