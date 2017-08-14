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
   case 'bus1'
    b = a.bus1;
   case 'bus2'
    b = a.bus2;
   case 'line'
    b = a.line;
   case 'n'
    b = a.n;
   case 'Cp'
    b = a.Cp;
   case 'y'
    b = a.y;
   case 'xcs'
    b = a.xcs;
   case 'Vd0'
    b = a.Vd0;
   case 'Vq0'
    b = a.Vq0;
   case 'Vref'
    b = a.Vref;
   case 'vp0'
    b = a.vp0;
   case 'vq0'
    b = a.vq0;
   case 'vref'
    b = a.vref;
   case 'vp'
    b = a.vp;
   case 'vq'
    b = a.vq;
   case 'iq'
    b = a.iq;
   case 'gamma'
    b = a.gamma;
   case 'store'
    b = a.store;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
