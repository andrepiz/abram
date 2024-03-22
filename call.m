clear
clc
close all

user_name = 'andpi';
abram_path = ['C:\Users\',user_name,'\OneDrive - Politecnico di Milano\03_PhD\06_Work\3_Radiometric Model\abram'];
addpath(genpath(abram_path));

%% INPUTS
inputs();

%% MODEL
run_model();

%% POSTPRO
postpro();