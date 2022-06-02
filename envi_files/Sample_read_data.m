clear; 
close all;
clc;
addpath('Data');

% [wavelength] = xlsread('hyperwavelength.xlsx');%headline (headerlines) of text file

%% white read
input_file = 'new_test'; 
headfile = strcat(input_file, '.bil.hdr'); 
imfile = strcat(input_file, '.bil'); 

% Read White head file
fid=fopen(headfile, 'r');
c2=textscan(fid, '%s %s %s');
fclose(fid);

% Read White samples, lines, and bands number of headfile
samples = str2double(char(c2{3}(3)));
lines = str2double(char(c2{3}(4)));
bands = str2double(char(c2{3}(5)));

% White average
[fid2,msg2] = fopen(imfile,'r');
[NormalData2, count2]= fread(fid2, [samples, lines*bands], 'uint16');
fclose(fid2);

I = zeros(samples, lines, bands);% first make all zero
II = zeros(samples, lines, bands);
BandImage = zeros(samples, lines);

% white image's each wavelength intensity graph
for ib = 1:bands
    for il = 1:lines
         BandImage(:,lines-il+1) = NormalData2(:,(il-1)*bands + ib);
    end
     I(:,:,ib) = BandImage;
end

% preview band number nnn
nnn = 100;% choose which band to see
figure(33)
imshow(I(:,:,nnn),[])

%addpath('calib_files')
% calib_file = xlsread('wave_calib_vnir.xlsx');
% wavelength = calib_file(576:1495,2);
% wavelength = decimate(wavelength,4);
% 
% info = enviinfo(I);
% info = my_hdr_info(info, wavelength, 'PCOPanda', 'VisNIR', 'bil',...
%         4, 4, 12);
% 
% save_name = 'new_test3';
% img_fmt = '.file';%'.file'
% enviwrite(I,info,['Data\',save_name,img_fmt]);
    
