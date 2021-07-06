% Erste geschätzte Position
xhat = [6377000 3000 4000 0];

%% Daten für das Beispiel mit 4 Satelliten
% % Satellitenpositionen zum Messzeitpunkt
% svPos = [22808160.9 -12005866.6  -6609526.5;
%          21141179.5  -2355056.3 -15985716.1;
%          20438959.3  -4238967.1  16502090.2;
%          18432296.2 -18613382.5  -4672400.8];
% 
% % Gemessene Pseudoranges rho
% pr = [21480623.3 
%     21971919.2 
%     22175603.9 
%     22747561.5];


%% Daten für das Beispiel mit 7 Satelliten
% Satellitenpositionen zum Messzeitpunkt
svPos = [22808160.9 -12005866.6  -6609526.5;
         21141179.5  -2355056.3 -15985716.1;
         20438959.3  -4238967.1  16502090.2;
         18432296.2 -18613382.5  -4672400.8;
         21772117.8  13773269.7   6656636.4;
         15561523.9   3469098.6 -21303596.2;
         13773316.6  15929331.4 -16266254.4];

% Gemessene Pseudoranges rho
pr = [21480623.3 
    21971919.2
    22175603.9 
    22747561.5
    21787252.3 
    23541613.4 
    24022907.4 ];