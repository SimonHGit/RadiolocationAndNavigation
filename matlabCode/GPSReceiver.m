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
            
            tic
            for ff = 1:length(fvec)
                mixedSignal = sig(:).' .* exp(-1j * 2* pi * fvec(ff) .* t );
                IN  = fft( mixedSignal);
                CA  = fft( ca( prns, : ) ,[],2);
                OUT = IN .* conj(CA);
                for sv = 1:nPrns
                    SS( ff, :, sv ) = abs( ifft( OUT( sv, : ) , [], 2 ) ) .^ 2;
                end
            end
            toc
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
    end
    
end

