addpath('results')

%%
img_abram = imread('AMI_EE3_040819_00208_00030_ABRAM.png');
img_amie = imread('AMI_EE3_040819_00208_00030_AMIE.png');
img_amie(img_amie<14) = 0;
% img_abram = imread('AMI_EE3_041111_00070_00018_ABRAM.png');
% img_amie = imread('AMI_EE3_041111_00070_00018_AMIE.png');
% img_amie(img_amie<20) = 0;

L_ssimval = ssim(img_abram, img_amie)
[L_ssimval, L_ssimmap] = ssim(img_abram, img_amie, 'exponents',[1 0 0]);
[C_ssimval, C_ssimmap] = ssim(img_abram, img_amie, 'exponents',[0 1 0]);
[S_ssimval, S_ssimmap] = ssim(img_abram, img_amie, 'exponents',[0 0 1]);

figure()
subplot(1,3,1)
imshow(L_ssimmap)
title(['Luminance ', num2str(L_ssimval)])
subplot(1,3,2)
imshow(C_ssimmap)
title(['Contrast ', num2str(C_ssimval)])
subplot(1,3,3)
imshow(S_ssimmap)
title(['Structure ', num2str(S_ssimval)])

%% ALIGN IMAGES
% Compute Normalized Cross-Correlation
nccMatrix = normxcorr2(img_abram, img_amie);

% Find the peak of NCC
[maxNccValue, maxIndex] = max(abs(nccMatrix(:)));
[ypeak, xpeak] = ind2sub(size(nccMatrix), maxIndex);

% Determine the offset
offsetY = ypeak - size(img_abram, 1);
offsetX = xpeak - size(img_abram, 2);

% Align the second image
img_abram_translate = imtranslate(img_abram, [offsetX, offsetY]);

%% REPERFORM SSIM
figure(), 
subplot(1,2,1)
imshow(img_abram_translate)
subplot(1,2,2)
imshow(img_amie)

[L_ssimval, L_ssimmap] = ssim(img_abram_translate, img_amie, 'exponents',[1 0 0]);
[C_ssimval, C_ssimmap] = ssim(img_abram_translate, img_amie, 'exponents',[0 1 0]);
[S_ssimval, S_ssimmap] = ssim(img_abram_translate, img_amie, 'exponents',[0 0 1]);

figure()
subplot(1,3,1)
imshow(L_ssimmap)
title(['Luminance ', num2str(L_ssimval)])
subplot(1,3,2)
imshow(C_ssimmap)
title(['Contrast ', num2str(C_ssimval)])
subplot(1,3,3)
imshow(S_ssimmap)
title(['Structure ', num2str(S_ssimval)])