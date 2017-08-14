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
   case 'vw'
    if length(index) == 2
      b = a.vw(index(2).subs{:});
    else
      b = a.vw;
    end
   case 'ws'
    if length(index) == 2
      b = a.ws(index(2).subs{:});
    else
      b = a.ws;
    end
   case 'vwa'
    b = a.vwa;
   case 'n'
    b = a.n;
   case 'store'
    b = a.store;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
   case 'speed'
    if length(index) == 2
      switch index(2).subs
       case 'vw'
        b = a.speed.vw;
       case 'time'
        b = a.speed.time;
      end
    elseif length(index) == 3
      switch index(3).subs
       case 'vw'
        b = a.speed(index(2).subs{:}).vw;
       case 'time'
        b = a.speed(index(2).subs{:}).time;
      end
    else
      b = a.speed;
    end
  end
end
