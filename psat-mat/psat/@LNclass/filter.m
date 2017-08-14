function [idx1,idx2,busidx1,busidx2] = filter(a,buslist)
% filter lines using bus list

idx1 = cell(0,0);
idx2 = cell(0,0);
busidx1 = [];
busidx2 = [];

fr = a.fr.*a.u;
to = a.to.*a.u;

for i = 1:length(buslist)
  
  idxfr = find(fr == buslist(i));
  idxto = find(to == buslist(i));

  if ~isempty(idxfr)
    idx = [];
    for h = 1:length(idxfr)
      k = idxfr(h);
      jdx = find(buslist == to(k));
      if isempty(jdx), idx = [idx; k]; end
    end
    if ~isempty(idx)
      idx1{end+1,1} = idx;
      busidx1 = [busidx1; i];
    end 
  end
  
  if ~isempty(idxto)
    idx = [];
    for h = 1:length(idxto)
      k = idxto(h);
      jdx = find(buslist == fr(k));
      if isempty(jdx), idx = [idx; k]; end
    end
    if ~isempty(idx)
      idx2{end+1,1} = idx;
      busidx2 = [busidx2; i];
    end 
  end

end

