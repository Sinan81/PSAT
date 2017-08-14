function warn(a,idx,msg)

global Bus

fm_disp(fm_strjoin('Warning: STATCOM #',int2str(idx),' at bus <', ...
               Bus.names(a.bus(idx)),'>: ',msg))