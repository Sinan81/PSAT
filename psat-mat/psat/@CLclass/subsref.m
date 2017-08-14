function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'q'
    if length(index) == 2
      b = a.q(index(2).subs{:});
    else
      b = a.q;
    end
   case 'vref'
    b = a.vref;
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'syn'
    b = a.syn;
   case 'cac'
    b = a.cac;
   case 'exc'
    b = a.exc;
   case 'svc'
    b = a.svc;
   case 'n'
    b = a.n;
   case 'Vs'
    b = a.Vs;
   case 'dVsdQ'
    b = a.dVsdQ;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
