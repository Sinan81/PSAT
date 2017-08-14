function out = vsi(a)

global DAE Line

out = zeros(a.n,1);

SIv  = find(a.type == 1);  % V
SIPs = find(a.type == 2);  % Pij
SIPr = find(a.type == 3);  % Pji
SIIs = find(a.type == 4);  % Iij
SIIr = find(a.type == 5);  % Iji
SIQs = find(a.type == 6);  % Qij
SIQr = find(a.type == 7);  % Qji

if SIPs, Ps = pjflows(Line,1,a.idx(SIPs),1); end
if SIPr, Pr = pjflows(Line,2,a.idx(SIPr),1); end
if SIIs, Is = pjflows(Line,3,a.idx(SIIs),1); end
if SIIr, Ir = pjflows(Line,4,a.idx(SIIr),1); end
if SIQs, Qs = pjflows(Line,5,a.idx(SIQs),1); end
if SIQr, Qr = pjflows(Line,6,a.idx(SIQr),1); end

if SIv , out(SIv)  = DAE.y(a.idx(SIv)); end
if SIPs, out(SIPs) = Ps; end
if SIPr, out(SIPr) = Pr; end
if SIIs, out(SIIs) = Is; end
if SIIr, out(SIIr) = Ir; end
if SIQs, out(SIQs) = Qs; end
if SIQr, out(SIQr) = Qr; end
