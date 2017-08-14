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
   case 'vref'
    if length(index) == 2
      b = a.vref(index(2).subs{:});
    else
      b = a.vref;
    end
   case 'bus'
    if length(index) == 2
      b = a.bus(index(2).subs{:});
    else
      b = a.bus;
    end
   case 'vbus'
    b = a.vbus;
   case 'n'
    b = a.n;
   case 'btx1'
    b = a.btx1;       
   case 'id'
    b = a.id;
   case 'iq'
    b = a.iq;
   case 'dat'
    if length(index) == 2
      b = a.dat(index(2).subs{:});
    else
      b = a.dat;
    end
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
