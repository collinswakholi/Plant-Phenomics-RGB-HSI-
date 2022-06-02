function varargout = Compute_Capture_Options(varargin)
% COMPUTE_CAPTURE_OPTIONS MATLAB code for Compute_Capture_Options.fig
%      COMPUTE_CAPTURE_OPTIONS, by itself, creates a new COMPUTE_CAPTURE_OPTIONS or raises the existing
%      singleton*.
%
%      H = COMPUTE_CAPTURE_OPTIONS returns the handle to a new COMPUTE_CAPTURE_OPTIONS or the handle to
%      the existing singleton*.
%
%      COMPUTE_CAPTURE_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPUTE_CAPTURE_OPTIONS.M with the given input arguments.
%
%      COMPUTE_CAPTURE_OPTIONS('Property','Value',...) creates a new COMPUTE_CAPTURE_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Compute_Capture_Options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Compute_Capture_Options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Compute_Capture_Options

% Last Modified by GUIDE v2.5 03-Jun-2021 15:45:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Compute_Capture_Options_OpeningFcn, ...
                   'gui_OutputFcn',  @Compute_Capture_Options_OutputFcn, ...
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


% --- Executes just before Compute_Capture_Options is made visible.
function Compute_Capture_Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Compute_Capture_Options (see VARARGIN)
global exp_hyper StageParams

start_pos = StageParams.pos;
stop_pos = StageParams.finalPos;
h_vel = StageParams.h_vel;
l_vel = StageParams.l_vel;

unit_time = StageParams.uTime;

% val_1 = stage_ratio(1)*(stop_pos-start_pos);
% val_2 = stage_ratio(2)*(stop_pos-start_pos);

% Start_pos = start_pos+val_1;
% Stop_pos = start_pos+val_2;

Start_pos = start_pos;
Stop_pos = stop_pos;


time_for_range = unit_time*(Stop_pos-Start_pos);

% compute capture speed

% compute # of steps
% steps = 640;
steps = StageParams.steps;
step_time = time_for_range/steps;

if step_time>(exp_hyper/1000000)
    step_time = ((exp_hyper-10)/1000000);
    my_time = (step_time*steps);
    h_vel = (time_for_range/my_time)*h_vel;     %*********************************

    % set h_vel
    l_vel = round(0.1*h_vel);
%     MyArcus.setParams(start_pos, l_vel, h_vel, accn);
end

utime = 1/(1.0644*h_vel - 70.23);
StageParams.uTime = utime;

handles.no_steps.String = num2str(steps);
handles.start_pos.String = num2str(Start_pos);
handles.stop_pos.String = num2str(Stop_pos);
handles.exp_Time.String = num2str(exp_hyper);
handles.cap_speed.String = num2str(h_vel);
handles.step_time.String = num2str(step_time);

StageParams.step_time = step_time;
StageParams.h_vel = h_vel;
StageParams.l_vel = l_vel;
StageParams.steps = steps;
StageParams.uTime = unit_time;
StageParams.Start = Start_pos;
StageParams.Stop = Stop_pos;


% save('StageParams.mat','StageParams');

% Choose default command line output for Compute_Capture_Options
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Compute_Capture_Options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Compute_Capture_Options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function start_pos_Callback(hObject, eventdata, handles)
% hObject    handle to start_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StageParams
Start_pos = str2double(get(hObject,'String'));

StageParams.Start = Start_pos;
% Hints: get(hObject,'String') returns contents of start_pos as text
%        str2double(get(hObject,'String')) returns contents of start_pos as a double


% --- Executes during object creation, after setting all properties.
function start_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function stop_pos_Callback(hObject, eventdata, handles)
% hObject    handle to stop_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StageParams
Stop_pos = str2double(get(hObject,'String'));
StageParams.Stop = Stop_pos;

% Hints: get(hObject,'String') returns contents of stop_pos as text
%        str2double(get(hObject,'String')) returns contents of stop_pos as a double


% --- Executes during object creation, after setting all properties.
function stop_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spa_resolution_Callback(hObject, eventdata, handles)
% hObject    handle to spa_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spa_resolution as text
%        str2double(get(hObject,'String')) returns contents of spa_resolution as a double


% --- Executes during object creation, after setting all properties.
function spa_resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spa_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exp_Time_Callback(hObject, eventdata, handles)
% hObject    handle to exp_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_Time as text
%        str2double(get(hObject,'String')) returns contents of exp_Time as a double


% --- Executes during object creation, after setting all properties.
function exp_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function no_steps_Callback(hObject, eventdata, handles)
% hObject    handle to no_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global steps StageParams
steps = str2double(get(hObject,'String'));
StageParams.steps = steps;
% Hints: get(hObject,'String') returns contents of no_steps as text
%        str2double(get(hObject,'String')) returns contents of no_steps as a double


% --- Executes during object creation, after setting all properties.
function no_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cap_speed_Callback(hObject, eventdata, handles)
% hObject    handle to cap_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h_vel l_vel StageParams
h_vel = str2double(get(hObject,'String'));
l_vel = round(0.1*h_vel);

StageParams.h_vel = h_vel;
StageParams.l_vel = l_vel;
% set_vel
MyArcus.setParams(StageParams.pos, l_vel, h_vel, StageParams.accn);
pause(.2);

% Hints: get(hObject,'String') returns contents of cap_speed as text
%        str2double(get(hObject,'String')) returns contents of cap_speed as a double


% --- Executes during object creation, after setting all properties.
function cap_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cap_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compute_btn.
function compute_btn_Callback(hObject, eventdata, handles)
% hObject    handle to compute_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global exp_hyper StageParams step_time

Start_pos = StageParams.Start;
Stop_pos = StageParams.Stop;
h_vel = StageParams.h_vel;
l_vel = StageParams.l_vel;
steps = StageParams.steps;

utime = 1/(1.0644*h_vel - 70.23);
StageParams.uTime = utime;

unit_time = StageParams.uTime;

time_for_range = unit_time*(Stop_pos-Start_pos);

% compute # of steps
step_time = time_for_range/steps;

if step_time>(exp_hyper/1000000)
    step_time = ((exp_hyper-10)/1000000);
    my_time = (step_time*steps);
    h_vel = (time_for_range/my_time)*h_vel;
    
    l_vel = round(0.1*h_vel);
    
end

unit_time = 1/(1.0644*h_vel - 70.23);
StageParams.uTime = unit_time;
    
MyArcus.setParams(Start_pos, l_vel, h_vel, StageParams.accn);
pause(.5);

StageParams.step_time = step_time;
StageParams.h_vel = h_vel;
StageParams.l_vel = l_vel;
StageParams.steps = steps;
StageParams.uTime = unit_time;
StageParams.Start = Start_pos;
StageParams.Stop = Stop_pos;

StageParams.pos = Start_pos;
StageParams.finalPos = Stop_pos

handles.no_steps.String = num2str(steps);
handles.start_pos.String = num2str(Start_pos);
handles.stop_pos.String = num2str(Stop_pos);
handles.exp_Time.String = num2str(exp_hyper);
handles.cap_speed.String = num2str(h_vel);
handles.step_time.String = num2str(step_time); 
% save('StageParams.mat','StageParams');
drawnow;

% --- Executes on button press in close_compute_cap.
function close_compute_cap_Callback(hObject, eventdata, handles)
% hObject    handle to close_compute_cap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close Compute_Capture_Options
