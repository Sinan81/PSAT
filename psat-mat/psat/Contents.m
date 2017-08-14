% PSAT - Power System Analysis Toolbox
%
% Copyright (C) 2002-2016 Federico Milano
%
% E-mail:    federico.milano@ucd.ie
% Web-site:  faraday1.ucd.ie/psat.html
%
% This toolbox is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2.0 of the License, or
% (at your option) any later version.
%
% This toolbox is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANDABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this toolbox; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
% USA.
%
% General Functions and GUIs:
%   psat    - start the program
%   fm_set     - general settings and utilities
%   fm_var     - global variable definition
%   fm_main    - main GUI
%
% Power Flow:
%   fm_spf     - standard power flow
%   fm_flows   - P and Q flows in transmission lines
%   fm_nrlf    - power flow with fixed state variables
%   fm_dynlf   - indicization of state variables (before power flow)
%   fm_dynidx  - indicization of state variables (after power flow)
%   fm_xfirst  - initial guess of state variables
%   fm_ncomp   - indicization of components
%   fm_inilf   - reset variables for power flow computations
%   fm_stat    - GUI for power flow result visualization
%   fm_base    - report of component quantities on system bases
%   fm_report  - creates ASCII file for power flow solutions
%
% Continuation Power Flow:
%   fm_cpf    - continuation power flow
%   fm_n1cont - N-1 contingency computations
%   fm_cpffig - GUI for continuation power flow
%
% Direct Methods
%   fm_snb    - saddle-node bifurcation (SNB) analysis
%   fm_snbfig - GUI for SNB analysis
%   fm_limit  - limit-induced bifurcation (LIB) analysis
%   fm_libfig - GUI for LIB analysis
%
% Optimal Power Flow:
%   fm_opf    - optimal power flow
%   fm_pareto - Pareto set computations
%   fm_atc    - Available transfer capability computations
%   fm_opffig - GUI for optimal power flow
%
% Small Signal Stability Analysis
%   fm_eigen  - eigenvalue computations
%   fm_eigfig - GUI for eigenvalue computations
%
% Time Domain Simulation:
%   fm_int   - time domain simulation
%   fm_tstep - definition of time step for transient computations
%   fm_out   - time domain simulation output
%   fm_snap  - GUI for snapshot settings
%
% User Defined Model Construction:
%   fm_build     - user define component builder
%   fm_comp      - general settings and utilities for component definition
%   fm_open      - open PSAT user defined models
%   fm_save      - save PSAT user defined models
%   fm_new       - reset user defined component variables
%   fm_add       - add user defined model variable
%   fm_del       - delete user defined model variable
%   fm_install   - install user defined component
%   fm_uninstall - uninstall user defined component
%   fm_component - GUI for user defined models
%   fm_make      - GUI for user defined component definition
%   fm_update    - GUI for displaying user defined model installation results
%   fm_cset      - GUI for component settings
%   fm_xset      - GUI for state variable settings
%   fm_sset      - GUI for service variable settings
%   fm_pset      - GUI for parameter variable settings
%
% Utilities Functions:
%   fm_idx     - name variable definition
%   fm_iidx    - find bus interconnetcions
%   fm_filenum - enumeration of output files
%   fm_status  - display convergence error
%   fvar       - convert variables in strings
%   pgrep      - search m-files for string
%   psed       - substitute string in m-files
%   sizefig    - determine figure size
%
% Output Text Functions:
%   fm_write    - call function for writing output results
%   fm_writehtm - write output results in HTML format
%   fm_writetex - write output results in LaTeX format
%   fm_writetxt - write output results in plain text
%   fm_writexls - write output results in Excel format
%
% Simulink Library and Utilities:
%   fm_lib       - PSAT library for Simulink
%   fm_simrep    - power flow report for Simulink models
%   fm_simset    - GUI for Simulink model settings
%   fm_simsave   - Save model as Simulink 3 (R11)
%
% Data File Conversion:
%   fm_dir     - GUI for data file conversion
%   fm_dirset  - general settings and utilities for data file conversion
%   filters/chapman2psat  - Chapman to PSAT filter (perl file)
%   filters/cyme2psat     - CYMFLOW to PSAT filter (perl file)
%   filters/epri2psat     - EPRI to PSAT filter (perl file)
%   filters/flowdemo2psat - FlowDemo.net to PSAT filter (perl file)
%   filters/ge2psat       - GE to PSAT filter (perl file)
%   filters/ieee2psat     - IEEE CDF to PSAT filter (perl file)
%   filters/matpower2psat - Matpower to PSAT filter (m-file)
%   filters/neplan2psat   - NEPLAN to PSAT filter (perl file)
%   filters/pcflo2psat    - PCFLO to PSAT filter (perl file)
%   filters/psap2psat     - PSAP to PSAT filter (perl file)
%   filters/psat2epri     - PSAT to EPRI filter (m-file)
%   filters/psat2ieee     - PSAT to IEEE filter (m-file)
%   filters/psse2psat     - PSS/E to PSAT filter (perl file)
%   filters/pst2psat      - PST to PSAT filter (m-file)
%   filters/pwrworld2psat - Powerworld to PSAT filter (perl file)
%   filters/sim2psat      - Simulink to PSAT filter (m-file)
%   filters/simpow2psat   - SIMPOW to PSAT filter (perl file)
%   filters/th2psat       - Tsinghua Univ. to PSAT filter (perl file)
%   filters/ucte2psat     - UCTE to PSAT filter (perl file)
%   filters/vst2psat      - VST to PSAT filter (perl file)
%
% Plotting Utilities:
%   fm_plot     - general function for plotting results
%   fm_plotfig  - GUI for plotting results
%   fm_axesdlg  - GUI for axes properties settings
%   fm_linedlg  - GUI for line properties settings
%   fm_linelist - GUI for line list browser
%   fm_view     - general function for sparse matrix visualization
%   fm_matrx    - GUI for sparse matrix visualization
%
% Command History:
%   fm_text - command history genral functions and utilities
%   fm_hist - GUI for command history visualization
%   fm_disp - command, message and error display
%   fval    - message line for variable manipulation
%
% Themes:
%   fm_theme    - general theme manager
%   fm_themefig - GUI of theme manager
%   fm_mat      - background for GUI images
%
% Other GUI Utilities:
%   fm_setting - GUI for general settings
%   fm_enter   - welcome GUI
%   fm_tviewer - GUI for text viewer selection
%   fm_about   - about PSAT
%   fm_iview   - image viewer
%   fm_author  - author's pic
%   fm_time    - the Long Now Organization
%   fm_clock   - analogic watch
%
% GNU License Files:
%   gnulicense  - type the GNU-GPL
%   fm_license  - GUI for the GNU-GPL
%   gnuwarranty - type the "no warranty" conditions
%   fm_warranty - GUI for the "no warranty" conditions
%
% PMU Placement Functions:
%   fm_pmuloc    - PMU placement manager
%   fm_pmun1     - PMU placement for device outages
%   fm_pmurec    - recursive method for PMU placement
%   fm_pmutry    - filter for zero-injection buses
%   fm_lssest    - linear static state estimation
%   fm_spantree  - spanning tree of existing PMUs
%   fm_mintree   - minimum tree search
%   fm_annealing - annealing method for PMU placement
%   fm_pmufig    - GUI for PMU placement
%
% Command Line Usage:
%   initpsat  - nitialize PSAT global variables
%   closepsat - clear all PSAT global variables from workspace
%   runpsat   - launch PSAT routine
%
% Interface Functions:
%   fm_gams    - GAMS interface for single-period OPF
%   fm_gamsfig - GUI of the GAMS interface
%   fm_uwpflow - UWPFLOW interface
%   fm_uwfig   - GUI of the UWPFLOW interface
%
% Numeric Linear Analysis Functions:
%   fex_abcd      - compute numeric matrices A, B, C and D