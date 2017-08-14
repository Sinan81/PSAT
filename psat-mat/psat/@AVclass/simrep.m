function simrep(a, blocks, masks, lines)

global DAE

if ~a.n, return, end

typeidx = find(strcmp(masks,'Exc'));

for h = 1:length(typeidx)
  line_out = find_system(lines,'SrcBlockHandle',blocks(typeidx(h)));
  v_out = ['Vf = ',fvar(DAE.y(a.vfd(h)),7),' p.u.'];
  set_param(line_out,'Name',v_out);
end

