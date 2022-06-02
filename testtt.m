 app.vid_FL = videoinput('gentl', 2, 'RGB8Packed');
               app.src_FL = getselectedsource(app.vid_FL);
               app.src_FL.BinningHorizontal = 'BinningHorizontal2';
               app.src_FL.BinningVertical = 'BinningVertical2';
               app.vid_FL.FramesPerTrigger = 4;
               triggerconfig(app.vid_FL, 'hardware', 'DeviceSpecific', 'DeviceSpecific'); 
               preview(app.vid_FL);