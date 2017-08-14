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
   case 'q'
    a.q = val;
   case 'syn'
    a.syn = val;
   case 'exc'
    a.exc = val;
   case 'Vs'
    a.Vs = val;
   case 'svc'
    a.svc = val;
   case 'dVsdQ'
    a.dVsdQ = val;
   case 'cac'
    a.cac = val;
   case 'vref'
    a.vref = val;
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
