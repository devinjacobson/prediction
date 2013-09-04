function varargout = ChannelHistogramsGUI(varargin);

% CHANNELHISTOGRAMSGUI M-file for ChannelHistogramsGUI.fig

% Begin initialization code - DO NOT EDIT --------------------------------------

gui_Singleton = 0;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChannelHistogramsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ChannelHistogramsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    
    gui_State.gui_Callback = str2func(varargin{1});
    
end

gui_mainfcn(gui_State, varargin{:});

% End initialization code - DO NOT EDIT ----------------------------------------


% --- Executes just before ChannelHistogramsGUI is made visible. ---------------

function ChannelHistogramsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChannelHistogramsGUI (see VARARGIN)

s = varargin{4};
eeg = varargin{3};
numCh = varargin{6};
numSample = varargin{7};
handles.chIX = varargin{5};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numBins = 500;    %%% User Selectable %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.Fig = 1;
handles.dataType = 2;

chMin = ceil(min(min(s))) * 0.75;
chMax = floor(max(max(s))) * 0.75;

handles.xLim   = [chMin, chMax];
handles.remFig = mod(numCh, 8);
handles.numFig = floor(numCh ./ 8);

handles.x = linspace(chMin, chMax, numBins);
areaHist  = numSample * (handles.x(2) - handles.x(1));

handles.IC   = hist(s', handles.x) ./ areaHist;
handles.EEG  = hist(eeg', handles.x) ./ areaHist;

handles.gauss = (1 ./ sqrt(2 .* pi)) .* exp(-0.5 .* handles.x .^ 2);

handles.ICcorr = corrcoef([handles.gauss(:) handles.IC]);
handles.ICcorr = handles.ICcorr(2:(numCh + 1), 1);

handles.EEGcorr = corrcoef([handles.gauss(:) handles.EEG]);
handles.EEGcorr = handles.EEGcorr(2:(numCh + 1), 1);

% Update handles structure
guidata(hObject, handles);

ButtonString(handles);
PlotHistograms(handles);




% --- Outputs from this function are returned to the command line.

function varargout = ChannelHistogramsGUI_OutputFcn(hObject, eventdata, handles)

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in Reverse.

function Reverse_Callback(hObject, eventdata, handles)

% hObject    handle to Reverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Fig > 1
    
    handles.Fig = handles.Fig - 1;
    guidata(hObject, handles);
    PlotHistograms(handles);
    ButtonString(handles);
    
end




% --- Executes on button press in Forward.

function Forward_Callback(hObject, eventdata, handles)

% hObject    handle to Forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Fig < handles.numFig + 1
    
    handles.Fig = handles.Fig + 1;
    guidata(hObject, handles);
    PlotHistograms(handles);
    ButtonString(handles);
    
end




function ButtonString(handles)

if handles.dataType == 1
    
    buttonMsg = 'Good Channels:';
    
else
    
    buttonMsg = 'Components:';
    
end

if handles.Fig > 1
    
    usrMsg = sprintf('<<< %s # %d - %d', buttonMsg, 1 + 8 * (handles.Fig - 2), 8 * (handles.Fig - 1));
    
else
    
    usrMsg = sprintf('<<< No Further %s', buttonMsg);
    
end

set(handles.Reverse, 'String', usrMsg);

if handles.Fig < handles.numFig
    
    usrMsg = sprintf('%s # %d - %d >>>', buttonMsg, 1 + 8 * (handles.Fig), 8 * (handles.Fig + 1));
    
else
    
    if handles.Fig == handles.numFig
        
        if handles.remFig
            
            usrMsg = sprintf('%s # %d - %d >>>', buttonMsg, 1 + 8 * (handles.Fig), handles.remFig + 8 * (handles.Fig));
            
        else
            
            usrMsg = sprintf('No Further %s >>>', buttonMsg);
            
        end
        
    else
        
        usrMsg = sprintf('No Further %s >>>', buttonMsg);
        
    end
    
end

set(handles.Forward, 'String', usrMsg);




function PlotHistograms(handles)

if handles.Fig < handles.numFig + 1
    
    for i = 1 : 8
    
        handles.h_Axes(i) = subplot(2, 4, i);
        handles.pos_Axes{i} = get(gca, 'Position');
        
        if handles.dataType == 1
        
            plot(handles.x, handles.EEG(:, i + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
            title(sprintf('Ch # %3d  |  Gaussian Correlation = %5.4f', handles.chIX(i + 8 * (handles.Fig - 1)), handles.EEGcorr(i + 8 * (handles.Fig - 1))));
            
        else
            
            plot(handles.x, handles.IC(:, i + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
            title(sprintf('IC # %3d  |  Gaussian Correlation = %5.4f', i + 8 * (handles.Fig - 1), handles.ICcorr(i + 8 * (handles.Fig - 1))));
            
        end

        xlim(handles.xLim);
    
    end
    
    handles.deleteFlag = 1;
    
    guidata(handles.FigureWindowOne, handles);

else
    
    if handles.remFig
        
        for i = 1 : handles.remFig
            
            subplot('Position', handles.pos_Axes{i});
            
            if handles.dataType == 1
        
                plot(handles.x, handles.EEG(:, i + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
                title(sprintf('Ch # %3d  |  Gaussian Correlation = %5.4f', handles.chIX(i + 8 * (handles.Fig - 1)), handles.EEGcorr(i + 8 * (handles.Fig - 1))));
            
            else
            
                plot(handles.x, handles.IC(:, i + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
                title(sprintf('IC # %3d  |  Gaussian Correlation = %5.4f', i + 8 * (handles.Fig - 1), handles.ICcorr(i + 8 * (handles.Fig - 1))));
            
            end

            xlim(handles.xLim);
            
        end

        if handles.deleteFlag

            for i = 1 + handles.remFig : 8
            
                delete(handles.h_Axes(i));
                
            end
            
            handles.deleteFlag = 0;
            
            guidata(handles.FigureWindowOne, handles);
            
        end
        
    end
    
end




function PlotSelected(hObject, evendata, handles)

curPlot = find(gco(hObject) == handles.h_Axes);

if ~isempty(curPlot)
    
    set(figure, 'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off', ...
                'Name', '~ Probability Density Function (PDF)');
            
    if handles.dataType == 1
        
        plot(handles.x, handles.EEG(:, curPlot + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
        title(sprintf('Ch # %3d  |  Gaussian Correlation = %5.4f', handles.chIX(curPlot + 8 * (handles.Fig - 1)), handles.EEGcorr(curPlot + 8 * (handles.Fig - 1))));
            
    else
            
        plot(handles.x, handles.IC(:, curPlot + 8 * (handles.Fig - 1)), 'k', handles.x, handles.gauss, 'r--', 'LineWidth', 1.0);
        title(sprintf('IC # %3d  |  Gaussian Correlation = %5.4f', curPlot + 8 * (handles.Fig - 1), handles.ICcorr(curPlot + 8 * (handles.Fig - 1))));
            
    end
    
    xlim(handles.xLim);
    
end




% --------------------------------------------------------------------
function Menu_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_EEG_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_EEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dataType = 1;

set(handles.Menu_IC, 'Checked', 'off');
set(handles.Menu_EEG, 'Checked', 'on');

guidata(handles.FigureWindowOne, handles);

ButtonString(handles);
PlotHistograms(handles);


% --------------------------------------------------------------------
function Menu_IC_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_IC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dataType = 2;

set(handles.Menu_IC, 'Checked', 'on');
set(handles.Menu_EEG, 'Checked', 'off');

guidata(handles.FigureWindowOne, handles);

ButtonString(handles);
PlotHistograms(handles);

