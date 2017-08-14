function warn(a,idx,msg)

global Bus

fm_disp(fm_strjoin('Warning: SSSC #',int2str(idx),' at bus <', ...
	       Bus.names(a.bus1(idx)),'>: ',msg))