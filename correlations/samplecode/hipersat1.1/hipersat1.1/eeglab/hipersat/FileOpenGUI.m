function varargout = FileOpenGUI(varargin);

% FILEOPENGUI M-file for FileOpenGUI.fig
%      FILEOPENGUI, by itself, creates a new FILEOPENGUI or raises the existing
%      singleton.
%
%      H = FILEOPENGUI returns the handle to a new FILEOPENGUI or the handle to
%      the existing singleton.
%
%      FILEOPENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEOPENGUI.M with the given input arguments.
%
%      FILEOPENGUI('Property','Value',...) creates a new FILEOPENGUI or raises
%      the existing singleton.  Starting from the left, property value pairs are
%      applied to the GUI before FileOpenGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileOpenGUI_OpeningFcn via varargin.

% Last Modified by GUIDE v2.5 04-May-2005 12:11:16



% Begin initialization code - DO NOT EDIT --------------------------------------

gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileOpenGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FileOpenGUI_OutputFcn, ...
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



% --- Executes just before FileOpenGUI is made visible.

function FileOpenGUI_OpeningFcn(hObject, eventdata, handles, varargin);

% hObject    handle to figure
% eventdata  reserved - defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileOpenGUI (see VARARGIN)

ListBox_Load(handles, pwd);

uiwait(hObject);



% --- Outputs from this function are returned to the command line.

function varargout = FileOpenGUI_OutputFcn(hObject, eventdata, handles);

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global metaData;

varargout{1} = handles.filePath;
varargout{2} = handles.fileName;
varargout{3} = metaData.numCh;
varargout{4} = metaData.numSamples;
        
delete(handles.FileOpenGUI);



% --- Executes on selection change in ListBox1.

function ListBox1_Callback(hObject, eventdata, handles);

% hObject    handle to ListBox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(handles.FileOpenGUI, 'SelectionType'), 'Open')
    
    userIX = get(hObject, 'Value');

    if handles.isDir(handles.dirIX(userIX))
        
        CancelButton_Callback(hObject, eventdata, handles);

        cd(handles.files{userIX});
        
        ListBox_Load(handles, pwd);
        
    else
        
        try
            
            [path file ext ver] = fileparts(which(handles.files{userIX}));
            
        catch
            
            return;
            
        end
        
        switch ext
            
            case '.raw'
                
                global metaData;
                
                handles.filePath = path;
                handles.fileStem = file;
                handles.fileName = [file ext];
                        
                [handles.fileID, handles.precision] = ReadRawHeader(handles.fileName);
                
                guidata(handles.FileOpenGUI, handles);
                
                set(handles.OkayButton,     'String',   'Import'                                        );
                set(handles.FileName,       'String',   sprintf('%s', handles.fileName)                 );
                set(handles.NumCh,          'String',   sprintf('%d', metaData.numCh)                   );
                set(handles.NumSample,      'String',   sprintf('%d', metaData.numSamples)              );
                set(handles.Freq,           'String',   sprintf('%d', metaData.samplingRate)            );
                set(handles.RecTimeYr,      'String',   sprintf('%d', metaData.recordingTimeYear)       );
                set(handles.RecTimeMo,      'String',   sprintf('%d', metaData.recordingTimeMonth)      );
                set(handles.RecTimeDay,     'String',   sprintf('%d', metaData.recordingTimeDay)        );
                set(handles.RecTimeHr,      'String',   sprintf('%d', metaData.recordingTimeHour)       );
                set(handles.RecTimeMin,     'String',   sprintf('%d', metaData.recordingTimeMinute)     );
                set(handles.RecTimeSec,     'String',   sprintf('%d', metaData.recordingTimeSecond)     );
                set(handles.RecTimeMsec,    'String',   sprintf('%d', metaData.recordingTimeMillisec)   );
                set(handles.NumEvents,      'String',   sprintf('%d', metaData.numEvents)               );
                set(handles.NumEpoc,        'String',   sprintf('%s', '--- Requires Data Import ---')   );
                
            otherwise
                
                CancelButton_Callback(hObject, eventdata, handles);
                
                errordlg('--- EGI (Raw) File Format Only ---', 'File Type Error');

        end
        
    end
    
