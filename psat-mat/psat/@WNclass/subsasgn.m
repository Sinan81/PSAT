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
   case 'vw'
    a.vw = val;
   case 'vwa'
    a.vwa = val;
   case 'n'
    a.n = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
   case 'speed'
    if length(index) == 2
      switch index(2).subs
       case 'vw'
        a.speed.vw = val;
       case 'time'
        a.speed.time = val;
      end
    elseif length(index) == 3
      switch index(3).subs
       case 'vw'
        a.speed(index(2).subs{:}).vw = val;
       case 'time'
        a.speed(index(2).subs{:}).time = val;
      end      
    end
  end
end
