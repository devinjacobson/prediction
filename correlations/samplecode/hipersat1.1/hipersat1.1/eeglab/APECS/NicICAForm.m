function NicICAForm(formPath, formName, sigClean);

% ======================= PRE-PROCESSING INSTRUCTIONS =====================
%
%       Data pre-whitened (No pre-processing):              (1)
%       Whiten data:                                        (2)
%       Whiten + Validate whitening:                        (3)
%       Whiten + Store whitened data:                       (4)
%       Whiten + Validate whitening + Store whitened data:  (5)
%
%   Signal Cleaner requires a sphering matrix to whiten the data and / or 
%   calculate the mixing and un-mixing matrices.
%
%       Options:
%
%       Pre-processor computes the sphering matrix
%       Sphering matrix supplied in a binary file (column-major)
%
% =========================== WEIGHT MATRIX SEED ==========================
%
%  -- Weight matrix seed:
%
%       'random'
%       'identity'
%       'user defined'
%
%   User defined => supply a weight matrix seed in a binary file (column-major).
%
% ========================== FastICA PROCESSING ===========================
%
%  -- Convergence Tolerance (Float): 0.0001
%
%  -- Maximum Iterations (Integer): 1000
%
%  -- Contrast function:
%
%       'cubic'
%       'gaussian'
%       'tanh'
%
% ========================== INFOMAX PROCESSING ===========================
%
%  -- Convergence Tolerance (Float): 0.000001
%
%  -- Maximum Iterations (Integer): 1024
%
%  -- Learning Set Size (Integer): 34
%
%  -- Learning Rate (Float): 0.00065
%
%  -- Annealing Degree (Integer): 60
%
%  -- Annealing Scale (Float): 0.90
%
%  -- Maximum Weight Size (Integer): 100000000
%
%  -- Maximum Divergence (Integer): 1000000000
%
%  -- Weight Restart Factor (Float): 0.9
%
%  -- Divergence Restart Factor (Float): 0.8
%
%  -- Minimum Learning Rate (Float): 0.00000001
%
%  -- Random Learning (yes 'y' or no 'n'): 'n'



% =========================================================================
% ================== Do Not Modify Code Beyond This Line ==================
% =========================================================================



switch sigClean.scfFormat
    
    case 1
        
        scfFormat = 'a';
        
    case 2
        
        scfFormat = 'b';
        
    case 3
        
        scfFormat = 'l';
        
    case 4
        
        scfFormat = 'p';
        
end



switch sigClean.outFormat
    
    case {'B', 'b', 'Big-endian'}
        
        outFormat = 'Big-endian'        ;
        
    case {'L', 'l', 'Little-endian'}
        
        outFormat = 'Little-endian'     ;
        
end



switch sigClean.icaProtocol
    
    case 1
        
        process  =  'FastICA'                   ;
        
        switch sigClean.contrast_f
    
            case 1
        
                contrastFunction  =  'cubic'    ;
        
            case 2
        
                contrastFunction  =  'tanh'     ;
        
        end
    
        switch sigClean.wgtMtrx
        
            case 1
        
                seedMatrix              =   'identity matrix'       ;
                seedMatrixSource        =   '""'                    ;
                seedMatrixType          =   '""'                    ;
                seedMatrixOrientation   =   '""'                    ;
        
            case 2
        
                seedMatrix              =   'random'                ;
                seedMatrixSource        =   '""'                    ;
                seedMatrixType          =   '""'                    ;
                seedMatrixOrientation   =   '""'                    ;
        
            case 3
        
                seedMatrix              =   'user defined'          ;
                seedMatrixSource        =   sigClean.wgtFileName    ;
                seedMatrixType          =   'b'                     ;
                seedMatrixOrientation   =   'column-major'          ;
        
        end
    
    case 2
        
        process  =  'Infomax'                                       ;
        
        switch sigClean.wgtMtrx2
        
            case 1
        
                seedMatrix              =   'identity matrix'       ;
                seedMatrixSource        =   '""'                    ;
                seedMatrixType          =   '""'                    ;
                seedMatrixOrientation   =   '""'                    ;
        
            case 2
        
                seedMatrix              =   'random'                ;
                seedMatrixSource        =   '""'                    ;
                seedMatrixType          =   '""'                    ;
                seedMatrixOrientation   =   '""'                    ;
        
            case 3
        
                seedMatrix              =   'user defined'          ;
                seedMatrixSource        =   sigClean.wgtFile2Name   ;
                seedMatrixType          =   'b'                     ;
                seedMatrixOrientation   =   'column-major'          ;
        
        end
        
end



if sigClean.doNotWhiten
    
    numPreprocessProcedure = 0;
    
