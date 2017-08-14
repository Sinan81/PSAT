function fcall(a)

global DAE Settings

if ~a.n, return, end

DAE.f(a.vw) = (DAE.y(a.ws)-DAE.x(a.vw))./a.con(:,4);
