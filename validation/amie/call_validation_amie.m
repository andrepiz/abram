clear
clc
close all

%% ADD PATHS
user_name = 'andpi';
abram_path = ['C:\Users\',user_name,'\OneDrive - Politecnico di Milano\03_PhD\06_Work\3_Radiometric Model\abram'];
addpath(genpath(abram_path));

init();

%% AMIE
imgfile_path = fullfile(img_path,'AMI_EE3_040819_00208_00030.IMG'); % Working
%imgfile_path = fullfile(img_path,'04-10-28\AMI_EE3_041028_00268_00030.IMG');
%imgfile_path = fullfile(img_path,'04-11-11\AMI_EE3_041111_00070_00018.IMG'); % Working
%imgfile_path = fullfile(img_path,'test\AMI_EE3_040819_00169_00010.IMG'); % Working

% imgfile_path = fullfile(img_path,'04-11-11\AMI_EE3_041111_00008_00040.IMG');
% imgfile_path = fullfile(img_path,'04-10-28\AMI_EE3_041028_00268_00030.IMG');
[params, label, bimg, img_real] = extract_IMG(imgfile_path, metakernel_path, true);

%% ABRAM
inputs_validation_amie();
run_model();

%% POSTPRO
postpro_validation_amie();