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
   case 'dat'
    if length(index) == 2
      a.dat(index(2).subs{:}) = val;
    else
      a.dat = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'z'
    if length(index) == 2
      a.z(index(2).subs{:}) = val;
    else
      a.z = val;
    end
   case 'bus'
    a.bus = val;
   case 'vbus'
    a.vbus = val;
   case 'slip'
    a.slip = val;    
   case 'e1r'
    a.e1r = val;    
   case 'e1m'
    a.e1m = val;    
   case 'e2r'
    a.e2r = val;    
   case 'e2m'
    a.e2m = val;    
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
