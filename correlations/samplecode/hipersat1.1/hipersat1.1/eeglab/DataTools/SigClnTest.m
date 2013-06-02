clear all ; clc ;

dataDir  = 'data';

dataExt  = '.scf';

formExt  = '.form';

process  = 'Infomax';

execLoc  = 'NIC-SPW.txt';

execName = 'signal_cleaner-gcc_mac';

SigClnPath   = char(regexp(which(execLoc), ['.+(?=(?:' filesep execLoc '))'], 'match'));

sigCleanExec = fullfile(SigClnPath, execName); disp(sprintf('\nExecutable: %s', sigCleanExec));

diary(fullfile(SigClnPath, dataDir, [process '_diary.txt']));

% ----------

numChan = 4;

dataName1 = '4x1001_white';

% ----------

disp(sprintf('\n\n---------------------------------------------------\n\n'));

sigCleanData = fullfile(SigClnPath, dataDir, [dataName1 dataExt]); disp(sprintf('Data Path: %s', sigCleanData));

sigCleanForm = fullfile(SigClnPath, dataDir, [dataName1 '_' process formExt]); disp(sprintf('Form Path: %s', sigCleanForm));

sigCleanWght = fullfile(SigClnPath, dataDir, [dataName1 '_' process '_binary.wgt']); disp(sprintf('Computed Weight Matrix Path: %s', sigCleanWght));

fid = fopen(sigCleanData, 'r', 'b');
if fid == -1
    error(sprintf('\n\nError (File Open): %s\n\n', sigCleanData));
else
    x1  = fread(fid, [numChan inf], 'real*8');
    fclose(fid);
end

disp(sprintf('Data Size: Rows = %d | Cols = %d', size(x1,1), size(x1,2)));

disp(sprintf('\n\n---------------------------------------------------\n\n'));

eval(['! ' sigCleanExec ' ' sigCleanForm]);

if strcmpi(process, 'Infomax')

    [Wgt1 Sph1] = runica( x1,                       ...
                          'sphering',   'none',     ...
                          'lrate',      0.001,      ...
                          'stop',       0.000001,   ...
                          'maxsteps',   1024,       ...
                          'posact',     'on' );
    
else

    [tmp, Wgt1] = fastica( x1,                                  ...
                           'initGuess',         eye(numChan),   ...
                           'whiteSig',          x1,             ...
                           'whiteMat',          eye(numChan),   ...
                           'dewhiteMat',        eye(numChan),   ...
                           'displayMode',       'off',          ...
                           'g',                 'tanh',         ...
                           'epsilon',           0.0001,         ...
                           'maxNumIterations',  1024 );
                    
end

fid = fopen(sigCleanWght, 'r', 'b');
if fid == -1
    error(sprintf('\n\nError (File Open): %s\n\n', sigCleanWght));
else
    Wgt1NIC = fread(fid, [numChan inf], 'real*8');
    fclose(fid);
end

% ----------

numChan = 36;

dataName2 = 'APECS';

% ----------

disp(sprintf('\n\n---------------------------------------------------\n\n'));

sigCleanData = fullfile(SigClnPath, dataDir, [dataName2 dataExt]); disp(sprintf('Data Path: %s', sigCleanData));

sigCleanForm = fullfile(SigClnPath, dataDir, [dataName2 '_' process formExt]); disp(sprintf('Form Path: %s', sigCleanForm));

sigCleanWght = fullfile(SigClnPath, dataDir, [dataName2 '_' process '_binary.wgt']); disp(sprintf('Computed Weight Matrix Path: %s', sigCleanWght));

fid = fopen(sigCleanData, 'r', 'b');
if fid == -1
    error(sprintf('\n\nError (File Open): %s\n\n', sigCleanData));
else
    x2  = fread(fid, [numChan inf], 'real*8');
    fclose(fid);
end

disp(sprintf('Data Size: Rows = %d | Cols = %d', size(x2,1), size(x2,2)));

disp(sprintf('\n\n---------------------------------------------------\n\n'));

eval(['! ' sigCleanExec ' ' sigCleanForm]);

if strcmpi(process, 'Infomax')

    [Wgt2 Sph2] = runica( x2,                       ...
                          'sphering',   'none',     ...
                          'lrate',      0.001,      ...
                          'stop',       0.000001,   ...
                          'maxsteps',   1024,       ...
                          'posact',     'on' );
    
else

    [tmp, Wgt2] = fastica( x2,                                  ...
                           'initGuess',         eye(numChan),   ...
                           'whiteSig',          x2,             ...
                           'whiteMat',          eye(numChan),   ...
                           'dewhiteMat',        eye(numChan),   ...
                           'displayMode',       'off',          ...
                           'g',                 'tanh',         ...
                           'epsilon',           0.0001,         ...
                           'maxNumIterations',  1024 );
                    
end

fid = fopen(sigCleanWght, 'r', 'b');
if fid == -1
    error(sprintf('\n\nError (File Open): %s\n\n', sigCleanWght));
else
    Wgt2NIC = fread(fid, [numChan inf], 'real*8');
    fclose(fid);
end

disp(sprintf('\n\n---------------------------------------------------\n\n'));

disp(['RunIca Weight Matrix ' dataName1 ':']);
disp(Wgt1(1:4,1:4));
disp(['NicIca Weight Matrix ' dataName1 ':']);
disp(Wgt1NIC(1:4,1:4));
disp(sprintf('Percent Max Abs Rltv Error %s: %9.6f', dataName1, max(max(abs((Wgt1 - Wgt1NIC) ./ Wgt1))) * 100));

disp(sprintf('\n\n---------------------------------------------------\n\n'));

disp(['RunIca Weight Matrix ' dataName2 ':']);
disp(Wgt2(1:4,1:4));
disp(['NicIca Weight Matrix ' dataName2 ':']);
disp(Wgt2NIC(1:4,1:4));
disp(sprintf('Percent Max Abs Rltv Error %s: %9.6f', dataName2, max(max(abs((Wgt2 - Wgt2NIC) ./ Wgt2))) * 100));

disp(sprintf('\n\n---------------------------------------------------\n\n'));

diary off;

eval([' ! mkdir ' fullfile(SigClnPath, dataDir, process) ' ; mv ' fullfile(SigClnPath, dataDir, '*.wgt') ' ' fullfile(SigClnPath, dataDir, process)]);
