function Eph = rdRinex(ephemerisfile)

% öffnen der Datei
fide = fopen(ephemerisfile);

% überspringen des Headers
head_lines = 0;
while 1 
   head_lines = head_lines + 1;
   line = fgetl(fide);
   answer = findstr(line,'END OF HEADER');
   if ~isempty(answer), 
       break;	
   end;
end;

% anzahl der vorhandenen Ephemeriden
noeph = -1;
while 1
   noeph = noeph +1 ;
   line = fgetl(fide);
   if line == -1, 
       break;  
   end
end;
noeph = noeph / 8;

% zurückstellen des File-Pointers
frewind(fide);
for i = 1:head_lines
    line = fgetl(fide); 
end;

% einlesen der Ephemeriden nach dem RINEX Format 2
for i = 1:noeph
   line = fgetl(fide);
   Eph(i).svprn = str2num(line(1:2));
   Eph(i).year = line(3:6);
   Eph(i).month = line(7:9);
   Eph(i).day = line(10:12);
   Eph(i).hour = line(13:15);
   Eph(i).minute = line(16:18);
   Eph(i).second = line(19:22);
   Eph(i).af0 = str2num(line(23:41));
   Eph(i).af1 = str2num(line(42:60));
   Eph(i).af2 = str2num(line(61:79));
   
   line = fgetl(fide);	  %
   Eph(i).IODE = line(4:22);
   Eph(i).crs = str2num(line(23:41));
   Eph(i).deltan = str2num(line(42:60));
   Eph(i).M0 = str2num(line(61:79));
   
   line = fgetl(fide);	  %
   Eph(i).cuc = str2num(line(4:22));
   Eph(i).ecc = str2num(line(23:41));
   Eph(i).cus = str2num(line(42:60));
   Eph(i).roota = str2num(line(61:79));
   
   line=fgetl(fide);
   Eph(i).toe = str2num(line(4:22));
   Eph(i).cic = str2num(line(23:41));
   Eph(i).Omega0 = str2num(line(42:60));
   Eph(i).cis = str2num(line(61:79));
   
   line = fgetl(fide);	    %
   Eph(i).i0 =  str2num(line(4:22));
   Eph(i).crc = str2num(line(23:41));
   Eph(i).omega = str2num(line(42:60));
   Eph(i).Omegadot = str2num(line(61:79));
   
   line = fgetl(fide);	    %
   Eph(i).idot = str2num(line(4:22));
   Eph(i).codes = str2num(line(23:41));
   Eph(i).weekno = str2num(line(42:60));
   Eph(i).L2flag = str2num(line(61:79));
   
   line = fgetl(fide);	    %
   Eph(i).svaccur = str2num(line(4:22));
   Eph(i).svhealth = str2num(line(23:41));
   Eph(i).tgd = str2num(line(42:60));
   Eph(i).iodc = line(61:79);
   
   line = fgetl(fide);	    %
   Eph(i).tom = str2num(line(4:22));
   %spare = line(23:41);
   %spare = line(42:60);
   %spare = line(61:79);
end
fclose(fide);

