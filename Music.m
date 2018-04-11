function varargout = Music(varargin)
% MUSIC MATLAB code for Music.fig
%      MUSIC, by itself, creates a new MUSIC or raises the existing
%      singleton*.
%
%      H = MUSIC returns the handle to a new MUSIC or the handle to
%      the existing singleton*.
%
%      MUSIC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUSIC.M with the given input arguments.
%
%      MUSIC('Property','Value',...) creates a new MUSIC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Music_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Music_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Music

% Last Modified by GUIDE v2.5 20-Aug-2015 16:09:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Music_OpeningFcn, ...
                   'gui_OutputFcn',  @Music_OutputFcn, ...
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


% --- Executes just before Music is made visible.
function Music_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Music (see VARARGIN)

% Choose default command line output for Music
handles.output = hObject;

% Set connection details
handles.comPort = 'COM10';
%handles.comPort = '/dev/tty.usbmodemfa131';

% Define display elements
handles.left    = [0 2 2 3 2 2 0; 1 1 0 1.5 3 2 2];
handles.up      = [1 2 2 3 1.5 0 1; 0 0 2 2 3 2 2];
handles.right   = [0 1 1 3 3 1 1; 1.5 0 1 1 2 2 3];
handles.down    = [1.5 3 2 2 1 1 0; 0 1 1 3 3 1 1];
handles.triPts  = [0 2 1 ; 0 0 1.5];
handles.box1    = [0 8 8 0; 24 24 26 26];
handles.box2    = [0 8 8 0; 19 19 21 21];
handles.box3    = [0 8 8 0; 14 14 16 16];
handles.box4    = [0 8 8 0; 9 9 11 11];

% Set the sampling rate
handles.fS = 44100;


% Initialize loop list from premade loopList.mat
handles.loops = {'AcousticBass','AcousticGuitar','Bass',...
    'AcousticGuitarB', 'DanceDrums',...
    'Drums','FunkClav','Horns'};

% Setup the dropdown menus of the tracks
set(handles.style1,'String',handles.loops)
set(handles.style2,'String',handles.loops)
set(handles.style3,'String',handles.loops)
set(handles.style4,'String',handles.loops)

% Define triggering thresholds
handles.xThresh = 1.75;
handles.yThresh = .9;
handles.zThresh = 1.75;

% Initialize variables
handles.bufferSize = 200;
handles.threshNum = 0;
handles.gx = zeros(1,handles.bufferSize);
handles.gy = zeros(1,handles.bufferSize);
handles.gz = zeros(1,handles.bufferSize);

% Initialize Track representation
handles.track1 = zeros(1,8);
handles.track2 = zeros(1,8);
handles.track3 = zeros(1,8);
handles.track4 = zeros(1,8);

%----------------Setup Acceleration Display--------------------------------

% Setup axes
axes(handles.accVisual)
view(3); axis equal; 
axis([-3 3 -3 3 -3 3]);

% Setup the timer function to constantly update the display
handles.accTimer = timer('ExecutionMode','fixedRate','Period',.01,...
    'TimerFcn', {@accUpdate, hObject});

%-----------------Setup initial workSpace display-------------------------
axes(handles.workSpace)
hold on
axis([0 64 0 30]) % Set axis range

% Show track lines
handles.t1Line = line([0 64],[25 25],'Linewidth',1);
handles.t2Line = line([0 64],[20 20],'Linewidth',1);
handles.t3Line = line([0 64],[15 15],'Linewidth',1);
handles.t4Line = line([0 64],[10 10],'Linewidth',1);

% Show measure boxes for each track
for ww = 1:4
    for ii = 0:7
        handles.(['mB' num2str(ii) 'T' num2str(ww)]) = ...
            fill(handles.(['box' num2str(ww)])(1,:)+8*ii, ...
                 handles.(['box' num2str(ww)])(2,:),'b');
             set(handles.(['mB' num2str(ii) 'T' num2str(ww)]),...
                 'FaceAlpha',.5)
    end
end

% Show the time track cursor
handles.tracker = fill(handles.triPts(1,:), handles.triPts(2,:), 'k');

