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
   case 'vf0'
    if length(index) == 2
      a.vf0(index(2).subs{:}) = val;
    else
      a.vf0 = val;
    end
   case 'pm0'
    if length(index) == 2
      a.pm0(index(2).subs{:}) = val;
    else
      a.pm0 = val;
    end
   case 'bus'
    a.bus = val;
   case 'vbus'
    a.vbus = val;
   case 'line'
    a.line = val;    
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
