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
   case 'vbus'
    b = a.vbus;
   case 'wind'
    b = a.wind;
   case 'n'
    b = a.n;
   case 'omega_t'
    b = a.omega_t;
   case 'omega_m'
    b = a.omega_m;
   case 'e1r'
    b = a.e1r;
   case 'e1m'
    b = a.e1m;
   case 'gamma'
    b = a.gamma;
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
