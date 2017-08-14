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
   case 'fr'
    if length(index) == 2
      b = a.fr(index(2).subs{:});
    else
      b = a.fr;
    end
   case 'vfr'
    if length(index) == 2
      b = a.vfr(index(2).subs{:});
    else
      b = a.vfr;
    end
   case 'to'
    if length(index) == 2
      b = a.to(index(2).subs{:});
    else
      b = a.to;
    end
   case 'vto'
    if length(index) == 2
      b = a.vto(index(2).subs{:});
    else
      b = a.vto;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'Y'
    if length(index) == 2
      b = a.Y(index(2).subs{:});
    else
      b = a.Y;
    end
   case 'Bp'
    if length(index) == 2
      b = a.Bp(index(2).subs{:});
    else
      b = a.Bp;
    end
   case 'Bpp'
    if length(index) == 2
      b = a.Bpp(index(2).subs{:});
    else
      b = a.Bpp;
    end
   case 'n'
    b = a.n;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
   case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end
  end
end