hold off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Music wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% Timer function to read the accelerometer and perform threshold detection
function [] = accUpdate(~,~,fHandle)

% Surpress error messages to stop clutter when closing the main GUI
try

% Get a copy of the main GUI handles
handles = guidata(fHandle);

% Read accelerometer
[gx, gy, gz] = readAcc(handles.accelerometer,handles.calCo);

% Update the buffer
handles.gx = [handles.gx(2:end) gx];
handles.gy = [handles.gy(2:end) gy];
handles.gz = [handles.gz(2:end) gz];

% Perform Threshold Detection
% Set the triggered flag variables to off
[handles.xPT, handles.xNT, handles.yPT, handles.yNT, handles.zPT,...
    handles.zNT] = deal(0);

% X
if     gx < -handles.xThresh
    handles.xNT = 1;
elseif gx > handles.xThresh
    handles.xPT = 1;
    
% Y
elseif gy < -handles.yThresh
    handles.yNT = 1;
elseif gy > handles.yThresh
    handles.yPT = 1;

% Z
elseif gz < -handles.zThresh
    handles.zNT = 1;
elseif gz > handles.zThresh
    handles.zPT = 1;
end

% Update acceleration display
set(handles.xVec, 'XData', [0 gx]);
set(handles.yVec, 'YData', [0 gy]);
set(handles.zVec, 'ZData', [0 gz]);
drawnow

% Due to weird interactions in call order(???), this is needed to ensure 
% that critical fields are not overwritten
h1 = guidata(fHandle);
handles.track1 = h1.track1;
handles.track2 = h1.track2;
handles.track3 = h1.track3;
handles.track4 = h1.track4;

% Update main GUI handles
guidata(fHandle,handles)

catch
end

% --------------------------------------------------------------------
function Init_Con_Callback(hObject, eventdata, handles)
% hObject    handle to Init_Con (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.accelerometer.s,~] = setupSerial(handles.comPort); % call function to
% setup serial conn.

% Calibrate Sensor
handles.calCo=calibrate(handles.accelerometer.s); 

% Setup initial acceeration display
[gx, gy, gz]=readAcc(handles.accelerometer,handles.calCo);

% Draw lines corresponding to the readings of the accelerometer (gx,gy,gz)
axes(handles.accVisual)
handles.xVec = line([0 gx], [0 0], [0 0], 'Color','r', 'Linewidth', 2);
handles.yVec = line([0 0], [0 gy], [0 0], 'Color','g','Linewidth', 2);
handles.zVec = line([0 0], [0 0], [0 gz], 'Color','b','Linewidth', 2);
drawnow

pause(.2)
% Update GUI handles before starting the timer
guidata(hObject,handles)

% Start the timer to update the acceleration display
start(handles.accTimer)



% --- Outputs from this function are returned to the command line.
function varargout = Music_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in mute4.
function mute4_Callback(hObject, eventdata, handles)
% hObject    handle to mute4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear4.
function clear4_Callback(hObject, eventdata, handles)
% hObject    handle to clear4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in record4.
function record4_Callback(hObject, eventdata, handles)
% hObject    handle to record4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recordFunc(hObject, eventdata, handles, 4)

% --- Executes on selection change in style4.
function style4_Callback(hObject, eventdata, handles)
% hObject    handle to style4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns style4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from style4


% --- Executes during object creation, after setting all properties.
function style4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to style4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mute3.
function mute3_Callback(hObject, eventdata, handles)
% hObject    handle to mute3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear3.
function clear3_Callback(hObject, eventdata, handles)
% hObject    handle to clear3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in record3.
function record3_Callback(hObject, eventdata, handles)
% hObject    handle to record3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recordFunc(hObject, eventdata, handles, 3)

% --- Executes on selection change in style3.
function style3_Callback(hObject, eventdata, handles)
% hObject    handle to style3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns style3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from style3


% --- Executes during object creation, after setting all properties.

function style3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to style3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mute2.
function mute2_Callback(hObject, eventdata, handles)
% hObject    handle to mute2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear2.
function clear2_Callback(hObject, eventdata, handles)
% hObject    handle to clear2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in record2.
function record2_Callback(hObject, eventdata, handles)
% hObject    handle to record2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recordFunc(hObject, eventdata, handles, 2)

