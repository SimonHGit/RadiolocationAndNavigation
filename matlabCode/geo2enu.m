function [E ,N ,U ] = geo2enu( lat, long, SV_xyz, U_xyz)
    
    phi     = deg2rad(lat);
    lambda  = deg2rad(long);

    Rl = [-sin(lambda),           cos(lambda),          0;
          -sin(phi)*cos(lambda), -sin(phi)*sin(lambda), cos(phi);
           cos(phi)*cos(lambda),  cos(phi)*sin(lambda), sin(phi)];
    
       
    tmp =  Rl * ( SV_xyz - U_xyz );
    
    
    
    E = tmp(1);
    N = tmp(2);
    U = tmp(3);


end
