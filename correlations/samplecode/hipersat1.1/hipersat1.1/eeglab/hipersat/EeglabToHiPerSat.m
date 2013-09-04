function [EEG, cancel] = EeglabToHiPerSat(options, EEG, icaType, tmpData);

% --------------------------------------------------------------------------------------------------------------------------

formExt  = '.form';
        
wgtExt   = '_binary.wgt';

sphExt   = '_binary.sph';

mixExt   = '_binary.mix';

umxExt   = '_binary.umx';

dataName = 'HiPerSat.scf';

hiperMfileSpace = regexprep(mfilename('fullpath'), '(?:\w+)$', '');

hiperSpace      = [hiperMfileSpace '..' filesep '..' filesep 'bin' filesep];
        
workSpace       = [hiperMfileSpace 'scratch' filesep];

% --------------------------------------------------------------------------------------------------------------------------

switch lower(icaType)
            
    case 'hfastica'
                
        icaProtocol = 1;
                
    case 'hinfomax'
                
        icaProtocol = 2;
                
end

[numChan numSmpl] = size(tmpData);
        
arg = char(regexp(options, '(?<=\s*,\s*)\S+', 'match'));
        
if isempty(arg)
            
    [sigClean] = IcaGuiEegLab(workSpace, dataName, formExt, wgtExt, sphExt, mixExt, umxExt, icaType, numChan, numSmpl, 'GUI');
    
    if isempty(sigClean)
                
        cancel  = 1;
                
        return;
                        
    else
                
        cancel = 0;
                
    end
    
else
            
    switch lower(arg)
                
        case 'default'
                        
            [sigClean] = IcaGuiEegLab(workSpace, dataName, formExt, wgtExt, sphExt, mixExt, umxExt, icaType, numChan, numSmpl, 'DEFAULT');
            
            cancel = 0;
    
        case 'form'

            [formName formPath] = uigetfile(formExt, 'Select HiPerSAT Form');

            if ~isequal(formName, 0)
    
                [sigClean] = LoadNicForm(fullfile(formPath, formName));
                
                if isempty(sigClean)
                            
                    errordlg(sprintf('--- Error (File Read): Select A Valid HiPerSAT Form (%s) ---', formExt), 'Input Error');
                    
                    cancel = 1;
                    
                    return;
                            
                else
                    
                    cancel = 0;
                    
                end
                            
                if isequal(sigClean.icaProtocol, icaProtocol)
                    
                    sigClean.scfFormat = 2;

                    sigClean.numChan = numChan;
                    sigClean.numSmpl = numSmpl;
                                    
                    sigClean.scfName = dataName;
                    sigClean.scfPath = workSpace;
    
                    [tmpVar tmpVar tmpVar] = computer ;
                    sigClean.outFormat     = tmpVar   ;
                    clear tmpVar                      ;

                    NicICAForm(workSpace, [dataName formExt], sigClean);
                                
                else
                 
                    errordlg(sprintf('--- Error (File Read): Select A Valid HiPerSAT Form (%s) ---', formExt), 'Input Error');
                    
                    cancel = 1;
                    
                    return;
                            
                end
            
            else
                
                cancel = 1;
                    
                return;
                
            end
                
        otherwise
                    
            errordlg('--- Error (Input): Input Keyword ''FORM'' Or Keyword ''DEFAULT'' ---', 'Input Error');
                
            cancel = 1;
                
            return;
            
    end
            
end


tmpID = fopen([workSpace dataName], 'w', 'b');

            
if (tmpID == -1)
    
    errordlg(sprintf('Error (File Open): %s', [workSpace dataName]), 'File Open Failure');
            
    return;
            
else
    
    fwrite(tmpID, tmpData, 'real*8');
    
    fclose(tmpID);
    
end


switch sigClean.icaProtocol
            
    case 1
                
        hipersatExec = 'hFastICA';
                
    case 2
                
        hipersatExec = 'hInfomax';
                
end



display(sigClean.argList); eval(['! ' hiperSpace hipersatExec ' ' sigClean.argList]);



if ~(sigClean.mixMtrxOutput || sigClean.unMixMtrxOutput)
    
    
    tmpID = fopen([workSpace dataName wgtExt], 'r');
    
            
    if (tmpID == -1)
        
        errordlg(sprintf('Error (File Open): %s', [workSpace dataName wgtExt]), 'File Open Failure');
        
        return;
        
    else
        
        EEG.icaweights = fread(tmpID, [numChan, numChan], 'real*8');
        
        fclose(tmpID);

    end
    
            
	if isequal(sigClean.sphFileName, 0)
                
        sphMatrix = [workSpace dataName sphExt];
                
    else
                
        sphMatrix = fullfile(sigClean.sphFilePath, sigClean.sphFileName);
                
    end
    
    
    tmpID = fopen(sphMatrix, 'r');
    
        
    if (tmpID == -1)
        
        errordlg(sprintf('Error (File Open): %s', sphMatrix), 'File Open Failure');
        
        return;
        
    else
        
        EEG.icasphere = fread(tmpID, [numChan, numChan], 'real*8');
                
        fclose(tmpID);
                
    end
    
    