end



% --- Executes during object creation, after setting all properties.

function ListBox1_CreateFcn(hObject, eventdata, handles);

% !!! Windows PC Only !!!

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end


function ListBox_Load(handles, currDir)

cd(currDir);

files                           =   dir;
handles.isDir                   =   [files.isdir];
[handles.files, handles.dirIX]  =   sortrows({files.name}');

guidata(handles.FileOpenGUI, handles);

set( handles.Text1,         ...
     ...
     'String', currDir );

set( handles.ListBox1,		...
     ...
     'Value', 1,            ...
     'String', handles.files );



% --- Executes on button press in OkayButton.

function OkayButton_Callback(hObject, eventdata, handles);

% hObject    handle to OkayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global metaData x;
    
switch get(handles.OkayButton, 'String')
        
    case 'Import'
    
        set( handles.OkayButton,    ...
             ...
             'String', 'Importing ...' ); pause(0.001);
    
        ReadRawData(handles.fileID, handles.precision);
    
        set( [ handles.OkayButton,  ...
               handles.NumEpoc ],   ...
               ...
               { 'String' }, { 'Save (.scf)' ; sprintf('%d', metaData.numEpoc) } );
        
    case 'Save (.scf)'

        [handles.fileName, handles.filePath] = uiputfile('*.scf', 'Select Signal Cleaner (.scf) Data File', [handles.fileStem '.scf']);
        
        figure(handles.FileOpenGUI);
        
        if isequal(handles.fileName, 0)
            
            handles.filePath = '>>> Path To .scf Data File';
            
            guidata(handles.FileOpenGUI, handles);
            
            uiresume;

            return;
            
        else
            
            [path name ext ver] = fileparts(handles.fileName);
            
            if strcmp(ext, '.scf')
                
                guidata(handles.FileOpenGUI, handles);
                
                uiresume;

            else
                
                if isempty(ext)
                    
                    handles.fileName = [handles.fileName '.scf'];
                    
                    guidata(handles.FileOpenGUI, handles);
            
                    uiresume;
                
                else
                
                    errordlg('--- Invalid Input: Please Save To A Valid Signal Cleaner (.scf) File ---', 'User Input Error');
                    
                    return;
                
                end
                
            end
            
        end

        set( handles.OkayButton, ...
             ...
             'String', 'Saving ...' ); pause(1.0);

        dataFile  =  fullfile(handles.filePath, handles.fileName);

        fid = fopen(dataFile, 'w', 'b');
            
        if (fid == -1)
    
            errordlg( sprintf( 'Error (File Open): %s' , dataFile ) , 'File Open Failure' );
    
        else
    
            fwrite(fid, x, 'real*8');
            fclose(fid);
    
        end

end



% --- Executes on button press in CancelButton.

function CancelButton_Callback(hObject, eventdata, handles);

% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fileID = 0;

guidata(handles.FileOpenGUI, handles);

set(handles.FileName,       'String',   ''      );
set(handles.NumCh,          'String',   ''      );
set(handles.NumSample,      'String',   ''      );
set(handles.Freq,           'String',   ''      );
set(handles.RecTimeYr,      'String',   ''      );
set(handles.RecTimeMo,      'String',   ''      );
set(handles.RecTimeDay,     'String',   ''      );
set(handles.RecTimeHr,      'String',   ''      );
set(handles.RecTimeMin,     'String',   ''      );
set(handles.RecTimeSec,     'String',   ''      );
set(handles.RecTimeMsec,    'String',   ''      );
set(handles.NumEvents,      'String',   ''      );
set(handles.NumEpoc,        'String',   ''      );
set(handles.OkayButton,     'String',   'Ready' );



% --- Executes on button press in CloseButton.

function CloseButton_Callback(hObject, eventdata, handles)

% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global metaData;

handles.filePath    =  0;
handles.fileName    =  0;
metaData.numCh      =  0;
metaData.numSamples =  0;

guidata(hObject, handles);

uiresume;


