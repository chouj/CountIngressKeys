%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Count the number of keys to each portal %%%%%%%%%%%%%%%%%%
%
% Counting how many duplicated keys to each specific portal you have, no
% matter where you put it (INVENTORY or CAPSULE or KEYLOCKER).
%
% Main procedure:
% - Record your phone's screen while you're browsing keys and move the
%   obtained MP4 file to PC.
% - Download Tesseract OCR and get it prepared.
% - Set parameters below according to your screen recording and aspect
%   ratio due to different mobile phone.
% - run the script.
% - Results will be stored in a .xls file
%
% Dependency
% - Tesseract OCR (https://github.com/tesseract-ocr/)
% - Computer Vision System Toolbox
%
% Author: github.com/chouj
% Aug 2018

%%%%%%%%%%%%%%% Parameters, modify them here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path of screen recording MP4 file
mv='c:\users\lenovo\downloads\IMG_8280.mp4';

implay(mv); % MATLAB player will pop out.


% find appropriate range of frames accordingly
startf = 1; % first frame
endf = 4570; % last frame


% path of the folder where .xls file will be generated
outputfolder='c:\users\lenovo\pictures\';

% path of tesseract.exe
te='e:\TesseractOCR\tesseract.exe';

% filename of .xls file. Note: not its path, only its name.
fname='keycounting3.xls';

% aspect ratio ranges
% iPhone 6
lbarrI = 1.65; % lower boundary of aspect ratio range for keys in Inventory
ubarrI = 1.68; % upper boundary of aspect ratio range for keys in Inventory
lbarrC = 0.96; % lower boundary of aspect ratio range for keys in Capsule/Keylocker
ubarrC = 0.98; % upper boundary of aspect ratio range for keys in Capsule/Keylocker

% MOTO G 2nd Gen
% lbarrI = 1.4; 
% ubarrI = 1.6; 
% lbarrC = 0.8; 
% ubarrC = 0.9; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

feature('DefaultCharacterSet', 'UTF8'); % Chinese character supported

v = VideoReader(mv);

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


for i=startf:endf
    
    % processing percentage
    percent=(i-startf+1)/(endf-startf+1)*100;
    disp(sprintf('%0.5g %s',percent,'%'));
    
    if i==startf % first frame
        
        knum=1; % the first key to be recognized and counted
        % figure;imshow(mov(i).cdata);
        bw=rgb2gray(mov(i).cdata); % colored image transferred to gray image
        bw = bw >100; % brightness modification for rectangle area detection
        stats = regionprops(not(bw)); % rectangle area detection
        for j=1:length(stats);area(j)=stats(j).Area;end
        [sortedarea,si]=sort(area); % find the second largest rectangle area
        % hold on;rectangle('Position', stats(si(end-1)).BoundingBox,'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        keypage=imcrop(bw,stats(si(end-1)).BoundingBox); % gray image cropping
        colorkeypage=imcrop(mov(i).cdata,stats(si(end-1)).BoundingBox); % colored image cropping
        % figure;imshow(colorkeypage,[]);
        
        % The Height/width ratio will be larger than 1 if it is a snapshot
        % of Inventory keys. Otherwise, the ratio will be less than 1 if it
        % is a screenshot of Capsule/Keylocker keys.
        if size(keypage,1)/size(keypage,2)<1
            topa=6.2;btma=4.5;btmb=8; % for Capsule/Keylocker keys
        else
            topa=10;btma=8;btmb=15; % for Inventory keys
        end
        % Using these parameters to find cropped area of key number or key
        % name.
        
        testflag(knum,1)=i; % for test
        
        % key number area cropping by using colored screenshot
        top=imcrop(colorkeypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
        
        % figure;imshow(top,[]);
        
        txt = ocr(top); % English and number recognition
        keynumtxt=txt.Text;
        
        % if nothing is recognized, redo cropping
        while isempty(strrep(keynumtxt, ' ', ''))==1
            top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
            clear txt keynumtxt
            txt = ocr(top);
            keynumtxt=txt.Text;
        end
        
        % key amount recognition by regular expression
        keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
        
        if isempty(keynumcell)==0 % something has been recognized
            if cell2mat(keynumcell{1})=='I' % if it is 'I'
                keynum(knum,1)=1;
            elseif cell2mat(keynumcell{1})=='l' % if it is 'l'
                keynum(knum,1)=1;
            elseif cell2mat(keynumcell{1})=='i' % if it is 'i'
                keynum(knum,1)=1;
            elseif cell2mat(keynumcell{1})=='|' % if it is '|'
                keynum(knum,1)=1;
            elseif lower(cell2mat(keynumcell{1}))=='s' % if it is 's'
                f0=figure;imshow(top); % show the cropped image, and wait for your judgement.
                s=input('Recognition failed, input it please: ','s');
                if isempty(s) | isnumeric(str2num(s))==0
                    s=input('Re-enter: ','s');
                end
                keynum(knum,1)=str2num(s);close(f0);
            elseif cell2mat(keynumcell{1})=='B' % if it is 'B'
                f0=figure;imshow(top);
                s=input('Recognition failed, input it please: ','s');
                if isempty(s) | isnumeric(str2num(s))==0
                    s=input('Re-enter: ','s');
                end
                keynum(knum,1)=str2num(s);close(f0);
            elseif isempty(str2num(cell2mat(keynumcell{1})))==1 % if it is not a number
                % re-conduct OCR on gray cropped screenshot
                top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                % figure;imshow(top,[]);
                txt = ocr(top);
                keynumtxt=txt.Text;
                while isempty(strrep(keynumtxt, ' ', ''))==1
                    top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                    clear txt keynumtxt
                    txt = ocr(top);
                    keynumtxt=txt.Text;
                end
                keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                if isempty(keynumcell)==0
                    
                    if cell2mat(keynumcell{1})=='I'
                        keynum(knum,1)=1;
                    elseif cell2mat(keynumcell{1})=='l'
                        keynum(knum,1)=1;
                    elseif cell2mat(keynumcell{1})=='i'
                        keynum(knum,1)=1;
                    elseif cell2mat(keynumcell{1})=='|'
                        keynum(knum,1)=1;
                    elseif lower(cell2mat(keynumcell{1}))=='s'
                        f0=figure;imshow(top);
                        s=input('Recognition failed, input it please: ','s');
                        if isempty(s) | isnumeric(str2num(s))==0
                            s=input('Re-enter: ','s');
                        end
                        keynum(knum,1)=str2num(s);close(f0);
                    elseif cell2mat(keynumcell{1})=='B'
                        f0=figure;imshow(top);
                        s=input('Recognition failed, input it please: ','s');
                        if isempty(s) | isnumeric(str2num(s))==0
                            s=input('Re-enter: ','s');
                        end
                        keynum(knum,1)=str2num(s);close(f0);
                    elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                        f0=figure;imshow(top);
                        s=input('Recognition failed, input it please: ','s');
                        if isempty(s) | isnumeric(str2num(s))==0
                            s=input('Re-enter: ','s');
                        end
                        keynum(knum,1)=str2num(s);close(f0);
                    else % if it is a number, then store it as number of keys
                        keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                    end
                else %if nothing has been recognized, show the figure and input the number.
                    f0=figure;imshow(top);
                    s=input('Recognition failed, input it please: ','s');
                    if isempty(s) | isnumeric(str2num(s))==0
                        s=input('Re-enter: ','s');
                    end
                    keynum(knum,1)=str2num(s);close(f0);
                end
            else % if it is a number, then store it as number of keys
                keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
            end
        elseif length(keynumcell)==0 & size(keypage,1)/size(keypage,2)>1
            % if nothing has been recognized and OCR is based on image of
            % Inventory keys, set number of keys to 1
            keynum(knum,1)=1;
        elseif length(keynumcell)==0 % if nothing has been recognized, re-conduct OCR on gray cropped screenshot
            top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
            % figure;imshow(top,[]);
            txt = ocr(top);
            keynumtxt=txt.Text;
            while isempty(strrep(keynumtxt, ' ', ''))==1
                top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                clear txt keynumtxt
                txt = ocr(top);
                keynumtxt=txt.Text;
            end
            keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
            if isempty(keynumcell)==0
                
                if cell2mat(keynumcell{1})=='I'
                    keynum(knum,1)=1;
                elseif cell2mat(keynumcell{1})=='l'
                    keynum(knum,1)=1;
                elseif cell2mat(keynumcell{1})=='i'
                    keynum(knum,1)=1;
                elseif cell2mat(keynumcell{1})=='|'
                    keynum(knum,1)=1;
                elseif lower(cell2mat(keynumcell{1}))=='s'
                    f0=figure;imshow(top);
                    s=input('Recognition failed, input it please: ','s');
                    if isempty(s) | isnumeric(str2num(s))==0
                        s=input('Re-enter: ','s');
                    end
                    keynum(knum,1)=str2num(s);close(f0);
                elseif cell2mat(keynumcell{1})=='B'
                    f0=figure;imshow(top);
                    s=input('Recognition failed, input it please: ','s');
                    if isempty(s) | isnumeric(str2num(s))==0
                        s=input('Re-enter: ','s');
                    end
                    keynum(knum,1)=str2num(s);close(f0);
                elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                    f0=figure;imshow(top);
                    s=input('Recognition failed, input it please: ','s');
                    if isempty(s) | isnumeric(str2num(s))==0
                        s=input('Re-enter: ','s');
                    end
                    keynum(knum,1)=str2num(s);close(f0);
                else
                    keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                end
            else
                f0=figure;imshow(top);
                s=input('Recognition failed, input it please: ','s');
                if isempty(s) | isnumeric(str2num(s))==0
                    s=input('Re-enter: ','s');
                end
                keynum(knum,1)=str2num(s);close(f0);
            end
        else
            f0=figure;imshow(top);
            s=input('Recognition failed, input it please: ','s');
            if isempty(s) | isnumeric(str2num(s))==0
                s=input('Re-enter: ','s');
            end
            keynum(knum,1)=str2num(s);close(f0);
            testflag(knum,2)=i;
        end
        
        % cropping of portal name area
        btm1=imcrop(colorkeypage,[0,size(keypage,1)-size(keypage,1)/btma,size(keypage,2),size(keypage,1)/btmb]);
        
        % save it for Tesseract OCR
        imwrite(im2bw(btm1),[outputfolder,'portaltest.jpg'],'JPEG');
        
        % dos command for Tesseract OCR
        dos([te,' ',outputfolder,'portaltest.jpg -psm 6 -l eng+chi_sim+chi_tra ',outputfolder,'out1']);
        
        % load the result back into workspace
        clear test
        test=importdata([outputfolder,'out1.txt']);
        if isstruct(test)==0
            if length(test)==1
                portalname{knum,1}=cell2mat(test);
            elseif length(test)==2
                portalname{knum,1}=[test{1},test{2}];
            elseif length(test)==3
                portalname{knum,1}=[test{1},test{2},test{3}];
            elseif length(test)==4
                portalname{knum,1}=[test{1},test{2},test{3},test{4}];
            elseif length(test)==5
                portalname{knum,1}=[test{1},test{2},test{3},test{4},test{5}];
            end
        else
            portalname{knum,1}=cell2mat(test.textdata);
        end
        
    else % if it's not the first frame for recognition
        
        clear bw stats sortedarea si keypage top txt keynumtxt kuynumcell btm area test colorkeypage keynumcell
        
        bw=rgb2gray(mov(i).cdata);
        bw = bw >100;
        stats = regionprops(not(bw));
        if length(stats)>=50 % the number of recognized rectangle should be larger than 50
            for j=1:length(stats);area(j)=stats(j).Area;end
            [sortedarea,si]=sort(area);
            % hold on;rectangle('Position', stats(si(end-1)).BoundingBox,'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
            keypage=imcrop(bw,stats(si(end-1)).BoundingBox);
            colorkeypage=imcrop(mov(i).cdata,stats(si(end-1)).BoundingBox);
            ratio(i)=size(keypage,1)/size(keypage,2); % for test. obtain the aspect ratio.
            
            % if it is a image of Capsule/Keylocker keys
            if size(keypage,1)/size(keypage,2)<=ubarrC&size(keypage,1)/size(keypage,2)>=lbarrC
                topa=6.2;btma=4.5;btmb=8;
                btm2=imcrop(colorkeypage,[0,size(keypage,1)-size(keypage,1)/btma,size(keypage,2),size(keypage,1)/btmb]);
                
                % Compute the correlation coefficient between current
                % portal name area and previous portal name area
                btm=resize(size(btm1),btm2);
                r=corr2(rgb2gray(btm),rgb2gray(btm1));
                
                if r<0.75
                    % if the coefficient is almost 1, they might be the same
                    % portal but different frame.
                    
                    knum=knum+1; % a new portal key waiting for recognition
                    testflag(knum,1)=i; % for test
                    top=imcrop(colorkeypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                    % figure;imshow(top,[]);
                    txt = ocr(top);
                    keynumtxt=txt.Text;
                    while isempty(strrep(keynumtxt, ' ', ''))==1
                        top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                        clear txt keynumtxt
                        txt = ocr(top);
                        keynumtxt=txt.Text;
                    end
                    keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                    if isempty(keynumcell)==0
                        if cell2mat(keynumcell{1})=='I'
                            keynum(knum,1)=1;
                            
                        elseif cell2mat(keynumcell{1})=='l'
                            keynum(knum,1)=1;
                        elseif cell2mat(keynumcell{1})=='|'
                            keynum(knum,1)=1;
                        elseif cell2mat(keynumcell{1})=='i'
                            keynum(knum,1)=1;
                        elseif lower(cell2mat(keynumcell{1}))=='s'
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        elseif cell2mat(keynumcell{1})=='B'
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                            top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                            % figure;imshow(top,[]);
                            txt = ocr(top);
                            keynumtxt=txt.Text;
                            while isempty(strrep(keynumtxt, ' ', ''))==1
                                top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                                clear txt keynumtxt
                                txt = ocr(top);
                                keynumtxt=txt.Text;
                            end
                            keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                            if isempty(keynumcell)==0
                                
                                if cell2mat(keynumcell{1})=='I'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='l'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='i'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='|'
                                    keynum(knum,1)=1;
                                elseif lower(cell2mat(keynumcell{1}))=='s'
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                elseif cell2mat(keynumcell{1})=='B'
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                else
                                    keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                                end
                            else
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            end
                        else
                            keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                        end
                    elseif length(keynumcell)==0 & size(keypage,1)/size(keypage,2)>1
                        keynum(knum,1)=1;
                    elseif length(keynumcell)==0
                        top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                        % figure;imshow(top,[]);
                        txt = ocr(top);
                        keynumtxt=txt.Text;
                        while isempty(strrep(keynumtxt, ' ', ''))==1
                            top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                            clear txt keynumtxt
                            txt = ocr(top);
                            keynumtxt=txt.Text;
                        end
                        keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                        if isempty(keynumcell)==0
                            
                            if cell2mat(keynumcell{1})=='I'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='l'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='i'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='|'
                                keynum(knum,1)=1;
                            elseif lower(cell2mat(keynumcell{1}))=='s'
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            elseif cell2mat(keynumcell{1})=='B'
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            else
                                keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                            end
                        else
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        end
                    else
                        f0=figure;imshow(top);
                        s=input('Recognition failed, input it please: ','s');
                        if isempty(s) | isnumeric(str2num(s))==0
                            s=input('Re-enter: ','s');
                        end
                        keynum(knum,1)=str2num(s);close(f0);
                        testflag(knum,2)=i;
                    end
                    imwrite(im2bw(btm2),[outputfolder,'portaltest.jpg'],'JPEG');
                    dos([te,' ',outputfolder,'portaltest.jpg -psm 6 -l eng+chi_sim+chi_tra ',outputfolder,'out1']);
                    clear test
                    test=importdata([outputfolder,'out1.txt']);
                    if isstruct(test)==0
                        if length(test)==1
                            portalname{knum,1}=cell2mat(test);
                        elseif length(test)==2
                            portalname{knum,1}=[test{1},test{2}];
                        elseif length(test)==3
                            portalname{knum,1}=[test{1},test{2},test{3}];
                        elseif length(test)==4
                            portalname{knum,1}=[test{1},test{2},test{3},test{4}];
                        elseif length(test)==5
                            portalname{knum,1}=[test{1},test{2},test{3},test{4},test{5}];
                        end
                    else
                        
                        portalname{knum,1}=cell2mat(test.textdata);
                        
                    end
                    
                end
                clear btm1
                btm1=btm2;
                clear btm2
                
                % if it is a image of Inventory keys
            elseif size(keypage,1)/size(keypage,2)<=ubarrI&size(keypage,1)/size(keypage,2)>=lbarrI
                topa=10;btma=8;btmb=15;
                btm2=imcrop(colorkeypage,[0,size(keypage,1)-size(keypage,1)/btma,size(keypage,2),size(keypage,1)/btmb]);
                
                btm=resize(size(btm1),btm2);
                r=corr2(rgb2gray(btm),rgb2gray(btm1));
                
                if r<0.75
                    
                    knum=knum+1;
                    testflag(knum,1)=i;
                    top=imcrop(colorkeypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                    % figure;imshow(top,[]);
                    txt = ocr(top);
                    keynumtxt=txt.Text;
                    while isempty(strrep(keynumtxt, ' ', ''))==1
                        top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                        clear txt keynumtxt
                        txt = ocr(top);
                        keynumtxt=txt.Text;
                    end
                    keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                    if isempty(keynumcell)==0
                        if cell2mat(keynumcell{1})=='I'
                            keynum(knum,1)=1;
                        elseif cell2mat(keynumcell{1})=='l'
                            keynum(knum,1)=1;
                        elseif cell2mat(keynumcell{1})=='i'
                            keynum(knum,1)=1;
                        elseif cell2mat(keynumcell{1})=='|'
                            keynum(knum,1)=1;
                        elseif lower(cell2mat(keynumcell{1}))=='s'
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        elseif cell2mat(keynumcell{1})=='B'
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                            top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                            % figure;imshow(top,[]);
                            txt = ocr(top);
                            keynumtxt=txt.Text;
                            while isempty(strrep(keynumtxt, ' ', ''))==1
                                top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                                clear txt keynumtxt
                                txt = ocr(top);
                                keynumtxt=txt.Text;
                            end
                            keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                            if isempty(keynumcell)==0
                                
                                if cell2mat(keynumcell{1})=='I'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='i'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='l'
                                    keynum(knum,1)=1;
                                elseif cell2mat(keynumcell{1})=='|'
                                    keynum(knum,1)=1;
                                elseif lower(cell2mat(keynumcell{1}))=='s'
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                elseif cell2mat(keynumcell{1})=='B'
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                                    f0=figure;imshow(top);
                                    s=input('Recognition failed, input it please: ','s');
                                    if isempty(s) | isnumeric(str2num(s))==0
                                        s=input('Re-enter: ','s');
                                    end
                                    keynum(knum,1)=str2num(s);close(f0);
                                else
                                    keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                                end
                            else
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            end
                        else
                            keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                        end
                    elseif length(keynumcell)==0 & size(keypage,1)/size(keypage,2)>1
                        keynum(knum,1)=1;
                    elseif length(keynumcell)==0
                        top=imcrop(keypage,[0,0,size(keypage,2),size(keypage,1)/topa]);
                        % figure;imshow(top,[]);
                        txt = ocr(top);
                        keynumtxt=txt.Text;
                        while isempty(strrep(keynumtxt, ' ', ''))==1
                            top=imcrop(top,[0,0,size(top,2),size(top,1)/1.05]);
                            clear txt keynumtxt
                            txt = ocr(top);
                            keynumtxt=txt.Text;
                        end
                        keynumcell=regexp(keynumtxt,'[xX](.+)[\]1lI]','tokens');
                        if isempty(keynumcell)==0
                            
                            if cell2mat(keynumcell{1})=='I'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='l'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='i'
                                keynum(knum,1)=1;
                            elseif cell2mat(keynumcell{1})=='|'
                                keynum(knum,1)=1;
                            elseif lower(cell2mat(keynumcell{1}))=='s'
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            elseif cell2mat(keynumcell{1})=='B'
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            elseif isempty(str2num(cell2mat(keynumcell{1})))==1
                                f0=figure;imshow(top);
                                s=input('Recognition failed, input it please: ','s');
                                if isempty(s) | isnumeric(str2num(s))==0
                                    s=input('Re-enter: ','s');
                                end
                                keynum(knum,1)=str2num(s);close(f0);
                            else
                                keynum(knum,1)=real(str2num(cell2mat(keynumcell{1})));
                            end
                        else
                            f0=figure;imshow(top);
                            s=input('Recognition failed, input it please: ','s');
                            if isempty(s) | isnumeric(str2num(s))==0
                                s=input('Re-enter: ','s');
                            end
                            keynum(knum,1)=str2num(s);close(f0);
                        end
                    else
                        f0=figure;imshow(top);
                        s=input('Recognition failed, input it please: ','s');
                        if isempty(s) | isnumeric(str2num(s))==0
                            s=input('Re-enter: ','s');
                        end
                        keynum(knum,1)=str2num(s);close(f0);
                        testflag(knum,2)=i;
                    end
                    
                    imwrite(im2bw(btm2),[outputfolder,'portaltest.jpg'],'JPEG');
                    dos([te,' ',outputfolder,'portaltest.jpg -psm 6 -l eng+chi_sim+chi_tra ',outputfolder,'out1']);
                    test=importdata([outputfolder,'out1.txt']);
                    if isstruct(test)==0
                        if length(test)==1
                            portalname{knum,1}=cell2mat(test);
                        elseif length(test)==2
                            portalname{knum,1}=[test{1},test{2}];
                        elseif length(test)==3
                            portalname{knum,1}=[test{1},test{2},test{3}];
                        elseif length(test)==4
                            portalname{knum,1}=[test{1},test{2},test{3},test{4}];
                        elseif length(test)==5
                            portalname{knum,1}=[test{1},test{2},test{3},test{4},test{5}];
                        end
                    else
                        
                        portalname{knum,1}=cell2mat(test.textdata);
                        
                    end
                    
                end
                
                % clear previous portal name area and make current one as
                % reference for correlation computing
                clear btm1
                btm1=btm2;
                clear btm2
            end
            
            
        end
    end
end

% optimize and clarify recognized portal names
for i=1:length(portalname)
    portalname{i} = strrep(portalname{i}, ' ', '');
    portalname{i} = strrep(portalname{i}, '\', '');
    portalname{i} = strrep(portalname{i}, '®F', '');
    portalname{i} = strrep(portalname{i}, '©Ö', '');
    portalname{i} = strrep(portalname{i}, '_', '');
    portalname{i} = strrep(portalname{i}, '?', '');
    portalname{i} = strrep(portalname{i}, '°ø', '');
    portalname{i} = strrep(portalname{i}, 'Ï‰', '');
    portalname{i} = strrep(portalname{i}, '|', '');
    portalname{i} = strrep(portalname{i}, '`', '');
    portalname{i} = strrep(portalname{i}, '°¨', '');
    portalname{i} = strrep(portalname{i}, '®E', '');
    portalname{i} = strrep(portalname{i}, '©q', '');
    portalname{i} = strrep(portalname{i}, '°≠', '');
    portalname{i} = strrep(portalname{i}, '°Æ', '');
    portalname{i} = strrep(portalname{i}, '.', '');
    portalname{i} = strrep(portalname{i}, '©y', '');
    portalname{i} = strrep(portalname{i}, '{', '');
    portalname{i} = strrep(portalname{i}, '}', '');
    portalname{i} = strrep(portalname{i}, '-', '');
    portalname{i} = strrep(portalname{i}, '[', '');
    portalname{i} = strrep(portalname{i}, ']', '');
    portalname{i} = strrep(portalname{i}, '°æ', '');
    portalname{i} = strrep(portalname{i}, '(', '');
    portalname{i} = strrep(portalname{i}, '°≤', '');
    portalname{i} = strrep(portalname{i}, '°≥', '');
    portalname{i} = strrep(portalname{i}, ')', '');
    portalname{i} = strrep(portalname{i}, '£®', '');
    portalname{i} = strrep(portalname{i}, '£©', '');
    portalname{i} = strrep(portalname{i}, '°Ω', '');
    portalname{i} = strrep(portalname{i}, '®A', '');
    portalname{i} = strrep(portalname{i}, ',', '');
    portalname{i} = strrep(portalname{i}, '£¨', '');
    portalname{i} = strrep(portalname{i}, '!', '');
    portalname{i} = strrep(portalname{i}, '£°', '');
    portalname{i} = strrep(portalname{i}, '£ø', '');
    portalname{i} = strrep(portalname{i}, '?', '');
    portalname{i} = strrep(portalname{i}, 'Î‰', '‘∫');
    
end

% if accidentally some recognized portal names are empty, delete them.
for i=1:length(portalname)
    if isempty(portalname{i})==1
        portalname(i)=[];
        keynum(i)=[];
    end
end

% delete consecutive same portal names because they might be the same
% portal but different frame
i=1;
while i<=length(keynum)-1
    if sum(ismember(portalname{i+1},portalname{i}))/length(portalname{i+1})==1
        portalname(i)=[];
        keynum(i)=[];
        i=1;
        continue
    end
    i=i+1;
end

% find unique portal names
[C,IA,IC] = unique(portalname,'stable');
[C1,IA1,IC1] = unique(portalname); % sorted version

% and associated their key numbers
uniquekeynum=keynum(IA);
uniquekeynum1=keynum(IA1);

% handle those keys stored in different places
for i=1:length(C)
    if sum(strcmp(C{i},portalname))>1 % if one portal name appears several times
        C{i,2}=sum(keynum(strcmp(C{i},portalname))); % do summation
    else
        C{i,2}=uniquekeynum(i);
    end
end

for i=1:length(C1)
    if sum(strcmp(C1{i},portalname))>1
        C1{i,2}=sum(keynum(strcmp(C1{i},portalname)));
    else
        C1{i,2}=uniquekeynum1(i);
    end
end

% output to file
xlswrite([outputfolder,fname],C,1,'A1');
xlswrite([outputfolder,fname],C1,1,'C1');