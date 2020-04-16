function OUT = PlaqueDetect(IMGname)

% this function automatically detects plaques from a 4x histological image
% NOTE: depending on staining methods and image resolution, the parameters need to be adjusted. 

close all;

%% key parameters
params.sens = 2.8; % a parameter for threshold
params.med = 9; % a parameter for median filter
params.min = 24; % a parameter for particle size filter (lower threshold)

%% STEP1: loading an original image
I1 = imread(IMGname); 

figure;
subplot(2,4,1); 
imshow(I1); 
title('original');

%% STEP2: determining threshold
M = median(double(I1(:)));
Error = mad(double(I1(:)),0); 
Thre = M + params.sens*Error; 

%% displaying intensity histogram and the threshold
n = hist(I1(:), 0:255);
subplot(2,4,2:4);
bar(0:255, n, 'k');hold on;
plot(M*ones(2,1), [0, max(n)], 'r:');
plot(Thre*ones(2,1), [0, max(n)], 'r:');hold off;
box off;
xlabel('int'); ylabel('# of pixels');

%% STEP3: creating a binary image after thresholding
I2 = I1;
I2(I2 >= Thre) = 255;
I2(I2 < Thre) = 0;

subplot(245);
imshow(I2);
title('binary');

%% STEP4: filtering (median filter to get rid of noisy signals)
I3 = medfilt2(I2, params.med*ones(1,2)); 
subplot(246);
imshow(I3);
title('filtered');

%% STEP5: additional filtering (particle size filter)
I4 = xor(bwareaopen(I3, 150), bwareaopen(I3, params.min)); 
subplot(247);
imshow(I4);
title('final');

%% STEP6: counting plaques
[B,~] = bwboundaries(I4,'noholes');

subplot(248);
imshow(I1); hold on % overlaying on the original image
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1); % appears as red
end
hold off;
title(['counted:', num2str(length(B))]);

%% output
OUT.count = length(B);
OUT.thre = Thre;
OUT.size = size(I1);
OUT.name = IMGname;
