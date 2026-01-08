abram_install()

%% GROUND TRUTH
% FC21A0002962_11198033947F1H.FIT
imgReal = imread('dawn_gt.png');

%% ABRAM RENDER
rend = abram.render('call_validation_dawn.yml');
imgAbram = rend.img;
imgAbram8bit = digital2digital(imgAbram, 14, 8);

%% POST-PRO

figure()
subplot(1,2,1)
imshow(imgReal);
title('REAL')
colorbar
subplot(1,2,2)
imshow(imgAbram8bit);
title('ABRAM')
colorbar

%% SSIM
[LCS, L, C, S] = ssim_comparison(imgReal, imgAbram8bit, 4, true, true, 8);
