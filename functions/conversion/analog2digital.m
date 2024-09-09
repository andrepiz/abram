function img_digital = analog2digital(img_analog, G_AD, nbit_in, nbit_out)
% Transform an analog image (number of electrons) into a digital image of 
% depth nbit_out, using the analog-to-digital gain G_AD referred to numbers
% of depth nbit_in
%
% 16-bit represents 65,536 different shades or distinct numbers (0-65535)
% 12-bit represents 4,096 different colors or distinct numbers (0-4096)
% 8-bit represents 256 different colors or distinct numbers (0-255)
% 
% G_AD is expressed in 1/e- (how many electrons make a digital number)

img_digital_temp = img_analog*G_AD/(2^nbit_in-1)*(2^nbit_out-1);
switch nbit_out
    case 8
        img_digital = uint8(img_digital_temp);

    case 12
        warning('No uint12 type present in MATLAB')
        img_digital = round(img_digital_temp);

    case 16
        img_digital = uint16(img_digital_temp);

    case 32
        img_digital = uint32(img_digital_temp);

    otherwise
        img_digital = img_digital_temp;
end