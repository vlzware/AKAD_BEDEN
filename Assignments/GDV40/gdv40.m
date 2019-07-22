clc; clear; close all;
cd '/MATLAB Drive'/GDV40/;

img1 = imread('bild1.tiff');
img2 = imread('bild2.tiff');
img1 = img1(:,:,1:3);
img2 = img2(:,:,1:3);
img1_g = rgb2gray(img1);
img2_g = rgb2gray(img2);
img1_gd = im2double(img1_g);
img2_gd = im2double(img2_g);

img_width = 640;
img_height = 480;
all_pixels = img_width * img_height;

%histograms
figure;
all_hist(img1_gd, all_pixels);
title('img1');

figure;
all_hist(img2_gd, all_pixels);
title('img2');
img1_reworked = imadjust(img1_gd, [140/255 255/255], [255/255 0/255], 0.0001);

figure;
imshow(img1_reworked, []);
title('img1 reworked');

figure;
all_hist(img1_reworked, all_pixels);
title('img1 reworked');

%noise removal
h = ones(3,3)/9;
lap_iso = [1 2 1; 2 -12 2; 1 2 1] / 4;

img2_mean = imfilter(img2_g, h);
img2_gauss = imgaussfilt(img2_g, 1.5);
img2_min = ordfilt2(img2_g, 1, ones(3,3));
img2_max = ordfilt2(img2_g, 9, ones(3,3));
img2_minmax = ordfilt2(img2_min, 9, ones(3,3));
img2_med = medfilt2(img2_g);    % same as: ordfilt2(img2_g, 5, ones(3,3));
img2_lap = imfilter(img2_med, lap_iso);

%enhance
img2_sub = imsubtract(img2_med, img2_lap);
shift = 1; scale = 150;
img2_div = uint8(imdivide(im2double(img2_med), im2double(img2_lap) + 1) * scale);

%show all
figure;
imshow(img2_gd, []);
title('Original');

figure;
imshow(img2_mean, []);
title('Mean value');

figure;
imshow(img2_gauss, []);
title('Gauss filter with sigma = 1.5');

figure;
imshow(img2_min, []);
title('Minimum filter');

figure;
imshow(img2_max, []);
title('Maximum filter');

figure;
imshow(img2_minmax, []);
title('Minimum + maximum filter');

figure;
imshow(img2_med, []);
title('Median filter');

figure;
imshow(img2_lap, []);
title('Laplace over Median filter');

figure;
imshow(img2_sub, []);
title('Enhanced through subtraction');

figure;
imshow(img2_div, []);
title('Enhanced through division');

function all_hist(myimg, all_pixels)
    imh = imhist(myimg);
    cdf1 = cumsum(imh);
    hold on
    
    h_max = max(imh/all_pixels);
    axis([0 256 0 h_max]);
    rectangle('Position', [0 0 256 h_max]);
    xticks([0:30:240 255]);
    yticks([]);
    
    %plot logarithmic histogram:
    area(log(imh) * h_max/ log(max(imh)), 'FaceAlpha', 0.5, 'LineWidth', 1);
    
    %plot normalised histogram:
    area(imh/all_pixels, 'FaceAlpha', 0.5, 'LineWidth', 1);
    
    %plot cumulative histogram:
    plot(cdf1 * h_max/all_pixels, 'LineWidth', 2);
    %p3.Color(4) = 0.8;
    
    hold off;
end

%{
function m_img = img_norm(img)
    m_img = (uint8(mat2gray(img) * 255));
end
%}