function mypreview_vignette_cor(obj, event, himage)
global vignette_corr FFC

data = event.Data;
if vignette_corr == 1
    data = double(data)/255;
    data = uint8(round(255*mat2gray(data.*FFC)));
end

 set(himage,'cdata', data)