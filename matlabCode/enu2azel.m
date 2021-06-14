function [Az, El] = enu2azel(east,north, up)

   Az   = atan2( east , north )/pi*180;
   El   = asind( up / sqrt(east^2 + north^2 + up^2) );   
end
