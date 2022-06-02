function info = my_hdr_info(info, wavelength, sensor_name, sensor_type, interleave_type,...
     data_type)

    info.description = sensor_name;
    info.data_type = data_type; 
    info.header_offset = 0;
    info.bitDepth = 12;
    info.interleave = interleave_type;
    info.sensor_type = sensor_type;
    info.byte_order = 0;
    info.wavelengthUnits = 'nm';
    info.wavelength = wavelength';
    
    
    