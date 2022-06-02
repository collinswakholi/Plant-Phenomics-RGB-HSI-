function varargout = data_collection_GUI(varargin)
% DATA_COLLECTION_GUI MATLAB code for data_collection_GUI.fig
%      DATA_COLLECTION_GUI, by itself, creates a new DATA_COLLECTION_GUI or raises the existing
%      singleton*.
%
%      H = DATA_COLLECTION_GUI returns the handle to a new DATA_COLLECTION_GUI or the handle to
%      the existing singleton*.
%
%      DATA_COLLECTION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_COLLECTION_GUI.M with the given input arguments.
%
%      DATA_COLLECTION_GUI('Property','Value',...) creates a new DATA_COLLECTION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_collection_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_collection_GUI_OpeningFcn via varargin.
%cd
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_collection_GUI

% Last Modified by GUIDE v2.5 24-Jun-2021 11:21:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_collection_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @data_collection_GUI_OutputFcn, ...
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


% --- Executes just before data_collection_GUI is made visible.
function data_collection_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_collection_GUI (see VARARGIN)
global Im_Data VID SRC exp ccm save_dir save_folder order preview_bin Img_loading corect_on
global save_fmt sav_bin cor_gamma exp_hyper vignette_corr rgb_on hsi_on dim wavelength
global FFC u_lim conv_belt conv_on stage_ratio bad_pix_mask 
global rgb_choice hsi_choice StageParams sav_opt delay_time

ms = msgbox('Loading dependencies...','Please wait!');
addpath(genpath(pwd));

imaqreset;
instrreset;

delay_time = 42; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StageParams = [];
sav_opt = 1;
StageParams.steps = 640;
stage_ratio = [0.1,0.9];
im_logo = imread('atitle.png');
imshow(im_logo, 'Parent',handles.logo_axes);
load('FFC.mat');

 % change if you need to
rgb_choice = 1;
hsi_choice = 0;

Img_loading = imread('loading_img.jpg');
wavelength = xlsread('wavelength_512.xlsx');
load('bad_pix_mask.mat')

order = [1,2];% order for RGB camera
preview_bin = 4;% for previwieng image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sav_bin = 1; % for saving image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dim = [512,640];
if sav_bin == 2
    sz = [1024,1296,3];
elseif sav_bin == 1
    sz = [2048,2592,3];
end
Im_Data = repmat({zeros(sz)},7,1);

vid = [];
src = [];

[VID.c1,VID.c2, VID.hyper] = deal(vid);
[SRC.c1,SRC.c2,SRC.hyper] = deal(src);

exp = 5000;
exp_hyper = 50000;
rgb_on = 1;
hsi_on = 0;

% ccm = load('ccm.mat');
save_dir = pwd;
date_str = datestr(datetime,29);
save_folder = date_str;
save_fmt = '.png';
corect_on = 1; 
cor_gamma = 0;
vignette_corr = 0;

handles.rgb_chamber.Value = rgb_on;
handles.hsi_chamber.Value = hsi_on;
handles.vgnt_correct.Value = vignette_corr;
handles.exp_hyper.String = num2str(exp_hyper);
handles.Correct_color.Value = 1;
handles.exp_edit.String = num2str(exp);
handles.dir_str.String = save_dir;
handles.sav_folder.String = save_folder;

info = imaqhwinfo('gentl');
device_ids = info.DeviceIDs;
if length(device_ids)<2
    errordlg(['Only ', num2str(length(device_ids)),' Cameras loaded'], 'Be Aware!!!')
    drawnow;
end

handles.uipanel1.Visible = 'On';
handles.hsi_chamber.Enable = 'Off';

% load conveyor belt
port_com = "COM7";
conv_belt = [];
try
    conv_belt = serialport(port_com,9600,'DataBits',8,'parity','none','stopbits',1,'FlowControl','software');
    configureTerminator(conv_belt,"CR") 
end
conv_on = 0;

delete(ms);

 %%
% Choose default command line output for data_collection_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% wait(job);
% UIWAIT makes data_collection_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_collection_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in capture_img.
function capture_img_Callback(hObject, eventdata, handles)
% hObject    handle to capture_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VID SRC exp ccm preview_bin Img_loading corect_on Im_Data sav_bin cor_gamma exp_hyper
global gamma fit_mtd gains cs whitePoint HSI_Data FFC u_lim bad_pix_mask conv_belt delay_time
global StageParams vignette_corr rgb_choice hsi_choice wavelength

