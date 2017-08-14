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
   case 'bus'
    a.bus = val;
   case 'Ik'
    a.Ik = val;    
   case 'Vk'
    a.Vk = val;    
   case 'pH2'
    a.pH2 = val;    
   case 'pH2O'
    a.pH2O = val;    
   case 'pO2'
    a.pO2 = val;    
   case 'qH2'
    a.qH2 = val;    
   case 'm'
    a.m = val;
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
