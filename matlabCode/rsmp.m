%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author:         Götz C. Kappen
%                   goetz.kappen@fh-muenster.de
%
%   Date:           2021/01/22
%
%   Filename:       rsmp.m
%
%   Main script for signal, generation, interferer mitigation, plotting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = rsmp(in,fsIn,fsOut)

% Verhältnis aus Wunsch-Sample-Rate und Ist-Sample-Rate
ratio = fsOut/fsIn;

% Floor Funktion zur Bestimmung der Anzahl der Ausgangs-Samples
n = floor(length(in)*ratio);
nbr = 1:n;

% Transformieren der Sample-Nummern
tmp = floor(nbr/ratio);
tmp = tmp + 1; 
tmp(tmp>length(in)) = length(in);

% Umschreiben des Index-Starts von 0 auf 1
out = in(tmp);


    

