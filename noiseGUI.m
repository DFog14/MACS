function varargout = noiseGUI(varargin)
% NOISEGUI MATLAB code for noiseGUI.fig
%      NOISEGUI, by itself, creates a new NOISEGUI or raises the existing
%      singleton*.
%
%      H = NOISEGUI returns the handle to a new NOISEGUI or the handle to
%      the existing singleton*.
%
%      NOISEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOISEGUI.M with the given input arguments.
%
%      NOISEGUI('Property','Value',...) creates a new NOISEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before noiseGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to noiseGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help noiseGUI

% Last Modified by GUIDE v2.5 13-Aug-2015 16:00:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @noiseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @noiseGUI_OutputFcn, ...
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


% --- Executes just before noiseGUI is made visible.
function noiseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to noiseGUI (see VARARGIN)

% Choose default command line output for noiseGUI
handles.output = hObject;

% Store the handles form the main GUI
if ~isempty(varargin)
    handles.parentGUI = varargin{1};
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes noiseGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = noiseGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togAnalysis.
function togAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to togAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togAnalysis

while get(hObject,'Value') == 1
% Get the latest version of the parent GUI's handles
handles.parentGUI = guidata(handles.parentGUI.figure1);

% Focus on the proper axees
axes(handles.histAxes)

% Plot the histogram of the data in the buffer
cla % clear past data
hist(handles.parentGUI.gx)

% Label the axes
xlabel('Gx Value')
ylabel('Amount of Values')

% Calculate statistics
dataAvg = mean(handles.parentGUI.gx);
dataSTDev = std(handles.parentGUI.gx);

% Find the values outside of 2 standard deviations
outliers = [handles.parentGUI.gx(handles.parentGUI.gx>...
    (dataAvg+2*dataSTDev)), handles.parentGUI.gx(handles.parentGUI.gx...
    <(dataAvg-2*dataSTDev))];
% find the count and standard deviation of the noise
outlierCount = length(outliers);
outlierMean  = mean(outliers);


% Update the display of the statistics
set(handles.outlierCount,'String',num2str(outlierCount))
set(handles.dataMeanDisp,'String',num2str(dataAvg))
set(handles.dataSTDDisp,'String',num2str(dataSTDev))
set(handles.dataVarianceDisp,'String',num2str(dataSTDev^2))
set(handles.noiseMeanDisp,'String',num2str(outlierMean))
    
end


% Update the handles
guidata(hObject, handles)
