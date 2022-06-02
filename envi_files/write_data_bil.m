% .bil write data script
%% ex1
data = reshape(uint16(1:600), [10 20 3]);
multibandwrite(data,'data.bil','bil');

%% ex2

numBands = 1;
dataDims = [1024 1024 numBands];
data = reshape(uint32(1:(1024 * 1024 * numBands)), dataDims);

for band = 1:numBands
   for row = 1:2
      for col = 1:2
 
         subsetRows = ((row - 1) * 512 + 1):(row * 512);
         subsetCols = ((col - 1) * 512 + 1):(col * 512);

         upperLeft = [subsetRows(1), subsetCols(1), band];
         multibandwrite(data(subsetRows, subsetCols, band), ...
                          'banddata.bil', 'bil', upperLeft, dataDims);

      end
   end
end

% read data

%% Example 1

% Setup initial parameters for a data set.
rows=3; cols=3; bands=5;
filename = tempname;

% Define the data set.
fid = fopen(filename, 'w', 'ieee-le');
fwrite(fid, 1:rows*cols*bands, 'double');
fclose(fid);

% Read every other band of the data using the Band-Sequential format.

im3 = multibandread(filename, [rows cols bands], ...
                    'double', 0, 'bil', 'ieee-le');
                
delete(filename);

%% Example 2
% Read int16 BIL data from the FITS file tst0012.fits, starting at byte 74880.

im4 = multibandread('tst0012.fits', [31 73 5], ...
                    'int16', 74880, 'bil', 'ieee-be', ...
                    {'Band', 'Range', [1 3]} );
im5 = double(im4)/max(max(max(im4)));
imagesc(im5);