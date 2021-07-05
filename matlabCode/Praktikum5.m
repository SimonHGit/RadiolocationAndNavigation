close all ; clear ; clc
x_hist = []
c = 3e8;
% load files 
directory = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';

%load( [directory '.mat'] ) %
%set: 
% svPos: Satellitenpositionen zum Messzeitpunkt
% xhat : erste geschätzte Position
% pr : Gemessene Pseudoranges rho
% svPos : Satellitenpositionen zum Messzeitpunkt
run([directory 'set_vars.m'])

% Geometriematrix H:

delta_x = zeros(4,1);

%userposition
x = xhat';
% x = [1 2 3 4]';

for indx = 1:20
    % actual pseudorange 
    pr_ = sqrt( sum( ( svPos - x(1:end-1).' ).^2 , 2 ) ) ;
    % difference to target pseudorange
    delta_pr = pr - pr_;
    % derivates
    H = jacobiMtrx( svPos , x , pr_);
    % new position
    delta_x = inv(H) * delta_pr;
    x = x + delta_x;
    %history
    x_hist = [x_hist, x(1:3)];
end

figure(1)
plot3(x_hist(1,sss:end),x_hist(2,sss:end),x_hist(3,sss:end),'.')
hold on
plot3(svPos(:,1),svPos(:,2),svPos(:,3),'*')
hold off



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