function warn(a,idx,msg)

fm_disp(fm_strjoin('Warning: TCSC #',int2str(idx),' between buses #', ...
	       int2str(a.bus1(idx)),' and #',int2str(a.bus2(idx)),msg))