else
    
    
    if sigClean.mixMtrxOutput
        
            
        tmpID = fopen([workSpace dataName mixExt], 'r');
        
            
        if (tmpID == -1)
        
            errordlg(sprintf('Error (File Open): %s', [workSpace dataName mixExt]), 'File Open Failure');
        
            return;
        
        else
        
            EEG.icawinv = fread(tmpID, [numChan, numChan], 'real*8');
        
            fclose(tmpID);
        
        end
    
        
        if ~sigClean.unMixMtrxOutput
    
            EEG.icaweights = inv(EEG.icawinv);
    
        end
        
    
    end
        
    
    if sigClean.unMixMtrxOutput
            
        
        tmpID = fopen([workSpace dataName umxExt], 'r');
        
            
        if (tmpID == -1)
            
                errordlg(sprintf('Error (File Open): %s', [workSpace dataName umxExt]), 'File Open Failure');
                
                return;
                
        else
                
                EEG.icaweights = fread(tmpID, [numChan, numChan], 'real*8');
                
                fclose(tmpID);
                
        end
    
        
        if ~sigClean.mixMtrxOutput
    
            EEG.icawinv = inv(EEG.icaweights);
    
        end
    
        
    end
    
        
    EEG.icasphere = eye(size(EEG.icaweights, 2));
    
    
end


% --------------------------------------------------------------------------------------------------------------------------


function [sigClean] = LoadNicForm(sigCleanForm);

sigClean = [];

formMap = struct( 'Process',                            { 'DefaultField'   ,    @IcaProtocol     },  ...
                  'N_processors',                       { 'numProc'        ,    @PassToDouble    },  ...
                  'Preprocessing_procedure',            { 'DefaultField'   ,    @DoNotWhiten     },  ...
                  'Sphering_source',                    { 'DefaultField'   ,    @SphFileName     },  ...
                  'Initialization_Type',                { 'DefaultField'   ,    @WgtMatrix       },  ...
                  'User_defined_source',                { 'DefaultField'   ,    @WgtFileName     },  ...
                  'Convergence_tolerance',              { 'DefaultField'   ,    @Tolerance       },  ...
                  'Maximum_iterations',                 { 'maxIter'        ,    @PassToDouble    },  ...
                  'Contrast_function',                  { 'DefaultField'   ,    @Contrast_f      },  ...
                  'Learning_rate',                      { 'lrnRate_i'      ,    @PassToDouble    },  ...
                  'Annealing_degree',                   { 'annealDegree_i' ,    @PassToDouble    },  ...
                  'Annealing_scale',                    { 'annealScale_i'  ,    @PassToDouble    },  ...
                  'Maximum_weight',                     { 'maxWgt_i'       ,    @PassToDouble    },  ...
                  'Maximum_divergence',                 { 'maxDiv_i'       ,    @PassToDouble    },  ...
                  'Weight_restart_factor',              { 'wgtRestart_i'   ,    @PassToDouble    },  ...
                  'Divergence_restart_factor',          { 'divRestart_i'   ,    @PassToDouble    },  ...
                  'Minimum_learning_rate',              { 'minLrn_i'       ,    @PassToDouble    },  ...
                  'Random_Learning',                    { 'rndmLrn_i'      ,    @PassToString    },  ...
                  'Weight_matrix_file',                 { 'wgtMtrxOutput'  ,    @FileOutput      },  ...
                  'Sphering_matrix_file',               { 'sphMtrxOutput'  ,    @FileOutput      },  ...
                  'Mixing_matrix_file',                 { 'mixMtrxOutput'  ,    @FileOutput      },  ...
                  'Unmixing_matrix_file',               { 'unMixMtrxOutput',    @FileOutput      },  ...
                  'Independent_component_file_name',    { 'DefaultField'   ,    @IcsFileName     },  ...
                  'Binary_File_Format',                 { 'outFormat'      ,    @PassToString    } );
              
fid = fopen(sigCleanForm);
        
if (fid == -1)
    
    errordlg( sprintf( 'Error (File Open): %s' , sigCleanForm ) , 'File Open Failure' );
    
    return;
            
else

    formData = textscan(fid, '%s', 'delimiter', '\n');
        
    fclose(fid);
            
end

for i = 1 : length(formData{1})
    
    if ~isempty(formData{1}{i})
        
        if isempty(regexp(formData{1}{i}, '^(?:\s*/{2})'))
                
            propertyName   =  char(regexprep(deblank(regexpi(formData{1}{i}, '(?:\w+\s*)+(?=:)', 'match')), '\s+', '_'));
                
            propertyValue  =  char(regexprep(deblank(regexpi(formData{1}{i}, '(?<=:\s*)(?:\S+\s*)+', 'match')), '\s+', ' '));
            
            if any(strcmp(propertyName, fieldnames(formMap)))
            
                [sigClean] = feval(formMap(2).(propertyName), formMap(1).(propertyName), propertyValue, sigClean);
                
            end
                
        end
            
    end
    
end



