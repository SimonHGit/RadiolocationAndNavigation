close all
clear 
clc


%% Einf�hrung in die Software u-center
    dir     = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Graphics\';
    fName   = {'V2_Watch.png',...
               'V2_SkyPlot.png',...
               'V2_SkyPlot_Trimble.png',...
               'V2_PosPlot.png',...
               'V2_HAE(Hist).png',...
               'V2_HAE(Time).png'};

    %a: show watch
    %figure(1); 
    %imshow(imread([dir fName{1}]))
    fprintf('Die Aufnahme fand am 12.5.21 von 9:42 bis 10:11 (UTC) statt\nAlso 11:42 bis 12:11 MEZ(Sommerzeit)\n')

    %b: Vergleich der Messung mit der Vorhersage aus Trimble Planning Tool
    % umrechnen der Position:
    position_dez = [52.14326339; 7.32134381]; % fh
    position_dez = [51.98601608; 4.38745694]; % delpht
    position_dec = dez2dec(position_dez);

    figure(2); 
    subplot(1, 2, 1)
    imshow( imread( [dir fName{2}] ) )
    subplot(1, 2, 2)
    imshow( imread( [dir fName{3}] ) )


    %b: Positionsplot
    figure(3); 
    imshow( imread([dir fName{4}] ) )

    %c: HAE Histogram
    figure(4); 
    subplot(1, 2, 1)
    imshow( imread( [dir fName{5}] ) )
    subplot(1, 2, 2)
    imshow( imread( [dir fName{6}] ) )
    
%% Einlesen der RINEX Daten
    % Infos:  http://gnss1.tudelft.nl/dpga/station/Delft.html#DELF
    % Source: http://gnss1.tudelft.nl/dpga/rinex/2021/131/
    % decompression: http://gnss1.tudelft.nl/pub/vdmarel/software/crz2rnx.html

    dir     = 'D:\Studium\Faecher\Master\27_OrtungUndNavigation\03_Praktikum\RadiolocationAndNavigation\Data\';
    fName   = { 'dlf11320.21n', 'delf1320.21n', 'dlf11320.21g', 'delf1320.21g' };
    data    = rdRinex( [ dir fName{2} ] );
    
    % extract ephimerides of relevant SVs in timeranges
    tStart  = datetime( [2021, 05, 12, 10, 00, 00] );
    tStop   = datetime( [2021, 05, 12, 12, 00, 00] );
    wFilter = struct( 'svprns', [02 12 25 29 31 32], 'tStart', tStart, 'tStop', tStop );
    wFilter = struct( 'svprns', [1:37], 'tStart', tStart, 'tStop', tStop );
    ephimeris = extractEphimerides(data,wFilter);
    
    % save navigation data of visible SVs
    saveNavData( ephimeris, dir );
    
    time_from = datetime( [2021, 05, 12, 12, 00, 00] );
    date_vec = time_from-hours(10):minutes(2):time_from+hours(10);
    
    % User Position
    phi     = position_dez(1);
    lambda  = position_dez(2);
    [x,y,z ] = geo2cart(phi, lambda, 135);
    U.ECEF = [x;y;z];
    
    
    for t_indx = 1:length(date_vec)
        for sv_indx = 1:length(ephimeris)
            ephi = ephimeris(sv_indx);

            % SV position
            [xk, yk, zk] = svPosECEF(ephi, date_vec(t_indx));
            SV(sv_indx).ECEF(:,t_indx) = [xk; yk; zk];


            % ENU conversion
            [SV(sv_indx).ENU.e(t_indx), SV(sv_indx).ENU.n(t_indx), SV(sv_indx).ENU.u(t_indx) ] = ...
                geo2enu( phi, lambda, SV(sv_indx).ECEF(:,t_indx), U.ECEF);

            % compute Azimute / Elevation
            [SV(sv_indx).ENU.az(t_indx), SV(sv_indx).ENU.el(t_indx)] = ...
                enu2azel(SV(sv_indx).ENU.e(t_indx), SV(sv_indx).ENU.n(t_indx), SV(sv_indx).ENU.u(t_indx));

        end
    end

    %skyplot
    figure(5)
    for sv_indx = 1:length(ephimeris)
        polarplot(deg2rad( SV(sv_indx).ENU.az) , SV(sv_indx).ENU.el,'LineWidth',2); hold on
    end
    hold off;
    ax = gca;
    rlim([0 90])
    ax.RDir = 'reverse';
    ax.ThetaDir = 'clockwise';
    ax.ThetaZeroLocation = 'top';
    legend(cellstr(num2str([ephimeris.svprn]', 'PRN = %d')))
    
    %3d plot
    figure(6);  clf
    for sv_indx = 1:length(ephimeris)
        plot3(SV(sv_indx).ECEF(1,:), SV(sv_indx).ECEF(2,:), SV(sv_indx).ECEF(3,:) ,'LineWidth',2);hold on
    end
    legend(cellstr(num2str([ephimeris.svprn]', 'PRN = %d')))
    plotWorld(); hold off;
    
    
    
    