function x = rFileUpload( data, filename, description )
    createClassFromWsdl( 'http://rubato.nic.uoregon.edu:4063/wsdl/test.wsdl' );
    t = TestService();
    s = size( data );
    rows = s(1);
    id = createFileEntry( t, filename, description, s(1), s(2), 'big', 'double' );
    fname = int2str( id.createFileEntryReturn );
    fid = fopen( fname, 'wb', 'b' );
    fwrite( fid, data, 'double' );
    fclose( fid );
    import ch.ethz.ssh2.*;
    c = Connection( 'rubato.nic.uoregon.edu', 3604 );
    c.connect();
    c.authenticateWithPassword( 'hipersat', 'apasswordforhipersat' );
    scp = SCPClient( c );
    scp.put( fname, '.' );
    c.close();
    delete(fname);
    x = id.createFileEntryReturn