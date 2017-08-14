function psatdomain(input)
% PSATDOMAIN defines the domain for the PSAT-Simulink library
%
% PSATDOMAIN(INPUT)
%          INPUT -> OBJECT OF THE Simulink.SlDomainInfo CLASS
%
% This function has been obtained by hacking Simulink
% classes, as no official documentation has been found.
%
%Author:    Federico Milano
%Date:      31-Dic-2005
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Path

% Methods for class Simulink.SlDomainInfo:
%
% Simulink.SlDomainPortType addPortType(SlDomainInfo, string)
% Simulink.SlDomainPortType findPortType(SlDomainInfo, string)
% Simulink.SlDomainImage getDomainImage(SlDomainInfo, string)

set(input, ...
    'name', 'PSATDomain', ...
    'lineBranching','off', ...
    'version','beta')

porttype = addPortType(input,'PMIOPort');
domainimage = getDomainImage(input, [Path.images,'domain_image.bmp']);

set(porttype,'icon',domainimage)