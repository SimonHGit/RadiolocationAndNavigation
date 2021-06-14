function d = L2DistGeo(pos_a_decimal , pos_b_decimal ,height)
    %L2Dist() calculates l2norm between two geographic positions
    % given in fractional degree
    [a(1),a(2),a(3)] = geo2cart(pos_a_decimal(1),pos_a_decimal(2),height);
    [b(1),b(2),b(3)] = geo2cart(pos_b_decimal(1),pos_b_decimal(2),height);
    
%     d_x = b.x - a.x
%     d_x = b.x - a.x
%     d_x = b.x - a.x
    d = (b-a);
    d = sqrt( d*d.' );

end