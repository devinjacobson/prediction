from twisted.application import internet
from twisted.application import service

from twisted.protocols.ftp import FTPFactory
from nevow import appserver
import Server

import InfomaxSoap

# The application
application = service.Application( 'HiPerSAT Server' )

# The nevow service

site = appserver.NevowSite( Server.ServerRoot() )
webServer = internet.TCPServer( 4063, site )

webServer.setServiceParent( application )


# scp server
from twisted.conch.ssh import keys, factory as SSHFactory
from twisted.cred import portal, checkers, credentials
from SCPServer import SCPRealm, getRSAKeys

sshFactory = SSHFactory.SSHFactory()
sshFactory.portal = portal.Portal( SCPRealm() )
users = { 'hipersat': 'apasswordforhipersat' }
sshFactory.portal.registerChecker(
    checkers.InMemoryUsernamePasswordDatabaseDontUse( **users ) )

pubkey, privkey = getRSAKeys()
sshFactory.publicKeys = {
    'ssh-rsa': keys.getPublicKeyString( data=pubkey ) }
sshFactory.privateKeys = {
    'ssh-rsa': keys.getPrivateKeyObject( data=privkey) }

scpService = internet.TCPServer( 3604, sshFactory )
scpService.setServiceParent( application )
