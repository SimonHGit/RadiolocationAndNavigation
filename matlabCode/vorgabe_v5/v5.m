%% Öffnen der RINEX-Dateien und Einlesen der Werte
rinexe('./data/dlf5248h.15N','eph.dat');
Eph = get_eph('eph.dat');

ofile1 = './data/dlf5248h.15O';
fid1 = fopen(ofile1,'rt');
[Obs_types1, ant_delta1, ifound_types1, eof11] = anheader(ofile1);
NoObs_types1 = 3;
pos = zeros(4,100);

%% Berechnen der Empfängerpositionen q
for q = 1:100
    % Einlesen einer neuen Epoche aus der Observationsdatei
    [time1, dt1, sats1, eof1] = fepoch_0(fid1);
    
    % Bestimmung der Anzahl der in den Daten vorhandenen Satelliten
    sats_in_eph = Eph(1,:);
    sats_in_obs = sats1;
    
    % Entfernen der Satelliten, für die nicht gleichzeitig Ephemeriden
    % und Pseudoranges in den Daten vorhanden sind
    for n = 1:length(sats_in_obs)
        tmp = find(sats_in_obs(n)==sats_in_eph);
        if isempty(tmp) == 1
            sats_in_obs(n) = 0;
        end
    end
    sats_in_obs(sats_in_obs == 0) = [];
    sats1 = sats_in_obs;
    NoSv1 = size(sats1,1);
    
    % Verwendung der C1 Daten (CA-Code auf L1)
    obs1 = grabdata(fid1, NoSv1, NoObs_types1);
    ot = fobs_typ(Obs_types1,'C1');
    
    %% Praktikumsaufgabe
    % Hier wird mit dem LMS-Algorithmus die Position berechnet und
    % in das Array pos eingetragen
    pos(:,q) = pvt(obs1(:,ot),sats1,time1,Eph);
end

%% Berechnung des Mittelwertes und Ausgabe der Ergebnisse
me = mean(pos,2);
fprintf('\nMittelwert der berechneten Empfängerpositionen:');
fprintf('\n\nX: %12.3f  Y: %12.3f  Z: %12.3f\n\n', me(1,1), me(2,1), me(3,1));
plot_handles = plot(1:q,(pos(1,:)-pos(1,1)*ones(1,q))','-',... 
                    1:q,(pos(2,:)-pos(2,1)*ones(1,q))','--',... 
                    1:q,(pos(3,:)-pos(3,1)*ones(1,q))','-.');
set(gca,'fontsize',14)
set(plot_handles,'linewidth',2)
xlabel('Zeit in $s$','Interpreter','LaTex')
ylabel('Relative Positionsaenderung $m$','Interpreter','LaTex')
legend('X','Y','Z')

% Unmrechnung der x,y,z-Werte in das geodätisch Koordinatensystem
[phi,lambda,h] = cart2geo(pos(1,1),pos(2,1),pos(3,1),5);

% Ausgabe zur Kopie der Position in Google Earth
fprintf([num2str(phi,'%2.10f') '°,' num2str(lambda,'%2.10f') '°\n\n'])

