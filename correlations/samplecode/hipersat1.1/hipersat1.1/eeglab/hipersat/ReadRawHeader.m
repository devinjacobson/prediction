function [fid, precision] =  ReadRawHeader(fileName);

% readRawHeader reads an EGI epoch-marked raw format file. 
%
% Epoch-marked raw format: Unsegmented simple binary format, version # 2, 4 or 6.
%
% Input Arguments:
%
%   fileName    - Name of EGI raw format file.
%
% Output Arguments:
%
%   metaData    - (Global Variable) Structure array containing the files meta data.
% 
%   fid         - EEG data file ID from fopen.
%
%   precision   - Numeric precision string. 

global metaData;

% Open the data file. -----------------------------------------------------------------------------

fid = fopen(fileName, 'r', 'b');

if (fid == -1)
    
    errordlg( sprintf( 'Error (File Open): %s' , fileName ) , 'File Open Failure' );
    
    return;

end

% Read the header info into the structure variable 'metaData'. ------------------------------------

metaData.versionNumber          =   fread(fid, 1, 'integer*4');

switch metaData.versionNumber

   case {3, 5, 7}
       
       errordlg( 'Error (File Open): Epoch-Marked Raw Format Only' , 'File Open Failure' );
       
       return;

end

metaData.recordingTimeYear      =   fread(fid, 1, 'integer*2');

metaData.recordingTimeMonth     =   fread(fid, 1, 'integer*2');

metaData.recordingTimeDay       =   fread(fid, 1, 'integer*2');

metaData.recordingTimeHour      =   fread(fid, 1, 'integer*2');

metaData.recordingTimeMinute    =   fread(fid, 1, 'integer*2');

metaData.recordingTimeSecond    =   fread(fid, 1, 'integer*2');

metaData.recordingTimeMillisec  =   fread(fid, 1, 'integer*4');

metaData.samplingRate           =   fread(fid, 1, 'integer*2');

metaData.numCh                  =   fread(fid, 1, 'integer*2');

metaData.boardGain              =   fread(fid, 1, 'integer*2');

metaData.numConvBits            =   fread(fid, 1, 'integer*2');

metaData.ampRange               =   fread(fid, 1, 'integer*2');

metaData.numSamples             =   fread(fid, 1, 'integer*4');

metaData.numEvents              =   fread(fid, 1, 'integer*2');

for i = 1:metaData.numEvents

    metaData.eventCodes{i}      =   fread(fid, [1, 4], 'uchar');

end
    
metaData.epocIX                 =   [];

metaData.numEpoc                =   0;

% Finished reading the header. --------------------------------------------------------------------

switch metaData.versionNumber

   case 2
       precision = 'integer*2';
   case 4
       precision = 'real*4';
   case 6
       precision = 'real*8';

end
