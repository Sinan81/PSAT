function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'svc'
    a.svc = val;
   case 'tcsc'
    a.tcsc = val;
   case 'statcom'
    a.statcom = val;
   case 'upfc'
    a.upfc = val;
   case 'sssc'
    a.sssc = val;
   case 'dfig'
    a.dfig = val;
   case 'n'
    a.n = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
