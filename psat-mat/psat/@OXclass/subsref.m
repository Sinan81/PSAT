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
   case 'v'
    if length(index) == 2
      b = a.v(index(2).subs{:});
    else
      b = a.v;
    end
   case 'If'
    if length(index) == 2
      b = a.If(index(2).subs{:});
    else
      b = a.If;
    end
   case 'exc'
    if length(index) == 2
      b = a.exc(index(2).subs{:});
    else
      b = a.exc;
    end
   case 'n'
    b = a.n;
   case 'u'
    b = a.u;
   case 'vref'
    b = a.vref;
   case 'p'
    b = a.p;
   case 'q'
    b = a.q;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
