function raw2scf( fileName )

% raw2scf.m: Script M-file to automate conversion of EGI epoch-marked raw format files to binary
% scf-formatted files.
%
% Epoch-marked raw format: Unsegmented simple binary format (raw format,
%                          version # 2, 4 or 6) with event codes <epoc> and <tim0>.

[ header, eegData, eventData, outputLog ] = ReadRaw(fileName);

% Display the header info.

usrMsg = sprintf('\nHeader Information:\n');
disp(usrMsg);
disp(outputLog);

outfile = [ fileName '.scf' ];

fid = fopen( outfile, 'w' );

fwrite( fid, eegData, 'real*8' );

fclose( fid );

disp( sprintf( '\nFile %s has been written', outfile ) );
