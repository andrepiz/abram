function [img_diff_normalized, img_diff, err_diff_normalized, err_diff] = ...
    diff_images(img1, img2)

% img1(img1<=1) = 0;
% img2(img2<=1) = 0;

img_diff_normalized = abs(double(img1)/max(double(img1),[],'all') - double(img2)/max(double(img2),[],'all'));
img_diff = imabsdiff(img1, img2);

err_diff_normalized = norm(double(img_diff_normalized));
err_diff = norm(double(img_diff));

end