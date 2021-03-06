function [ phi,lambda,h ] = cart2geo( x,y,z )
%C2G Summary of this function goes here
%   Entwickeln Sie die [...] Funktion (c2g.m), die kartesische Koordinaten in geografische Koordinaten transformiert.
    
    if nargin == 1
        z = x(3);
        y = x(2);
        x = x(1);
    end
    %WGS system:
    a = 6378137;%m
    f = 1/298.257;
    e = sqrt(2*f-f^2);
    
    %initial values
    p = sqrt(x^2+y^2);
    
    phi = 0;
    h = 0;
    delta_h = 10;
    h_old = delta_h;
    while abs(delta_h) > 0.1
        h_old = h;
        N = a/sqrt(1-e^2*sin(phi)^2);
        h = p/cos(phi)-N;
        phi = atan(z/p*(1-e^2*N/(N+h))^-1);
        delta_h = h_old-h;
    end
    phi = rad2deg(phi);
    lambda = atand(y/x);

end

