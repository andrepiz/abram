function printFigureAs(fh, fileType, saveFolder)

if ~exist("fileType","var")
    fileType = 'png';
end

if ~exist("saveFolder","var")
    saveFolder = pwd;
end

switch fileType
    case {'png','fig'}
        cp_install(), cp_save_this_fig(struct('file_type',fileType))
    case 'pdf'
        exportgraphics(fh,fullfile(saveFolder,strcat(fh.Name,".pdf")),"ContentType","vector")
end

end
