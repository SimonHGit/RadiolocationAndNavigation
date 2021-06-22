close all
clear 
clc

%% settings


%% load files 
directory = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';

load( [directory 'settings.mat'] ) %
load( [directory 'trackingResults.mat'] ) %
sig = trackResults.I_P;



gpsr = GPSReceiver([],[],[]);




%% logic stream
% bitStream = gpsr.processBitStream(I_P);


    flips = abs(diff(sig));     %logic changes
    firstFlip = find(flips>4e3,1);
    nIntgrSampl = 20;
    %get first and last sample
    iStart = mod(firstFlip,nIntgrSampl);
    iStop = floor((length(sig)-iStart)/nIntgrSampl)*nIntgrSampl+iStart-1;
    sig = sig(iStart:iStop);
    integrated = reshape(sig,[nIntgrSampl, length(sig)/nIntgrSampl]);
    integrated = sum(integrated,1);

    bitStream = integrated;
    bitStream(bitStream>0)=1;
    bitStream(bitStream<=0)=-1;

%% präambel position
pattern = [1 -1 -1 -1 1 -1 1 1 ];

[ correlated , lag ] = xcorr( bitStream, pattern );
bitStream = bitStream==1;
%find pattern matches
[ ~ , subFrameIndx ] = findpeaks( correlated, lag, 'MinPeakHeight', 7);
%compute distance to each matching
Distance = subFrameIndx' - subFrameIndx;
%get matches with distance of 300 bit
[~,c1] = find( Distance == 300 );
[~,c2] = find( Distance == -300 , 1, 'last');
subframeIndx = subFrameIndx( [c1; c2] ) + 1;

%plot( lag, abs(correlated), subframeID, 7*ones(size(subframeID)),'+')



%% dekodieren
for iFrame = 1
    eph = struct();
    for iSubframe = 1:6
       %1-3 Ephimerides
       %4 - Ionosphaere, Timecorrection, Almanach(prn>=25)
       %5 - Almanach(prn<25)
       d = bitStream( (iFrame-1)*1500 + subframeIndx(iSubframe):(subframeIndx(iSubframe+1)-1)   );
       
       %TLM telemetry word
       paeamble = d(1:8);
       D30 = d([30:30:270]);
       D = xor(d,[repelem([false D30],30)]);
       
       %HOW hand over word
       %how.TOW_CM          = D(31:47);  %tow-count message (truncated)
       %how.momentumFlag    = D(48);
       %how.syncronisationFlag = D(49);
       how.subFrameID = logical2dec(D(50:52));
       %how.parityStuff = stream(23); 
       how.Parity = D(55:60);
       switch how.subFrameID
          case 1
              eph.WeekNo        = logical2dec( D( 61:70 )            );
              eph.satHealth     = logical2dec( D( 77:82 )            );
              eph.IODC          = logical2dec( D( [83:84 211:218])   );
              eph.T_GD          = logical2dec( D( 197:204 )          ) * 2^-31; 
              eph.t_OC          = logical2dec( D( 219:234 )          ) * 2^4;
              eph.a_f2          = logical2dec( D( 241:248 )          ) * 2^-55;
              eph.a_f1          = logical2dec( D( 249:264 )          ) * 2^-43;
              eph.a_f0          = logical2dec( D( 271:292 )          ) * 2^-31;
          case 2 
              eph.IODE      = logical2dec( D( 61:68 )            ); %??????????????????
              eph.crs       = logical2dec( D(  69:84 )           ) * 2^-15;
              eph.deltan    = logical2dec( D( 91:106 )           ) * 2^-43;   
              eph.M0        = logical2dec( D( [107:114 121:144] )) * 2^-31;
              eph.cuc       = logical2dec( D( 151:166 )          ) * 2^-29;
              eph.ecc       = logical2dec( D( [167:174 181:204] )) * 2^-33;
              eph.cus       = logical2dec( D( 211:226 )          ) * 2^-29;
              eph.roota     = logical2dec( D( [227:234 241:264] )) * 2^-19;
              eph.toe       = logical2dec( D( 271:286 )          ) * 2^4;
          case 3 
              eph.cic       = logical2dec( D( 61:86 )            ) * 2^-29;
              eph.Omega0    = logical2dec( D( [77:84 91:114] )   ) * 2^-31;
              eph.cis       = logical2dec( D( 121:136 )          ) * 2^-29;
              eph.i0        = logical2dec( D( [137:144 151:174] )) * 2^-31;
              eph.crc       = logical2dec( D( 181:196 )          ) * 2^-5;
              eph.omega     = logical2dec( D( [197:204 211:234] )) * 2^-31;
              eph.Omegadot  = logical2dec( D( 241:264 )          ) * 2^-43;
              eph.IODE      = logical2dec( D( 271:278 ));%??????????????????
              eph.idot      = logical2dec( D( 279:292 )          ) * 2^-43;
          case 4
          case 5
          otherwise
       end
    end
    Frames(iFrame) = struct('how',how,'eph',eph);
end