% --- Executes on selection change in style2.
function style2_Callback(hObject, eventdata, handles)
% hObject    handle to style2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns style2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from style2


% --- Executes during object creation, after setting all properties.
function style2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to style2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mute1.
function mute1_Callback(hObject, eventdata, handles)
% hObject    handle to mute1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test = 'wow';

% --- Executes on button press in clear1.
function clear1_Callback(hObject, eventdata, handles)
% hObject    handle to clear1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Plays the track selected
function playTrack(curTrack, fHandle)

% Get a fresh copy of handles
handles = guidata(fHandle);

% Process the track
processTrack(trackNum, hObject);
% Get a fresh copy of handles
handles = guidata(fHandle);
sound(handles.(['track' num2str(curTrack) 'S']), ...
    handles.fS)

guidata(fHandle,handles)

% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Play all loops
handles = guidata(hObject);
playAll(hObject)

% The recording function for all of the record buttons
function recordFunc(hObject,eventdata, handles, trackNum)

% Set initial cursor position
curPos = 1;
updateDisp(trackNum, curPos, hObject);

% loop until exited
while 1
    % Force the monitoring function to run, as the timer won't trigger in
    % the while loop when recording
    accUpdate('','',hObject)
    
    % Get a fresh copy of the handles
    handles = guidata(hObject);
    
    % Detect a selection
    % X
    if handles.xPT
        % Store the selected value at the selected measure
        handles.(['track' num2str(trackNum)])(curPos) = 1;
        
        % Play the selected loop for the current instrument
        playLoop(trackNum,1, hObject);
        
        % Increment the currently selected position
        curPos = curPos + 1;
    elseif handles.xNT
        % Store the selected value at the selected measure
        handles.(['track' num2str(trackNum)])(curPos) = 2;
        
        % Play the selected loop for the current instrument
        playLoop(trackNum,2, hObject);
        
        % Increment the currently selected position
        curPos = curPos + 1;
   
     % Y
    elseif handles.yPT
        % Store the selected value at the selected measure
        handles.(['track' num2str(trackNum)])(curPos) = 3;
        
        % Play the selected loop for the current instrument
        playLoop(trackNum, 3, hObject);
        
        % Increment the currently selected position
        curPos = curPos + 1;
    elseif handles.yNT
        % Store the selected value at the selected measure
        handles.(['track' num2str(trackNum)])(curPos) = 4;
        
        % Play the selected loop for the current instrument
        playLoop(trackNum, 4, hObject);
        
        % Increment the currently selected position
        curPos = curPos + 1;
    
     % Z
    elseif handles.zPT
        % Change selection +1
        curPos = curPos+1;
        % Make sure multiple commands aren't fired off at once accidentally
        pause(.5)
    elseif handles.zNT
        % Make sure to not go out of bounds of the measure selection
        if curPos ~= 1
            % Change position -1
            curPos = curPos-1;
        end
        % Make sure multiple commands aren't fired off at once accidentally
        pause(.5)
    end
    
    % If the selection is out of bounds to the right of the measure
    % selction, end the recording automatically
    if curPos > 8
        % Process the track of selections into a sound file
        % Get a fresh copy of handles after saving
         guidata(hObject,handles)
         processTrack(trackNum, hObject);
         handles = guidata(hObject);
         guidata(hObject,handles)
        break
    elseif handles.xPT || handles.xNT || handles.yPT || handles.yNT ...
            || handles.zPT || handles.zNT
        
        % Update the display
        updateDisp(trackNum, curPos, hObject);
        guidata(hObject,handles)
    end
    
    % Update the handles
    guidata(hObject,handles)
end
% Set the selection to off
updateDisp(0, curPos, hObject);

% --- Executes on button press in record1.
function record1_Callback(hObject, eventdata, handles)
% hObject    handle to record1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Trigger the record function with the current trackNum
recordFunc(hObject, eventdata, handles, 1)


% Process the selected loops in track trackNum into a sound file
function processTrack(trackNum, fHandle)

