function [xk, yk, zk] = svPosECEF(ephi, date)   

    toe = ephi.toe;
    ecc = ephi.ecc;
    deltan = ephi.deltan;
    M0 = ephi.M0;
    omega = ephi.omega;
    cuc = ephi.cuc;
    cus = ephi.cus;
    crc = ephi.crc;
    crs = ephi.crs;
    cic = ephi.cic;
    cis = ephi.cis;
    i0 = ephi.i0;
    idot = ephi.idot;
    Omega0 = ephi.Omega0;
    Omegadot = ephi.Omegadot;
    
    
    %WGS system:
    mu = 3.986005*1e14;
    Omega_edot = 7.292151467*1e-5;
    
    %
    a   = ephi.roota.^2;
    n0  = sqrt(mu/a^3);
    
    %time since last Sunday
    sunday = dateshift(ephi.date, 'dayofweek', 'Sunday', 'previous');
    sunday.Hour = 0; sunday.Minute = 0; sunday.Second = 0;
    t = mod( seconds(diff( [sunday,date] ))+18, 604800 );
    

    %Time from ephemeris reference time    
    tk  = t - toe;    
    if tk > 302400
        tk = tk-604800;
    elseif tk < -302400
        tk = tk+604800;
    end
    %Corrected Mean Motion
    n   = n0 + deltan;
    %Mean Anomaly
    Mk = M0 + n * tk;
    Mk = rem(Mk+2*pi,2*pi);
    
    %solve Eccentric anomaly iteratively (alterative code)
    Ek = Mk;
    Mk_delta = 1;
    for indx = 1:10
        Mk_temp = Ek + ecc*sin(Ek);
        Mk_delta = Mk - Mk_temp;
        Ek = Ek + Mk_delta;
        %Ek = Mk+ecc*sin(Ek);
        if abs(Mk_delta) < 1e-12
            break
        end
    end
    Ek = rem(Ek+2*pi,2*pi);
        
    %True Anomaly
    vk = atan2( sqrt( 1 - ecc^2 )* sin( Ek ) , (cos( Ek )  - ecc ) );
    
    %Argument of Latitude    
    Phik = vk + omega;
    Phik = rem(Phik+2*pi,2*pi);
    
    %second harmonic perturbations
    delta_uk = cuc * cos( 2 * Phik ) + cus * sin( 2 * Phik );
    delta_rk = crc * cos( 2 * Phik ) + crs * sin( 2 * Phik );
    delta_ik = cic * cos( 2 * Phik ) + cis * sin( 2 * Phik );
    
    %corrected argument of latitude
    uk =  Phik + delta_uk;
    %Corrected radius
    rk = a * ( 1 - ecc * cos( Ek ) ) + delta_rk;
    %corrected inclination
    ik = i0 +delta_ik + idot * tk;
    
    %positions in orbital plane
    xk_ = rk * cos( uk ); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%??????????? correct?
    yk_ = rk * sin( uk );
    
    %corrected longitude of ascending node
    Omegak = Omega0 + ( Omegadot - Omega_edot ) * tk ...
                         - Omega_edot * toe;
    %?Omegak = rem(Omegak+2*pi,2*pi);
    
    %Eart Centered, Eart-Fixed coordinates
    xk = xk_ * cos(Omegak) - yk_ * cos(ik) * sin(Omegak); 
    yk = xk_ * sin(Omegak) + yk_ * cos(ik) * cos(Omegak); 
    zk = yk_ * sin(ik); 
        
end