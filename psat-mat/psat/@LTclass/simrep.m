function simrep(a, blocks, masks, lines)

if ~a.n, return, end

[Ps,Qs,Pr,Qr] = flows(a,[],[],[],[]);

lineidx = find(strcmp(masks,'Ltc'));

for i = 1:length(lineidx)
  % MaskValues = get_param(blocks(lineidx(i)),'MaskValues');
  line_out = find_system(lines,'SrcBlockHandle',blocks(lineidx(i)));
  line_in  = find_system(lines,'DstBlockHandle',blocks(lineidx(i)));
  if (length(line_in) == 2)
    line_in = line_in(2);
  end
  v_out = [' <- P = ',fvar(Pr(i),7),' p.u.',char(10), ...
      ' <- Q = ',fvar(Qr(i),7),' p.u.'];
  v_in  = ['P = ',fvar(Ps(i),7),' p.u. ->',char(10), ...
      'Q = ',fvar(Qs(i),7),' p.u. ->'];
  set_param(line_out,'Name',v_out)
  set_param(line_in ,'Name',v_in)
end
