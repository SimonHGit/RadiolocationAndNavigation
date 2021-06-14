function dez = dec2dez(position_time)
% Schreiben Sie eine MATLAB-Funktion (dec2dez.m) die aus der Darstellung in Grad,
% Minuten, Sekunden (plus Nachkommastellen) die Darstellung in Grad und Dezimalstellen berechnet.
%   Example Input:
%   position_time = [52 08 35.7764;...
%                    07 19 16.6976]
   deg = position_time(:,1);
   min = position_time(:,2);
   sek = position_time(:,3);
   
   dez = deg + min/60 + sek/3600;
   
end