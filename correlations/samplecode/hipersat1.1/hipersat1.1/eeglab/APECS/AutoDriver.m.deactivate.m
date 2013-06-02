% ----------------------------------------------------------------------------------------------------------------


% Name of .raw formatted file

fileName        = [];


% ----------------------------------------------------------------------------------------------------------------


% 'Y' or 'y' to segment the data; 'N' or 'n' otherwise
   
segment         = [];


% ---------------------------------------- !!! Segment = 'Y' OR 'y' !!! ------------------------------------------


% Number of segments (Positive integer)

numSeg          = [];


% ----------------------------------------------------------------------------------------------------------------


% 1) Eliminate user-specified bad channels
% 2) Eliminate low-variance channels: |Channel Variance| < Low-Variance Threshold
% 3) Eliminate user-specified bad channels + Eliminate remaining low-variance channels
% 4) No bad / low-variance channels

badChProtocol   = [];


% --------------------------------------- !!! BadChanProtocol = 1 OR 3 !!! ---------------------------------------


% Pointer to bad channels (Comma separated list of integer channel numbers, enclosed by [])

badCh           = [];


% --------------------------------------- !!! BadChanProtocol = 2 OR 3 !!! ---------------------------------------


% Low-Variance Threshold: Channel is marked bad if 0 <= Channel Variance <= badChTol

badChTol        = [];


% ----------------------------------------------------------------------------------------------------------------


% 1) Re-insert the saturated observations into the filtered data
% 2) Replace the saturated observations with zeros in the filtered data
% 3) Remove all saturated observations + corresponding event markers from the filtered data
                        
satObsProtocol  = []; 


% ----------------------------------------------------------------------------------------------------------------


% 1) FastICA (MATLAB)
% 2) Infomax (MATLAB)
% 3) HiPerSAT - FastICA (C++): Default Parameters Only
% 4) HiPerSAT - Infomax (C++): Default Parameters Only
% 5) SOBI (MATLAB)
                        
icaProtocol     = [];


% ------------------------------------------ !!! IcaProtocol = 5 !!! ---------------------------------------------


%   Vector of time delays ([Delay #1 Delay #2 ... Delay #N] or [] for default)

tau             = [];


% ----------------------------------------------------------------------------------------------------------------


% 1) Blink Template Correlation
% 2) VEOG Polarity Inversion
% 3) Blink Template Correlation + VEOG Polarity Inversion

blinkProtocol   = [];


% --------------------------------------- !!! BlinkProtocol = 1 OR 3 !!! -----------------------------------------


% 1) Specify a single blink template tolerance
% 2) Specify a range of blink template tolerances
                        
fltrProtocol    = [];


% ----------------------------------------- !!! FltrProtocol = 1 !!! ---------------------------------------------


% Minimum correlation for matching the blink template: 0 <= fltrTol <= 1

fltrTol         = [];


% ----------------------------------------- !!! FltrProtocol = 2 !!! ---------------------------------------------


% Minimum correlation for matching the blink template: 0 <= fltrTolMin < fltrTolMax <= 1

fltrTolMin      = [];

% Maximum correlation for matching the blink template: 0 <= fltrTolMin < fltrTolMax <= 1

fltrTolMax      = [];

% Tolerance step size

fltrTolInc      = [];


% ----------------------------------------------------------------------------------------------------------------
