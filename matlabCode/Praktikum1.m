clear 
clc
%% Navigation mit Landmarken und Kompass - Entfällt

%% Koordinatentransformation

    % Breite: Latitude (N/S)    52°08'35.7764"N 
    % Länge:  Longitude(W/E)     7°19'16.6976"E
    lat_sex =  [52 08 35.7764];
    long_sex = [07 19 16.6976];
    height = 65;
    position_sex = [ lat_sex ; long_sex ];
 
    %1. transform geographic to cartesian
    position_dez = dec2dez(position_sex);
    lat_dez  = position_dez(1);
    long_dez = position_dez(2);
    
    [x,y,z]  = geo2cart(lat_dez , long_dez , height);
    %2. transform cartesian to geographic
    [lat_new , long_new , height_new] = cart2geo(x,y,z);
    
    %3. error in latitude-fractional seconds
    dez2dec([lat_new;long_new]) ;
    
    %show position in browser:
    url = sprintf('https://www.google.de/maps/@%3.7f,%3.7f,17z',lat_new,long_new);
    web(url)
    
    %4. measure distance of s-building fh muenster (campus steinfurt)
    A = [52.142382, 7.320353];
    B = [52.142365, 7.321063];
    %measured on google maps : 48,52m
    dist = L2DistGeo(A,B,height);
    
%% 