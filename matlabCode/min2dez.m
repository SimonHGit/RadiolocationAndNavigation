function dez = min2dez(position_time)
% die aus der Darstellung in Grad,
% Minuten (plus Nachkommastellen) die Darstellung in Grad und Dezimalstellen berechnet.
%   Example Input:
%   position_time = [4722.80340]
   deg = sign(position_time)*floor(abs(position_time/100));
   min = (position_time - deg*100);
   
   dez = deg + min/60 ;
   
end