function img_digital_out = digital2digital(img_digital_in, nbit_in, nbit_out)
% Resample a digital image with depth nbit_in into a digital image of
% depth nbit_out
%
% 16-bit represents 65,536 different shades or distinct numbers 
% 8-bit represents 256 different colors or distinct numbers
% 

img_digital_out = double(img_digital_in)/(2^nbit_in-1)*(2^nbit_out-1);

switch nbit_out
    case 8
        img_digital_out = uint8(img_digital_out);
    case 16
        img_digital_out = uint16(img_digital_out);
    case 32
        img_digital_out = uint32(img_digital_out);
    otherwise
        img_digital_out = round(img_digital_out);
        nbit_out_new = 8*ceil(nbit_out/8);
        warning([num2str(nbit_out) '-bit image not allowed, image will be saved in ',num2str(nbit_out_new),'-bit'])
        img_digital_out = digital2digital(img_digital_out, nbit_in, nbit_out_new);
end

end