else
    
    numPreprocessProcedure = 1;
    preprocessProcedureString{numPreprocessProcedure} = 'whiten';
    
    if sigClean.valWhiten
        
        numPreprocessProcedure = numPreprocessProcedure + 1;
        preprocessProcedureString{numPreprocessProcedure} = 'validate whitening';
        
    end
    
    if sigClean.storeWhtData
        
        numPreprocessProcedure = numPreprocessProcedure + 1;
        preprocessProcedureString{numPreprocessProcedure} = 'store whitened data';
        
    end
    
end



if isequal(sigClean.sphFileName, 0)
        
    sphereMatrixSource       =   '""'                   ;
    sphereMatrixType         =   '""'                   ;
    sphereMatrixOrientation  =   '""'                   ;
        
else
        
    sphereMatrixSource       =   sigClean.sphFileName   ;
    sphereMatrixType         =   'b'                    ;
    sphereMatrixOrientation  =   'column-major'         ;
        
end



showConvergence             =   'yes'                                                           ;

averageVectorScreen         =   'n'                                                             ;

covarianceMatrixScreen      =   'n'                                                             ;

qMatrixScreen               =   'n'                                                             ;

lambdaMatrixScreen          =   'n'                                                             ;

spheringMatrixScreen        =   'n'                                                             ;

weightMatrixScreen          =   'n'                                                             ;

mixingMatrixScreen          =   'n'                                                             ;

unmixingMatrixScreen        =   'n'                                                             ;

iCMatrixScreen              =   'n'                                                             ;

averageVectorFile           =   'n'                                                             ;

covarianceMatrixFile        =   'n'                                                             ;

qMatrixFile                 =   'n'                                                             ;

lambdaMatrixFile            =   'n'                                                             ;

if sigClean.sphMtrxOutput
    
    sphereMatrixFile        =   'e'                                                             ;
    
else
    
    sphereMatrixFile        =   'n'                                                             ;
    
end

if sigClean.wgtMtrxOutput
    
    weightMatrixFile        =   'e'                                                             ;
    
else
    
    weightMatrixFile        =   'n'                                                             ;
    
end

if sigClean.mixMtrxOutput
    
    mixingMatrixFile        =   'b'                                                             ;
    
else
    
    mixingMatrixFile        =   'n'                                                             ;
    
end

if sigClean.unMixMtrxOutput
    
    unmixingMatrixFile      =   'b'                                                             ;
    
else
    
    unmixingMatrixFile      =   'n'                                                             ;
    
end

if sigClean.iCMtrxOutput
    
    iCMatrixFile            =   [ char(regexp(formName, '.+(?=\.\w{3,})', 'match')) '.ics' ]    ;
    
else
    
    iCMatrixFile            =   '""'                                                            ;
    
end



% Open Unified Form File

fid = fopen(fullfile(formPath, formName), 'wt');

if (fid == -1)
    
    errordlg( sprintf( 'Error (File Open): %s' , fullfile(formPath, formName) ) , 'File Open Failure' );
    
    return;
    
end



% Generate Signal_Cleaning.form

fprintf(fid,    '//\n//%s\n//\n',                'Signal_Cleaning_Form Component'    );

fprintf(fid,    'Process: %s\n',                 process                             );
fprintf(fid,    'Source data location: %s\n',    sigClean.scfName                    );
fprintf(fid,    'File type: %s\n',               scfFormat                           );
fprintf(fid,    'Orientation: %s\n',             'channels x observations'           );
fprintf(fid,    'Channels: %d\n',                sigClean.numChan                    );
fprintf(fid,    'Observations: %d\n',            sigClean.numSmpl                    );
fprintf(fid,    'N processors: %d\n',            sigClean.numProc                    );



% Generate FastICA_Process.form / Infomax_Process.form

