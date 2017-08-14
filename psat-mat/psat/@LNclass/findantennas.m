function [busidx,lineidx] = findantennas(a)
% FINDANTENNAS finds buses in antenna and returns the indexes
%              of buses and of the unique connected lines
%
% BUSIDX:  indexes of buses in antenna
% LINEIDX: indexes of lines connected to buses in antenna
%
global Bus

busidx = 0;
lineidx = [];

if ~a.n, return, end

nl = [1:a.n];
ivec = sparse(nl,a.fr,1,a.n,Bus.n);
jvec = sparse(nl,a.to,1,a.n,Bus.n);
lineidx = find(sum([ivec;jvec],1)==1);

disp(' ')

if isempty(lineidx)
  busidx = 0;
  fm_disp('All lines are used for (N-1) contingency evaluations.')
else
  busidx = find(sum(ivec(lineidx,:)+jvec(lineidx,:),2));
  fm_disp('Detected the following antennas:')
  fm_disp(fm_strjoin('Bus "',Bus.names(busidx),'" is in antenna.'))
  fm_disp(['When these lines are out, connected generators ', ...
           'and/or loads will be neglected.'])
end
