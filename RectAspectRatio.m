function ratio=RectAspectRatio(fname)
%Aspect Ratio of the largest rectangle detected in each frame.
%
% Author: github.com/chouj
% Aug 2018

if nargin<1
    error('Not Enough Inputs. At least 1 inputs');
end
if nargin>1
    error('Too Many Inputs. Just one MP4 file name');
end

while exist(fname)~=2
    fname=input('File not exist! Please re-enter: ','s');
    if isempty(fname)==1
        fname=input('No input! Please re-enter: ','s');
    end
end

v = VideoReader(fname);

vidWidth = v.Width;
vidHeight = v.Height;

% Struct array for MP4 created
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);

% fetch all frames
k = 1;
while hasFrame(v)
    mov(k).cdata = readFrame(v);
    k = k+1;
end

for i=1:k-1
    clear bw stats area sortedarea si keypage
    bw=rgb2gray(mov(i).cdata); % colored image transferred to gray image
    bw = bw >110; % brightness modification for rectangle area detection
    stats = regionprops(not(bw)); % rectangle area detection
    if length(stats)>1
        for j=1:length(stats);area(j)=stats(j).Area;end
        [sortedarea,si]=sort(area); % find the second largest rectangle area
        keypage=imcrop(bw,stats(si(end-1)).BoundingBox); % gray image cropping
        ratio(i)=size(keypage,1)/size(keypage,2);
    end
end

figure;
plot(ratio);
end