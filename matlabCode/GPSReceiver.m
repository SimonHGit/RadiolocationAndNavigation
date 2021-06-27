classdef GPSReceiver
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties 
        fs      % sample rate
        fca     % CA-code Frequency
        fif     % intermediate frequency
        
        
        ca_fca  % CA-code in CA-code Frequency
        ca_fs   % CA-code in sample rate
        
        signal  %
        corrTHD     = 1.5e9;
        checkPrns   = 1:37;
        fvec
        tau
        
        SS      % correlation (freq, ca, prn)
        visiblePRN 
        codeshift
        doppler
        
        
        preamble = [1 -1 -1 -1 1 -1 1 1 ]; %
        ephimeris 
        Frames
        
    end
    
    methods
        function obj = GPSReceiver(fs,fca,fif)
            fprintf('->construct <strong> GPSReceiver</strong>-object\n')
            obj.fs = fs;
            obj.fca = fca;
            obj.fif = fif;
        end
        
        function obj = resampleCaCode(obj)
            fprintf( '->resample CA Codes from %.2d to %.2d MHz\n',...
                     obj.fca*1e-6 , obj.fs*1e-6 )
                 
            for cc = 1:size(obj.ca_fca,1)
                X(cc,:) = rsmp( obj.ca_fca(cc,:) , obj.fca , obj.fs );
            end
            obj.ca_fs = X;
        end
        
        function obj = acquire(obj, sig)
            fprintf( '->Acquisition of %i space vehicles\n',...
                     length(obj.checkPrns))
             
            fvec = obj.fvec;
            fs = obj.fs;
            prns = obj.checkPrns;
            ca = obj.ca_fs;
            nSamples = length(sig);
            t = ( 1:nSamples ) / fs ;
            obj.tau = ((-nSamples/2+1):nSamples/2)/fs;
            nPrns = size(ca,1);
            
            % correlate
            if size(ca,2)<length(sig)
                %ca = [ca zeros(nPrns,length(sig)-size(ca,2))];
                ca = repmat(ca,1,length(sig)/size(ca,2));
            end
            SS = zeros(length(fvec),length(sig),nPrns);            %SignalStrength
            
            
            for ff = 1:length(fvec)
                mixedSignal = sig(:).' .* exp(-1j * 2* pi * fvec(ff) .* t );
                IN  = fft( mixedSignal);
                CA  = fft( ca( prns, : ) ,[],2);
                OUT = IN .* conj(CA);
                for sv = 1:nPrns
                    SS( ff, :, sv ) = abs( ifft( OUT( sv, : ) , [], 2 ) ) .^ 2;
                end
            end
            
            corrTHD = obj.corrTHD;
            visiblePRN =[];
            codeshift =[];
            doppler =[];
            
            for sv = prns
                [ peak(sv) pindx(1,1:2,sv) ] = findmax( SS(:,:,sv) );
                if peak(sv) > corrTHD
                    visiblePRN  = [visiblePRN; sv];
                    codeshift   = [codeshift; (pindx(1,2,sv)-nSamples)/2/fs];
                    doppler     = [doppler; fvec(pindx(1,1,sv))];
                end
            end
                
            obj.SS          = SS;
            obj.visiblePRN  = visiblePRN;
            obj.codeshift   = codeshift;
            obj.doppler     = doppler;
            
            
        end
        
        function t = visibleSVs(obj)
           t =  table( obj.visiblePRN , obj.codeshift , obj.doppler ,...
               'VariableNames',{'visiblePRN','codeshift','doppler'});
        end
        
        function plotAmbiguity( obj, prnToPlot )
            fprintf('-> visiualize %i abiguity-functions\n' , length(prnToPlot))
            f = repmat(obj.fvec'/1e6,1,length(obj.tau));
            tau = repmat( obj.tau, length(obj.fvec), 1 );
            for sv = prnToPlot(:)'
                figure( 100 + sv );
                surf( f , tau, obj.SS( :, :, sv ), 'EdgeColor', 'none' )
                xlabel( 'f in MHz'  )
                ylabel( '\tau in s' )
                zlabel( '\rho_{xy}' )
                title(sprintf('prn %i',sv)) 
            end
        end
        
        function bitStream = processBitStream(obj,I_P)
            flips = abs(diff(I_P));     %logic changes
            firstFlip = find(flips > 4e3,1);
            nIntgrSampl = 20;
            %get first and last sample
            iStart = mod(firstFlip,nIntgrSampl);
            iStop = floor((length(I_P)-iStart)/nIntgrSampl)*nIntgrSampl+iStart-1;
            I_P = I_P(iStart:iStop);
            integrated = reshape(I_P,[nIntgrSampl, length(I_P)/nIntgrSampl]);
            integrated = sum(integrated,1);

            bitStream_integr = integrated;
            bitStream(bitStream_integr>0)  = true;
            bitStream(bitStream_integr<=0) = false;
        end
        
        function subframeIndx = getPreamblePos(obj,bitStream_bool)
            bitStream_signum = 1*bitStream_bool - 1*~bitStream_bool;
            [ correlated , lag ] = xcorr(bitStream_signum , obj.preamble );
            %find pattern matches
            [ ~ , subFrameIndx ] = findpeaks( correlated, lag, 'MinPeakHeight', 7);
            %compute distance to each matching
            Distance = subFrameIndx' - subFrameIndx;
            %get matches with distance of 300 bit
            [~,c1] = find( Distance == 300 );
            [~,c2] = find( Distance == -300 , 1, 'last');
            subframeIndx = subFrameIndx( [c1; c2] ) + 1;
        end
        
        function obj = decode(obj,bitStream_bool,subframeIndx)
            for iFrame = 1
                eph = struct();
                for iSubframe = 1:6
                   %1-3 Ephimerides
                   %4 - Ionosphaere, Timecorrection, Almanach(prn>=25)
                   %5 - Almanach(prn<25)
                   d = bitStream_bool( (iFrame-1)*1500 + subframeIndx(iSubframe):(subframeIndx(iSubframe+1)-1)   );

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
                %Frames(iFrame) = struct('how',how,'eph',eph);
                obj.ephimeris = eph;
            end
        end
        
        
        
        
        % set methods
        function obj = set.fs(obj,x)
            obj.fs = x;
        end
        function obj = set.fca(obj,x)
            obj.fca = x;
        end
        function obj = set.fif(obj,x)
            obj.fif = x;
        end
        function obj = set.ca_fca(obj,caCodesLUT)
            obj.ca_fca = caCodesLUT;
        end
        function obj = set.ca_fs(obj,x)
            obj.ca_fs = x;
        end
        function obj = set.signal(obj,x)
            obj.signal = x;
        end
        function obj = set.fvec(obj,x)
            obj.fvec = x;
        end
        function obj = set.tau(obj,x)
            obj.tau = x;
        end
        function obj = set.SS(obj,x)
            obj.SS = x;
        end
        function obj = set.visiblePRN(obj,x)
            obj.visiblePRN = x;
        end
        function obj = set.codeshift(obj,x)
            obj.codeshift = x;
        end
        function obj = set.doppler(obj,x)
            obj.doppler = x;
        end
        function obj = set.ephimeris(obj,x)
            obj.ephimeris = x;
        end
    end
    
end

