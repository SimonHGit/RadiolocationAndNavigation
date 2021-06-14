close all
clear 
clc


%% einfachen Akquisition
fs  = 16.3676e6;    %sample Frequency
fca = 1.023e6;      %freq CA-Code
fif = 4.1304e6;    %intermediate frequency
t_code = 1e-3;      %length of code
fvec = (-5e3:250:5e3)+fif;

%load codes
dir = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';
f_name = 'GPSL1_LUT.mat' ;
load([dir f_name]) %caCodesLUT
load([dir  'prnOnly.mat']) %sigCode

%CA-Code upsampling
for prnn = 1:size(caCodesLUT,1)
    ca(prnn,:) = rsmp(caCodesLUT(prnn,:),fca,fs);
end

%function out = acquire(CA , timeSignal)

%a) check Phase
    %cross correlate ca code with signal
    [rxy, lag] = xcorr( sigCode , ca(1,:)  );
    lag = lag/fs;
        rxy = rxy.^2;
        rxy = (rxy/max(rxy));
        figure(1)
        plot(lag,rxy)
        xlabel('\tau')
        ylabel('\rho_{xy}')
        %xlim([-1 1]*length(sigCode)/2/fs)
        title('corr in time-domain / s')
%b) speed up by using fft
    IN  = fft(sigCode);
    CA  = fft(ca(1,:),[],2);
    OUT = IN.*conj(CA);
    out = abs(ifft(OUT,[],2)).^2;
        figure(2)
        lag = (1:length(out))/fs;
        plot(lag,out')
        xlabel('\tau')
        ylabel('\rho_{xy}')
        %xlim([-1 1]*length(sigCode)/2/fs)
        title('corr in f-domain')
%c) 
    f_name = 'prnFreqOnly.mat' ;
    load([dir f_name])  %sig
    sig = hilbert(sig);
    t = (1:length(sig))/fs;
    SS = [];            %SignalStrength
    for ff = 1:length(fvec)
        mixedSignal = sig .* exp(-1j * 2* pi * fvec(ff) .* t );
        IN  = fft(mixedSignal);
        CA  = fft(ca(1,:),[],2);
        OUT = IN.*conj(CA);
        SS(ff,:) = sum(abs(ifft(OUT,[],2)).^2,1);
    end
    figure(3);
    surf(repmat(fvec'/1e6,1,length(mixedSignal)),...
        repmat((1:length(mixedSignal))/fs,length(fvec),1),...
        SS,'EdgeColor','none')
    xlabel('f in MHz')
    ylabel('\tau in s')
    zlabel('\rho_{xy}')
    
%% d + e
    fs  = 16e6;         %sample Frequency
    fca = 1.023e6;      %freq CA-Code
    fif = 4e6;          %intermediate frequency
    t_code = 1e-3;      %length of code
    fvec = (-5e3:250:5e3)+fif;
    
    clear ca
    for cc = 1:size(caCodesLUT,1)
        ca(cc,:) = rsmp(caCodesLUT(cc,:),fca,fs);
    end

    f_name = 'rfCplx.mat' ;
    load([dir f_name]); %rfCplx
    sig = rfCplx(1:16e3);
    sigLen = length(mixedSignal);
    t = (1:sigLen)/fs;
    
    SS = [];            %SignalStrength
    for ff = 1:length(fvec)
        mixedSignal = sig .* exp(1j * 2* pi * fvec(ff) .* t );
        IN  = fft(mixedSignal);
        CA  = fft(ca,[],2);
        OUT = IN.*conj(CA);
        for sv = 1:size(CA,1)
            SS(ff,:,sv) = abs(ifft(OUT(sv,:),[],2)).^2;
        end
    end
    
    corrTHD = 1.5e9;
    visiblePRN =[];
    codeshift =[];
    doppler =[];
    for prnn = 1:37
        [peak(prnn) pindx(1,1:2,prnn)] = findmax(SS(:,:,prnn));
        if peak(prnn) > corrTHD
            
            visiblePRN  = [visiblePRN; prnn];
            codeshift   = [codeshift; (pindx(1,2,prnn)-sigLen)/2/fs];
            doppler     = [doppler; fvec(pindx(1,1,prnn))];
            
            
            figure(100+prnn);
            surf(repmat(fvec'/1e6,1,sigLen),...
               repmat((-sigLen/2+1:sigLen/2)/fs,length(fvec),1),...
               SS(:,:,prnn),'EdgeColor','none')
            xlabel('f in MHz')
            ylabel('\tau in s')
            zlabel('\rho_{xy}')
            title(sprintf('prn %i',prnn)) 
            
        end
    end
    table(visiblePRN,codeshift,doppler)
    
    









