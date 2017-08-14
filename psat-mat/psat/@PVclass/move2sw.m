function data = move2sw(a)

global DAE

[amax,idx] = max(a.u.*a.con(:,4));
data = [a.con(idx,[1 2 3 5]), ...
        DAE.y(a.bus(idx)), ...
        a.con(idx,[6 7 8 9 4 10]), 0, 1];
a = remove(a,idx);
