%% ABRAM INSTALLATION %%

% MATLAB environment
clear
close all
restoredefaultpath

if ispc
    
    op_sys = 'Windows';

    user_path = userpath;

elseif ismac
    
    op_sys = 'MacOS';

    user_path = userpath;

elseif isunix

    op_sys = 'Linux/UNIX';

    user_path = userpath; 
    if isempty(user_path)
        userpath(fullfile('/home',getenv('USER')))
        user_path = userpath;
    end

else

    error('Unknown operating system. ABRAM can not be installed :(');

end

if isfile("abram_install.m")
    % SAVE INSTALL TO PATH
    if isfile(fullfile(user_path,"abram_install.m"))
        delete(fullfile(user_path,"abram_install.m"))
    end
    copyfile("abram_install.m",user_path)
    % SAVE PATH TREE
    writelines(["function abram_home_path = abram_home()",join(["abram_home_path = '",pwd,"';"],''),"end"],'abram_home.m')
    if isfile(fullfile(user_path,"abram_home.m"))
        delete(fullfile(user_path,"abram_home.m"))
    end
    movefile('abram_home.m',user_path)
end

% Path
addpath(genpath(abram_home()))
if ~isfile(fullfile(abram_home(), "abram_install.m"))
    error('The registered abram path is wrong. Please run again abram_install() from ABRAM main directory')
end

% Remove debug folder from path if it exists
debug_path = fullfile(abram_home(), 'debug');
if isfolder(debug_path)
    rmpath(genpath(debug_path))
end

% DISPLAY
fprintf(['*** ABRAM 1.6 installed in ', op_sys, '. Have fun! ***\n'])