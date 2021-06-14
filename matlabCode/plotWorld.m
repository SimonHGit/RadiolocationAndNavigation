function plotWorld()
    %WGS system:
    a = 6378137;%m
    f = 1/298.257223563;
    e = sqrt(2*f-f^2);

    [X,Y,Z] = ellipsoid(0,0,0,a, a, a*(1-f));
    surf(X,Y,Z)

end
