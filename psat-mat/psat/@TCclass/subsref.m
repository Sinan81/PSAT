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
   case 'x0'
    if length(index) == 2
      b = a.x0(index(2).subs{:});
    else
      b = a.x0;
    end
   case 'pref'
    if length(index) == 2
      b = a.pref(index(2).subs{:});
    else
      b = a.pref;
    end
   case 'bus1'
    b = a.bus1;
   case 'bus2'
    b = a.bus2;
   case 'n'
    b = a.n;
   case 'line'
    b = a.line;
   case 'X0'
    b = a.X0;
   case 'Pref'
    b = a.Pref;
   case 'x1'
    b = a.x1;
   case 'x2'
    b = a.x2;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
