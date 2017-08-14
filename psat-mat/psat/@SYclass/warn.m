function warn(a,idx,msg)

global Bus

fm_disp(fm_strjoin('Warning: Synchronous Machine #', ...
               int2str(idx),'(model ',num2str(a.con(idx,5)), ...
               ') at bus ',Bus.names(a.bus(idx)),msg))