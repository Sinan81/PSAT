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
   case 'q1'
    if length(index) == 2
      b = a.q1(index(2).subs{:});
    else
      b = a.q1;
    end
   case 'q'
    if length(index) == 2
      b = a.q(index(2).subs{:});
    else
      b = a.q;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'bus'
    b = a.bus;
   case 'vbus'
    b = a.vbus;
   case 'n'
    b = a.n;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
