function fm_pmurep
% FM_PMUREP write PMU Placement File
%
%Author:    Federico Milano
%Date:      15-Mar-2004
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global PMU

if isempty(PMU.report), fm_pmuloc; end

% writing data...
fm_write(PMU.report.Matrix,PMU.report.Header, ...
         PMU.report.Cols,PMU.report.Rows)