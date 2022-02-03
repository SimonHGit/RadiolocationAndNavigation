close all ; clear ; clc



x_hist = [];
c = 3e8;
mu = 0.3;

%Data 

%% Daten f�r das Beispiel mit 4 Satelliten
% % Satellitenpositionen zum Messzeitpunkt
% svPos = [22808160.9 -12005866.6  -6609526.5;
%          21141179.5  -2355056.3 -15985716.1;
%          20438959.3  -4238967.1  16502090.2;
%          18432296.2 -18613382.5  -4672400.8];
% % Gemessene Pseudoranges rho
% pr = [21480623.3 21971919.2 22175603.9 22747561.5]';


%% Daten f�r das Beispiel mit 7 Satelliten
% Satellitenpositionen zum Messzeitpunkt
svPos = [22808160.9 -12005866.6  -6609526.5;
         21141179.5  -2355056.3 -15985716.1;
         20438959.3  -4238967.1  16502090.2;
         18432296.2 -18613382.5  -4672400.8;
         21772117.8  13773269.7   6656636.4;
         15561523.9   3469098.6 -21303596.2;
         13773316.6  15929331.4 -16266254.4];

% Gemessene Pseudoranges rho
pr = [21480623.3 21971919.2 22175603.9 22747561.5 21787252.3 23541613.4 24022907.4]';

% start position
x = [6377000 3000 4000 0]';
x = 1e7*[-3 5 1 0 ]';

for indx = 1:200
    % actual pseudorange 
    pr_ = sqrt( sum( ( svPos - x(1:end-1).' ).^2 , 2 ) ) + x(4) ; %norm der pseudorange
    % difference to target pseudorange
    delta_pr = pr - pr_;
    % derivates
    H = jacobiMtrx( svPos , x , pr_);
    % new position
    %pseudiinverse
    H_pseudo = inv(H.' * H) * H.';
    delta_x = H_pseudo * delta_pr * mu;
    x = x + delta_x;
    %history
    x_hist = [x_hist, x];
end

[lat,long,height] = cart2geo(x(1),x(2),x(3));

%% graphics
figure(1)
plot3(x_hist(1,:),x_hist(2,:),x_hist(3,:),'.-')
hold on
plot3(svPos(:,1),svPos(:,2),svPos(:,3),'*')
plotWorld();
hold off

grid on
axis equal

%% used function
function H = jacobiMtrx( X , xu_ , r_)
    nSat = size(X,1);
    for k = 1 : nSat
        a(k,1) =  -( X(k,1) - xu_(1) ) / r_( k );
        b(k,1) =  -( X(k,2) - xu_(2) ) / r_( k );
        c(k,1) =  -( X(k,3) - xu_(3) ) / r_( k );
    end
    H = [a b c 3e8*ones(nSat,1)];
end