switch process
    
    case 'FastICA'
        
        fprintf(fid, '//\n//%s\n//\n',                          'FastICA_Process_Form Component' );
        
        fprintf(fid, 'Preprocessing procedure: %d\n',           numPreprocessProcedure           );

        if numPreprocessProcedure ~= 0
            fprintf(fid,'%s\n',preprocessProcedureString{:});
        end
        
        fprintf(fid, 'Sphering matrix: %s\n',                   sigClean.sphereMatrix   );
        fprintf(fid, 'Sphering source: %s\n',                   sphereMatrixSource      );
        fprintf(fid, 'Sphering type: %s\n',                     sphereMatrixType        );
        fprintf(fid, 'Sphering orientation: %s\n',              sphereMatrixOrientation );
        
        fprintf(fid, 'Convergence tolerance: %12.10f\n',        sigClean.tol_f          );
    	fprintf(fid, 'Maximum iterations: %d\n',                sigClean.maxIter        );
        fprintf(fid, 'Retries: %d\n',                           0                       );
        fprintf(fid, 'Contrast function: %s\n',                 contrastFunction        );
        
        fprintf(fid, 'Initialization Type: %s\n',               seedMatrix              );
        fprintf(fid, 'User defined source: %s\n',               seedMatrixSource        );
        fprintf(fid, 'User defined type: %s\n',                 seedMatrixType          );
        fprintf(fid, 'User defined orientation: %s\n',          seedMatrixOrientation   );
        
    case 'Infomax'
        
        fprintf(fid, '//\n//%s\n//\n',                          'Infomax_Process_Form Component' );
        
        fprintf(fid, 'Preprocessing procedure: %d\n',           numPreprocessProcedure           );

        if numPreprocessProcedure ~= 0
            fprintf(fid,'%s\n',preprocessProcedureString{:});
        end
        
        fprintf(fid, 'Sphering matrix: %s\n',                   sigClean.sphereMatrix   );
        fprintf(fid, 'Sphering source: %s\n',                   sphereMatrixSource      );
        fprintf(fid, 'Sphering type: %s\n',                     sphereMatrixType        );
        fprintf(fid, 'Sphering orientation: %s\n',              sphereMatrixOrientation );
        
        fprintf(fid, 'Convergence tolerance: %12.10f\n',        sigClean.tol_i          );
        fprintf(fid, 'Maximum iterations: %d\n',                sigClean.maxIter        );
        fprintf(fid, 'Retries: N/A\n'                                                   );
        
        fprintf(fid, 'Initialization Type: %s\n',               seedMatrix              );
        fprintf(fid, 'User defined source: %s\n',               seedMatrixSource        );
        fprintf(fid, 'User defined type: %s\n',                 seedMatrixType          );
        fprintf(fid, 'User defined orientation: %s\n',          seedMatrixOrientation   );
        
        fprintf(fid, 'Learn set size: %d\n',                    0                       );
        fprintf(fid, 'Learning rate: %12.10f\n',                sigClean.lrnRate_i      );
        fprintf(fid, 'Annealing degree: %d\n',                  sigClean.annealDegree_i );
        fprintf(fid, 'Annealing scale: %12.10f\n',              sigClean.annealScale_i  );
        
        fprintf(fid, 'Maximum weight: %d\n',                    sigClean.maxWgt_i       );
        fprintf(fid, 'Maximum divergence: %d\n',                sigClean.maxDiv_i       );
        fprintf(fid, 'Weight restart factor: %12.10f\n',        sigClean.wgtRestart_i   );
        fprintf(fid, 'Divergence restart factor: %12.10f\n',    sigClean.divRestart_i   );
        fprintf(fid, 'Minimum learning rate: %12.10f\n',        sigClean.minLrn_i       );
        
        fprintf(fid, 'Random Learning: %s\n',                   sigClean.rndmLrn_i      );
        
end



% Generate ICA_Output.form
        
fprintf(fid, '//\n//%s\n//\n',                          'ICA_Output_Form Component' );
        
fprintf(fid, 'Show convergence: %s\n',                  showConvergence             );

fprintf(fid, 'Weight matrix screen: %s\n',              weightMatrixScreen      );
fprintf(fid, 'Mixing matrix screen: %s\n',              mixingMatrixScreen      );
fprintf(fid, 'Unmixing matrix screen: %s\n',            unmixingMatrixScreen    );
fprintf(fid, 'Q matrix screen: %s\n',                   qMatrixScreen           );
fprintf(fid, 'Lambda ^(-1/2) matrix screen: %s\n',      lambdaMatrixScreen      );
fprintf(fid, 'Average vector screen: %s\n',             averageVectorScreen     );
fprintf(fid, 'Covariance matrix screen: %s\n',          covarianceMatrixScreen  );
fprintf(fid, 'IC matrix screen: %s\n',                  iCMatrixScreen          );
fprintf(fid, 'Sphering matrix screen: %s\n',            spheringMatrixScreen    );

fprintf(fid, 'Binary File Format: %s\n',                outFormat               );

fprintf(fid, 'Weight matrix file: %s\n',                weightMatrixFile        );
fprintf(fid, 'Mixing matrix file: %s\n',                mixingMatrixFile        );
fprintf(fid, 'Unmixing matrix file: %s\n',              unmixingMatrixFile      );
fprintf(fid, 'Q matrix file: %s\n',                     qMatrixFile             );
fprintf(fid, 'Lambda ^(-1/2) matrix file: %s\n',        lambdaMatrixFile        );
fprintf(fid, 'Average vector file: %s\n',               averageVectorFile       );
fprintf(fid, 'Covariance matrix file: %s\n',            covarianceMatrixFile    );
fprintf(fid, 'Independent component file name: %s\n',   iCMatrixFile            );
fprintf(fid, 'Sphering matrix file: %s\n',              sphereMatrixFile        );

fprintf(fid, 'File name: %s\n',                         char(regexp(formName, '.+(?=\.\w{3,})', 'match')) );



% Close the file

fclose(fid);
