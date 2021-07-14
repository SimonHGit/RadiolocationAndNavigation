function Obs = grabdata(fid, NoSv, NoObs)
%GRABDATA Positioned in a RINEX file at a selected epoch
%  	    reads observations of NoSv satellites

%Kai Borre 09-13-96
%Copyright (c) by Kai Borre
%$Revision: 1.0 $  $Date: 1997/09/23  $

global lin

Obs = zeros(NoSv-1, NoObs);

if NoObs <= 1	  % This will typical be Turbo SII data
    for u = 1:NoSv
        lin = fgetl(fid);
        for k = 1:NoObs
            Obs(u,k) = str2num(lin(2+16*(k-1):16*k-2));
        end
    end
else		        % This will typical be Z12 data
    Obs = Obs(:,[1 2 3]); % We cancel the last two columns 6 and 7
    for u = 1:NoSv
        lin = fgetl(fid);
        lin_doppler = fgetl(fid);
        for k = 1:NoObs
            if isempty(str2num(lin(1+16*(k-1):16*k-2))) == 1
                Obs(u,k) = nan;
            else
                Obs(u,k) = str2num(lin(1+16*(k-1):16*k-2));
            end
            % Obs(u,NoObs) = str2num(lin(65:78));
        end
    end
end
%%%%%%%%% end grabdata.m %%%%%%%%%
