function [] = saveFigAs(fh, fileType, saveFolder, flag_high_quality, flag_single_f, flag_overwrite)

    figureName  = get(fh,'Name');
        
    if(~isempty(figureName))
        nameofFile  = figureName;
    else
        nameofFile  = num2str(fh.Number);
    end
    
    if(~isempty(nameofFile))
        ixDiv       = findstr(nameofFile,'/');
        nameofFile(ixDiv) = '%';
        ixDiv       = findstr(nameofFile,':');
        nameofFile(ixDiv) = '-';
        ixDiv       = findstr(nameofFile,'\');
        nameofFile(ixDiv) = '&';
        ixDiv       = findstr(nameofFile,'[');
        nameofFile(ixDiv) = '-';
        ixDiv       = findstr(nameofFile,']');
        nameofFile(ixDiv) = '-';
        ixDiv       = findstr(nameofFile,'*');
        nameofFile(ixDiv) = 'x';

        if(exist(saveFolder,'dir') ~= 7)
            mkdir(saveFolder);
        end

        switch fileType
            case {'FIG','fig','Fig'}
                fileName = [saveFolder nameofFile];
            case {'EMF','emf','Emf'}
                fileName = [saveFolder nameofFile];
            case {'PNG','png','Png'}
                fileName = [saveFolder nameofFile];
            case {'fig_png','Fig_Png','FIG_PNG'}
                fileName_1 = [saveFolder nameofFile];
                fileName_2 = [saveFolder nameofFile];
            otherwise 
                error('Unexpected filetype - Use "fig", "emf", "png" or "fig_png"')
        end

        switch fileType
            case {'FIG','fig','Fig'}
                file_with_ext   = [fileName '.fig'];
                flag_single_f = 1;
            case {'EMF','emf','Emf'}
                file_with_ext   = [fileName '.emf'];
                flag_single_f = 1;
            case {'PNG','png','Png'}
                file_with_ext   = [fileName '.png'];
                flag_single_f = 1;
            case {'fig_png','Fig_Png','FIG_PNG'}
                file_with_ext_1 = [fileName_1 '.fig'];
                file_with_ext_2 = [fileName_2 '.png'];
                flag_single_f = 0;
        end

        k           = 2;
        if(flag_overwrite == 0)
            if(flag_single_f == 1)
                while(exist(file_with_ext,'file') == 2)
                    switch fileType
                        case {'FIG','fig','Fig'}
                            file_with_ext   = [fileName '_' sprintf('%2.2d',k) '.fig'];
                        case {'EMF','emf','Emf'}
                            file_with_ext   = [fileName '_' sprintf('%2.2d',k) '.emf'];
                        case {'PNG','png','Png'}
                            file_with_ext   = [fileName '_' sprintf('%2.2d',k) '.png'];
                        case {'PDF','pdf','Pdf'}
                            file_with_ext   = [fileName '_' sprintf('%2.2d',k) '.pdf'];
                    end

                    k = k + 1;
                end
            else
                while(exist(file_with_ext_1,'file') == 2)
                    switch fileType
                        case {'fig_png','Fig_Png','FIG_PNG'}
                            file_with_ext_1   = [fileName_1 '_' sprintf('%2.2d',k) '.fig'];
                            file_with_ext_2   = [fileName_2 '_' sprintf('%2.2d',k) '.png'];
                    end

                    k = k + 1;
                end
            end
        end
        
        if(flag_high_quality == 1)
            % show before saving
            figure(fh)
        end

        switch fileType
            case {'FIG','fig','Fig'}
                savefig(fh,file_with_ext,'compact');
            case {'EMF','emf','Emf'}
                print(fh,'-dmeta',file_with_ext);
            case {'PNG','png','Png'}
                if(flag_high_quality == 1)
                    feval('export_fig','filename',file_with_ext,'-transparent',p.transparent,'-r200',fh);
                else
                    print(fh,'-dpng',file_with_ext);
                end
            case {'fig_png','Fig_Png','FIG_PNG'}
                
                savefig(fh,file_with_ext_1,'compact');
                
                if(flag_high_quality == 1)
                    feval('export_fig','filename',file_with_ext_2,'-transparent',p.transparent,'-r200',fh);
                else
                    print(fh,'-dpng',file_with_ext_2);
                end

            case {'pdf','PDF'}
                exportgraphics(fh, file_with_ext, "ContentType","vector")
        end

    end
end
    