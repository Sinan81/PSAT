function islands(a)

if ~a.n, return, end

global Bus Ltc Phs Hvdc Lines

% looking for islanded buses
traceY = abs(sum(a.Y).'-diag(a.Y));
traceY = gettrace(Ltc,traceY);
traceY = gettrace(Phs,traceY);
traceY = gettrace(Hvdc,traceY);
traceY = gettrace(Lines,traceY);

Bus = islands(Bus,traceY);
