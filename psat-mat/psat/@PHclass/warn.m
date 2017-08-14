function warn(a,idx,msg)

global Bus

fm_disp(fm_strjoin('Warning: PHS #',int2str(idx),' between buses <', ...
	       Bus.names{a.bus1(idx)},'> and <', ...
               Bus.names{a.bus2(idx)},'> ',msg))