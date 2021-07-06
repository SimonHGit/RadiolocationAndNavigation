close all ; clear ; clc
x_hist = []
c = 3e8;
% load files 
directory = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';

%set: 
% svPos: Satellitenpositionen zum Messzeitpunkt
% xhat : erste geschätzte Position
% pr : Gemessene Pseudoranges rho
% svPos : Satellitenpositionen zum Messzeitpunkt
run([directory 'set_vars.m'])

%userposition
x = xhat';
%  x = 6e6*[1 2 3 4]';

for indx = 1:20
    % actual pseudorange 
    pr_ = sqrt( sum( ( svPos - x(1:end-1).' ).^2 , 2 ) ) ; %norm der pseudorange
    % difference to target pseudorange
    delta_pr = pr - pr_;
    % derivates
    H = jacobiMtrx( svPos , x , pr_);
    % new position
    %seudiinverse
    H_pseudo = inv(H.' * H) * H.';
    delta_x = H_pseudo * delta_pr ;
    x = x + delta_x;
    %history
    x_hist = [x_hist, x(1:3)];
end

figure(1)
sss = 1 ;
plot3(x_hist(1,sss:end),x_hist(2,sss:end),x_hist(3,sss:end),'.-')
hold on
plot3(svPos(:,1),svPos(:,2),svPos(:,3),'*')
hold off

[p,l,h] = cart2geo(x(1),x(2),x(3))


function H = jacobiMtrx( X , xu_ , r_)
    nSat = size(X,1);
    for k = 1 : nSat
        a(k,1) =  -( X(k,1) - xu_(1) ) / r_( k );
        b(k,1) =  -( X(k,2) - xu_(2) ) / r_( k );
        c(k,1) =  -( X(k,3) - xu_(3) ) / r_( k );
    end
    H = [a b c ones(nSat,1)];
end


function d = l2norm( A , b )
    for jj = 1:size(A,1)
        d(jj) = sum( ( A(jj,:)-b(:)' ).^2 );
    end
    d = sqrt(d);
end