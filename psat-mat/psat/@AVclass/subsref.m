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
   case 'bus'
    if length(index) == 2
      b = a.bus(index(2).subs{:});
    else
      b = a.bus;
    end
   case 'vref'
    if length(index) == 2
      b = a.vref(index(2).subs{:});
    else
      b = a.vref;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'syn'
    if length(index) == 2
      b = a.syn(index(2).subs{:});
    else
      b = a.syn;
    end
   case 'vbus'
    b = a.vbus;
   case 'n'
    b = a.n;
   case 'vf'
    b = a.vf;
   case 'vfd'
    b = a.vfd;
   case 'vm'
    b = a.vm;
   case 'vr1'
    b = a.vr1;
   case 'vr2'
    b = a.vr2;
   case 'vr3'
    b = a.vr3;
   case 'vref0'
    if length(index) == 2
      b = a.vref0(index(2).subs{:});
    else
      b = a.vref0;
    end
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
