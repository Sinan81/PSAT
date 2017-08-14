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
   case 'bus'
    if length(index) == 2
      b = a.bus(index(2).subs{:});
    else
      b = a.bus;
    end
   case 'vbus'
    if length(index) == 2
      b = a.vbus(index(2).subs{:});
    else
      b = a.vbus;
    end
   case 'n'
    b = a.n;
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'refbus'
    b = a.refbus;
   case 'store'
    b = a.store;
   case 'pg'
    b = a.pg;
   case 'qg'
    b = a.qg;
   case 'dq'
    b = a.dq;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
