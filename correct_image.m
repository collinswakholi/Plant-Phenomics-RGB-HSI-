function Im_out = correct_image(Im, ccm, fit_mtd, gains, color_space, whitePoint)

sz = size(Im);

Im = double(Im)./((2^8)-1);

Im = reshape(Im,sz(1)*sz(2),3).*gains;
% r_dsg_img = rescale(r_dsg_img,0,1);
Im(Im > 1) = 1;

c_Im = ccmapply(Im,...
                     fit_mtd,...
                     ccm);

Im_out = reshape(c_Im,sz(1),sz(2),3);

if strcmp(color_space,'xyz')
    Im_out = xyz2rgb(Im_out,'WhitePoint',whitePoint,'OutputType','uint8');
end