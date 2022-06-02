 
clear; clc;

imaqreset;
aaa = imaqhwinfo('gige');
ids = aaa.DeviceIDs;
vid = gigecam(ids{1,1});
vid.PixelFormat = 'Mono14';
vid.ExposureTime = 60000;

preview(vid);

img =  snapshot(vid);

l_lim = min(min(img));
u_lim = max(max(img));

if (2^14 - u_lim)>5
    white_pro = mat2gray(img);
    mean_white = smooth(mean(white_pro,1));   
    M =  max(mean_white);

    I_corr = M*((1-mean_white)./(mean_white)); % flat field correction algorithm
    I_Corr = (1-min(I_corr))+I_corr;

    FFC = repmat(I_Corr',512,1);

    save('FFC.mat','FFC','u_lim','l_lim')
else
    disp('white image is saturated, please take white again')
end

% white_correct = white_pro.*FFC;

% imshowpair(white_pro,white_correct,'montage')

% aaa = mean_white.*(I_Corr);
% plot(aaa)
% hold on; 
% plot(mean_white)