% save('StageParams.mat','StageParams');
% collect data from RGB cameras
if rgb_choice == 1
    aa = 0;
    fg = waitbar(0,'Please wait...','Name','Collecting RGB');

    for i = 1:2
        vid = eval(['VID.c',num2str(i),';']);
        src = eval(['SRC.c',num2str(i)],';');
        try
            eval(['load("CCM_cam',num2str(i),'.mat");']); % contains 'ccm' 'fit_mtd' 'gains' 'gamma' 'cs' 'whitePoint'
            aa = 1;
        end

        % stop preview
        stoppreview(vid);

        % change binning for capturing data
        if sav_bin == 2
            src.BinningHorizontal = 'BinningHorizontal2'; % binning = 2
            src.BinningVertical = 'BinningVertical2';

        elseif sav_bin == 1
            src.BinningHorizontal = 'BinningHorizontal1'; % binning = 1
            src.BinningVertical = 'BinningVertical1';
        end
        src.ExposureTime = exp;

        % capture image
        Im = (getsnapshot(vid));

        % correct image
        if corect_on && (aa==1)
            Im = correct_image(Im, ccm, fit_mtd, gains, cs, whitePoint);
        end

        if (cor_gamma==1) && (aa==1)
            Im = imadjust(Im,[],[], gamma);
        end

        Im_Data{i} = Im;

        waitbar(i/2,fg,['Collecting ', num2str(i+1),' out of 2'],'Name','Collecting RGB')
        drawnow;
    end
    delete(fg);

    % Display images
    for i  = 1:2
        eval(['imshow(Im_Data{i}, "Parent", handles.axes_cam',num2str(i),');']);
    end
    drawnow;
    
    % move stage
    writeline(conv_belt,"WWRA0#013");
    drawnow;
    
    pause(2)% wait for 2 seconds

    for i = 1:2
        % display loading image on axes(i)
        eval(['himage = imshow(Img_loading, "Parent", handles.axes_cam',num2str(i),');']);
        drawnow;

        try
            vid = eval(['VID.c',num2str(i),';']);
            src = eval(['SRC.c',num2str(i)]);

            % change back to dispaly binning
            switch preview_bin
                case 4 
                    src.BinningHorizontal = 'BinningHorizontal4';
                    src.BinningVertical = 'BinningVertical4';
                case 2
                    src.BinningHorizontal = 'BinningHorizontal2';
                    src.BinningVertical = 'BinningVertical2';
                case 1
                    src.BinningHorizontal = 'BinningHorizontal1';
                    src.BinningVertical = 'BinningVertical1';
                otherwise
                    src.BinningHorizontal = 'BinningHorizontal4';
                    src.BinningVertical = 'BinningVertical4';
            end
            src.ExposureTime = round(exp/preview_bin);
            % preview
            preview(vid,himage);

            drawnow;
        catch
            warndlg(['Camera_',num2str(i),' ID Not found'], 'Warning!!!');
        end
    end
else
    writeline(conv_belt,"WWRA0#013");
    drawnow;
end

if (hsi_choice*rgb_choice) == 1
    pause(delay_time);
end
% collect data from HSI cameras
if hsi_choice == 1
    
    SRC.hyper.ExposureTime = exp_hyper;
    SRC.hyper.AcquisitionFrameRate = SRC.hyper.AcquisitionFrameRateLimit-1;
    warning('off','all')
    
    % set up trigger
    VID.hyper.FramesPerTrigger = round(10*StageParams.steps);
    VID.hyper.TriggerRepeat = 0;

    triggerconfig(VID.hyper, 'immediate');
    
    % start moving stage
    % move to start position
    para = MyArcus.getParams;
    pause(0.2);
    
    if abs(para.pos - StageParams.Start)>5
        kk = 1;
        MyArcus.moveToAbs(StageParams.Start);
        while kk > 0
            out = MyArcus.IsBusy;
            if out == 1
                break;
            end
        end

        kk = 1;
        while kk>0
            out = MyArcus.IsBusy;
            if out==0
                kk = 0;
            else
                kk = kk+1;
            end

        end
    end
    
