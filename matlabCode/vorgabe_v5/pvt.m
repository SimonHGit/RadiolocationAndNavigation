function pos = pvt(pr,sats,time,Eph)
% pvt Computation of receiver position from pseudoranges
%          using ordinary least-squares principle

% Konstanten
v_light = 299792458;
nbrSV = size(pr,1);
nbrIt = 6;

% Findet die korrekten Ephemeriden für die aktuelle Positionsbestimmung
col_Eph = zeros(1,10);
for t = 1:nbrSV
    col_Eph(t) = find_eph(Eph,sats(t),time);
end

% Erste Schätzung der Position (0,0,0,0)
pos = zeros(4,1);

H = zeros(nbrSV,4);
omc = zeros(nbrSV,1);

for iter = 1:nbrIt
    
    % Berechnen der Geometriematrix und der Differenz zwischen gemessener
    % geschätzter Zeit
    
    for n = 1:nbrSV
        % k ist der Vektor mit den aktuell getrackten PRNs
        k = col_Eph(n);
        
        % Berechnet die erste Schätzung der Sendezeit aus der Pseudorange
        tx_RAW = time - pr(n)/v_light;
        
        % Korrektur der Rohzeit; verwendet Time of clock und
        % Clock-Parameter aus den Ephmeriden
        t0c = Eph(21,k);
        dt = check_t(tx_RAW-t0c);
        tcorr = Eph(2,k)*dt^2 + Eph(20,k)*dt + Eph(19,k);
        
        % Berechnung der Sendezeit des Satelliten
        tx_GPS = tx_RAW-tcorr;
        
        %% Ergänzungen hier
        % Berechnung der Satellitenposition auf Basis der Sendetzeit
        % HIER müssen Sie die Funktion satpos mit den richtigen Argumenten
        % verwenden und das Ergebnis in die Variable svpos speichern
        svpos = satpos(tx_GPS,Eph(:,k));
        
        % Differenz zwischen geschätzter und berechnet Position
        omc(n) = pr(n)-norm(svpos-pos(1:3),'fro')-pos(4)+v_light*tcorr;
        
        % Geometriematrix
        H(n,:) = [(-(svpos(1)-pos(1)))/pr(n)...
                  (-(svpos(2)-pos(2)))/pr(n) ...
                  (-(svpos(3)-pos(3)))/pr(n) 1];
    end
    
    %% Lösen des (überbestimmten) Gleichungssystems
    % Ergänzungen hier    
    %pseudiinverse
    H_pseudo    = inv(H.' * H) * H.';
    dx          = H_pseudo * omc;
    % Update der Position
    pos = pos+dx;
    
end
