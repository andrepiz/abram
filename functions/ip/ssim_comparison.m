function [LCS, L, C, S, Limg, Cimg, Simg] = ssim_comparison(img, tmpl, noise_level, flag_apply_ncc, flag_plot)

img(img<noise_level) = 0;

if ~flag_apply_ncc

    LCS = ssim(img, tmpl);
    [L, Limg] = ssim(img, tmpl, 'exponents',[1 0 0]);
    [C, Cimg] = ssim(img, tmpl, 'exponents',[0 1 0]);
    [S, Simg] = ssim(img, tmpl, 'exponents',[0 0 1]);

    img_plot = double(img);
    img_tmpl = double(tmpl);

else

    % ALIGN IMAGES
    % Compute Normalized Cross-Correlation
    nccMatrix = normxcorr2(img, tmpl);
    
    % Find the peak of NCC
    [maxNccValue, maxIndex] = max(abs(nccMatrix(:)));
    [ypeak, xpeak] = ind2sub(size(nccMatrix), maxIndex);
    
    % Determine the offset
    offsetY = ypeak - size(img, 1);
    offsetX = xpeak - size(img, 2);
    
    % Align the image to the template
    imgtrans = imtranslate(img, [offsetX, offsetY]);
    
    LCS = ssim(imgtrans, tmpl);
    [L, Limg] = ssim(imgtrans, tmpl, 'exponents',[1 0 0]);
    [C, Cimg] = ssim(imgtrans, tmpl, 'exponents',[0 1 0]);
    [S, Simg] = ssim(imgtrans, tmpl, 'exponents',[0 0 1]);

    img_plot = double(imgtrans);
    img_tmpl = double(tmpl);

end

if flag_plot

    mask_img = img_plot/max(img_plot,[],'all');
    mask_img(mask_img>0) = uint8(255);
    mask_img = repmat(mask_img, 1, 1, 3);
    mask_img(:,:, 2:3) = 0;

    mask_tmpl = img_tmpl/max(img_tmpl,[],'all');
    mask_tmpl(mask_tmpl>0) = uint8(255);
    mask_tmpl = repmat(mask_tmpl, 1, 1, 3);
    mask_tmpl(:,:, 1:2) = 0;
    
    figure()
    hold on
    fh_img = imshow(mask_img);
    fh_img.AlphaData = 0.2*(double(img_plot)>0);
    hold on
    fh_tmpl = imshow(mask_tmpl);
    fh_tmpl.AlphaData = 0.2*(double(img_tmpl)>0);
    title('Template (B) overlapped over the image (R)')
    
    figure()
    subplot(1,3,1)
    imshow(Limg)
    colorbar
    title(['Luminance ', num2str(L)])
    subplot(1,3,2)
    imshow(Cimg)
    colorbar
    title(['Contrast ', num2str(C)])
    subplot(1,3,3)
    imshow(Simg)
    colorbar
    title(['Structure ', num2str(S)])
end

end