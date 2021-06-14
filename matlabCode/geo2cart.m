function [ X, Y, Z ] = geo2cart( lat_dez, long_dez,heigth)
%G2C Summary of this function goes here
%   WGS84 Bezugssystem
%   Input in fractions.


    phi     = lat_dez;
    lambda  = long_dez;

    %WGS system:
    a = 6378137;%m
    f = 1/298.257223563;
    e = sqrt(2*f-f^2);

    N = a/(sqrt(1-e^2*sind(phi)^2));


    X = ( N + heigth ) * cosd(phi) * cosd(lambda);
    Y = ( N + heigth ) * cosd(phi) * sind(lambda);
    Z = ( ( 1-e^2 ) * N + heigth) * sind(phi);

end
