function [EEG, VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, minAmp, maxAmp] = EegNetType(numCh);

% Specifies data acquisition hardware.

VEOGstr{1} = 'LUVEOG: # ';
VEOGstr{2} = 'RUVEOG: # ';
VEOGstr{3} = 'LLVEOG: # ';
VEOGstr{4} = 'RLVEOG: # ';

HEOGstr{1} = 'LHEOG: # ';
HEOGstr{2} = 'RHEOG: # ';  

switch numCh
    
    case 256
        
        VEOG(1) = 36;
        VEOG(2) = 18;
        VEOG(3) = 242;
        VEOG(4) = 241;
        
        HEOG(1) = 251;
        HEOG(2) = 227;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-256Ch';
        
    case 127
        
        VEOG(1) = 24;
        VEOG(2) = 11;
        VEOG(3) = 126;
        VEOG(4) = 125;
        
        HEOG(1) = 127;
        HEOG(2) = 124;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-127Ch';
        
    case 69
        
        VEOG(1) = 13;
        VEOG(2) = 06;
        VEOG(3) = 68;
        VEOG(4) = 67;
        
        HEOG(1) = 69;
        HEOG(2) = 66;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-69Ch';
        
    case {36, 37}
        
        VEOG(1) = 06;
        VEOG(2) = 02;
        VEOG(3) = 35;
        VEOG(4) = 34;
        
        HEOG(1) = 36;
        HEOG(2) = 33;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-36Ch';
        
    case 34
        
        VEOG(1) = 06;
        VEOG(2) = 02;
        VEOG(3) = 33;
        VEOG(4) = 34;
        
        HEOG(1) = 33;
        HEOG(2) = 34;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-34Ch';
        
    case 22
        
        VEOG(1) = 04;
        VEOG(2) = 02;
        VEOG(3) = 21;
        VEOG(4) = 20;
        
        HEOG(1) = 22;
        HEOG(2) = 19;
        
        minAmp = -250;
        maxAmp = +500;
        
        EEG = 'Net256-22Ch';
        
    otherwise
        
        errMsg = sprintf('\n\nData For %d Channel Net Not Available\n\n', numCh);
        error(errMsg);
        
end

numVEOG = length(VEOG);
numHEOG = length(HEOG);
