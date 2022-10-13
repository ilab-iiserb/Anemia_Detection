clc;    
close all;  
imtool close all;  
clear;  
workspace;  
format long g;
format compact;
fontSize = 26;
%===============================================================================

%Upload image
[rgbImage, map] = imread("(Upload_image_here).jpg");

% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(rgbImage);
Image = imresize(rgbImage, [500 500]);

% If it's RGB instead of grayscale, convert it to gray scale.
if numberOfColorBands > 1
	grayImage = Image(:, :, 1); % Take red channel.
else
	grayImage = Image;
end

% Display the original image.
subplot(2, 3, 1);
imshow(grayImage, []);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Arial','fontsize',18)
axis on;

% Enlarge figure to full screen.
g = gcf;
g.WindowState = 'maximized';
g.NumberTitle = 'off';
g.Name = 'Histogram Analysis';
drawnow;

%===============================================================================

% Display the histogram and perform thresholding
subplot(2, 3, 2);
[pixelCounts, grayLevels] = imhist(grayImage);
bar(grayLevels, pixelCounts);
grid on;
title('Original Gray Scale Image Histogram', 'FontSize', fontSize);
xlabel('Gray Level', 'FontSize', fontSize);
ylabel('Pixel Count', 'FontSize', fontSize);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Arial','fontsize',18)
level = graythresh(grayImage);

% Get a binary image
mask = grayImage > 240;
% Get rid of white surround.
mask = imclearborder(mask);

% Display the binary mask image.
subplot(2, 3, 3);
imshow(mask, []);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Arial','fontsize',18)
axis on;
minBlobSize = 50;

% Watershed algorithm
D = bwdist(mask);
L = watershed(mask);         	% Performed on distance transform image
L(mask) = 0;					%Performed on binary image
bw2 = ~bwareaopen(mask, 10); 
D = -bwdist(mask);
Ld = watershed(D);
bw = bw2;
bw2(Ld == 0) = 0;
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;

% Get rid of blobs less than that many pixels in area.
mask = bwareaopen(mask, minBlobSize);

% Display the binary mask image.
subplot(2, 3, 4);
imshow(mask, []);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Arial','fontsize',18)
axis on;

% Find out the areas
props = regionprops(mask, 'Area');
allAreas = sort([props.Area], 'ascend');

% Show distribution of areas:
subplot(2, 3, 5:6);
histogram(allAreas);
total = histcounts(allAreas);
xlabel('Area in Pixels', 'FontSize', fontSize);
ylabel('Blob Count', 'FontSize', fontSize); 
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Arial','fontsize',18)
grid on;
blobs = histcounts(allAreas);
total_blobs = sum(blobs);
if total_blobs > 5
    fprintf("Anemia probability = HIGH");
else
    fprintf("Anemia probability = LOW");
end