% Get a fresh copy of handles
handles = guidata(fHandle);

% Get the name of the current instrument
curInst = handles.loops{get(...
    handles.(['style', num2str(trackNum)]),'Value')};

% Read the first loop and initialize the .track[trackNum] field
if handles.(['track' num2str(trackNum)])(1) == 0;
   handles.(['track' num2str(trackNum) 'S']) = zeros(179712,2);
else
handles.(['track' num2str(trackNum) 'S']) = ...
    audioread(['./Loops/' curInst num2str(handles.(['track' ...
       num2str(trackNum)])(1)) '.mp3']);
end

% For each measure, load in the loop and append the data to the track sound
% file to create the entire finished track
for ii = 2:8
    if handles.(['track' num2str(trackNum)])(ii) == 0;
        handles.(['track' num2str(trackNum) 'S']) = [...
            handles.(['track' num2str(trackNum) 'S']); zeros(179712,2)];
    else
        % Load the loop for the loop "ii"
    [curAudio,~] = audioread(['./Loops/' curInst num2str(handles. ...
        (['track' num2str(trackNum)])(ii)) '.mp3']);
    length(curAudio)
    
    % Append the new loop to the track
    handles.(['track' num2str(trackNum) 'S']) = [ ...
        handles.(['track' num2str(trackNum) 'S']); curAudio];
    end
end

% Update the handles
guidata(fHandle, handles)

% Process all tracks into a single audio stream
function playAll(fHandle)

% Process all the tracks
for ii = 1:4
    processTrack(ii, fHandle)
end

% Get a fresh copy of handles
handles = guidata(fHandle);

% Combine all of the tracks
handles.trackF = handles.track1S + handles.track2S + handles.track3S;

% Scale the track to have a max of 1 for using sound()
% handles.trackF = 2*handles.fS/(max(handles.fS)-min(handles.fS));
% handles.trackF = handles.trackF-min(handles.trackF)-1;

% Play the combined track
sound(handles.trackF,handles.fS)

% Update the handles
guidata(fHandle, handles)



% Plays the specified loop for the instrument in the specified track
function [] = playLoop(trackNum, loopNum, fHandle)

% Get a copy of handles
handles = guidata(fHandle);

% Get the name of the current instrument
curInst = handles.loops{get(...
    handles.(['style', num2str(trackNum)]),'Value')};

% Load and play the specified loop for the current instrument
[loop,~] = audioread(['./Loops/' curInst num2str(loopNum) '.mp3']);
sound(loop,handles.fS)

% Wait a moment so that multiple sound commands arent entered at once
% accidentally
pause(4)


% Updates the display of the current measure on the specified track
function [] = updateDisp(trackNum, curPos, fHandle)
% A trackNum of 0 means "no selection" and clears the selection display
 
% get a copy of handles
handles = guidata(fHandle);

% Update all of the measure boxes to be blue (unselected)
for ww = 1:4
    for ii = 0:7
        set(handles.(['mB' num2str(ii) 'T' num2str(ww)]), 'FaceColor'...
            ,'b')
        
        if ww == trackNum
            set(handles.(['mB' num2str(ii) 'T' num2str(ww)]), 'EdgeColor'...
            ,'r')
        else
            set(handles.(['mB' num2str(ii) 'T' num2str(ww)]), 'EdgeColor'...
            ,'k')
        end
    end
end

% Set the currently selected measure box to be red (selected) unless
% deselction is indicated with a trackNum of 0
if trackNum ~= 0
set(handles.(['mB' num2str(curPos-1) 'T' num2str(trackNum)]), 'FaceColor'...
            ,'r')
end
        

% --- Executes on selection change in style1.
function style1_Callback(hObject, eventdata, handles)
% hObject    handle to style1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns style1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from style1


% --- Executes during object creation, after setting all properties.
function style1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to style1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop the timer
 try
     stop(handles.accTimer)
 catch
 end
     
% Close the connection
closeSerial

% Surpress errors due to the tiemr when closing
try
% Hint: delete(hObject) closes the figure
delete(hObject);
catch
end
