function varargout = BlinkSplitGUI(varargin);
% BLINKSPLITGUI M-file for BlinkSplitGUI.fig
%      BLINKSPLITGUI, by itself, creates a new BLINKSPLITGUI or raises the existing
%      singleton*.
%
%      H = BLINKSPLITGUI returns the handle to a new BLINKSPLITGUI or the handle to
%      the existing singleton*.
%
%      BLINKSPLITGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BLINKSPLITGUI.M with the given input arguments.
%
%      BLINKSPLITGUI('Property','Value',...) creates a new BLINKSPLITGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BlinkSplitGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BlinkSplitGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BlinkSplitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BlinkSplitGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before BlinkSplitGUI is made visible.
function BlinkSplitGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BlinkSplitGUI (see VARARGIN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preOffset = 500;      %%% User %%%
pstOffset = 1000;  %%% Selectable %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.s = varargin{3};
handles.numCh = varargin{4};
handles.numSmpl = varargin{5};
handles.eyeCode = varargin{6};
handles.sampFreq = varargin{7};
handles.eventData = varargin{8};

if isempty(handles.eyeCode)
    
    return;
    
end

% Update handles structure
guidata(hObject, handles);

set(handles.EditPreEventOffset, 'string', int2str(preOffset));
set(handles.EditPostEventOffset, 'string', int2str(pstOffset));

preOffset = round(handles.sampFreq * preOffset / 1000);
pstOffset = round(handles.sampFreq * pstOffset / 1000);

[segLen, icERP, IX] = berp(preOffset, pstOffset, handles);
plotBerp(preOffset, pstOffset, segLen, icERP, IX, handles);


% --------------------


% --- Outputs from this function are returned to the command line.
function varargout = BlinkSplitGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------


function EditPreEventOffset_Callback(hObject, eventdata, handles)
% hObject    handle to EditPreEventOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPreEventOffset as text
%        str2double(get(hObject,'String')) returns contents of EditPreEventOffset as a double


% --------------------


% --- Executes during object creation, after setting all properties.
function EditPreEventOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPreEventOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------


function EditPostEventOffset_Callback(hObject, eventdata, handles)
% hObject    handle to EditPostEventOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPostEventOffset as text
%        str2double(get(hObject,'String')) returns contents of EditPostEventOffset as a double


% --------------------


% --- Executes during object creation, after setting all properties.
function EditPostEventOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPostEventOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------


% --- Executes on button press in SearchButton.
function SearchButton_Callback(hObject, eventdata, handles)
% hObject    handle to SearchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

preOffset = str2double(get(handles.EditPreEventOffset, 'string'));
pstOffset = str2double(get(handles.EditPostEventOffset, 'string'));

if isnan(preOffset)
    errordlg('Enter an integer Pre-Event Offset time in millisec!', 'Bad Input');
    return;
else
    preOffset = round(abs(preOffset));
end

if isnan(pstOffset)
    errordlg('Enter an integer Post-Event Offset time in millisec!', 'Bad Input');
    return;
else
    pstOffset = round(abs(pstOffset));
end

preOffset = round(handles.sampFreq * preOffset / 1000);
pstOffset = round(handles.sampFreq * pstOffset / 1000);

[segLen, icERP, IX] = berp(preOffset, pstOffset, handles);
plotBerp(preOffset, pstOffset, segLen, icERP, IX, handles);


% --------------------


function [segLen, icERP, IX] = berp(preOffset, pstOffset, handles)


blnkIx = find(handles.eventData(handles.eyeCode,:));

numBlnk = length(blnkIx);


for i = 1 : numBlnk
    
    seg{i} = [blnkIx(i) - preOffset : blnkIx(i) + pstOffset];

end

segLen = 1 + preOffset + pstOffset;

seg(find(any(reshape([seg{:}],segLen,numBlnk) < 1) | any(reshape([seg{:}],segLen,numBlnk) > handles.numSmpl))) = [];

numSeg = length(seg);


icERP = zeros(segLen, handles.numCh);

for i = 1 : handles.numCh
    
    icERP(:,i) = sum(reshape(handles.s(i,[seg{:}]),segLen,numSeg), 2) ./ numSeg;
    
end


icCorr = corrcoef(icERP);

[icCorrSort, IX] = sort(abs(icCorr(:,1)), 'descend');


set(handles.NumSeg, 'String', sprintf('BERPs: %d Segment Avg', numSeg));

set(handles.ResultSplit1, 'String', sprintf('IC-%03d Pri-BERP r: %5.4f', IX(2), icCorrSort(2)));

set(handles.ResultSplit2, 'String', sprintf('IC-%03d Pri-BERP r: %5.4f', IX(3), icCorrSort(3)));


% --------------------


function plotBerp(preOffset, pstOffset, segLen, icERP, IX, handles)


meanErp = mean(icERP(:,IX(1)));
    
if ( icERP(preOffset + 1, IX(1)) - meanErp ) < 0
        
    axes(handles.BlinkERP); plot(-1 * (icERP(:,IX(1)) - meanErp));
        
else
        
    axes(handles.BlinkERP); plot(+1 * (icERP(:,IX(1)) - meanErp));
        
end
    
yLim = get(gca, 'ylim');
yTick = get(gca, 'YTick');
yTickLabel = get(gca, 'YTickLabel');

set(gca,'xlim', [1 segLen], ...
        'XTick', [1, preOffset + 1, segLen], ...
        'Xlabel', text('String', 'Sample Offset'), ...
        'XTickLabel', [-1 * preOffset, 0, +1 * pstOffset], ...
        'Title', text('String', sprintf('------- IC-%03d: Primary Blink Component ERP -------', IX(1))));


meanErp = mean(icERP(:,IX(2)));
    
if ( icERP(preOffset + 1, IX(2)) - meanErp ) < 0
        
    axes(handles.SplitERP1); plot(-1 * (icERP(:,IX(2)) - meanErp));
        
else
        
    axes(handles.SplitERP1); plot(+1 * (icERP(:,IX(2)) - meanErp));
        
end
    
set(gca,'ylim', yLim, ...
        'YTick', yTick, ...
        'YTickLabel', yTickLabel);

set(gca,'xlim', [1 segLen], ...
        'XTick', [1, preOffset + 1, segLen], ...
        'Xlabel', text('String', 'Sample Offset'), ...
        'XTickLabel', [-1 * preOffset, 0, +1 * pstOffset], ...
        'Title', text('String', sprintf('------- IC-%03d: Secondary Blink Component ERP -------', IX(2))));


meanErp = mean(icERP(:,IX(3)));
    
if ( icERP(preOffset + 1, IX(3)) - meanErp ) < 0
        
    axes(handles.SplitERP2); plot(-1 * (icERP(:,IX(3)) - meanErp));
        
else
        
    axes(handles.SplitERP2); plot(+1 * (icERP(:,IX(3)) - meanErp));
        
end
    
set(gca,'ylim', yLim, ...
        'YTick', yTick, ...
        'YTickLabel', yTickLabel);

set(gca,'xlim', [1 segLen], ...
        'XTick', [1, preOffset + 1, segLen], ...
        'Xlabel', text('String', 'Sample Offset'), ...
        'XTickLabel', [-1 * preOffset, 0, +1 * pstOffset], ...
        'Title', text('String', sprintf('------- IC-%03d: Tertiary Blink Component ERP -------', IX(3))));
