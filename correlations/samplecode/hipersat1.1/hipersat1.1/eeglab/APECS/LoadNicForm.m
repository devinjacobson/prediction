function [sigClean] = LoadNicForm(sigCleanForm);

sigClean = ([]);

formMap = struct( 'Process',                   { 'DefaultField'   ,    @IcaProtocol     },  ...
                  'N_processors',              { 'numProc'        ,    @PassToDouble    },  ...
                  'Preprocessing_procedure',   { 'DefaultField'   ,    @DoNotWhiten     },  ...
                  'Sphering_source',           { 'DefaultField'   ,    @SphFileName     },  ...
                  'Convergence_tolerance',     { 'tol'            ,    @PassToDouble    },  ...
                  'Maximum_iterations',        { 'maxIter'        ,    @PassToDouble    },  ...
                  'Initialization_Type',       { 'DefaultField'   ,    @WgtMatrix       },  ...
                  'User_defined_source',       { 'DefaultField'   ,    @WgtFileName     },  ...
                  'Contrast_function',         { 'DefaultField'   ,    @Contrast_f      },  ...
                  'Learning_rate',             { 'lrnRate_i'      ,    @PassToDouble    },  ...
                  'Annealing_degree',          { 'annealDegree_i' ,    @PassToDouble    },  ...
                  'Annealing_scale',           { 'annealScale_i'  ,    @PassToDouble    },  ...
                  'Maximum_weight',            { 'maxWgt_i'       ,    @PassToDouble    },  ...
                  'Maximum_divergence',        { 'maxDiv_i'       ,    @PassToDouble    },  ...
                  'Weight_restart_factor',     { 'wgtRestart_i'   ,    @PassToDouble    },  ...
                  'Divergence_restart_factor', { 'divRestart_i'   ,    @PassToDouble    },  ...
                  'Minimum_learning_rate',     { 'minLrn_i'       ,    @PassToDouble    },  ...
                  'Random_learning',           { 'rndmLrn_i'      ,    @PassToString    },  ...
                  'Weight_matrix_file',        { 'wgtMtrxOutput'  ,    @FileOutput      },  ...
                  'Sphering_matrix_file',      { 'sphMtrxOutput'  ,    @FileOutput      },  ...
                  'Mixing_matrix_file',        { 'mixMtrxOutput'  ,    @FileOutput      },  ...
                  'Unmixing_matrix_file',      { 'unMixMtrxOutput',    @FileOutput      },  ...
                  'IC_matrix_file',            { 'iCMtrxOutput'   ,    @FileOutput      } );
              
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
        
end



function [sigClean] = WgtMatrix(propName, propValue, sigClean);

switch propValue
    
    case 'identity matrix'
        
        sigClean.wgtMtrx = 1;
        
    case 'random'
        
        sigClean.wgtMtrx = 2;
        
    case 'user defined'
        
        sigClean.wgtMtrx = 3;
        
end
        
        
   
        
function [sigClean] = WgtFileName(propName, propValue, sigClean);

switch propValue
    
    case '""'
        
        sigClean.wgtFilePath = 0;
        
        sigClean.wgtFileName = 0;
        
    otherwise
        
        [path name ext ver]  = fileparts(propValue);
        
        sigClean.wgtFilePath = path;
        
        sigClean.wgtFileName = [name ext];
        
end
        
        
    
function [sigClean] = Contrast_f(propName, propValue, sigClean);

switch propValue
    
    case 'cubic'
        
        sigClean.contrast_f = 1;
        
    case 'tanh'
        
        sigClean.contrast_f = 2;
        
end



function [sigClean] = FileOutput(propName, propValue, sigClean);

switch propValue
    
    case 'b'
        
        sigClean.(propName) = 1;
        
    case 'n'
        
        sigClean.(propName) = 0;
        
end



function [sigClean] = PassToDouble(propName, propValue, sigClean);

sigClean.(propName) = str2num(propValue);



function [sigClean] = PassToString(propName, propValue, sigClean);

sigClean.(propName) = propValue;
