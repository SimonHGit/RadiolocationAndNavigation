function out = dez2dec(position_decimal)
%Schreiben Sie eine MATLAB-Funktion (dec2dez.m) die aus der Darstellung in Grad,
% Minuten, Sekunden (plus Nachkommastellen) die Darstellung in Grad und Dezimalstellen berechnet.
%   Example Input:
%   position_decimal = [ 52.1433; 7.3213]
   deg = floor(position_decimal); %deg
   x = (position_decimal-deg)*60;
   min = floor(x); % remove deg
   sek = (x-min)*60;
   
   out = [deg ,min , sek];
   
end