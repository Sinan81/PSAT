function simrep(a, blocks, masks, lines)

if ~a.n, return, end

typeidx = find(strcmp(masks,'PQ'));

for h = 1:length(typeidx)
  line_in = find_system(lines,'DstBlockHandle',blocks(typeidx(h)));
  if isempty(line_in)
    line_in = find_system(lines,'SrcBlockHandle',blocks(typeidx(h)));
  end
  v_in  = ['P = ',fvar(a.P0(h),7),' p.u. ->',char(10), ...
      'Q = ',fvar(a.Q0(h),7),' p.u. ->'];
  set_param(line_in,'Name',v_in);
end

