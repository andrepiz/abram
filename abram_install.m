%% ABRAM INSTALLATION %%

% MATLAB environment
clear
close all

if isfile("abram_install.m")
    % SAVE INSTALL TO PATH
    copyfile("abram_install.m",userpath)
    % SAVE PATH TREE
    writelines(["function abram_home_path = abram_home()",join(["abram_home_path = '",pwd,"';"],''),"end"],'abram_home.m')
    movefile('abram_home.m',userpath)
end

% Path
addpath(genpath(abram_home))
rmpath(genpath(fullfile(abram_home,'debug')))

% DISPLAY
fprintf(['*** ABRAM 1.5 installed. Have fun! ***\n'])
