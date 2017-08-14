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
   case 'n'
    a.n = val;
   case 'bus'
    if length(index) == 2
      a.bus(index(2).subs{:}) = val;
    else
      a.bus = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'vbus'
    if length(index) == 2
      a.vbus(index(2).subs{:}) = val;
    else
      a.vbus = val;
    end
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
