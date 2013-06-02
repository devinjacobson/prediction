function varargout = IcaGuiEegLab(varargin);

% ICAGUIEEGLAB M-file for IcaGuiEegLab.fig
%
%      ICAGUIEEGLAB, by itself, creates a new ICAGUIEEGLAB or raises the existing
%      singleton.
%
%      H = ICAGUIEEGLAB returns the handle to a new ICAGUIEEGLAB or the handle to
%      the existing singleton*.
%
%      ICAGUIEEGLAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ICAGUIEEGLAB.M with the given input arguments.
%
%      ICAGUIEEGLAB('Property','Value',...) creates a new ICAGUIEEGLAB or raises
%      the existing singleton.  Starting from the left, property value pairs are
%      applied to the GUI before IcaGuiEegLab_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IcaGuiEegLab_OpeningFcn via varargin.



% Begin initialization code - DO NOT EDIT --------------------------------------



gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IcaGuiEegLab_OpeningFcn, ...
                   'gui_OutputFcn',  @IcaGuiEegLab_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    
    gui_State.gui_Callback = str2func(varargin{1});
    
end

if nargout
    
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    
else
    
    gui_mainfcn(gui_State, varargin{:});
    
end



% End initialization code - DO NOT EDIT ----------------------------------------



% --- Executes just before IcaGuiEegLab is made visible.

function IcaGuiEegLab_OpeningFcn(hObject, eventdata, handles, varargin);

% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IcaGuiEegLab (see VARARGIN)

global sigClean;

InitializeSigCleanVar;

switch lower(varargin{8})
    
    case 'hfastica'
        
        sigClean.icaProtocol = 1    ;
        
    case 'hinfomax'
        
        sigClean.icaProtocol = 2    ;
        
end

sigClean.scfPath = varargin{1}      ;
sigClean.scfName = varargin{2}      ;
sigClean.formExt = varargin{3}      ;
sigClean.wgtExt  = varargin{4}      ;
sigClean.sphExt  = varargin{5}      ;
sigClean.mixExt  = varargin{6}      ;
sigClean.umxExt  = varargin{7}      ;
sigClean.numChan = varargin{9}      ;
sigClean.numSmpl = varargin{10}     ;

[tmpVar tmpVar tmpVar] = computer   ;
sigClean.outFormat     = tmpVar     ;
clear tmpVar                        ;

switch varargin{11}
    
    case 'GUI'

        RefreshSigCleanGUI(handles, eventdata)      ;

        uiwait                                      ;
        
    case 'DEFAULT'
	
        NicICAForm(sigClean.scfPath, [sigClean.scfName sigClean.formExt], sigClean) ;
        
        return                                                                      ;
        
end



% --- Outputs from this function are returned to the command line.

function varargout = IcaGuiEegLab_OutputFcn(hObject, eventdata, handles);

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

varargout{1} = sigClean;

delete(handles.IcaGuiEegLab);



function PathEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to PathEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Inactive: Set by EEGLAB



% --- Executes during object creation, after setting all properties.

function PathEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to PathEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function ChanEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to ChanEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Inactive: Set by EEGLAB



% --- Executes during object creation, after setting all properties.

function ChanEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to ChanEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function SmplEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to SmplEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Inactive: Set by EEGLAB



% --- Executes during object creation, after setting all properties.

function SmplEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to SmplEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on selection change in ProcessPopUp.

function ProcessPopUp_Callback(hObject, eventdata, handles);

% hObject    handle to ProcessPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.icaProtocol = get(hObject, 'Value');

switch sigClean.icaProtocol
    
    case 1  % Fast ICA
        
        enable_val = 'On';
        color_val = [0.0 0.0 0.0];
        FastIcaPanel(handles, enable_val, color_val);
        
        enable_val = 'Inactive';
        color_val = [0.4 0.4 0.4];
        InfomaxPanel(handles, enable_val, color_val);
        
    case 2  % Infomax
        
        enable_val = 'On';
        color_val = [0.0 0.0 0.0];
        InfomaxPanel(handles, enable_val, color_val);
        
        enable_val = 'Inactive';
        color_val = [0.4 0.4 0.4];
        FastIcaPanel(handles, enable_val, color_val);
        
end

        

% --- Executes during object creation, after setting all properties.

function ProcessPopUp_CreateFcn(hObject, eventdata, handles);

% hObject    handle to ProcessPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function NumProcEditBox_Callback(hObject, eventdata, handles)

% hObject    handle to NumProcEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.numProc = str2num(get(hObject, 'String'));

