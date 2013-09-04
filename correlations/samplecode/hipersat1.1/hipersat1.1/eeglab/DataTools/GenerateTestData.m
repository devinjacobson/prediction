clear all; clc;
rand('state', sum(100*clock));

disp(sprintf(['Generates linear mixtures (the EEG) from independent, identically distributed,\n' ...
              'uniformly random data with zero mean and unity variance (the IC).  The EEG mixtures,\n' ...
              'both raw and white, are written to separate big-endian or little-endian formatted\n' ...
              'binary files in column-major order.  The mixing matrix (A) is stored in a .mat file.']));

fileName = input('\nEnter a file name: ', 's');
fileType = input('\nBinary files in big-endian (be) format, little-endian (le) format or both (bo): ', 's');

numCh = input('\nEnter the number of channels: ');
numSample = input(['\nEnter the number of samples (Note ' int2str(numCh) '^2 = ' int2str(numCh .^ 2) '): ']);

switch fileType
    
    case 'be'
        
        fileType = 'b';
        
    case 'le'
        
        filetype = 'l';
        
    case 'bo'
        
        fileType = ['b' 'l'];
        
    otherwise
        
        error('!!! File Type Must Be Either ''be'', ''le''  or ''bo'' !!!');

end

x = zeros(numCh, numSample);
s = rand(numCh, numSample);
A = rand(numCh, numCh);

s = inv(diag(std(s', 1))) * (s - repmat(mean(s, 2), 1, numSample));
x = A * s;

for i = 1:length(fileType)
    
    fid  = fopen([fileName '_unwhite_' fileType(i) '.scf'], 'w', fileType(i));
    if fid == -1
        error('!!! File Open Failure: Raw EEG Mixture !!!');
    else
        fwrite(fid, x, 'real*8');
    end
    fclose(fid);
    
end

[V, D] = eig(cov(x', 1));
Sph = sqrt(inv(D)) * V';
x = Sph * x;

for i = 1:length(fileType)
    
    fid  = fopen([fileName '_white_' fileType(i) '.scf'], 'w', fileType(i));
    if fid == -1
        error('!!! File Open Failure: Whitened EEG Mixture !!!');
    else
        fwrite(fid, x, 'real*8');
    end
    fclose(fid);
    
end

W = inv(A);
Wgt = W * inv(Sph);

save([fileName '.mat'], 'A', 'W', 'Wgt', 'Sph', '-mat');

