function rewindFastForward(fileID, precision, segSize, firstByte, gotoBOF, fwdSeg, rewSeg)

global metaData logFile logFileIx;

switch precision
    case 'integer*2'
        numBytes = 2;
    case 'real*4'
        numBytes = 4;
    case 'real*8'
        numBytes = 8;
end

if rewSeg
    fseek(fileID, -1 * numBytes * segSize * (metaData.numCh + metaData.numEvents), 'cof');
elseif fwdSeg
    fseek(fileID, +1 * numBytes * segSize * (metaData.numCh + metaData.numEvents), 'cof');
elseif gotoBOF
    fseek(fileID, firstByte, 'bof');
end