if isempty(sigClean.numProc) || imag(sigClean.numProc) || (sigClean.numProc <= 0) || mod(sigClean.numProc, 1)
    
    errordlg('--- Invalid Input: Number Of Processors Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function NumProcEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to NumProcEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on button press in DoNotWhitenButton.

function DoNotWhitenButton_Callback(hObject, eventdata, handles);

% hObject    handle to DoNotWhitenButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.doNotWhiten = get(hObject, 'Value');

if sigClean.doNotWhiten
    
    sigClean.storeWhtData  = 0;
    sigClean.sphMtrxOutput = 0;
    
    set( [ handles.StoreDataChkBox,     ...
           handles.SphMtrxChkBox ],     ...
           ...
           'Value', 0,                  ...
           'Enable', 'Inactive',        ...
           'ForegroundColor', [0.4 0.4 0.4] );
       
    if isequal(sigClean.sphFileName, 0)
       
        sigClean.wgtMtrxOutput   = 1;
        sigClean.mixMtrxOutput   = 0;
        sigClean.unMixMtrxOutput = 0;
        sigClean.iCMtrxOutput    = 0;
               
        set( [ handles.WgtMtrxChkBox,       ...
               handles.MixMtrxChkBox,       ...
               handles.UnMixMtrxChkBox,     ...
               handles.ICMtrxChkBox ],      ...
               ...
               { 'Value' }, { 1 ; 0 ; 0 ; 0 } );
           
        set( handles.SphMtrxPopUp,              ...
             ...
             'Value', 2,                        ...
             'String', { '--- Select Sphering Matrix ---' , '--- Sphering Matrix: N/A ---' } );
         
    else
        
        set( handles.SphMtrxPopUp,              ...
             ...
             'Value', 2,                        ...
             'String', { '--- Select Sphering Matrix ---' , [ 'Sphering Matrix: ' sigClean.sphFileName ] } );
         
    end

else
    
    if isequal(sigClean.sphFileName, 0)
    
        set( [ handles.StoreDataChkBox,     ...
               handles.SphMtrxChkBox ],     ...
               ...
               'Enable', 'On',              ...
               'ForegroundColor', [0.0 0.0 0.0] );
       
        set( handles.SphMtrxPopUp,              ...
             ...
             'Value', 1,                        ...
             'String', { '--- Compute Sphering Matrix ---' , '--- Select Sphering Matrix ---' } );

    else
        
        sigClean.sphMtrxOutput = 0;

        set( [ handles.StoreDataChkBox,     ...
               handles.SphMtrxChkBox ],     ...
               ...
               { 'Value' , 'Enable' , 'ForegroundColor' },    ...
               { sigClean.storeWhtData , 'On' , [0.0 0.0 0.0] ; 0 , 'Inactive' , [0.4 0.4 0.4] } );
           
        set( handles.SphMtrxPopUp,              ...
             ...
             'Value', 2,                        ...
             'String', { '--- Compute Sphering Matrix ---' , [ 'Sphering Matrix: ' sigClean.sphFileName ] } );
         
    end
    
end



% --- Executes on selection change in SphMtrxPopUp.

function SphMtrxPopUp_Callback(hObject, eventdata, handles);

% hObject    handle to SphMtrxPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

switch get(hObject, 'Value')
    
    case 1
        
        if sigClean.doNotWhiten
                
            [sigClean.sphFileName, sigClean.sphFilePath] = uigetfile('*.sph', 'Select Sphering Matrix');
            
            figure(handles.IcaGuiEegLab);
                
            if isequal(sigClean.sphFileName, 0)
                
                sigClean.wgtMtrxOutput   = 1;
                sigClean.mixMtrxOutput   = 0;
                sigClean.unMixMtrxOutput = 0;
                sigClean.iCMtrxOutput    = 0;
                
                sigClean.sphereMatrix = 'none';

                set( [ handles.WgtMtrxChkBox,       ...
                       handles.MixMtrxChkBox,       ...
                       handles.UnMixMtrxChkBox,     ...
                       handles.ICMtrxChkBox ],      ...
                       ...
                       { 'Value' }, { 1 ; 0 ; 0 ; 0 } );
        
                set( hObject,     ...
                     ...
                     'Value', 2,  ...
                     'String', { '--- Select Sphering Matrix ---' , '--- Sphering Matrix: N/A ---' } );
                    
            else
                    
                sigClean.sphereMatrix = 'file';

                set( hObject,     ...
                     ...
                     'Value', 2,  ...
                     'String', { '--- Select Sphering Matrix ---' , [ 'Sphering Matrix: ' sigClean.sphFileName ] } );
                    
            end
            
        else
            
            sigClean.sphFileName = 0;
            sigClean.sphFilePath = 0;
            sigClean.sphereMatrix = 'none';
    
            set( [ handles.StoreDataChkBox,     ...
                   handles.SphMtrxChkBox ],     ...
                   ...
                   'Enable', 'On',              ...
                   'ForegroundColor', [0.0 0.0 0.0] );
       
            set( hObject,     ...
                 ...
                 'Value', 1,  ...
                 'String', { '--- Compute Sphering Matrix ---' , '--- Select Sphering Matrix ---' } );

        end
            
    case 2
        
        if ~sigClean.doNotWhiten
                
            [sigClean.sphFileName, sigClean.sphFilePath] = uigetfile('*.sph', 'Select Sphering Matrix');
            
            figure(handles.IcaGuiEegLab);

            if isequal(sigClean.sphFileName, 0)
                    
                sigClean.sphereMatrix = 'none';
                
                set( [ handles.StoreDataChkBox,     ...
                       handles.SphMtrxChkBox ],     ...
                       ...
                       'Enable', 'On',              ...
                       'ForegroundColor', [0.0 0.0 0.0] );
       
                set( hObject,     ...
                     ...
                     'Value', 1,  ...
                     'String', { '--- Compute Sphering Matrix ---' , '--- Select Sphering Matrix ---' } );
                    
            else
                    
                sigClean.sphMtrxOutput = 0;
                sigClean.sphereMatrix = 'file';

                set( [ handles.StoreDataChkBox,     ...
                       handles.SphMtrxChkBox ],     ...
                       ...
                       { 'Value' , 'Enable' , 'ForegroundColor' },    ...
                       { sigClean.storeWhtData , 'On' , [0.0 0.0 0.0] ; 0 , 'Inactive' , [0.4 0.4 0.4] } );
                
                set( hObject,     ...
                     ...
                     'Value', 2,  ...
                     'String', { '--- Compute Sphering Matrix ---' , [ 'Sphering Matrix: ' sigClean.sphFileName ] } );
                    
            end
            
        end
    
end

if ~isequal(sigClean.sphFileName, 0)
    
    FileTransfer(sigClean.sphFilePath, sigClean.scfPath, sigClean.sphFileName);
         
end



% --- Executes during object creation, after setting all properties.

function SphMtrxPopUp_CreateFcn(hObject, eventdata, handles);

% hObject    handle to SphMtrxPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on button press in ValWhitenChkBox.

function ValWhitenChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to ValWhitenChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.valWhiten = get(hObject, 'Value');



% --- Executes on button press in StoreDataChkBox.

function StoreDataChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to StoreDataChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.storeWhtData = get(hObject, 'Value');



% --- Executes on button press in WgtMtrxChkBox.

function WgtMtrxChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to WgtMtrxChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.wgtMtrxOutput = get(hObject, 'Value');

if ~sigClean.wgtMtrxOutput
    
    if ~(sigClean.mixMtrxOutput || sigClean.unMixMtrxOutput)
        
        sigClean.wgtMtrxOutput = 1;
        
        set( handles.WgtMtrxChkBox,  ...
             ...
             'Value', 1 );
        
        if ~sigClean.doNotWhiten
            
            if isequal(sigClean.sphFileName, 0)
            
                sigClean.sphMtrxOutput = 1;
            
                set( handles.SphMtrxChkBox,  ...
                     ...
                     'Value', 1 );
                 
            end
             
        end
        
    end
    
end



% --- Executes on button press in SphMtrxChkBox.

function SphMtrxChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to SphMtrxChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.sphMtrxOutput = get(hObject, 'Value');

if ~sigClean.sphMtrxOutput
    
    if ~(sigClean.mixMtrxOutput || sigClean.unMixMtrxOutput)
        
        sigClean.wgtMtrxOutput = 1;
        sigClean.sphMtrxOutput = 1;
        
        set( handles.WgtMtrxChkBox,  ...
             ...
             'Value', 1 );
        
        set( handles.SphMtrxChkBox,  ...
             ...
             'Value', 1 );
             
    end
    
end



% --- Executes on button press in MixMtrxChkBox.

function MixMtrxChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to MixMtrxChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.mixMtrxOutput = get(hObject, 'Value');

if sigClean.mixMtrxOutput
    
    if sigClean.doNotWhiten
        
        if isequal(sigClean.sphFileName, 0)
            
            set( handles.SphMtrxPopUp,  ...
                 ...
                 'Value', 1 );
             
            SphMtrxPopUp_Callback(handles.SphMtrxPopUp, eventdata, handles);
            
        end
        
    end
    
else
    
    if ~sigClean.unMixMtrxOutput
            
        sigClean.wgtMtrxOutput = 1;
        
        set( handles.WgtMtrxChkBox,  ...
             ...
             'Value', 1 );
        
        if ~sigClean.doNotWhiten
            
            if isequal(sigClean.sphFileName, 0)
            
                sigClean.sphMtrxOutput = 1;
            
                set( handles.SphMtrxChkBox,  ...
                     ...
                     'Value', 1 );
                 
            end
            
        end
        
    end
    
end



% --- Executes on button press in UnMixMtrxChkBox.

function UnMixMtrxChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to UnMixMtrxChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.unMixMtrxOutput = get(hObject, 'Value');

if sigClean.unMixMtrxOutput
    
    if sigClean.doNotWhiten
        
        if isequal(sigClean.sphFileName, 0)
            
            set( handles.SphMtrxPopUp,  ...
                 ...
                 'Value', 1 );
             
            SphMtrxPopUp_Callback(handles.SphMtrxPopUp, eventdata, handles);
            
        end
        
    end
    
else
    
    if ~sigClean.mixMtrxOutput
            
        sigClean.wgtMtrxOutput = 1;
        
        set( handles.WgtMtrxChkBox,  ...
             ...
             'Value', 1 );
        
        if ~sigClean.doNotWhiten
            
            if isequal(sigClean.sphFileName, 0)
            
                sigClean.sphMtrxOutput = 1;
            
                set( handles.SphMtrxChkBox,  ...
                     ...
                     'Value', 1 );
                 
            end
            
        end
        
    end
    
end



% --- Executes on button press in ICMtrxChkBox.

function ICMtrxChkBox_Callback(hObject, eventdata, handles);

% hObject    handle to ICMtrxChkBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.iCMtrxOutput = get(hObject, 'Value');

if sigClean.doNotWhiten
        
    if isequal(sigClean.sphFileName, 0)
            
        set( handles.SphMtrxPopUp,  ...
             ...
             'Value', 1 );
         
        SphMtrxPopUp_Callback(handles.SphMtrxPopUp, eventdata, handles);
            
    end
        
end



% --- Executes on selection change in WgtMtrxPopUp.

function WgtMtrxPopUp_Callback(hObject, eventdata, handles);

% hObject    handle to WgtMtrxPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.wgtMtrx = get(hObject, 'Value');

if (sigClean.wgtMtrx == 3)
    
    if ~sigClean.load
    
        [sigClean.wgtFileName, sigClean.wgtFilePath] = uigetfile('*.wgt', 'Select Weight Matrix Seed');
    
        figure(handles.IcaGuiEegLab);
        
    end
        
    if isequal(sigClean.wgtFileName, 0)
            
        sigClean.wgtMtrx = 1;
            
        set( hObject,       ...
                            ...
             'Value', 1 );
             
    end
        
end
    
if isequal(sigClean.wgtFileName, 0)
        
    set( hObject,        ...
                         ...
         'String', { 'Identity Matrix Seed' , 'Random Matrix Seed' , 'User Defined Matrix Seed' } );
        
else
        
    set( hObject,        ...
                         ...
         'String', { 'Identity Matrix Seed' , 'Random Matrix Seed' , [ 'Weight Matrix Seed: ' sigClean.wgtFileName ] } );
     
    FileTransfer(sigClean.wgtFilePath, sigClean.scfPath, sigClean.wgtFileName);
    
end



% --- Executes during object creation, after setting all properties.

function WgtMtrxPopUp_CreateFcn(hObject, eventdata, handles);

% hObject    handle to WgtMtrxPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on selection change in ContrastPopUp.

function ContrastPopUp_Callback(hObject, eventdata, handles);

% hObject    handle to ContrastPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.contrast_f = get(hObject, 'Value');



% --- Executes during object creation, after setting all properties.

function ContrastPopUp_CreateFcn(hObject, eventdata, handles);

% hObject    handle to ContrastPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function TolEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to TolEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.tol_f = str2num(get(hObject, 'String'));

if isempty(sigClean.tol_f) || imag(sigClean.tol_f) || (sigClean.tol_f <= 0)
    
    errordlg('--- Invalid Input: Convergence Tolerance Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function TolEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to TolEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function MaxIterEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to MaxIterEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.maxIter = str2num(get(hObject, 'String'));

if isempty(sigClean.maxIter) || imag(sigClean.maxIter) || (sigClean.maxIter <= 0)
    
    errordlg('--- Invalid Input: Maximum Iterations Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function MaxIterEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to MaxIterEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on selection change in WgtMtrx2PopUp.

function WgtMtrx2PopUp_Callback(hObject, eventdata, handles);

% hObject    handle to WgtMtrx2PopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.wgtMtrx2 = get(hObject, 'Value');

if (sigClean.wgtMtrx2 == 3)
    
    if ~sigClean.load
    
        [sigClean.wgtFile2Name, sigClean.wgtFile2Path] = uigetfile('*.wgt', 'Select Weight Matrix Seed');
    
        figure(handles.IcaGuiEegLab);
        
    end
        
    if isequal(sigClean.wgtFile2Name, 0)
            
        sigClean.wgtMtrx2 = 1;
            
        set( hObject,       ...
                            ...
             'Value', 1 );
             
    end
        
end
    
if isequal(sigClean.wgtFile2Name, 0)
        
    set( hObject,        ...
                         ...
         'String', { 'Identity Matrix Seed' , 'Random Matrix Seed' , 'User Defined Matrix Seed' } );
        
else
        
    set( hObject,        ...
                         ...
         'String', { 'Identity Matrix Seed' , 'Random Matrix Seed' , [ 'Weight Matrix Seed: ' sigClean.wgtFile2Name ] } );
     
    FileTransfer(sigClean.wgtFile2Path, sigClean.scfPath, sigClean.wgtFile2Name);
    
end



% --- Executes during object creation, after setting all properties.

function WgtMtrx2PopUp_CreateFcn(hObject, eventdata, handles);

% hObject    handle to WgtMtrx2PopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function Tol2EditBox_Callback(hObject, eventdata, handles);

% hObject    handle to Tol2EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.tol_i = str2num(get(hObject, 'String'));

if isempty(sigClean.tol_i) || imag(sigClean.tol_i) || (sigClean.tol_i <= 0)
    
    errordlg('--- Invalid Input: Convergence Tolerance Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



function Tol2EditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to Tol2EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function MaxIter2EditBox_Callback(hObject, eventdata, handles);

% hObject    handle to MaxIter2EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.maxIter = str2num(get(hObject, 'String'));

if isempty(sigClean.maxIter) || imag(sigClean.maxIter) || (sigClean.maxIter <= 0)
    
    errordlg('--- Invalid Input: Maximum Iterations Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function MaxIter2EditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to MaxIter2EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function LrnRateEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to LrnRateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.lrnRate_i = str2num(get(hObject, 'String'));

if isempty(sigClean.lrnRate_i) || imag(sigClean.lrnRate_i) || (sigClean.lrnRate_i <= 0)
    
    errordlg('--- Invalid Input: Learning Rate Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function LrnRateEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to LrnRateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function AnnealDegreeEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to AnnealDegreeEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.annealDegree_i = str2num(get(hObject, 'String'));

if isempty(sigClean.annealDegree_i) || imag(sigClean.annealDegree_i) || (sigClean.annealDegree_i <= 0)
    
    errordlg('--- Invalid Input: Annealing Degree Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function AnnealDegreeEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to AnnealDegreeEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function AnnealScaleEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to AnnealScaleEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.annealScale_i = str2num(get(hObject, 'String'));

if isempty(sigClean.annealScale_i) || imag(sigClean.annealScale_i) || (sigClean.annealScale_i <= 0)
    
    errordlg('--- Invalid Input: Annealing Scale Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function AnnealScaleEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to AnnealScaleEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function MaxWgtEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to MaxWgtEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.maxWgt_i = str2num(get(hObject, 'String'));

if isempty(sigClean.maxWgt_i) || imag(sigClean.maxWgt_i) || (sigClean.maxWgt_i <= 0)
    
    errordlg('--- Invalid Input: Maximum Weight Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function MaxWgtEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to MaxWgtEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function MaxDivEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to MaxDivEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.maxDiv_i = str2num(get(hObject, 'String'));

if isempty(sigClean.maxDiv_i) || imag(sigClean.maxDiv_i) || (sigClean.maxDiv_i <= 0)
    
    errordlg('--- Invalid Input: Maximum Divergence Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function MaxDivEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to MaxDivEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function WgtRestartEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to WgtRestartEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.wgtRestart_i = str2num(get(hObject, 'String'));

if isempty(sigClean.wgtRestart_i) || imag(sigClean.wgtRestart_i) || (sigClean.wgtRestart_i <= 0)
    
    errordlg('--- Invalid Input: Weight Restart Factor Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function WgtRestartEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to WgtRestartEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function DivRestartEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to DivRestartEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.divRestart_i = str2num(get(hObject, 'String'));

if isempty(sigClean.divRestart_i) || imag(sigClean.divRestart_i) || (sigClean.divRestart_i <= 0)
    
    errordlg('--- Invalid Input: Divergence Restart Factor Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function DivRestartEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to DivRestartEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function MinLrnEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to MinLrnEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.minLrn_i = str2num(get(hObject, 'String'));

if isempty(sigClean.minLrn_i) || imag(sigClean.minLrn_i) || (sigClean.minLrn_i <= 0)
    
    errordlg('--- Invalid Input: Minimum Learning Rate Field ---', 'User Input Error');
    set(hObject, 'String', '');
    
end



% --- Executes during object creation, after setting all properties.

function MinLrnEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to MinLrnEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



function RndmLrnEditBox_Callback(hObject, eventdata, handles);

% hObject    handle to RndmLrnEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean.rndmLrn_i = get(hObject, 'String');

if ~any(strcmpi(sigClean.rndmLrn_i, {'Y', 'y', 'N', 'n'}))
    
    errordlg('--- Invalid Input: Random Learning Field ---', 'User Input Error');
    set(hObject, 'String', '');

end



% --- Executes during object creation, after setting all properties.

function RndmLrnEditBox_CreateFcn(hObject, eventdata, handles);

% hObject    handle to RndmLrnEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end



% --- Executes on button press in SaveButton.

function SaveButton_Callback(hObject, eventdata, handles);

% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

errorFlag = 0;

if sigClean.doNotWhiten

    if isequal(sigClean.sphFileName, 0)
        
        set( handles.SphMtrxPopUp,  ...
             ...
             'Value', 1 );
         
        SphMtrxPopUp_Callback(handles.SphMtrxPopUp, eventdata, handles);
        
        if isequal(sigClean.sphFileName, 0)
            
            errorFlag = 1;
            
            InitializeSigCleanVar;

            RefreshSigCleanGUI(handles, eventdata);
            
        end
        
    end
    
end
    
if ~(sigClean.mixMtrxOutput || sigClean.unMixMtrxOutput)
    
    if ~sigClean.wgtMtrxOutput
        
        errorFlag = 1;
		
        sigClean.wgtMtrxOutput = 1;

        set( handles.WgtMtrxChkBox,    ...
             ...
             'Value', 1 );
    
	end

	if ~sigClean.doNotWhiten
            
		if isequal(sigClean.sphFileName, 0)
		
			if ~sigClean.sphMtrxOutput
			
				errorFlag = 1;
            
				sigClean.sphMtrxOutput = 1;
            
                set( handles.SphMtrxChkBox,  ...
                     ...
                     'Value', 1 );
					 
			end
                 
		end
            
	end
        
end

if errorFlag
	
    errordlg('--- Invalid State: Setting Default Outputs ---', 'HiPerSAT State Error');
	
    return;
	
end

sigClean = NicICAForm(sigClean.scfPath, [sigClean.scfName sigClean.formExt], sigClean);

uiresume;



% --- Executes on button press in LoadButton.

function LoadButton_Callback(hObject, eventdata, handles);

% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

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
              
[formName formPath] = uigetfile(sigClean.formExt, 'Select HiPerSAT Form');

figure(handles.IcaGuiEegLab);

if isequal(formName, 0)
    
    return;
    
else
    
    [path name ext] = fileparts(formName);
    
    if strcmp(ext, sigClean.formExt)
        
        fid = fopen(fullfile(formPath, formName));
        
    else
        
        if isempty(ext)
            
            formName = [formName sigClean.formExt];
            
            fid = fopen(fullfile(formPath, formName));
        
        else
            
            errordlg( sprintf( '--- Error (Input): Select A Valid HiPerSAT Form (%s) ---', sigClean.formExt ), 'Input Error' );
        
            return
            
        end
        
    end
    
end

if (fid == -1)
    
    errordlg( sprintf( 'Error (File Open): %s' , fullfile(formPath, formName) ) , 'File Open Failure' );
    
    return;
            
else

    set(hObject, 'String', 'Loading ...'); pause(0.1);
    
    formData = textscan(fid, '%s', 'delimiter', '\n');
        
    fclose(fid);
            
end

for i = 1 : length(formData{1})
    
    if ~isempty(formData{1}{i})
        
        if isempty(regexp(formData{1}{i}, '^(?:\s*/{2})'))
                
            propertyName   =  char(regexprep(deblank(regexpi(formData{1}{i}, '(?:\w+\s*)+(?=:)', 'match')), '\s+', '_'));
                
            propertyValue  =  char(regexprep(deblank(regexpi(formData{1}{i}, '(?<=:\s*)(?:\S+\s*)+', 'match')), '\s+', ' '));
            
            if any(strcmp(propertyName, fieldnames(formMap)))
            
                feval(formMap(2).(propertyName), formMap(1).(propertyName), propertyValue);
                
            end
                
        end
            
    end
    
end

sigClean.load = 1;

RefreshSigCleanGUI(handles, eventdata);

set(hObject, 'String', ['Load (' sigClean.formExt ')']);

sigClean.load = 0;



% --- Executes on button press in ResetButton.

function ResetButton_Callback(hObject, eventdata, handles);

% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InitializeSigCleanVar;

RefreshSigCleanGUI(handles, eventdata);



% --- Executes on button press in CloseButton.

function CloseButton_Callback(hObject, eventdata, handles);

% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sigClean;

sigClean = [];

uiresume;



function InitializeSigCleanVar;

global sigClean;

sigClean.scfFormat          =    2              ;

sigClean.numProc            =    1              ;
sigClean.doNotWhiten        =    0              ;

sigClean.sphFileName        =    0              ;
sigClean.sphFilePath        =    0              ;
sigClean.sphereMatrix       =    'none'         ;

sigClean.valWhiten          =    0              ;
sigClean.storeWhtData       =    0              ;

sigClean.wgtMtrxOutput      =    1              ;
sigClean.sphMtrxOutput      =    1              ;
sigClean.mixMtrxOutput      =    0              ;
sigClean.unMixMtrxOutput    =    0              ;
sigClean.iCMtrxOutput       =    0              ;

sigClean.load               =    0              ;

sigClean.wgtFileName        =    0              ;
sigClean.wgtFilePath        =    0              ;
sigClean.wgtMtrx            =    1              ;

sigClean.wgtFile2Name       =    0              ;
sigClean.wgtFile2Path       =    0              ;
sigClean.wgtMtrx2           =    1              ;

sigClean.tol_f              =    0.0001         ;
sigClean.tol_i              =    0.000001       ;

sigClean.maxIter            =    1024           ;

sigClean.contrast_f         =    2              ;

sigClean.lrnRate_i          =    0.001          ;
sigClean.annealDegree_i     =    60             ;
sigClean.annealScale_i      =    0.9            ;
sigClean.maxWgt_i           =    100000000      ;
sigClean.maxDiv_i           =    100000000      ;
sigClean.wgtRestart_i       =    0.9            ;
sigClean.divRestart_i       =    0.8            ;
sigClean.minLrn_i           =    0.00000001     ;
sigClean.rndmLrn_i          =    'Y'            ;



function FastIcaPanel(handles, enable_val, color_val);
           
set( [ handles.WgtMtrxPopUp,            ...
       handles.ContrastPopUp,           ...
       handles.TolEditBox,              ...
       handles.MaxIterEditBox ],        ...
       ...
       'Enable', enable_val,            ...
       'Foregroundcolor', color_val );
   
set( [ handles.TolStaticTxt,            ...
       handles.MaxIterStaticTxt ],      ...
       ...
       'Foregroundcolor', color_val );



function InfomaxPanel(handles, enable_val, color_val);

set( [ handles.WgtMtrx2PopUp,           ...
       handles.Tol2EditBox,             ...
       handles.MaxIter2EditBox,         ...
       handles.LrnRateEditBox,          ...
       handles.AnnealDegreeEditBox,     ...
       handles.AnnealScaleEditBox,      ...
       handles.MaxWgtEditBox,           ...
       handles.MaxDivEditBox,           ...
       handles.WgtRestartEditBox,       ...
       handles.DivRestartEditBox,       ...
       handles.MinLrnEditBox,           ...
       handles.RndmLrnEditBox ],        ...
       ...
       'Enable', enable_val,            ...
       'Foregroundcolor', color_val );
   
set( [ handles.Tol2StaticTxt,           ...
       handles.MaxIter2StaticTxt,       ...
       handles.LrnRateStaticTxt,        ...
       handles.AnnealDegreeStaticTxt,   ...
       handles.AnnealScaleStaticTxt,    ...
       handles.MaxWgtStaticTxt,         ...
       handles.MaxDivStaticTxt,         ...
       handles.WgtRestartStaticTxt,     ...
       handles.DivRestartStaticTxt,     ...
       handles.MinLrnStaticTxt,         ...
       handles.RndmLrnStaticTxt ],      ...
       ...
       'Foregroundcolor', color_val );



function RefreshSigCleanGUI(handles, eventdata);

global sigClean;

set(handles.ProcessPopUp,         'Value',    sigClean.icaProtocol              );

ProcessPopUp_Callback(handles.ProcessPopUp, eventdata, handles                  );

set(handles.NumProcEditBox,       'String',   int2str(sigClean.numProc)         );

set(handles.DoNotWhitenButton,    'Value',    sigClean.doNotWhiten              );

DoNotWhitenButton_Callback(handles.DoNotWhitenButton, eventdata, handles        );

set(handles.ValWhitenChkBox,      'Value',    sigClean.valWhiten                );
set(handles.StoreDataChkBox,      'Value',    sigClean.storeWhtData             );

set(handles.WgtMtrxChkBox,        'Value',    sigClean.wgtMtrxOutput            );
set(handles.SphMtrxChkBox,        'Value',    sigClean.sphMtrxOutput            );
set(handles.MixMtrxChkBox,        'Value',    sigClean.mixMtrxOutput            );
set(handles.UnMixMtrxChkBox,      'Value',    sigClean.unMixMtrxOutput          );
set(handles.ICMtrxChkBox,         'Value',    sigClean.iCMtrxOutput             );

set(handles.WgtMtrxPopUp,         'Value',    sigClean.wgtMtrx                  );

WgtMtrxPopUp_Callback(handles.WgtMtrxPopUp, eventdata, handles                  );

set(handles.WgtMtrx2PopUp,        'Value',    sigClean.wgtMtrx2                 );

WgtMtrx2PopUp_Callback(handles.WgtMtrx2PopUp, eventdata, handles                );

set(handles.TolEditBox,           'String',   num2str(sigClean.tol_f)           );
set(handles.Tol2EditBox,          'String',   num2str(sigClean.tol_i)           );
set(handles.MaxIterEditBox,       'String',   int2str(sigClean.maxIter)         );
set(handles.MaxIter2EditBox,      'String',   int2str(sigClean.maxIter)         );

set(handles.ContrastPopUp,        'Value',    sigClean.contrast_f               );

set(handles.LrnRateEditBox,       'String',   num2str(sigClean.lrnRate_i)       );
set(handles.AnnealDegreeEditBox,  'String',   num2str(sigClean.annealDegree_i)  );
set(handles.AnnealScaleEditBox,   'String',   num2str(sigClean.annealScale_i)   );
set(handles.MaxWgtEditBox,        'String',   int2str(sigClean.maxWgt_i)        );
set(handles.MaxDivEditBox,        'String',   int2str(sigClean.maxDiv_i)        );
set(handles.WgtRestartEditBox,    'String',   num2str(sigClean.wgtRestart_i)    );
set(handles.DivRestartEditBox,    'String',   num2str(sigClean.divRestart_i)    );
set(handles.MinLrnEditBox,        'String',   num2str(sigClean.minLrn_i)        );
set(handles.RndmLrnEditBox,       'String',   sigClean.rndmLrn_i                );

set( handles.IcaGuiEegLab,           ...
                                     ...
     'Name',   '<<<< HiPerSAT: ICA Form Editor >>>>' );
    
set( [ handles.ChanEditBox,                                         ...
       handles.SmplEditBox,                                         ...
       handles.PathEditBox ],                                       ...
                                                                    ...
       { 'Enable' , 'ForegroundColor' 'String' },                   ...
       { 'Inactive' , [0.4 0.4 0.4] , int2str(sigClean.numChan) ;   ...
         'Inactive' , [0.4 0.4 0.4] , int2str(sigClean.numSmpl) ;   ...
         'Inactive' , [0.4 0.4 0.4] , '<<<< Running HiPerSAT Via EEGLAB >>>>' } );



function FileTransfer(inFilePath, outFilePath, fileName)

global sigClean;

fid = fopen(fullfile(inFilePath, fileName), 'r');
    
tmpVar = fread(fid, [sigClean.numChan, sigClean.numChan], 'real*8');
    
fclose(fid);
    
fid = fopen(fullfile(outFilePath, fileName), 'w');
    
fwrite(fid, tmpVar, 'real*8');
    
fclose(fid);
    
clear tmpVar;



function IcaProtocol(propName, propValue)

global sigClean;

switch propValue
    
    case 'FastICA'
        
        sigClean.icaProtocol = 1;
        
    case 'Infomax'
        
        sigClean.icaProtocol = 2;
        
end



function DoNotWhiten(propName, propValue)

global sigClean;

switch propValue
    
    case '0'
        
        sigClean.doNotWhiten = 1;
        
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
        
        
        
function SphFileName(propName, propValue)

global sigClean;

switch propValue
    
    case '""'
        
        sigClean.sphFilePath = 0;
        
        sigClean.sphFileName = 0;
        
    otherwise
        
        [path name ext] = fileparts(propValue);
        
        sigClean.sphFilePath = path;
        
        sigClean.sphFileName = [name ext];
        
        FileTransfer(sigClean.sphFilePath, sigClean.scfPath, sigClean.sphFileName);

end



function WgtMatrix(propName, propValue)

global sigClean;

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



function WgtFileName(propName, propValue)

global sigClean;

switch sigClean.icaProtocol
    
    case 1

        switch propValue
    
            case '""'
        
                sigClean.wgtFilePath = 0;
        
                sigClean.wgtFileName = 0;
        
            otherwise
        
                [path name ext]  = fileparts(propValue);
        
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
        
                [path name ext]  = fileparts(propValue);
        
                sigClean.wgtFile2Path = path;
        
                sigClean.wgtFile2Name = [name ext];
        
                FileTransfer(sigClean.wgtFile2Path, sigClean.scfPath, sigClean.wgtFile2Name);

        end
        
end



function Tolerance(propName, propValue)

global sigClean;

switch sigClean.icaProtocol
    
    case 1
        
        sigClean.tol_f = str2num(propValue);
        
    case 2
        
        sigClean.tol_i = str2num(propValue);
        
end
        
        
    
function Contrast_f(propName, propValue)

global sigClean;

switch propValue
    
    case 'cubic'
        
        sigClean.contrast_f = 1;
        
    case 'tanh'
        
        sigClean.contrast_f = 2;
        
end



function PassToDouble(propName, propValue)

global sigClean;

sigClean.(propName) = str2num(propValue);



function PassToString(propName, propValue)

global sigClean;

sigClean.(propName) = propValue;



function FileOutput(propName, propValue)

global sigClean;

switch propValue
    
    case {'a', 'b', 'l', 'p'}
        
        sigClean.(propName) = 1;
        
    case 'n'
        
        sigClean.(propName) = 0;
        
end



function IcsFileName(propName, propValue)

global sigClean;

switch propValue
    
    case {'""'}
        
        sigClean.iCMtrxOutput = 0;
        
    otherwise
        
        sigClean.iCMtrxOutput = 1;
        
end