function FileTransfer(inFilePath, outFilePath, fileName)

global sigClean;

fid = fopen(fullfile(inFilePath, fileName), 'r');
    
tmpVar = fread(fid, [sigClean.numChan, sigClean.numChan], 'real*8');
    
fclose(fid);
    
fid = fopen(fullfile(outFilePath, fileName), 'w');
    
fwrite(fid, tmpVar, 'real*8');
    
fclose(fid);
    
clear tmpVar;



function [sigClean] = IcaProtocol(propName, propValue, sigClean);

switch propValue
    
    case 'FastICA'
        
        sigClean.icaProtocol = 1;
        
    case 'Infomax'
        
        sigClean.icaProtocol = 2;
        
end



function [sigClean] = DoNotWhiten(propName, propValue, sigClean);

switch propValue
    
    case '0'
        
        sigClean.doNotWhiten   =  1;
        sigClean.valWhiten     =  0;
        sigClean.storeWhtData  =  0;
        
    case '1'

        sigClean.doNotWhiten   =  0;
        sigClean.valWhiten     =  0;
        sigClean.storeWhtData  =  0;
        
    case '2'
        
        sigClean.doNotWhiten   =  0;
        sigClean.valWhiten     =  1;
        sigClean.storeWhtData  =  0;
        
    case '3'
        
        sigClean.doNotWhiten   =  0;
        sigClean.valWhiten     =  1;
        sigClean.storeWhtData  =  1;
        
end
        
        
        
function [sigClean] = SphFileName(propName, propValue, sigClean);

switch propValue
    
    case '""'
        
        sigClean.sphFilePath  =  0;
        
        sigClean.sphFileName  =  0;
        
        sigClean.sphereMatrix =  'none';
        
    otherwise
        
        [path name ext ver]   =  fileparts(propValue);
        
        sigClean.sphFilePath  =  path;
        
        sigClean.sphFileName  =  [name ext];
        
        sigClean.sphereMatrix =  'file';
        
        FileTransfer(sigClean.sphFilePath, sigClean.scfPath, sigClean.sphFileName);

end



function [sigClean] = WgtMatrix(propName, propValue, sigClean);

switch sigClean.icaProtocol
    
    case 1
    
        switch propValue
    
            case 'identity matrix'
        
                sigClean.wgtMtrx = 1;
        
            case 'random'
        
                sigClean.wgtMtrx = 2;
        
            case 'user defined'
        
                sigClean.wgtMtrx = 3;
                
        end
        
    case 2
        
        switch propValue
    
            case 'identity matrix'
        
                sigClean.wgtMtrx2 = 1;
        
            case 'random'
        
                sigClean.wgtMtrx2 = 2;
        
            case 'user defined'
        
                sigClean.wgtMtrx2 = 3;
                
        end
        
end



function [sigClean] = WgtFileName(propName, propValue, sigClean);

switch sigClean.icaProtocol
    
    case 1

        switch propValue
    
            case '""'
        
                sigClean.wgtFilePath = 0;
        
                sigClean.wgtFileName = 0;
        
            otherwise
        
                [path name ext ver]  = fileparts(propValue);
        
                sigClean.wgtFilePath = path;
        
                sigClean.wgtFileName = [name ext];
        
                FileTransfer(sigClean.wgtFilePath, sigClean.scfPath, sigClean.wgtFileName);

        end
    
    case 2
        
        switch propValue
    
            case '""'
        
                sigClean.wgtFile2Path = 0;
        
                sigClean.wgtFile2Name = 0;
        
            otherwise
        
                [path name ext ver]  = fileparts(propValue);
        
                sigClean.wgtFile2Path = path;
        
                sigClean.wgtFile2Name = [name ext];
        
                FileTransfer(sigClean.wgtFile2Path, sigClean.scfPath, sigClean.wgtFile2Name);

        end
        
end
        
        
    
function [sigClean] = Tolerance(propName, propValue, sigClean);

switch sigClean.icaProtocol
    
    case 1
        
        sigClean.tol_f = str2num(propValue);
        
    case 2
        
        sigClean.tol_i = str2num(propValue);
        
end
        
        
    
function [sigClean] = Contrast_f(propName, propValue, sigClean);

switch propValue
    
    case 'cubic'
        
        sigClean.contrast_f = 1;
        
    case 'tanh'
        
        sigClean.contrast_f = 2;
        
end



function [sigClean] = PassToDouble(propName, propValue, sigClean);

sigClean.(propName) = str2num(propValue);



function [sigClean] = PassToString(propName, propValue, sigClean);

sigClean.(propName) = propValue;



function [sigClean] = FileOutput(propName, propValue, sigClean);

switch propValue
    
    case {'a', 'b', 'l', 'p'}
        
        sigClean.(propName) = 1;
        
    case 'n'
        
        sigClean.(propName) = 0;
        
end



function [sigClean] = IcsFileName(propName, propValue, sigClean);

switch propValue
    
    case {'""'}
        
        sigClean.iCMtrxOutput = 0;
        
    otherwise
        
        sigClean.iCMtrxOutput = 1;
        
end
