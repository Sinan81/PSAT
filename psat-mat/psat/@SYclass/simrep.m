function simrep(a, blocks, masks, lines)

global DAE

if ~a.n, return, end

typeidx = find(strcmp(masks,'Syn'));

for h = 1:length(typeidx)
  line_out = find_system(lines,'SrcBlockHandle',blocks(typeidx(h)));
  v_out = ['P = ',fvar(DAE.y(a.p(h)),7),' p.u. ->',char(10) ...
      ,'Q = ',fvar(DAE.y(a.q(h)),7),' p.u. ->'];
  set_param(line_out,'Name',v_out);
end

