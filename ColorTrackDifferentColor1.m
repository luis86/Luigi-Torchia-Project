

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);

%s=serial('/dev/tty.Bluetooth-Incoming-Port'); % this value may change, read error message if received
%fopen(s);


%vid = videoinput('macvideo', 2, 'YUY2_640x480'); % change to 'winvideo' on WindowsPC
%vid = videoinput('macvideo', 1);

vid = videoinput(camera_name, camera_id, format);

warning('off', 'Images:initSize:adjustingMag');

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;
set(vid,'StartFcn',@imaqcallback)
set(vid,'TriggerFcn',@imaqcallback)
set(vid,'StopFcn',@imaqcallback)

% Start the video aquisition here
start(vid)


count1 = 1;
count2 = 1;
while(vid.FramesAcquired<=2000000)
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
  

	% Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
	diff_im = imsubtract(data(:,:,2), rgb2gray(data));
    
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18);
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);
    
    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8); 
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid', 'Area', 'PixelList');
    
    for object = 1:length(stats)
		if stats(object).Area > 10000
			disp('Color of Green Seen');
            
            if (count1==1)
            web('/Users/luigitorchia/Desktop/robotB.html');
            count2 = 1;
            end
            count1 = count1+1;
     
		end
    end

	
	diff_im = imsubtract(data(:,:,3), rgb2gray(data));
    diff_im = medfilt2(diff_im, [3 3]);
    diff_im = im2bw(diff_im,0.18);
    diff_im = bwareaopen(diff_im,300);
    bw = bwlabel(diff_im, 8);   
    stats = regionprops(bw, 'BoundingBox', 'Centroid', 'Area', 'PixelList');
    for object = 1:length(stats)
		if stats(object).Area > 30000
			disp('Color of Blue Seen')
            if(count2 == 1)
            web('/Users/luigitorchia/Desktop/robotA.html');
            count1 =1;
            end
            count2 = count2+1;
		end
    end

	

    
   flushdata(vid); 
end
% Both the loops end here.