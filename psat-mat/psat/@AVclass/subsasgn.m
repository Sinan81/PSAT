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
   case 'vbus'
    a.vbus = val;
   case 'syn'
    a.syn = val;
   case 'vr1'
    a.vr1 = val;
   case 'vr2'
    a.vr2 = val;
   case 'vr3'
    a.vr3 = val;
   case 'vm'
    a.vm = val;
   case 'vf'
    a.vf = val;
   case 'vref'
    a.vref = val;
   case 'vref0'
    if length(index) == 2
      a.vref0(index(2).subs{:}) = val;
    else
      a.vref0 = val;
    end
   case 'n'
    a.n = val;
   case 'u'
    a.u = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
