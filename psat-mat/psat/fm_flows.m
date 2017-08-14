function varargout = fm_flows(varargin)
%FM_FLOWS computes active and reactive flows in transmission lines
%
% [PIJ,QIJ,PJI,QJI] = FM_FLOWS
% [PIJ,QIJ,PJI,QJI,FRV,TOV] = FM_FLOWS
% [PIJ,QIJ,PJI,QJI,FR,TO] = FM_FLOWS('ONLYIDX')
% [FR,TO] = FM_FLOWS('BUS')
% [BUSES,NISLAND] = FM_FLOWS('CONNECTIVITY')
% [BUSES,NISLAND] = FM_FLOWS('CONNECTIVITY','VERBOSE')
%
%see also classes LINE, UPFC, TCSC and SSSC
%
%Author:    Federico Milano
%Date:      03-Aug-2006
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Line Upfc Sssc Tcsc Ltc Phs Hvdc Lines

if nargin
  type = varargin{1};
else
  type = 'voltage';
end

if ~strcmp(type,'onlyidx')
  [Ps,Qs,Pr,Qr] = flows(Line);
  [Ps,Qs,Pr,Qr] = flows(Tcsc,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Sssc,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Upfc,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Ltc,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Phs,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Hvdc,Ps,Qs,Pr,Qr);
  [Ps,Qs,Pr,Qr] = flows(Lines,Ps,Qs,Pr,Qr);
end

switch type
 case {'bus','onlyidx','connectivity'}
  Fr = [Line.fr; Ltc.bus1; Phs.bus1; Hvdc.bus1; Lines.bus1];
  To = [Line.to; Ltc.bus2; Phs.bus2; Hvdc.bus2; Lines.bus2];
 otherwise
  Fr = [Line.vfr; Ltc.v1; Phs.v1; Hvdc.v1; Lines.v1];
  To = [Line.vto; Ltc.v2; Phs.v2; Hvdc.v2; Lines.v2];
end

switch nargout
 case 2
  varargout{1} = Fr;
  varargout{2} = To;
 case 4
  varargout{1} = Ps;
  varargout{2} = Qs;
  varargout{3} = Pr;
  varargout{4} = Qr;
 case 6
  varargout{1} = Ps;
  varargout{2} = Qs;
  varargout{3} = Pr;
  varargout{4} = Qr;
  varargout{5} = Fr;
  varargout{6} = To;
end

if strcmp(type,'connectivity')

  global Bus Syn SW PV PQ Settings

  if Bus.n > 1000,
    msg = ['* Warning: The connectivity check is disabled for ' ...
            'networks with more than 1000 buses.'];
    fm_disp(msg)
    return
  end

  if nargin == 2
    flag = varargin{2};
  else
    flag = 'mute';
  end

  nb = Bus.n;
  U = [Line.u; Ltc.u; Phs.u; Hvdc.u; Lines.u];

  % connectivity matrix
  connect_mat = ...
      sparse(Fr,Fr,1,nb,nb) + ...
      sparse(Fr,To,U,nb,nb) + ...
      sparse(To,To,1,nb,nb) + ...
      sparse(To,Fr,U,nb,nb);

  % find network islands using QR factorization
  if Settings.octave
    [Q,R] = qr(full(connect_mat));
  else
    [Q,R] = qr(connect_mat);
  end
  idx = find(abs(sum(R,2)-diag(R)) < 1e-5);

  % find generators per island
  nisland = length(idx);
  buses = [];
  if nisland > 1
    buses = cell(nisland,1);
    disp(['There are ',num2str(nisland),' islanded networks'])
    gen_bus = [getbus(Syn);getbus(SW);getbus(PV);getbus(PQ,'gen')];
    for i = 1:nisland
      buses{i} = find(Q(:,idx(i)));
      nbuses = length(buses{i});
      ngen = length(intersect(gen_bus,buses{i}));
      if strcmp(flag,'verbose')
        fm_disp([' * * Sub-network ', num2str(i),' has ', ...
                 num2str(nbuses),' bus(es) and ', ...
                 num2str(ngen),' generator(s)'])
      end
    end
  end

  if nargout
    varargout{1} = buses;
    varargout{2} = nisland;
  end

end