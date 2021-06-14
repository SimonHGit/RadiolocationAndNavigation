function [] = saveNavData(ephimerides, dir)
    for indx = 1:length(ephimerides)
       eph = ephimerides(indx);
       phc_c = struct2cell(eph);
       T = table(fieldnames(eph),phc_c,'VariableNames',{'Paramname','val'});
       writetable(T,[dir 'navdata_' num2str(indx) '.txt'],'Delimiter',' ');
    end
end