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
   case 'p'
    if length(index) == 2
      b = a.p(index(2).subs{:});
    else
      b = a.p;
    end
   case 'q'
    if length(index) == 2
      b = a.q(index(2).subs{:});
    else
      b = a.q;
    end
   case 'vf0'
    if length(index) == 2
      b = a.vf0(index(2).subs{:});
    else
      b = a.vf0;
    end
   case 'pm0'
    if length(index) == 2
      b = a.pm0(index(2).subs{:});
    else
      b = a.pm0;
    end
   case 'Pg0'
    if length(index) == 2
      b = a.Pg0(index(2).subs{:});
    else
      b = a.Pg0;
    end
   case 'vf'
    if length(index) == 2
      b = a.vf(index(2).subs{:});
    else
      b = a.vf;
    end
   case 'pm'
    if length(index) == 2
      b = a.pm(index(2).subs{:});
    else
      b = a.pm;
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
   case 'delta'
    if length(index) == 2
      b = a.delta(index(2).subs{:});
    else
      b = a.delta;
    end
   case 'omega'
    if length(index) == 2
      b = a.omega(index(2).subs{:});
    else
      b = a.omega;
    end
   case 'e1q'
    b = a.e1q;
   case 'e1d'
    b = a.e1d;
   case 'e2q'
    b = a.e2q;
   case 'e2d'
    b = a.e2d;
   case 'psiq'
    b = a.psiq;
   case 'psid'
    b = a.psid;
   case 'store'
    b = a.store;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
