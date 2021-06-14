close all
clear 
clc

%% settings
    fs  = 16e6;         %sample Frequency
    fca = 1.023e6;      %freq CA-Code
    fif = 4e6;          %intermediate frequency
    t_code = 1e-3;      %length of code
    fvec = (-5e3:250:5e3)+fif;
    nSamples = 16e3;
    
    
%% load files 
    dir = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';
    load( [dir 'GPSL1_LUT.mat'] ) %caCodesLUT
    load( [dir 'prnOnly.mat'] )   %sigCode
    load( [dir 'rfCplx.mat']  )    %sig
    sig = rfCplx( 1:nSamples  ); %cut signal

%% acquisition 
    %create receiver
    gpsr = GPSReceiver(fs, fca, fif);
    % set ca Codes
    gpsr.ca_fca = caCodesLUT;
    %resample ca code
    gpsr = gpsr.resampleCaCode();
    
    %acquisition
    gpsr.checkPrns = 1:37;
    gpsr.fvec = fvec;
    
    gpsr = gpsr.acquire(sig);
    SV_table = gpsr.visibleSVs()
    gpsr.plotAmbiguity(gpsr.visiblePRN)
    
    