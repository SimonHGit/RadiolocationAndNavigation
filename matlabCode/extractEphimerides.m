function eph = extractEphimerides(data,wFilter)

    ID = [];
    for indx = 1:length(data)
        data(indx).date = datetime( [2e3 + str2num(data(indx).year),...
                                    str2num(data(indx).month),...
                                    str2num(data(indx).day),...
                                    str2num(data(indx).hour),...
                                    str2num(data(indx).minute),...
                                    str2num(data(indx).second)]);
        %check prns
        if any(data(indx).svprn == wFilter.svprns)
            if wFilter.tStart <= data(indx).date & wFilter.tStop > data(indx).date
                wFilter.svprns(data(indx).svprn == wFilter.svprns) = [];
                ID = [ID indx];
            end
        end
    end
    
    eph = data(ID);

end