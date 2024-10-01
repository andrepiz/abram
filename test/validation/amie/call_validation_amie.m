abram_install();

%% AMIE EXTRACTOR
% Note: change path to yours in init.m and metakernel.tm
init();

% img_name = 'AMI_EE3_040819_00208_00030.IMG'; noise_level = 57; % Working 
img_name = 'AMI_EE3_041111_00070_00018.IMG'; noise_level = 72; % Working
% img_name = 'AMI_EE3_040819_00169_00010.IMG'; noise_level = 41; % Working
%img_name = 'AMI_EE3_041028_00269_00005.IMG'; noise_level = 116; % Working
%img_name = 'AMI_EE3_041111_00008_00040.IMG';
% img_name = 'AMI_EE3_040504_00038_00020.IMG';
imgfile_path = fullfile(img_path, img_name); 

mfbias_path = 'mf\mfbias.mat';
mfdc_path = 'mf\mfdc.mat';

[params, label, bimg_real] = extract_IMG(imgfile_path, metakernel_path, false);
[img_real, img_real_corrected, EC_real, EC_real_corrected] = correct_IMG(imgfile_path, metakernel_path, mfbias_path, mfdc_path, false);

%% ABRAM
flag_displacement = true;
flag_normal = true;

inputs_validation_amie();
run_model();

%% POSTPRO
postpro_validation_amie();