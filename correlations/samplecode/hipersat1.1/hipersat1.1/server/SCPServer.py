from twisted.cred import portal
from twisted.conch import avatar, interfaces as conchinterfaces
from twisted.conch.ssh import common, keys, session
from zope.interface import implements
from twisted.internet import reactor
import os



class SCPAvatar( avatar.ConchUser ):
    implements( conchinterfaces.ISession )

    def __init__( self, username ):
        avatar.ConchUser.__init__( self )
        self.username = username
        self.channelLookup.update({'session':session.SSHSession})

    def openShell( self, protocol ):
        pass

    def getPty( self, terminal, windowSize, attrs ):
        return None

    def execCommand( self, protocol, cmd ):
        c = cmd.split()

        if c[0] == 'scp':
            reactor.spawnProcess( 
                protocol, 
                'scp', ['scp', '-t', '-d', 'file' ] )

    def closed( self ):
        pass

class SCPRealm:
    implements( portal.IRealm )

    def requestAvatar( self, avatarId, mind, *interfaces ):
        if conchinterfaces.IConchUser in interfaces:
            return interfaces[0], SCPAvatar( avatarId ), lambda: None
        else:
            return Exception, "The interface you requested is not supported"

def getRSAKeys():
    if not (os.path.exists('public.key') and os.path.exists('private.key')):
        # generate a RSA keypair
        print "Generating RSA keypair..."
        from Crypto.PublicKey import RSA
        KEY_LENGTH = 1024
        rsaKey = RSA.generate(KEY_LENGTH, common.entropy.get_bytes)
        print rsaKey
        publicKeyString = keys.makePublicKeyString(rsaKey)
        privateKeyString = keys.makePrivateKeyString(rsaKey)
        # save keys for next time
        file('public.key', 'w+b').write(publicKeyString)
        file('private.key', 'w+b').write(privateKeyString)
        print "done."
    else:
        publicKeyString = file('public.key').read()
        privateKeyString = file('private.key').read()

    return publicKeyString, privateKeyString
