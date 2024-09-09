function L_ssimval = ssim_comparison(img, img_ref, noise_level, flag_ncc)

img_ref(img_ref<noise_level) = 0;

if ~flag_ncc
L_ssimval = ssim(img, img_ref);
[L_ssimval, L_ssimmap] = ssim(img, img_ref, 'exponents',[1 0 0]);
[C_ssimval, C_ssimmap] = ssim(img, img_ref, 'exponents',[0 1 0]);
[S_ssimval, S_ssimmap] = ssim(img, img_ref, 'exponents',[0 0 1]);

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

else
% ALIGN IMAGES
% Compute Normalized Cross-Correlation
nccMatrix = normxcorr2(img, img_ref);

% Find the peak of NCC
[maxNccValue, maxIndex] = max(abs(nccMatrix(:)));
[ypeak, xpeak] = ind2sub(size(nccMatrix), maxIndex);

% Determine the offset
offsetY = ypeak - size(img, 1);
offsetX = xpeak - size(img, 2);

% Align the second image
img_abram_translate = imtranslate(img, [offsetX, offsetY]);

% REPERFORM SSIM
% figure(), 
% subplot(1,2,1)
% imshow(img_abram_translate)
% subplot(1,2,2)
% imshow(img_ref)

[L_ssimval, L_ssimmap] = ssim(img_abram_translate, img_ref, 'exponents',[1 0 0]);
[C_ssimval, C_ssimmap] = ssim(img_abram_translate, img_ref, 'exponents',[0 1 0]);
[S_ssimval, S_ssimmap] = ssim(img_abram_translate, img_ref, 'exponents',[0 0 1]);

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

end

end