%   
    kk = 1;
    km = 1;
    total_time = StageParams.steps*StageParams.step_time;
    
    fg = waitbar(0,'Please wait...','Name','Collecting HSI');
    MyArcus.moveToAbs(StageParams.Stop);
    while kk > 0
        out = MyArcus.IsBusy;
        if out == 1
            break;
        end
    end
    
    tic;
    start(VID.hyper);
    while km>0
        out = MyArcus.IsBusy;
        if out==0
            km = 0;
        else
            km = km+1;
            tt = toc;
            waitbar(tt/total_time,fg,[num2str(tt*100/total_time,'%2.2f'),'% complete...'],'Name','Collecting HSI')
        end

    end
    
    stop(VID.hyper);
    data = getdata(VID.hyper, VID.hyper.FramesAvailable);
    VID.hyper.FramesPerTrigger = 1;
    
    sz = size(data);
    data = reshape(data,sz(1),sz(2),sz(4));
    
    interval = sz(4)/StageParams.steps;
    old_idx = [1:StageParams.steps];
    new_idx = round(old_idx*interval);
    
    HSI_Data = data(:,:,new_idx);
    clearvars data
    disp('Done HSI collecting data');
    
    delete(fg);
    
    % stop stage, return home
    try
        MyArcus.Abort;
    end
    
    % change speed
    MyArcus.setParams(StageParams.Start, 2*StageParams.l_vel, 2*StageParams.h_vel, StageParams.accn)
%     MyArcus.moveToAbs(StageParams.Start);
    pause(0.5)
    MyArcus.setParams(StageParams.Start, StageParams.l_vel, StageParams.h_vel, StageParams.accn)
    pause(0.5)
    
    % correct image (remove dead pixels and vignette correction)
    if vignette_corr==1
        fg1 = waitbar(0,'Please wait...');
        for ii = 1:size(HSI_Data,3)
            
            % FFC and remove bad pixels
            frame = (double(HSI_Data(:,:,ii))/(2^14)).*bad_pix_mask;
            HSI_Data(:,:,ii) = uint16(round((2^14)*mat2gray(frame.*FFC)));
            waitbar(ii/size(HSI_Data,3),fg1,['Vignette correction for ', num2str(ii+1),'steps out of ', size(HSI_Data,3)])
        end
        delete(fg1);
    end
    
    % make correct orientaion of data (samples x lines x bands)
    HSI_Data = permute(HSI_Data,[2,3,1]);
    
    % display data
    figure(300)
    nn = [120,170,250]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% what band do you want to display?
    img = cat(3,HSI_Data(:,:,nn(1)), HSI_Data(:,:,nn(2)), HSI_Data(:,:,nn(3)));
    img = im2uint8(mat2gray(img));
    imshow(img); % display band 250
%     title([num2str(wavelength(nn)),' nm Band Image'])
%     colormap('jet');
    
%     save('HSI_Data.mat', 'HSI_Data', 'wavelength')
    writeline(conv_belt,"WWRB0#013");
    
    writeline(conv_belt,"WWRC0#013");
    pause(delay_time)
    writeline(conv_belt,"WWRC0#013");
    
    writeline(conv_belt,"WWRD0#013");
    pause(delay_time)
    writeline(conv_belt,"WWRD0#013");
    
    drawnow;
    
else
    writeline(conv_belt,"WWRB0#013");
    pause(delay_time)
    writeline(conv_belt,"WWRB0#013")
    
    writeline(conv_belt,"WWRC0#013");
    pause(delay_time)
    writeline(conv_belt,"WWRC0#013");
    
    writeline(conv_belt,"WWRD0#013");
    pause(delay_time)
    writeline(conv_belt,"WWRD0#013");
    drawnow;
end

% --- Executes on button press in get_dir.
function get_dir_Callback(hObject, eventdata, handles)
% hObject    handle to get_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global save_dir
save_dir = uigetdir(pwd);
handles.dir_str.String = save_dir;
drawnow;
% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Im_Data save_dir save_folder save_fmt HSI_Data wavelength
global rgb_choice hsi_choice sav_opt

