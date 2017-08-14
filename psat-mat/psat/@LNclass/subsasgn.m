function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'Y'
    if length(index) == 2
      a.Y(index(2).subs{:}) = val;
    else
      a.Y = val;
    end
   case 'p'
    if length(index) == 2
      a.p(index(2).subs{:}) = val;
    else
      a.p = val;
    end
   case 'q'
    if length(index) == 2
      a.q(index(2).subs{:}) = val;
    else
      a.q = val;
    end
   case 'fr'
    if length(index) == 2
      a.fr(index(2).subs{:}) = val;
    else
      a.fr = val;
    end
   case 'to'
    if length(index) == 2
      a.to(index(2).subs{:}) = val;
    else
      a.to = val;
    end
   case 'n'
    a.n = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
