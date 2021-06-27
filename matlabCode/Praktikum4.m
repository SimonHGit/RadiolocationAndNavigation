close all ; clear ; clc

% load files 
directory = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';

load( [directory 'settings.mat'] ) %
load( [directory 'trackingResults.mat'] ) %
I_P = trackResults.I_P;

%init receiver
gpsr = GPSReceiver([],[],[]);

% logic stream
bitStream_bool = gpsr.processBitStream(I_P);

% präambel position
subframeIndx = gpsr.getPreamblePos(bitStream_bool);

%dekodieren
gpsr = gpsr.decode(bitStream_bool,subframeIndx);


gpsr.ephimeris