sav_folder = [save_dir,'\',save_folder];

mgg = msgbox('Saving Data','Please wait...');
% create main folder
try
    mkdir(sav_folder)
catch
    msgbox('folder already exists');
end

% create RGB data folder
try
    mkdir([sav_folder,'\RGB'])
catch
    msgbox('folder already exists');
end

% create HSI data folder
try
    mkdir([sav_folder,'\HSI'])
catch
    msgbox('folder already exists');
end

if rgb_choice == 1 % for saving rgb data
    fg = waitbar(0,'Please wait...');
    for i = 1:2
        imwrite(Im_Data{i},[sav_folder,'\RGB\Img_',num2str(i),save_fmt]);
        waitbar(i/2,fg,['Saving image ', num2str(i),' out of 2'])
        drawnow;
    end
    delete(fg)
end

if hsi_choice == 1
    DateString = datestr(now,30);
    
    if sav_opt<4
        info = enviinfo(HSI_Data);
        sensor_name = 'Spectronon Pika NIR 640';
        sensor_type = 'NIR';
        interleave_type = 'bil';
        data_type = 12;
        my_info = my_hdr_info(info, wavelength, sensor_name, sensor_type, interleave_type,data_type);
        if sav_opt == 1
            enviwrite(HSI_Data,my_info,[sav_folder,'\HSI\',DateString,'.bil']);
        elseif sav_opt == 2
            enviwrite(HSI_Data,my_info,[sav_folder,'\HSI\',DateString,'.img']);
        elseif sav_opt == 3
            enviwrite(HSI_Data,my_info,[sav_folder,'\HSI\',DateString,'.dat']);
        end
    else
        save([sav_folder,'\HSI\',DateString,'.mat'],'HSI_Data','wavelength'); 
    end
    mg = msgbox('HSI Data saved','Done...');
    pause(1)
    delete(mg)
end

delete(mgg)

% --- Executes on button press in exit_GUI.
function exit_GUI_Callback(hObject, eventdata, handles)
% hObject    handle to exit_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Im_Data VID SRC i_hsi conv_belt conv_on

try
    turn_off_all_Callback(hObject, eventdata, handles);
end

conv_on = 0;
delete(conv_belt);

% dump all Data
Im_Data = [];
clear VID SRC % clear camera objects
imaqreset; % reset imaq
close data_collection_GUI 

% --- Executes on button press in Correct_color.
function Correct_color_Callback(hObject, eventdata, handles)
% hObject    handle to Correct_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global corect_on
corect_on = get(hObject,'Value'); 


% --- Executes on button press in turn_cameras.
function turn_cameras_Callback(hObject, eventdata, handles)
% hObject    handle to turn_cameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VID SRC exp preview_bin turnon_cam Img_loading order

turnon_cam = get(hObject,'Value');

if turnon_cam == 1
    himage = [];
        % connect all cameras
        vid = [];
        src = [];

        for i = 1:2
            % display loading image on axes(i)
            eval(['himage = imshow(Img_loading, "Parent",handles.axes_cam',num2str(i),');']);
            drawnow

            try
                vid = videoinput('gentl',order(i),'RGB8Packed');
                vid.FramesperTrigger = 1;
                triggerconfig(vid, 'hardware', 'DeviceSpecific');

                src = getselectedsource(vid);
                src.ExposureTime = exp/(preview_bin);
                src.GainAuto = 'Off';
                src.BalanceWhiteAuto = 'Off';
                
                switch preview_bin
                    case 4 
                        src.BinningHorizontal = 'BinningHorizontal4';
                        src.BinningVertical = 'BinningVertical4';
                    case 2
                        src.BinningHorizontal = 'BinningHorizontal2';
                        src.BinningVertical = 'BinningVertical2';
                    case 1
                        src.BinningHorizontal = 'BinningHorizontal1';
                        src.BinningVertical = 'BinningVertical1';
                    otherwise
                        src.BinningHorizontal = 'BinningHorizontal4';
                        src.BinningVertical = 'BinningVertical4';
                end

                % preview
                preview(vid,himage);
                drawnow ;


                % turn button  color green
                eval(['handles.Ind_',num2str(i),'.BackgroundColor = [0,1,0];']);

                % save vid and src items
                eval(['VID.c',num2str(i),' = vid;']);
                eval(['SRC.c',num2str(i),' = src;']);
                drawnow;
            catch
                warndlg(['Camera_',num2str(i),' ID Not found'], 'Warning!!!');
            end
        end

    else

        for j = 1:2
            % disconnect all cameras
            try
                eval(['closepreview(VID.c',num2str(j),')']);
            end

            %turn all the lights off
            eval(['handles.Ind_',num2str(j),'.BackgroundColor = [0.9,0.9,0.9];']);
            drawnow;
        end
        imaqreset;
end

% Hint: get(hObject,'Value') returns toggle state of turn_cameras


% --- Executes during object creation, after setting all properties.
function turn_cameras_CreateFcn(hObject, eventdata, handles)
% hObject    handle to turn_cameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function exp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to exp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global exp SRC preview_bin
exp = str2double(get(hObject,'String'));
exp1 = round(exp/preview_bin);

for i = 1:2
    src = eval(['SRC.c',num2str(i)]);
    try
        src.ExposureTime = exp1;
    catch
        warndlg(['Camera#',nun2str(i),' exposure not set']);
    end
end

% Hints: get(hObject,'String') returns contents of exp_edit as text
%        str2double(get(hObject,'String')) returns contents of exp_edit as a double


% --- Executes during object creation, after setting all properties.
function capture_img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capture_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function sav_folder_Callback(hObject, eventdata, handles)
% hObject    handle to sav_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global save_folder
save_folder = get(hObject,'String');
handles.sav_folder.String = save_folder;
drawnow;
% Hints: get(hObject,'String') returns contents of sav_folder as text
%        str2double(get(hObject,'String')) returns contents of sav_folder as a double


% --- Executes on button press in correct_gamma.
function correct_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to correct_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cor_gamma
cor_gamma = get(hObject,'Value');

% Hint: get(hObject,'Value') returns toggle state of correct_gamma


% --- Executes on mouse press over axes background.
function axes15_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in turn_on_stage.
function turn_on_stage_Callback(hObject, eventdata, handles)
% hObject    handle to turn_on_stage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stage_on StageParams 
stage_on = get(hObject,'Value'); 

if stage_on==1
    
    % load/enable stage
    Res = MyArcus.Enable;
    
    % send stage to home and set current position to zero
    if (strcmp(Res,'1'))||(strcmp(Res,'OK'))
        MyArcus.resetStage;
        Res = MyArcus.goHome;
        pause(0.5)
        kk = 1; 
        while kk > 0 % wait for stage to go home
            out = MyArcus.IsBusy;
            if out==0
                kk = 0;
            end
        end
        
        Res = MyArcus.setAsZero;
        % turn light on
        handles.stageLight.BackgroundColor = [0,1,0];
        drawnow;
    else
        disp('Check stage connection or restart PC')
        handles.stageLight.BackgroundColor = [1,0,0];
        drawnow;
    end
    
    dd = msgbox('Calibrating stage...', 'please wait!!!');
    % return some values
    info = MyArcus.DevInfo;
    params = MyArcus.getParams;
    params.steps = StageParams.steps;
    pause(0.1);
    
    StageParams = params;
    StageParams.info = info;
    
    % determine stop position
    MyArcus.setParams(StageParams.pos,4*StageParams.l_vel,4*StageParams.h_vel,StageParams.accn)
    pause(0.1);
    
    kk = 1;
    MyArcus.JogPlus;
    while kk > 0 % wait for command to be executed
        out = MyArcus.IsBusy;
        if out == 1
            break;
        end
    end
%     pause(1);
    
    % check if stage is busy
    kk = 1; 
    while kk > 0 % wait for stage to move
        out = MyArcus.IsBusy;
        if out==0
            kk = 0;
        end
    end
    
    % get final position, move back home
    params2 = MyArcus.getParams;
    pause(0.1)
    StageParams.finalPos = params2.pos;
    StageParams.Start = StageParams.pos;
    StageParams.Stop = StageParams.finalPos;
    StageParams.step_time = 0;
    
    kk = 1;
    MyArcus.JogMinus;
    while kk > 0 % wait for command to be executed
        out = MyArcus.IsBusy;
        if out == 1
            break;
        end
    end
    
    kc = 1; % check if stage is busy
    while kc >0
        out1 = MyArcus.IsBusy;
        if out1==0
            kc = 0;
        end
    end
    
    MyArcus.resetStage;
    pause(0.2)
    
    params2 = MyArcus.getParams;
    pause(0.1)
    
    hvel = params2.h_vel;
    utime = 1/(1.0644*hvel - 70.23);
    StageParams.uTime = utime; 
    
    Res = MyArcus.goHome;
    pause(0.2);
    
    close(dd)
    % enable calculate options button
    handles.calc_opts.Enable = 'on';
%     save('StageParams.mat','StageParams');
else
    % attempt stop all motion
    try
        MyArcus.Abort;
    catch
        MyArcus.Stop;
    end
    
    % attempt disable stage
    MyArcus.Disable;
    
    handles.calc_opts.Enable = 'off';
    % turn light off
    handles.stageLight.BackgroundColor = [0.9,0.9,0.9];
 
end
% Hint: get(hObject,'Value') returns toggle state of turn_on_stage


% --- Executes on button press in turn_on_HSI.
function turn_on_HSI_Callback(hObject, eventdata, handles)
% hObject    handle to turn_on_HSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global exp_hyper vignette_corr i_hsi Img_loading himage2 frame_period aaa VID dim pos
global FFC wavelength img SRC

hsi_val = get(hObject,'Value');

pos = round(0.5*dim);
img = zeros(dim);

if hsi_val == 1
    i_hsi = 1;
    
    % display loading image
    himage2= imshow(Img_loading, 'Parent',handles.axes_hyper);
    drawnow;
    
    % load camera object
    
%         aaa = imaqhwinfo('gige');
%         ids = aaa.DeviceIDs;
%         VID.hyper = gigecam(ids{1,1});
        VID.hyper = videoinput('gige', 1, 'Mono14');
        SRC.hyper = VID.hyper.Source;
        SRC.hyper.ExposureMode = 'Timed';
    
%     VID.hyper.PixelFormat = 'Mono14';
    
    setappdata(himage2,'UpdatePreviewWindowFcn',@mypreview_vignette_cor);
    dt = preview(VID.hyper, himage2);
    drawnow;
    
    
    
    handles.Ind_hyper.BackgroundColor = [0,1,0];
    drawnow;
    
    % set exposure
    SRC.hyper.ExposureTime = exp_hyper;
    while i_hsi > 0
        
        try
            coord_input = get(handles.axes_hyper,'CurrentPoint');
            mean_coord = mean(coord_input); 
            if all(mean_coord(1:2)>=0)
                pos = round([mean_coord(2),mean_coord(1)]);
            end
            
            img = getsnapshot(VID.hyper);
            if vignette_corr
                img = uint16(round((double(img)/(2^14).*FFC)*2^14));
            end
            SRC.hyper.AcquisitionFrameRate = SRC.hyper.AcquisitionFrameRateLimit - 1;
            warning('off','all')
            fps = SRC.hyper.AcquisitionFrameRate;
            ROI = [SRC.hyper.AutoModeRegionHeight,SRC.hyper.AutoModeRegionWidth];
            int_hyper = max(max(img));
            
%             save('img.mat','img')
            line_spectra = flipud(mean(img(:,pos(2)-2:pos(2)+2),2));
            line_spatial = mean(img(pos(1)-2:pos(1)+2,:),1);
            
            % plot spatial
            plot(line_spatial,'b',...
                'LineWidth',1.5,...
                'Parent',handles.axes_spatial)
            axis(handles.axes_spatial,[0 640 0 16400]);
            box(handles.axes_spatial,'on');
            set(handles.axes_spatial,'XGrid','on','YGrid','on');
            
            % plot spetral
            plot(line_spectra,wavelength,'r',...
                'LineWidth',1.5,...
                'Parent',handles.axes_spectral)
            axis(handles.axes_spectral,[0 16400 800 1800]);
            box(handles.axes_spectral,'on');
            set(handles.axes_spectral,'XGrid','on','YGrid','on', 'XDir','reverse');
            
            handles.fps_preview.String = num2str(fps);
            handles.ROI_value.String = num2str(ROI);
            handles.int_value.String = num2str(int_hyper);
            drawnow;
        end
    end
    
else
    i_hsi = 0;
%     closePreview(VID.hyper);
    try
        stoppreview(VID.hyper);
        closepreview(VID.hyper);
    end
    handles.Ind_hyper.BackgroundColor = [0.9,0.9,0.9];
    drawnow;
    
end
% Hint: get(hObject,'Value') returns toggle state of turn_on_HSI


% --- Executes on button press in turn_on_conveyor.
function turn_on_conveyor_Callback(hObject, eventdata, handles)
% hObject    handle to turn_on_conveyor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global conv_belt conv_on
conv_on = get(hObject,'Value');

if conv_on == 1 % connect conveyor
    writeline(conv_belt,"WWR90#013"); % turn on all chambers

    %turn on greeen light
    handles.conv_ind.BackgroundColor = [0,1,0];
else % disconnect conveyor
    writeline(conv_belt,"WWR00#013"); % turn off all chambers
    handles.conv_ind.BackgroundColor = [0.9,0.9,0.9];
end
% Hint: get(hObject,'Value') returns toggle state of turn_on_conveyor



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to fps_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fps_preview as text
%        str2double(get(hObject,'String')) returns contents of fps_preview as a double


% --- Executes during object creation, after setting all properties.
function fps_preview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fps_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exp_hyper_Callback(hObject, eventdata, handles)
% hObject    handle to exp_hyper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global exp_hyper SRC

exp_hyper = str2double(get(hObject,'String'));
SRC.hyper.ExposureTime = exp_hyper;

SRC.hyper.AcquisitionFrameRate = SRC.hyper.AcquisitionFrameRateLimit - 1;
warning('off','all')
fps = SRC.hyper.AcquisitionFrameRate;
handles.fps_preview.String = num2str(fps);
drawnow;
% Hints: get(hObject,'String') returns contents of exp_hyper as text
%        str2double(get(hObject,'String')) returns contents of exp_hyper as a double


% --- Executes during object creation, after setting all properties.
function exp_hyper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_hyper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in vgnt_correct.
function vgnt_correct_Callback(hObject, eventdata, handles)
% hObject    handle to vgnt_correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vignette_corr

vignette_corr = get(hObject,'Value');
drawnow;
% Hint: get(hObject,'Value') returns toggle state of vgnt_correct


% --- Executes on button press in turn_off_all.
function turn_off_all_Callback(hObject, eventdata, handles)
% hObject    handle to turn_off_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i_hsi VID turnon_cam hsi_val conv_belt
i_hsi = 0;

% turn off cameras
turnon_cam = 0;
try
    stoppreview(VID.c1);
end
handles.turn_cameras.Value = 0;
handles.Ind_1.BackgroundColor = [0.9,0.9,0.9];
drawnow;

try
    stoppreview(VID.c2);
end
handles.Ind_2.BackgroundColor = [0.9,0.9,0.9];
drawnow;

hsi_val =  0;
try
%     closePreview(VID.hyper);
    closepreview(VID.hyper);
    stoppreview(VID.hyper);
end
handles.turn_on_HSI.Value = 0;
handles.Ind_hyper.BackgroundColor = [0.9,0.9,0.9];
drawnow;

% turn off stage
    % attempt stop all motion
    try
        MyArcus.Abort;
    catch
        MyArcus.Stop;
    end

    % attempt disable stage
    MyArcus.Disable;

    % turn light off
    handles.stageLight.BackgroundColor = [0.9,0.9,0.9];
    handles.turn_on_stage.Value = 0;

% turn off conveyor
writeline(conv_belt,"WWR00#013");% turn off all
handles.conv_ind.BackgroundColor = [0.9,0.9,0.9];
handles.turn_on_conveyor.Value = 0;
drawnow;






% --- Executes on button press in calc_opts.
function calc_opts_Callback(hObject, eventdata, handles)
% hObject    handle to calc_opts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global exp_hyper StageParams stage_ratio dim HSI_Data
aa = Compute_Capture_Options;
waitfor(aa);

hsi_dims = [dim(2),StageParams.steps,dim(1)];
HSI_Data = zeros(dim(1),dim(2),StageParams.steps);
handles.hyper_dims.String = num2str(hsi_dims);
handles.hsi_chamber.Enable = 'On';
drawnow;


% --- Executes during object creation, after setting all properties.
function hyper_dims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hyper_dims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in rgb_chamber.
function rgb_chamber_Callback(hObject, eventdata, handles)
% hObject    handle to rgb_chamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rgb_choice

rgb_choice = get(hObject,'Value');


% Hint: get(hObject,'Value') returns toggle state of rgb_chamber


% --- Executes on button press in hsi_chamber.
function hsi_chamber_Callback(hObject, eventdata, handles)
% hObject    handle to hsi_chamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global hsi_choice

hsi_choice = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of hsi_chamber


% --- Executes on selection change in save_fmt.
function save_fmt_Callback(hObject, eventdata, handles)
% hObject    handle to save_fmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sav_opt
sav_opt = get(hObject,'Value');
% Hints: contents = cellstr(get(hObject,'String')) returns save_fmt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_fmt


% --- Executes during object creation, after setting all properties.
function save_fmt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_fmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
