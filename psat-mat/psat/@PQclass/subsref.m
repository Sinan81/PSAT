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
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'bus'
    b = a.bus;
   case 'n'
    b = a.n;
   case 'store'
    b = a.store;
   case 'P0'
    if length(index) == 2
      b = a.P0(index(2).subs{:});
    else
      b = a.P0;
    end
   case 'Q0'
    if length(index) == 2
      b = a.Q0(index(2).subs{:});
    else
      b = a.Q0;
    end
   case 'gen'
    b = a.gen;
   case 'shunt'
    b = a.shunt;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
