function islands_line(a)

if ~a.n, return, end

global Bus Ltc Phs Hvdc Lines

% looking for islanded buses
traceY = abs(sum(a.Y).'-diag(a.Y));
traceY = gettrace_ltc(Ltc,traceY);
traceY = gettrace_phs(Phs,traceY);
traceY = gettrace_hvdc(Hvdc,traceY);
traceY = gettrace_lines(Lines,traceY);

Bus = islands_bus(Bus,traceY);
