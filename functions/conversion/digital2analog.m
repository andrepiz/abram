function img_analog = digital2analog(img_digital, G_DA, nbit_in, nbit_out)
% Transform a digital image with depth nbit_in into an analog image (number 
% of electrons) using the digital-to-analog gain G_DA referred to numbers of
% depth nbit_out
%
% 16-bit represents 65,536 different shades or distinct numbers 
% 12-bit represents 4,096 different colors or distinct numbers
% 8-bit represents 256 different colors or distinct numbers
% 
% G_DA is expressed in e- (how many digital numbers make an electron)

img_digital_resampled = double(img_digital)/(2^nbit_in-1)*(2^nbit_out-1);
img_analog = img_digital_resampled * G_DA;

end