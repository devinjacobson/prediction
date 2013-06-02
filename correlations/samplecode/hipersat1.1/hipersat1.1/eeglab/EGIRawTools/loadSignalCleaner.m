%
%
%

fileName = '../tmp/Prewhitened_cubic_test_binary.wgt';

fid = fopen( fileName, 'rb' );
scCubicWeight = fread( fid, [4,inf], 'real*8' );
fclose( fid );

disp( 'Here are the SignalCleaner cubic weights' );

scCubicWeight( 1:4, 1:4 )


fileName = '../tmp/Prewhitened_tanh_test_binary.wgt';

fid = fopen( fileName, 'rb' );
scTanhWeight = fread( fid, [4,inf], 'real*8' );
fclose( fid );

disp( 'Here are the SignalCleaner tanh weights' );

scTanhWeight( 1:4, 1:4 )



fileName = '../tmp/Prewhitened_tanh_big_test_binary.wgt';

fid = fopen( fileName, 'rb' );
scTanhWeightBig = fread( fid, [22,inf], 'real*8' );
fclose( fid );

disp( 'Here are the SignalCleaner tanh weights' );

scTanhWeightBig( 1:2, 1:2 )

fileName = '../tmp/Prewhitened_cubic_big_test_binary.wgt';

fid = fopen( fileName, 'rb' );
scCubicWeightBig = fread( fid, [22,inf], 'real*8' );
fclose( fid );

disp( 'Here are the SignalCleaner cubic weights' );

scCubicWeightBig( 1:22, 1:22 )
