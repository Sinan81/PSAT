function simrep(a, blocks, masks, lines)

global Bus

if ~a.n, return, end

typeidx = find(strcmp(masks,'PV'));
p = getpg(a,'all');

for h = 1:length(typeidx)
  line_out = find_system(lines,'SrcBlockHandle',blocks(typeidx(h)));
  v_out = ['P = ',fvar(p(h),7),' p.u. ->',char(10),['Q ' ...
      '= '],fvar(Bus.Qg(a.bus(h)),7),' p.u. ->'];
  set_param(line_out,'Name',v_out);
end

