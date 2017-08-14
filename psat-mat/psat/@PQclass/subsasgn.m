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
   case 'bus'
    a.bus = val;
   case 'gen'
    a.gen = val;
   case 'shunt'
    a.shunt = val;
   case 'n'
    a.n = val;
   case 'P0'
    if length(index) == 2
      a.P0(index(2).subs{:}) = val;
    else
      a.P0 = val;
    end
   case 'Q0'
    if length(index) == 2
      a.Q0(index(2).subs{:}) = val;
    else
      a.Q0 = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
