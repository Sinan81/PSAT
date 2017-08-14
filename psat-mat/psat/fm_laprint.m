function fm_laprint(figno,filename,varargin)
%FM_LAPRINT prints a figure for inclusion in LaTeX documents.
%  It creates an eps-file and a tex-file. The tex-file contains the
%  annotation of the figure such as titles, labels and texts. The
%  eps-file contains the non-text part of the figure as well as the 
%  position of the text-objects. The packages 'epsfig' and 'psfrag' are 
%  required for the LaTeX run. A postscript driver like 'dvips' is 
%  required for printing. 
%
%  Usage:   fm_laprint
%
%  This opens a graphical user interface window, to control the
%  various options. It is self-explainatory. Just try it.
%
%  Example: Suppose you have created a MATLAB Figure. Saving the figure 
%  with LaPrint (using default values everywhere), creates the two
%  files unnamed.eps and unnamed.tex. The tex-file calls the
%  eps-file and can be included into a LaTeX document as follows: 
%       .. \usepackage{epsfig,psfrag} ..
%       .. \input{unnamed} ..
%  This will create a figure of width 12cm in the LaTeX document. 
%  Its texts (labels,title, etc) are set in LaTeX and have 80% of the 
%  font size of the surrounding text. Figure widths, text font
%  sizes, file names and various other issues can be freely 
%  adjusted using the interface window.
%
%  Alternatively, you can control the behaviour of LaPrint using various 
%  extra input arguments. This is recommended for advanced users only.
%  Help on advanced usage is obtained by typing fm_laprint({'AdvancedHelp'}).
%
%  The document 'MATLAB graphics in LaTeX documents: Some tips and
%  a tool' contains more help on LaPrint and various examples. 
%  It can be obtained along with the most recent version of LaPrint
%  from http://www.uni-kassel.de/~linne/matlab/.

%  known problems and limitations, things to do, ...
%  --  The matlab functions copyobj and plotedit have bugs. 
%      If this is a problem, use option 'nofigcopy'.
%  --  multi-line text is not supported
%  --  cm is the only unit used (inches not supported)
%  --  a small preview would be nice

%  (c) Arno Linnemann.   All rights reserved. 
%  The author of this program assumes no responsibility for any  errors 
%  or omissions. In no event shall he be liable for damages  arising out of 
%  any use of the software. Redistribution of the unchanged file is allowed.
%  Distribution of changed versions is allowed provided the file is renamed
%  and the source and authorship of the original version is acknowledged in 
%  the modified file.

%  Please report bugs, suggestions and comments to:
%  Arno Linnemann
%  Control and Systems Theory
%  Department of Electrical Engineering 
%  University of Kassel
%  34109 Kassel
%  Germany
%  mailto:linnemann@uni-kassel.de
%  http://www.uni-kassel.de/~linne/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Initialize
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global LAPRINTOPT
global LAPRINTHAN
global Theme Fig

laprintident = '2.03 (19.1.2000)'; 
vers=version;
vers=eval(vers(1:3));
if vers < 5.0
  fm_disp('LaPrint Error: Matlab 5.0 or above is required.',2)
  return
end

% no output
if nargout
  fm_disp('La Print Error: No output argument is required.',2)
  return
end  

if nargin==0

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%
  %%%% GUI
  %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if ishandle(Fig.laprint), return, end
  
  %---------------------------------
  % default values
  %---------------------------------
  
  LAPRINTOPT.figno=gcf;
  LAPRINTOPT.filename='unnamed';
  LAPRINTOPT.verbose=0;
  LAPRINTOPT.asonscreen=0;
  LAPRINTOPT.keepticklabels=0;
  LAPRINTOPT.mathticklabels=0;
  LAPRINTOPT.keepfontprops=0;
  LAPRINTOPT.extrapicture=1;
  LAPRINTOPT.loose=0;
  LAPRINTOPT.nofigcopy=0;
  LAPRINTOPT.nohead=0;
  LAPRINTOPT.noscalefonts=0;
  LAPRINTOPT.caption=0;
  LAPRINTOPT.commenttext=['Figure No. ' int2str(LAPRINTOPT.figno)];
  LAPRINTOPT.width=12;
  LAPRINTOPT.factor=0.8;
  LAPRINTOPT.viewfile=0;
  LAPRINTOPT.viewfilename='unnamed_';
  
  LAPRINTOPT.HELP=1;
  
  %---------------------------------
  % open window
  %---------------------------------
  
  hf = figure;
  Fig.laprint = hf;
  clf reset;
  set(hf,'NumberTitle','off')
  %set(hf,'CreateFcn','Fig.laprint = hf;')
  set(hf,'FileName','fm_laprint')
  set(hf,'DeleteFcn','fm_laprint({''quit''})')
  set(hf,'MenuBar','none')
  set(hf,'Color',Theme.color01)
  set(hf,'Name','LaPrint (LaTeX Print)')
  set(hf,'Units','points')
  set(hf,'Resize','off')
  h=uicontrol(hf);
  set(h,'Units','points')
  fsize=get(h,'Fontsize');
  delete(h)
  posf=get(hf,'Position');
  figheight=30*fsize;
  posf= [ posf(1)   posf(2)+posf(4)-figheight ...
          31*fsize  figheight];
  set(hf,'Position',posf)
  curh=figheight-0*fsize;
  
  %---------------------------------
  % LaTeX logo
  %---------------------------------
  
  h1 = axes('Parent',hf, ...
            'Units','points', ...
            'Box','on', ...
            'CameraUpVector',[0 1 0], ...
            'CameraUpVectorMode','manual', ...
            'Color',Theme.color04, ...
            'HandleVisibility','on', ...
            'HitTest','off', ...
            'Layer','top', ...
            'Position',[23*fsize 20.5*fsize 7*fsize 7*fsize], ...
            'Tag','Axes1', ...
            'XColor',Theme.color03, ...
            'XLim',[0.5 128.5], ...
            'XLimMode','manual', ...
            'XTickLabelMode','manual', ...
            'XTickMode','manual', ...
            'YColor',Theme.color03, ...
            'YDir','reverse', ...
            'YLim',[0.5 128.5], ...
            'YLimMode','manual', ...
            'YTickLabelMode','manual', ...
            'YTickMode','manual', ...
            'ZColor',[0 0 0]);
  h2 = image('Parent',h1, ...
             'CData',fm_mat('misc_laprint'), ...
             'Tag','Axes1Image1', ...
             'XData',[1 128], ...
             'YData',[1 128]);

  %---------------------------------
  % figure no.
  %---------------------------------

  loch=1.7*fsize;
  curh=curh-loch-1*fsize;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'BackgroundColor',Theme.color01)
  set(h,'style','text')
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 8*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string','Figure No.:')

  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'Parent',hf)
  set(h,'style','edit')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[10*fsize curh 3*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'String',int2str(LAPRINTOPT.figno))
  set(h,'Callback','fm_laprint({''figno''});')
  LAPRINTHAN.figno=h;

  %---------------------------------
  % filename
  %---------------------------------

  loch=1.7*fsize;
  curh=curh-loch;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 8*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string','filename (base):')

  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'Parent',hf)
  set(h,'style','edit')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[10*fsize curh 12*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'String',LAPRINTOPT.filename)
  set(h,'Callback','fm_laprint({''filename''});')
  LAPRINTHAN.filename=h;

  %---------------------------------
  % width
  %---------------------------------

  loch=1.7*fsize;
  curh=curh-loch-1*fsize;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 17*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string','Width in LaTeX document [cm]:')

  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'Parent',hf)
  set(h,'style','edit')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[19*fsize curh 3*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'String',num2str(LAPRINTOPT.width))
  set(h,'Callback','fm_laprint({''width''});')
  LAPRINTHAN.width=h;

  %---------------------------------
  % factor
  %---------------------------------

  loch=1.7*fsize;
  curh=curh-loch;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 17*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string','Factor to scale fonts and eps figure:')

  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'Parent',hf)
  set(h,'style','edit')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[19*fsize curh 3*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'String',num2str(LAPRINTOPT.factor))
  set(h,'Callback','fm_laprint({''factor''});')
  LAPRINTHAN.factor=h;

  %---------------------------------
  % show sizes
  %---------------------------------

  loch=1.7*fsize;
  curh=curh-loch;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 22*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string',[ 'latex figure size: ' ])
  LAPRINTHAN.texsize=h;

  loch=1.7*fsize;
  curh=curh-loch;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 22*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string',[ 'postscript figure size: ' ])
  LAPRINTHAN.epssize=h;

  %---------------------------------
  % comment/caption text
  %---------------------------------
  loch=1.7*fsize;
  curh=curh-loch-fsize;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 12*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'string','Comment/Caption text:')

  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','edit')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[14*fsize curh 16*fsize loch])
  set(h,'HorizontalAlignment','left')
  set(h,'String',LAPRINTOPT.commenttext)
  set(h,'Callback','fm_laprint({''commenttext''});')
  LAPRINTHAN.commenttext=h;

  %---------------------------------
  % text
  %---------------------------------

  loch=10*fsize;
  curh=curh-loch-fsize;
  h = uicontrol;
  set(h,'Parent',hf)
  set(h,'style','text')
  set(h,'FontName',Theme.font01)
  set(h,'BackgroundColor',Theme.color04)
  set(h,'ForegroundColor',Theme.color05)
  set(h,'Units','points')
  set(h,'Position',[1*fsize curh 29*fsize loch])
  set(h,'HorizontalAlignment','left')
  %set(h,'BackgroundColor',[1 1 1])
  LAPRINTHAN.helptext=h;
  if (isempty(get(LAPRINTOPT.figno,'children')))
    txt=['Warning: Figure ' int2str(LAPRINTOPT.figno) ... 
         ' is empty. There is nothing to do yet.' ];
  else
    txt='';
  end  
  showtext({['This is LaPrint, Version ', laprintident, ...
             ', by Arno Linnemann. ', ...
             'The present version was slightly modified by ', ...
             'Federico Milano (17.12.2003) and can be used only from within ', ...
             'PSAT. To get started, press ''Help'' below.', txt]})
  showsizes;
  %---------------------------------
  % save, quit, help
  %---------------------------------

  loch=2*fsize;
  curh=curh-loch-fsize;
  h=uicontrol;
  set(h,'Parent',hf)
  set(h,'Style','pushbutton')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','Points')
  set(h,'Position',[23*fsize curh 5*fsize loch])
  set(h,'HorizontalAlignment','center')
  set(h,'String','Quit')
  set(h,'Callback','fm_laprint({''quit''});')

  h=uicontrol;
  set(h,'Parent',hf)
  set(h,'Style','pushbutton')
  set(h,'BackgroundColor',Theme.color01)
  set(h,'Units','Points')
  set(h,'Position',[13*fsize curh 5*fsize loch])
  set(h,'HorizontalAlignment','center')
  set(h,'String','Help')
  set(h,'Callback','fm_laprint({''help''});')

  h=uicontrol;
  set(h,'Parent',hf)
  set(h,'BackgroundColor',Theme.color03)
  set(h,'FontWeight','bold')
  set(h,'ForegroundColor',Theme.color09)
  set(h,'Style','pushbutton')
  set(h,'Units','Points')
  set(h,'Position',[3*fsize curh 5*fsize loch])
  set(h,'HorizontalAlignment','center')
  set(h,'String','Export')
  set(h,'Callback','fm_laprint({''save''});')

  %---------------------------------
  % options uimenue
  %---------------------------------

  % Menu File
  h1 = uimenu('Parent',hf, ...
              'Label','File', ...
              'Tag','MenuFile');
  h2 = uimenu('Parent',h1, ...
              'Label', 'Export figure', ...
              'Callback','fm_laprint({''save''});', ... 
              'Accelerator','s', ...
              'Tag','file_save');
  h2 = uimenu('Parent',h1, ...
              'Label', 'Quit LaPrint', ...
              'Callback','fm_laprint({''quit''});', ... 
              'Accelerator','x', ...
              'Separator','on', ...
              'Tag','file_quit');

  hm=uimenu('label','Options');

  LAPRINTHAN.asonscreen=uimenu(hm,...
                               'label','as on screen',...
                               'callback','fm_laprint({''asonscreen''})',...
                               'checked','off');

  LAPRINTHAN.keepticklabels=uimenu(hm,...
                                   'label','keep tick labels',...
                                   'callback','fm_laprint({''keepticklabels''})',...
                                   'checked','off');

  LAPRINTHAN.mathticklabels=uimenu(hm,...
                                   'label','math tick labels',...
                                   'callback','fm_laprint({''mathticklabels''})',...
                                   'checked','off');

  LAPRINTHAN.keepfontprops=uimenu(hm,...
                                  'label','keep font props',...
                                  'callback','fm_laprint({''keepfontprops''})',...
                                  'checked','off');

  LAPRINTHAN.extrapicture=uimenu(hm,...
                                 'label','extra picture',...
                                 'callback','fm_laprint({''extrapicture''})',...
                                 'checked','on');

  LAPRINTHAN.loose=uimenu(hm,...
                          'label','print loose',...
                          'callback','fm_laprint({''loose''})',...
                          'checked','off');

  LAPRINTHAN.nofigcopy=uimenu(hm,...
                              'label','figure copy',...
                              'callback','fm_laprint({''nofigcopy''})',...
                              'checked','on');

  LAPRINTHAN.nohead=uimenu(hm,...
                           'label','file head',...
                           'callback','fm_laprint({''nohead''})',...
                           'checked','on');

  LAPRINTHAN.noscalefonts=uimenu(hm,...
                                 'label','scale fonts',...
                                 'callback','fm_laprint({''noscalefonts''})',...
                                 'checked','on');

  LAPRINTHAN.caption=uimenu(hm,...
                            'label','caption',...
                            'callback','fm_laprint({''caption''})',...
                            'checked','off');

  LAPRINTHAN.viewfile=uimenu(hm,...
                             'label','viewfile',...
                             'callback','fm_laprint({''viewfile''})',...
                             'checked','off');

  uimenu(hm,...
         'label','Defaults',...
         'callback','laprint({''defaults''})',...
         'separator','on');

  % Menu Help
  h1 = uimenu('Parent',hf, ...
              'Label','Help', ...
              'Tag','MenuFile');
  h2 = uimenu('Parent',h1, ...
              'Label', 'LaPrint help', ...
              'Callback','fm_laprint({''help''});', ... 
              'Accelerator','h', ...
              'Tag','file_help');
  h2 = uimenu('Parent',h1, ...
              'label','About',...
              'callback','fm_laprint({''whois''})');

  %---------------------------------
  % make hf invisible
  %---------------------------------
  set(hf,'HandleVisibility','callback') 

  return
end  % if nargin==0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% callback calls
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isa(figno,'cell')
  switch lower(figno{1})
    %%% figno %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'figno'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.figno=eval(get(LAPRINTHAN.figno,'string'));
    figure(LAPRINTOPT.figno)
    figure(Fig.laprint)
    txt=[ 'Pushing ''Export'' will save the contents of Figure No. '...
	  int2str(LAPRINTOPT.figno) '.' ];
    showtext({txt});
    %%% filename %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'filename'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.filename=get(LAPRINTHAN.filename,'string');
    LAPRINTOPT.viewfilename=[ LAPRINTOPT.filename '_'];
    [texfullnameext,texbasenameext,texbasename,texdirname] = ...
	getfilenames(LAPRINTOPT.filename,'tex',0);
    [epsfullnameext,epsbasenameext,epsbasename,epsdirname] = ...
	getfilenames(LAPRINTOPT.filename,'eps',0);
    txt0=[ 'Pushing ''save'' will create the following files:' ];
    txt1=[ texfullnameext '  (LaTeX file)' ];
    txt2=[ epsfullnameext '  (Postscript file)'];
    if exist(texfullnameext,'file')
      txt5=[ 'Warning: LaTeX file exists an will be overwritten.'];
    else 
      txt5='';
    end  
    if exist(epsfullnameext,'file')
      txt6=[ 'Warning: Postscript file exists an will be overwritten.'];
    else 
      txt6='';
    end
    if LAPRINTOPT.viewfile
      [viewfullnameext,viewbasenameext,viewbasename,viewdirname] = ...
 	  getfilenames(LAPRINTOPT.viewfilename,'tex',0);
      txt3=[ viewfullnameext '  (View file)'];
      if exist(viewfullnameext,'file')
        txt7=[ 'Warning: View file exists an will be overwritten.'];
      else 
        txt7='';
      end
    else
      txt3='';
      txt7='';
    end 
    showtext({txt0,txt1,txt2,txt3,txt5,txt6,txt7});
    %%% width %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'width'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.width=eval(get(LAPRINTHAN.width,'string'));
    txt1=[ 'The width of the figure in the LaTeX document is set to '...
	   int2str(LAPRINTOPT.width) ' cm. Its height is determined '...
	   'by the aspect ratio of the figure on screen '...
	   '(i.e. the figure ''position'' property).']; 
    showtext({txt1});
    showsizes;
    %%% factor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'factor'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.factor=eval(get(LAPRINTHAN.factor,'string'));
    txt1=[ 'The factor to scale the fonts and the eps figure is set to '...
	   num2str(LAPRINTOPT.factor) '.'];
    if LAPRINTOPT.factor < 1
      txt2=[ 'Thus the (bounding box of the) eps figure is ' ...
	     'larger than the figure in the LaTeX document ' ...
	     'and the text fonts of the figure are ' ...
	     'by the factor ' num2str(LAPRINTOPT.factor) ' smaller ' ...
	     'than the fonts of the surrounding text.'];
    elseif LAPRINTOPT.factor > 1
      txt2=[ 'Thus the (bounding box of the) eps figure ' ...
	     'is smaller than the figure in the LaTeX document. ' ...
	     'Especially, the text fonts of the figure are ' ...
	     'by the factor ' num2str(LAPRINTOPT.factor) ' larger ' ...
	     'than the fonts of the surrounding text.'];
    else 
      txt2=[ 'Thus the eps figure is displayed 1:1.'...
	     'Especially, the text fonts of the figure are of ' ...
	     'the same size as the fonts of the surrounding text.'];
    end  
    showtext({txt1,txt2});
    showsizes;
   case 'commenttext'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.commenttext=get(LAPRINTHAN.commenttext,'string');
    txt=[ 'The comment text is displayed in the commenting header '...
          'of the tex file. This is for bookkeeping only.' ...
          'If the option ''caption'' is set to ''on'', then '...
          'this text is also displayed in the caption of the figure.'];
    showtext({txt});
    %%% options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'asonscreen'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', the ticks, ticklabels '...
	   'and lims are printed ''as on screen''. Note that the '...
	   'aspect ratio of the printed figure is always equal '...
	   'to the aspect ratio on screen.'];
    if LAPRINTOPT.asonscreen==1
      LAPRINTOPT.asonscreen=0;
      set(LAPRINTHAN.asonscreen,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.asonscreen=1;
      set(LAPRINTHAN.asonscreen,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'keepticklabels'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', the tick labels '...
	   'are kept within the eps-file and are therefore not set '...
	   'in LaTeX. This option is useful for some rotated 3D plots.'];
    if LAPRINTOPT.keepticklabels==1
      LAPRINTOPT.keepticklabels=0;
      set(LAPRINTHAN.keepticklabels,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.keepticklabels=1;
      set(LAPRINTHAN.keepticklabels,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'mathticklabels'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', the tick labels '...
	   'are set in LaTeX math mode.'];
    if LAPRINTOPT.mathticklabels==1
      LAPRINTOPT.mathticklabels=0;
      set(LAPRINTHAN.mathticklabels,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.mathticklabels=1;
      set(LAPRINTHAN.mathticklabels,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'keepfontprops'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint tries to ',...
	   'translate the MATLAB font properties (size, width, ',...
	   'angle) into similar LaTeX font properties. Set to ''off'', ',...
	   'LaPrint does not introduce any LaTeX font selection commands.'];
    if LAPRINTOPT.keepfontprops==1
      LAPRINTOPT.keepfontprops=0;
      set(LAPRINTHAN.keepfontprops,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.keepfontprops=1;
      set(LAPRINTHAN.keepfontprops,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'loose'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint uses the ',...
	   '''-loose'' option in the Matlab print command. '];
    if LAPRINTOPT.loose==1
      LAPRINTOPT.loose=0;
      set(LAPRINTHAN.loose,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.loose=1;
      set(LAPRINTHAN.loose,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'extrapicture'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint adds an ',...
	   'extra picture environment to each axis correponding to a '...
	   '2D plot. The picture ',...
	   'is empty, but alows to place LaTeX objects in arbitrary ',...
	   'positions by editing the tex file. '];
    if LAPRINTOPT.extrapicture==1
      LAPRINTOPT.extrapicture=0;
      set(LAPRINTHAN.extrapicture,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.extrapicture=1;
      set(LAPRINTHAN.extrapicture,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'nofigcopy'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint creates a temporary ',...
	   'figure to introduce the tags. If set to ''off'', it directly ',...
	   'modifies the original figure. ' ...
	   'There are some bugs in the Matlab copyobj '...
	   'command. If you encounter these cases, set this '...
	   'option to ''off''.'];
    if LAPRINTOPT.nofigcopy==1
      LAPRINTOPT.nofigcopy=0;
      set(LAPRINTHAN.nofigcopy,'check','on')
      txt2= 'Current setting is: on'; 
    else
      LAPRINTOPT.nofigcopy=1;
      set(LAPRINTHAN.nofigcopy,'check','off')
      txt2='Current setting is: off'; 
    end      
    showtext({txt1, txt2});
   case 'nohead'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint ',...
	   'adds a commenting head to the tex-file. To save disk '...
	   'space, out can turn this option ''off''.'];
    if LAPRINTOPT.nohead==1
      LAPRINTOPT.nohead=0;
      set(LAPRINTHAN.nohead,'check','on')
      txt2= 'Current setting is: on'; 
    else
      LAPRINTOPT.nohead=1;
      set(LAPRINTHAN.nohead,'check','off')
      txt2='Current setting is: off'; 
    end      
    showtext({txt1, txt2});
   case 'noscalefonts'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint scales the ',...
	   'fonts with the figure. With this option set to '...
	   '''off'', the font size in the figure is equal to the '...
	   'size of the surrounding text.'];
    if LAPRINTOPT.noscalefonts==1
      LAPRINTOPT.noscalefonts=0;
      set(LAPRINTHAN.noscalefonts,'check','on')
      txt2= 'Current setting is: on'; 
    else
      LAPRINTOPT.noscalefonts=1;
      set(LAPRINTHAN.noscalefonts,'check','off')
      txt2='Current setting is: off'; 
    end      
    showtext({txt1, txt2});
   case 'caption'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint  adds ',...
	   '\caption{' LAPRINTOPT.commenttext ,...
	   '} and \label{fig:' LAPRINTOPT.filename '} entries ',...
	   'to the tex-file.'];
    if LAPRINTOPT.caption==1
      LAPRINTOPT.caption=0;
      set(LAPRINTHAN.caption,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.caption=1;
      set(LAPRINTHAN.caption,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'viewfile'
    global LAPRINTOPT
    global LAPRINTHAN
    txt1=[ 'With this option set to ''on'', LaPrint creates an ',...
	   'additional file ' LAPRINTOPT.viewfilename ...
	   '.tex containing a LaTeX document ',...
	   'which calls the tex-file.'];
    if LAPRINTOPT.viewfile==1
      LAPRINTOPT.viewfile=0;
      set(LAPRINTHAN.viewfile,'check','off')
      txt2= 'Current setting is: off'; 
    else
      LAPRINTOPT.viewfile=1;
      set(LAPRINTHAN.viewfile,'check','on')
      txt2='Current setting is: on'; 
    end      
    showtext({txt1, txt2});
   case 'defaults'
    global LAPRINTOPT
    global LAPRINTHAN
    LAPRINTOPT.asonscreen=0;
    LAPRINTOPT.keepticklabels=0;
    LAPRINTOPT.mathticklabels=0;
    LAPRINTOPT.keepfontprops=0;
    LAPRINTOPT.extrapicture=1;
    LAPRINTOPT.loose=0;
    LAPRINTOPT.nofigcopy=0;
    LAPRINTOPT.nohead=0;
    LAPRINTOPT.noscalefonts=0;
    LAPRINTOPT.caption=0;
    LAPRINTOPT.viewfile=0;
    set(LAPRINTHAN.asonscreen,'check','off')
    set(LAPRINTHAN.keepticklabels,'check','off')
    set(LAPRINTHAN.mathticklabels,'check','off')
    set(LAPRINTHAN.keepfontprops,'check','off')
    set(LAPRINTHAN.extrapicture,'check','off')
    set(LAPRINTHAN.loose,'check','off')
    set(LAPRINTHAN.nofigcopy,'check','on')
    set(LAPRINTHAN.nohead,'check','on')
    set(LAPRINTHAN.noscalefonts,'check','on')
    set(LAPRINTHAN.caption,'check','off')
    set(LAPRINTHAN.viewfile,'check','off')
    showtext({[ 'All options availabe through the menu bar '...
                'are set to their default values.']});
   case 'whois'
    showtext({'To blame for LaPrint:',...
	      'Arno Linnemann','Control and Systems Theory',...
	      'Department of Electrical Engineering',...
	      'University of Kassel',...
	      '34109 Kassel      |   mailto:linnemann@uni-kassel.de'...
	      'Germany             |   http://www.uni-kassel.de/~linne/'})
    %%% help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'help'
    global LAPRINTOPT
    global LAPRINTHAN
    txt0='...Press ''Help'' again to continue....';
    if LAPRINTOPT.HELP==1
      txt=[ 'LAPRINT prints a figure for inclusion in LaTeX documents. ',...
            'It creates an eps-file and a tex-file. The tex-file contains the ',...
            'annotation of the figure such as titles, labels and texts. The ',...
            'eps-file contains the non-text part of the figure as well as the ',...
            'position of the text-objects.'];
      txt={txt,txt0};
    elseif LAPRINTOPT.HELP==2
      txt1= [ 'The packages epsfig and psfrag are ',...
              'required for the LaTeX run. A postscript driver like dvips is ',...
              'required for printing. ' ]; 
      txt2=' ';
      txt3= ['It is recommended to switch off the Matlab TeX ' ...
	     'interpreter before using LaPrint:'];
      txt4= ' >> set(0,''DefaultTextInterpreter'',''none'')';
      txt={txt1,txt2,txt3,txt4,txt0};
    elseif LAPRINTOPT.HELP==3
      txt1= [ 'EXAMPLE: Suppose you have created a MATLAB Figure.'];
      txt2= [ 'Saving the figure with LaPrint (using default '...
              'values everywhere), creates the two files unnamed.eps '...
              'and unnamed.tex. The tex-file calls the eps-file '...
              'and can be included into a LaTeX document as follows:']; 
      txt={txt1,txt2,txt0};
    elseif LAPRINTOPT.HELP==4
      txt1='    ..';
      txt2='    \usepackage{epsfig,psfrag}';
      txt3='    ..';
      txt4='    \input{unnamed}';
      txt5='    ..';
      txt={txt1,txt2,txt3,txt4,txt5,txt0};
    elseif LAPRINTOPT.HELP==5
      txt1=[ 'This will create a figure of width 12cm in the LaTeX '...
	     'document. Its texts (labels,title, etc) are set in '...
	     'LaTeX and have 80% of the font size of the '...
	     'surrounding text.'];
      txt={txt1,txt0};
    elseif LAPRINTOPT.HELP==6
      txt1=[ 'The LaTeX figure width, the scaling factor and the '...
	     'file names can be adjusted using '...
	     'this interface window.'];
      txt2=[ 'More options are available through the menu bar above. '...
	     'Associated help is displayed as you change the options.'];
      txt={txt1,txt2,txt0};
    elseif LAPRINTOPT.HELP==7
      txt1=[ 'The document ''MATLAB graphics in LaTeX documents: '...
	     'Some tips and a tool'' contains more help on LaPrint '...
	     'and various examples. It can be obtained along '...
	     'with the most recent version of LaPrint from '...
	     'http://www.uni-kassel.de/~linne/matlab/.'];
      txt2=[ 'Please report bugs, suggestions '...
	     'and comments to linnemann@uni-kassel.de.'];
      txt={txt1,txt2,txt0};
    else
      txt={'Have fun!'};
      LAPRINTOPT.HELP=0;  
    end  
    LAPRINTOPT.HELP=LAPRINTOPT.HELP+1;  
    showtext(txt);
    %%% quit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'quit'
    LAPRINTHAN=[];
    LAPRINTOPT=[];
    delete(Fig.laprint)
    Fig.laprint = -1;
    %%% Advanced Help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'advancedhelp'
    disp(' ')
    disp('Advanced usage: fm_laprint(figno,filename,opt1,opt2,..)')
    disp('where ')
    disp('  figno      : integer, figure to be printed')
    disp('  filename   : string, basename of files to be created')
    disp('  opt1,..    : strings, describing optional inputs as follows')
    disp('')
    disp('   ''width=xx''      : xx is the width of the figure in the tex')
    disp('                     file (in cm).')
    disp('   ''factor=xx''     : xx is the factor by which the figure in ')
    disp('                     the LaTeX document is smaller than the figure')
    disp('                     in the postscript file.')
    disp('                     A non-positive number for xx lets the factor')
    disp('                     be computed such that the figure in the')
    disp('                     postscript file has the same size as the')
    disp('                     figure on screen.')
    disp('   ''asonscreen''    : prints a graphics ''as on screen'',')
    disp('                     retaining ticks, ticklabels and lims.')
    disp('   ''verbose''       : verbose mode; asks before overwriting')
    disp('                     files and issues some more messages.') 
    disp('   ''keepticklabels'': keeps the tick labels within the eps-file')
    disp('   ''mathticklabels'': tick labels are set in LaTeX math mode')
    disp('   ''keepfontprops'' : tries to translate the MATLAB font') 
    disp('                     properties (size, width, angle) into')
    disp('                     similar LaTeX font properties.') 
    disp('   ''noscalefonts''  : does not scale the fonts with the figure.') 
    disp('   ''noextrapicture'': does not add extra picture environments.')
    disp('   ''loose''         : uses ''-loose'' in the Matlab print command.')
    disp('   ''nofigcopy''     : directly modifies the figure figno.')
    disp('   ''nohead''        : does not place a commenting head in ')
    disp('                     the tex-file. ')
    disp('   ''caption=xx''    : adds \caption{xx} and \label{fig:filename}') 
    disp('                     entries to the tex-file.')
    disp('   ''comment=xx''    : places the comment xx into the header') 
    disp('                     of the tex-file')
    disp('   ''viewfile=xx''   : creates an additional file xx.tex')
    disp('                     containing a LaTeX document which calls')
    disp('                     the tex-file.')
    disp(' ')
    
   %%% save %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'save'
    global LAPRINTOPT
    global LAPRINTHAN
    global Fig
    
    psatfigs = fieldnames(Fig);
    for hhh = 1:length(psatfigs)
      psatfigno = getfield(Fig,psatfigs{hhh});
      if psatfigno == LAPRINTOPT.figno        
        fm_choice('Exporting PSAT GUIs using LaPrint is not allowed.',2)
        return
      end
    end
    lapcmd = [ 'fm_laprint(' int2str(LAPRINTOPT.figno) ...
               ', ''' LAPRINTOPT.filename ''''...
               ', ''width=' num2str(LAPRINTOPT.width) '''' ...
               ', ''factor=' num2str(LAPRINTOPT.factor) '''' ];
    if LAPRINTOPT.verbose
      lapcmd = [ lapcmd ,', ''verbose''' ];
    end  
    if LAPRINTOPT.asonscreen
      lapcmd = [ lapcmd ,', ''asonscreen''' ];
    end  
    if LAPRINTOPT.keepticklabels
      lapcmd = [ lapcmd ,', ''keepticklabels''' ];
    end  
    if LAPRINTOPT.mathticklabels
      lapcmd = [ lapcmd ,', ''mathticklabels''' ];
    end  
    if LAPRINTOPT.keepfontprops
      lapcmd = [ lapcmd ,', ''keepfontprops''' ];
    end  
    if ~LAPRINTOPT.extrapicture
      lapcmd = [ lapcmd ,', ''noextrapicture''' ];
    end
    if LAPRINTOPT.loose
      lapcmd = [ lapcmd ,', ''loose''' ];
    end  
    if LAPRINTOPT.nofigcopy
      lapcmd = [ lapcmd ,', ''nofigcopy''' ];
    end  
    if LAPRINTOPT.nohead
      lapcmd = [ lapcmd ,', ''nohead''' ];
    end  
    if LAPRINTOPT.noscalefonts
      lapcmd = [ lapcmd ,', ''noscalefonts''' ];
    end  
    if LAPRINTOPT.caption
      lapcmd = [ lapcmd ,', ''caption=' LAPRINTOPT.commenttext '''' ];
    end  
    if length(LAPRINTOPT.commenttext)
      lapcmd = [ lapcmd ,', ''comment=' LAPRINTOPT.commenttext '''' ];
    end  
    if LAPRINTOPT.viewfile
      lapcmd = [ lapcmd ,', ''viewfile=' LAPRINTOPT.viewfilename '''' ];
    end  
    lapcmd = [ lapcmd ')'];
    showtext({'Saving using:', lapcmd });
    eval(lapcmd)
   otherwise
    fm_disp('LaPrint Error: unknown callback option!',2)
  end
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 1 of advanced usage:
%%%% Check inputs and initialize
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% called directly or via gui?
directcall=1;
iswarning=0;
if exist('LAPRINTHAN','var')
  if ~isempty(LAPRINTHAN)
    directcall=0;
  end
end  

if nargin==1
  if ~isa(figno,'char')
    filename='unnamed';
  else  
    filename=figno;
    figno=gcf;
  end  
end
if ~isa(figno,'double') 
  fm_disp(['LaPrint Error: "',num2str(figno),'" is not a figure handle.'],2) 
  return
end
if ~any(get(0,'children')==figno)
  fm_disp(['LaPrint Error: "',num2str(figno),'" is not a figure handle.'],2) 
  return
end
if ~isa(filename,'char')
  filename
  fm_disp(['La Print Error: file name is not valid.'],2) 
  return
end

% default values
furtheroptions='';
verbose=0;
asonscreen=0;
keepticklabels=0;
mathticklabels=0;
keepfontprops=0;
extrapicture=1;
loose=0;
nofigcopy=0;
nohead=0;
noscalefonts=0;
caption=0;
commenttext='';
captiontext='';
width=12;
factor=0.8;
viewfile=0;

% read and check options  
if nargin>2  
  for i=1:nargin-2
    if ~isa(varargin{i},'char')
      fm_disp('LaPrint Error: Options must be character arrays.',2)
      return
    end  
    oriopt=varargin{i}(:)';
    opt=[ lower(strrep(oriopt,' ','')) '                   ' ];
    if strcmp(opt(1:7),'verbose')
      verbose=1;
      furtheroptions=[ furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:10),'asonscreen')
      asonscreen=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:14),'keepticklabels')
      keepticklabels=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:14),'mathticklabels')
      mathticklabels=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:13),'keepfontprops')
      keepfontprops=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:14),'noextrapicture')
      extrapicture=0;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:5),'loose')
      loose=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:9),'nofigcopy')
      nofigcopy=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:12),'noscalefonts')
      noscalefonts=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:6),'nohead')
      nohead=1;
      furtheroptions=[furtheroptions ' / ' deblank(opt) ]; 
    elseif strcmp(opt(1:7),'caption')
      caption=1;
      eqpos=findstr(oriopt,'=');
      if isempty(eqpos)
	furtheroptions=[furtheroptions ' / ' deblank(opt) ];
	captiontext=[];
      else	
	furtheroptions=[furtheroptions ' / ' oriopt ];
	captiontext=oriopt(eqpos+1:length(oriopt));
      end	
    elseif strcmp(opt(1:8),'comment=')
      eqpos=findstr(oriopt,'=');
      furtheroptions=[furtheroptions ' / ' oriopt ];
      commenttext=oriopt(eqpos(1)+1:length(oriopt));
    elseif strcmp(opt(1:9),'viewfile=')
      viewfile=1;
      eqpos=findstr(oriopt,'=');
      furtheroptions=[furtheroptions ' / ' oriopt ];
      viewfilename=oriopt(eqpos(1)+1:length(oriopt));
    elseif strcmp(opt(1:6),'width=')
      eval([ opt ';' ]);
    elseif strcmp(opt(1:7),'factor=')
      eval([ opt ';' ]);
    else
      fm_disp(['LaPrint Error: Option ' varargin{i} ' not recognized.'],2)
      return
    end   
  end
end
furtheroptions=strrep(strrep(furtheroptions,'\','\\'),'%','%%');
captiontext=strrep(strrep(captiontext,'\','\\'),'%','%%');
commenttext=strrep(strrep(commenttext,'\','\\'),'%','%%');

if verbose, 
  fm_disp(['This is LaPrint, version ',laprintident,'.']); 
end  

if mathticklabels
  Do='$';
else  
  Do='';
end  

% eps- and tex- filenames
[epsfullnameext,epsbasenameext,epsbasename,epsdirname]= ...
    getfilenames(filename,'eps',verbose);
[texfullnameext,texbasenameext,texbasename,texdirname]= ...
    getfilenames(filename,'tex',verbose);
if ~strcmp(texdirname,epsdirname)
  fm_disp(['LaPrint Warning: eps-file and tex-file are placed in ' ...
           'different directories.'])  
  iswarning=1;
end  
if viewfile
  [viewfullnameext,viewbasenameext,viewbasename,viewdirname]= ...
      getfilenames(viewfilename,'tex',verbose);
  if strcmp(texfullnameext,viewfullnameext)
    fm_disp(['LaPrint Error: The tex- and view-file coincide. Use ' ...
             'different names.'],2)
    return
  end  
  if ~strcmp(texdirname,viewdirname)
    fm_disp(['LaPrint Warning: eps-file and view-file are placed '...
	   'in different directories.'])
    iswarning=1;
  end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 2 of advanced usage:
%%%% Create new figure, insert tags, and bookkeep original text
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open new figure (if required) and set properties

if ~nofigcopy
  figno=copyobj(figno,0);
  set(figno,'Numbertitle','off')
  set(figno,'MenuBar','none')
  pause(0.5)  
end  

if asonscreen
  xlimmodeauto=findobj(figno,'xlimmode','auto');
  xtickmodeauto=findobj(figno,'xtickmode','auto');
  xticklabelmodeauto=findobj(figno,'xticklabelmode','auto');
  ylimmodeauto=findobj(figno,'ylimmode','auto');
  ytickmodeauto=findobj(figno,'ytickmode','auto');
  yticklabelmodeauto=findobj(figno,'yticklabelmode','auto');
  zlimmodeauto=findobj(figno,'zlimmode','auto');
  ztickmodeauto=findobj(figno,'ztickmode','auto');
  zticklabelmodeauto=findobj(figno,'zticklabelmode','auto');
  set(xlimmodeauto,'xlimmode','manual')
  set(xtickmodeauto,'xtickmode','manual')
  set(xticklabelmodeauto,'xticklabelmode','manual')
  set(ylimmodeauto,'ylimmode','manual')
  set(ytickmodeauto,'ytickmode','manual')
  set(yticklabelmodeauto,'yticklabelmode','manual')
  set(zlimmodeauto,'ylimmode','manual')
  set(ztickmodeauto,'ytickmode','manual')
  set(zticklabelmodeauto,'yticklabelmode','manual')
end  
set(figno,'paperunits','centimeters');
set(figno,'units','centimeters');
%oripp=get(figno,'PaperPosition');
orip=get(figno,'Position');

if factor <= 0
  factor=width/orip(3);
end 
latexwidth=width;
epswidth=latexwidth/factor;
epsheight = epswidth*orip(4)/orip(3);

set(figno,'PaperPosition',[1 1 epswidth epsheight ])
set(figno,'Position',[orip(1)+0.5 orip(2)-0.5 epswidth epsheight ])
set(figno,'Name',[ 'To be printed; size: ' num2str(factor,3) ...
                   ' x (' num2str(epswidth,3) 'cm x ' num2str(epsheight,3) 'cm)' ])

asonscreen_dummy=0;
if asonscreen_dummy
  set(xlimmodeauto,'xlimmode','auto')
  set(xtickmodeauto,'xtickmode','auto')
  set(xticklabelmodeauto,'xticklabelmode','auto')
  set(ylimmodeauto,'ylimmode','auto')
  set(ytickmodeauto,'ytickmode','auto')
  set(yticklabelmodeauto,'yticklabelmode','auto')
  set(zlimmodeauto,'ylimmode','auto')
  set(ztickmodeauto,'ytickmode','auto')
  set(zticklabelmodeauto,'yticklabelmode','auto')
end

% some warnings
if directcall
  if (epswidth<13) || (epsheight<13*0.75)
    disp('warning: The size of the eps-figure is quite small.')
    disp('         The text objects might not be properly set.')
    disp('         Reducing ''factor'' might help.')
  end
  if latexwidth/epswidth<0.5
    disp([ 'warning: The size of the eps-figure is large compared ' ...
           'to the latex figure.' ])
    disp('         The text size might be too small.')
    disp('         Increasing ''factor'' might help.')
  end  
  if (orip(3)-epswidth)/orip(3) > 0.1
    disp(['warning: The size of the eps-figure is much smaller '...
	  'than the original'])
    disp('         figure on screen. Matlab might save different ticks and')
    disp([ '         ticklabels than in the original figure. See option ' ...
           '''asonsceen''. ' ])
  end
end  

if verbose
  disp('Strike any key to continue.');
  pause
end  

%
% TEXT OBJECTS: modify new figure 
%

% find all text objects
hxl=get(findobj(figno,'type','axes'),'xlabel');
hyl=get(findobj(figno,'type','axes'),'ylabel');
hzl=get(findobj(figno,'type','axes'),'zlabel');
hti=get(findobj(figno,'type','axes'),'title');
hte=findobj(figno,'type','text');
% array of all text handles
htext=unique([ celltoarray(hxl) celltoarray(hyl) celltoarray(hzl) ...
               celltoarray(hti) celltoarray(hte)]);
nt=length(htext);

% generate new strings and store old ones
oldstr=get(htext,'string');
newstr=cell(nt,1);
basestr='str00';
for i=1:nt
  if isa(oldstr{i},'cell')
    if length(oldstr{i})>1
      disp('LaPrint warning: Annotation in form of a cell is currently')
      disp('         not supported. Ignoring all but first component.')
      iswarning=1;
    end
    % To do: place a parbox here. 
    oldstr{i}=oldstr{i}{1};
  end  
  if size(oldstr{i},1)>1
    disp([ 'LaPrint warning: Annotation in form of string matrices ' ...
           'is currently not supported.' ])
    disp('         Ignoring all but first row.')
    iswarning=1;
    % To do: place a parbox here. 
    oldstr{i}=oldstr{i}(1,:);
  end  
  if length(oldstr{i})
    oldstr{i}=strrep(strrep(oldstr{i},'\','\\'),'%','%%');
    newstr{i} = overwritetail(basestr,i);
  else  
    newstr{i}='';    
  end
end

% replace strings in figure
for i=1:nt
  set(htext(i),'string',newstr{i});
  %set(htext(i),'visible','on');
end    

% get alignments
hora=get(htext,'HorizontalAlignment');
vera=get(htext,'VerticalAlignment');
align=cell(nt,1);
for i=1:nt
  align{i}=hora{i}(1);
  if strcmp(vera{i},'top')
    align{i}=[align{i} 't'];
  elseif strcmp(vera{i},'cap')
    align{i}=[align{i} 't'];
  elseif strcmp(vera{i},'middle')
    align{i}=[align{i} 'c'];
  elseif strcmp(vera{i},'baseline')
    align{i}=[align{i} 'B'];
  elseif strcmp(vera{i},'bottom')
    align{i}=[align{i} 'b'];
  end
end  

% get font properties and create commands
if nt > 0
  [fontsizecmd{1:nt}] = deal('');
  [fontanglecmd{1:nt}] = deal('');
  [fontweightcmd{1:nt}] = deal('');
end
selectfontcmd='';

if keepfontprops

  % fontsize
  set(htext,'fontunits','points');
  fontsize=get(htext,'fontsize');
  for i=1:nt
    fontsizecmd{i}=[ '\\fontsize{' num2str(fontsize{i}) '}{' ...
                     num2str(fontsize{i}*1.5) '}'  ];
  end
  
  % fontweight
  fontweight=get(htext,'fontweight');
  for i=1:nt
    if strcmp(fontweight{i},'light')
      fontweightcmd{i}=[ '\\fontseries{l}\\mathversion{normal}' ];
    elseif strcmp(fontweight{i},'normal')
      fontweightcmd{i}=[ '\\fontseries{m}\\mathversion{normal}' ];
    elseif strcmp(fontweight{i},'demi')
      fontweightcmd{i}=[ '\\fontseries{sb}\\mathversion{bold}' ];
    elseif strcmp(fontweight{i},'bold')
      fontweightcmd{i}=[ '\\fontseries{bx}\\mathversion{bold}' ];
    else
      disp([ ' LaPrint warning: unknown fontweight:' fontweight{i} ])
      iswarning=1;
      fontweightcmd{i}=[ '\\fontseries{m}\\mathversion{normal}' ];
    end
  end  

  % fontangle
  fontangle=get(htext,'fontangle');
  for i=1:nt
    if strcmp(fontangle{i},'normal')
      fontanglecmd{i}=[ '\\fontshape{n}' ];
    elseif strcmp(fontangle{i},'italic')
      fontanglecmd{i}=[ '\\fontshape{it}' ];
    elseif strcmp(fontangle{i},'oblique')
      fontangle{i}=[ '\\fontshape{it}' ];
    else
      disp([ ' LaPrint warning: unknown fontangle:' fontangle{i} ])
      iswarning=1;
      fontanglecmd{i}=[ '\\fontshape{n}' ];
    end
  end  
  selectfontcmd= '\\selectfont ';
  
end

%
% LABELS: modify new figure
%

if ~keepticklabels

  % all axes
  hax=celltoarray(findobj(figno,'type','axes'));
  na=length(hax);

  if directcall
    % try to figure out if we have 3D axes an warn
    issuewarning=0;
    for i=1:na
      issuewarning=max(issuewarning,is3d(hax(i)));
    end
    if issuewarning
      disp('LaPrint warning: There seems to be a 3D plot. The LaTeX labels are')
      disp('         possibly incorrect. The option  ''keepticklabels'' might')
      disp('         help. The option ''nofigcopy'' might be wise, too.')
    end
  end  

  % try to figure out if we linear scale with extra factor 
  % and determine powers of 10
  powers=NaN*zeros(na,3);  % matrix with powers of 10 
  for i=1:na                    % all axes
    allxyz={ 'x', 'y', 'z' };
    for ixyz=1:3                % x,y,z
      xyz=allxyz{ixyz};
      ticklabelmode=get(hax(i),[ xyz 'ticklabelmode']);
      if strcmp(ticklabelmode,'auto')
        tick=get(hax(i),[ xyz 'tick']);
        ticklabel=get(hax(i),[ xyz 'ticklabel']);	      
	nticks=size(ticklabel,1);
	if nticks==0,
          powers(i,ixyz)=0;
	end  
        for k=1:nticks        % all ticks
	  label=str2num(ticklabel(k,:));
	  if length(label)==0, 
	    powers(i,ixyz)=0;
	    break; 
	  end  
	  if ( label==0 ) && ( abs(tick(k))>1e-10 )
	    powers(i,ixyz)=0;
	    break; 
          end	      
	  if label~=0    
            expon=log10(tick(k)/label);
	    rexpon=round(expon);
	    if abs(rexpon-expon)>1e-10
              powers(i,ixyz)=0;
	      break; 
	    end	
            if isnan(powers(i,ixyz))
	      powers(i,ixyz)=rexpon;
	    else 	
	      if powers(i,ixyz)~=rexpon
        	powers(i,ixyz)=0;
	        break; 
              end		
	    end 
          end  	    
	end % k	    
      else % if 'auto'
        powers(i,ixyz)=0;
      end % if 'auto'
    end % ixyz
  end % i
  
  % replace all ticklabels and bookkeep
  nxlabel=zeros(1,na);
  nylabel=zeros(1,na);
  nzlabel=zeros(1,na);
  allxyz={ 'x', 'y', 'z' };
  for ixyz=1:3
    xyz=allxyz{ixyz};
    k=1;
    basestr=[ xyz '00' ];
    if strcmp(xyz,'y') % 'y' is not horizontally centered! 
      basestr='v00';
    end  
    oldtl=cell(na,1);
    newtl=cell(na,1);
    nlabel=zeros(1,na);
    for i=1:na
      % set(hax(i),[ xyz 'tickmode' ],'manual')
      % set(hax(i),[ xyz 'ticklabelmode' ],'manual')
      oldtl{i}=chartocell(get(hax(i),[ xyz 'ticklabel' ]));
      nlabel(i)=length(oldtl{i});
      newtl{i}=cell(1,nlabel(i));
      for j=1:nlabel(i)
        newtl{i}{j} = overwritetail(basestr,k);
        k=k+1;
        oldtl{i}{j}=deblank(strrep(strrep(oldtl{i}{j},'\','\\'),'%','%%'));
      end
      set(hax(i),[ xyz 'ticklabel' ],newtl{i});
    end  
    eval([ 'old' xyz 'tl=oldtl;' ]);
    eval([ 'new' xyz 'tl=newtl;' ]);
    eval([ 'n' xyz 'label=nlabel;' ]);
  end

  % determine latex commands for font properties
  
  if keepfontprops

    % font size
    afsize=zeros(na,1);
    for i=1:na
      afsize(i)=get(hax(i),'fontsize');
    end          
    if (any(afsize ~= afsize(1) ))
      disp('LaPrint warning: Different font sizes for axes not supported.')
      disp([ '         All axses will have font size ' ...
	     num2str(afsize(1)) '.' ] )
      iswarning=1;
    end      
    afsizecmd = [ '\\fontsize{' num2str(afsize(1)) '}{' ...
                  num2str(afsize(1)*1.5) '}'  ];

    % font weight
    afweight=cell(na,1);
    for i=1:na
      afweight{i}=get(hax(i),'fontweight');
    end
    if strcmp(afweight{1},'light')
      afweightcmd=[ '\\fontseries{l}\\mathversion{normal}' ];
    elseif strcmp(afweight{1},'normal')
      afweightcmd=[ '\\fontseries{m}\\mathversion{normal}' ];
    elseif strcmp(afweight{1},'demi')
      afweightcmd=[ '\\fontseries{sb}\\mathversion{bold}' ];
    elseif strcmp(afweight{1},'bold')
      afweightcmd=[ '\\fontseries{bx}\\mathversion{bold}' ];
    else
      disp([ ' LaPrint warning: unknown fontweight:' afweight{1} ])
      iswarning=1;
      afweightcmd=[ '\\fontseries{m}\\mathversion{normal}' ];
    end
    for i=1:na
      if ~strcmp(afweight{i},afweight{1})
        disp(' LaPrint warning: Different font weights for axes not')
        disp([ '      supported. All axes will have font weight ' afweightcmd])
        iswarning=1;
      end      
    end      

    % font angle
    afangle=cell(na,1);
    for i=1:na
      afangle{i}=get(hax(i),'fontangle');
    end
    if strcmp(afangle{1},'normal')
      afanglecmd=[ '\\fontshape{n}' ];
    elseif strcmp(afangle{1},'italic')
      afanglecmd=[ '\\fontshape{it}' ];
    elseif strcmp(afangle{1},'oblique')
      afanglecmd=[ '\\fontshape{it}' ];
    else
      disp([ ' LaPrint warning: unknown fontangle:' afangle{1} ])
      iswarning=1;
      afanglecmd=[ '\\fontshape{n}' ];
    end
    for i=1:na
      if ~strcmp(afangle{i},afangle{1})
        disp('LaPrint warning: Different font angles for axes not supported.')
        disp([ '         All axes will have font angle ' afanglecmd ] )
        iswarning=1;
      end      
    end      
    
  end

end

%
% extra picture environment
%

if extrapicture
  unitlength=zeros(na,1);
  ybound=zeros(na,1);
  for i=1:na
    if ~is3d(hax(i))
      xlim=get(hax(i),'xlim');
      ylim=get(hax(i),'ylim');
      axes(hax(i));
      hori=text(ylim(1),ylim(1),[ 'origin' int2str(i) ]);
      set(hori,'VerticalAlignment','bottom');
      set(hori,'Fontsize',2);
      pos=get(hax(i),'Position');
      unitlength(i)=pos(3)*epswidth;
      ybound(i)=(pos(4)*epsheight)/(pos(3)*epswidth);
    else
      if directcall
	disp('LaPrint warning: Option ''extrapicture'' for 3D axes not supported.')
      end  
    end
  end 
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 3 of advanced usage:
%%%% save eps and tex files
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% save eps file
%
if ~loose
  cmd=[ 'print(''-deps'',''-f' int2str(figno) ''',''' epsfullnameext ''')' ];
else
  cmd=[ 'print(''-deps'',''-loose'',''-f' int2str(figno) ...
	''',''' epsfullnameext ''')' ];
end  

if verbose
  disp([ 'executing: '' ' cmd ' ''' ]);
end
eval(cmd);

%
% create latex file
%
if verbose
  disp([ 'writing to: '' ' texfullnameext ' ''' ])
end
fid=fopen(texfullnameext,'w');

% head
if ~nohead
  fprintf(fid,[ '%% This file is generated by the MATLAB m-file fm_laprint.m.' ...
                ' It can be included\n']);
  fprintf(fid,[ '%% into LaTeX documents using the packages epsfig and ' ...
                'psfrag. It is accompanied\n' ]);
  fprintf(fid,  '%% by a postscript file. A sample LaTeX file is:\n');
  fprintf(fid, '%%    \\documentclass{article} \\usepackage{epsfig,psfrag}\n');
  fprintf(fid,[ '%%    \\begin{document}\\begin{figure}\\input{' ...
                texbasename '}\\end{figure}\\end{document}\n' ]);
  fprintf(fid, [ '%% See http://www.uni-kassel.de/~linne/ for recent ' ...
                 'versions of fm_laprint.m.\n' ]);
  fprintf(fid,  '%%\n');
  fprintf(fid,[ '%% created by:           ' 'LaPrint version ' ...
                laprintident '\n' ]);
  fprintf(fid,[ '%% created on:           ' datestr(now) '\n' ]);
  fprintf(fid,[ '%% options used:        ' furtheroptions '\n' ]);
  fprintf(fid,[ '%% latex width:          ' num2str(latexwidth) ' cm\n' ]);
  fprintf(fid,[ '%% factor:               ' num2str(factor) '\n' ]);
  fprintf(fid,[ '%% eps file name:        ' epsbasenameext '\n' ]);
  fprintf(fid,[ '%% eps bounding box:     ' num2str(epswidth) ...
                ' cm x ' num2str(epsheight) ' cm\n' ]);
  fprintf(fid,[ '%% comment:              ' commenttext '\n' ]);
  fprintf(fid,'%%\n');
else 
  fprintf(fid,[ '%% generated by fm_laprint.m\n' ]);
  fprintf(fid,'%%\n');
end

% go on
fprintf(fid,'\\begin{psfrags}%%\n');
%fprintf(fid,'\\fontsize{10}{12}\\selectfont%%\n');
fprintf(fid,'\\psfragscanon%%\n');

% text strings

numbertext=0;
for i=1:nt
  numbertext=numbertext+length(newstr{i});
end
if numbertext>0,
  fprintf(fid,'%%\n');
  fprintf(fid,'%% text strings:\n');
  for i=1:nt
    if length(newstr{i})
      alig=strrep(align{i},'c','');
      fprintf(fid,[ '\\psfrag{' newstr{i} '}[' alig '][' alig ']{' ...
                    fontsizecmd{i} fontweightcmd{i} fontanglecmd{i} selectfontcmd ...
                    oldstr{i} '}%%\n' ]);
    end
  end
end

% labels

if ~keepticklabels
  if keepfontprops
    fprintf(fid,'%%\n');
    fprintf(fid,'%% axes font properties:\n');
    fprintf(fid,[ afsizecmd afweightcmd '%%\n' ]);
    fprintf(fid,[ afanglecmd '\\selectfont%%\n' ]);
  end  
  nxlabel=zeros(1,na);
  nylabel=zeros(1,na);
  nzlabel=zeros(1,na);
  for i=1:na
    nxlabel(i)=length(newxtl{i});
    nylabel(i)=length(newytl{i});
    nzlabel(i)=length(newztl{i});
  end    
  
  allxyz={ 'x', 'y', 'z' };
  for ixyz=1:3
    xyz=allxyz{ixyz};
    eval([ 'oldtl=old' xyz 'tl;' ]);
    eval([ 'newtl=new' xyz 'tl;' ]);
    eval([ 'nlabel=n' xyz 'label;' ]);
    if sum(nlabel) > 0
      fprintf(fid,'%%\n');
      fprintf(fid,[ '%% ' xyz 'ticklabels:\n']);
      if xyz=='x'
        poss='[t][t]';
      else
        poss='[r][r]';
      end  
      for i=1:na
        if nlabel(i)
          if strcmp(get(hax(i),[ xyz 'scale']),'linear')
	    % lin scale
	    % all but last
            for j=1:nlabel(i)-1
              fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
                            Do oldtl{i}{j} Do '}%%\n' ]);
            end 
            % last
            rexpon=powers(i,ixyz);
	    if rexpon
	      if xyz=='x'
	        fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                              '}' poss '{\\shortstack{' ... 
                              Do oldtl{i}{nlabel(i)} Do '\\\\$\\times 10^{'...
                              int2str(rexpon) '}\\ $}}%%\n' ]);
              else
                fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                              '}' poss '{' Do oldtl{i}{nlabel(i)} Do ...
                              '\\setlength{\\unitlength}{1ex}%%\n' ...
                              '\\begin{picture}(0,0)\\put(0.5,1.5){$\\times 10^{' ...
                              int2str(rexpon) '}$}\\end{picture}}%%\n' ]);
              end
            else
	      fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} '}' poss '{' ...
                            Do oldtl{i}{nlabel(i)} Do '}%%\n' ]);
            end
          else
            % log scale
            for j=1:nlabel
              fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{$10^{' ...
                            oldtl{i}{j} '}$}%%\n' ]);
            end
          end
        end   
      end
    end
  end
end  

% extra picture
if extrapicture
  fprintf(fid,'%%\n');
  fprintf(fid,'%% extra picture(s):\n');
  for i=1:na
    fprintf(fid,[ '\\psfrag{origin' int2str(i) '}[lb][lb]{' ...
                  '\\setlength{\\unitlength}{' ...
		  num2str(unitlength(i),'%5.5f') 'cm}%%\n' ]);
    fprintf(fid,[ '\\begin{picture}(1,' ...
		  num2str(ybound(i),'%5.5f') ')%%\n' ]);
    %fprintf(fid,'\\put(0,0){}%% lower left corner\n');
    %fprintf(fid,[ '\\put(1,' num2str(ybound(i),'%5.5f') ...
    %	          '){}%% upper right corner\n' ]);
    fprintf(fid,'\\end{picture}%%\n');
    fprintf(fid,'}%%\n');
  end
end  

% figure
fprintf(fid,'%%\n');
fprintf(fid,'%% Figure:\n');
if caption
  fprintf(fid,[ '\\parbox{' num2str(latexwidth) 'cm}{\\centering%%\n' ]);
end  
if noscalefonts
  fprintf(fid,[ '\\epsfig{file=' epsbasenameext ',width=' ...
                num2str(latexwidth) 'cm}}%%\n' ]);
else  
  fprintf(fid,[ '\\resizebox{' num2str(latexwidth) 'cm}{!}' ...
                '{\\epsfig{file=' epsbasenameext '}}%%\n' ]);
end
if caption
  if isempty(captiontext)
    captiontext=[ texbasenameext ', ' epsbasenameext ];
  end  
  fprintf(fid,[ '\\caption{' captiontext '}%%\n' ]);
  fprintf(fid,[ '\\label{fig:' texbasename '}%%\n' ]);
  fprintf(fid,[ '}%%\n' ]);
end  
fprintf(fid,'\\end{psfrags}%%\n');
fprintf(fid,'%%\n');
fprintf(fid,[ '%% End ' texbasenameext '\n' ]);
fclose(fid);

set(figno,'Name','Printed by LaPrint')
if ~nofigcopy
  if verbose
    disp('Strike any key to continue.');
    pause
  end  
  close(figno)
end

%
% create view file
%
if viewfile
  if verbose
    disp([ 'writing to: '' ' viewfullnameext ' ''' ])
  end
  fid=fopen(viewfullnameext,'w');

  if ~nohead
    fprintf(fid,[ '%% This file is generated by fm_laprint.m.\n' ]);
    fprintf(fid,[ '%% It calls ' texbasenameext ...
		  ', which in turn  calls ' epsbasenameext '.\n' ]);
    fprintf(fid,[ '%% Process this file using\n' ]);
    fprintf(fid,[ '%%   latex ' viewbasenameext '\n' ]);
    fprintf(fid,[ '%%   dvips -o' viewbasename '.ps ' viewbasename '.dvi' ...
                  '\n']);
    fprintf(fid,[ '%%   ghostview ' viewbasename '.ps&\n' ]);
  else 
    fprintf(fid,[ '%% generated by fm_laprint.m\n' ]);
  end

  fprintf(fid,[ '\\documentclass{article}\n' ]);
  fprintf(fid,[ '\\usepackage{epsfig,psfrag,a4}\n' ]);
  fprintf(fid,[ '\\usepackage[latin1]{inputenc}\n' ]);
  if ~strcmp(epsdirname,viewdirname)
    %disp([ 'warning: The view-file has to be supplemented by '...
    %	   'path information.' ])
    fprintf(fid,[ '\\graphicspath{{' epsdirname '}}\n' ]);
  end  
  fprintf(fid,[ '\\begin{document}\n' ]);
  fprintf(fid,[ '\\pagestyle{empty}\n' ]);
  fprintf(fid,[ '\\begin{figure}[ht]\n' ]);
  fprintf(fid,[ '  \\begin{center}\n' ]);
  if strcmp(texdirname,viewdirname) 
    %fprintf(fid,[ '    \\fbox{\\input{' texbasenameext '}}\n' ]);
    fprintf(fid,[ '    \\input{' texbasenameext '}\n' ]);
  else
    %fprintf(fid,[ '    \\fbox{\\input{' texdirname texbasenameext '}}\n' ]);
    fprintf(fid,[ '    \\input{' texdirname texbasenameext '}\n' ]);
  end
  fprintf(fid,[ '    %% \\caption{A LaPrint figure}\n' ]);
  fprintf(fid,[ '    %% \\label{fig:' texbasename '}\n' ]);
  fprintf(fid,[ '  \\end{center}\n' ]);
  fprintf(fid,[ '\\end{figure}\n' ]);
  fprintf(fid,[ '\\vfill\n' ]);
  fprintf(fid,[ '\\begin{flushright}\n' ]);
  fprintf(fid,[ '\\tiny printed with LaPrint on ' ...
		datestr(now) '\\\\\n' ]);
  fprintf(fid,[ '\\verb+' viewdirname viewbasenameext '+\\\\\n' ]);
  fprintf(fid,[ '\\verb+( ' texdirname texbasenameext ' )+\\\\\n' ]);
  fprintf(fid,[ '\\verb+( ' epsdirname epsbasenameext ' )+\n' ]);
  fprintf(fid,[ '\\end{flushright}\n' ]);
  fprintf(fid,[ '\\end{document}\n' ]);
  fclose(fid);
  if verbose
    yn=input([ 'Perform LaTeX run on ' viewbasenameext '? (y/n) '],'s');
    if strcmp(yn,'y') 
      cmd=[ '!latex ' viewbasenameext ];
      disp([ 'executing: '' ' cmd ' ''' ]);
      eval(cmd);
      yn=input([ 'Perform dvips run on ' viewbasename '.dvi? (y/n) '],'s');
      if strcmp(yn,'y') 
        cmd=[ '!dvips -o' viewbasename '.ps ' viewbasename '.dvi' ];
        disp([ 'executing: '' ' cmd ' ''' ]);
        eval(cmd);
        yn=input([ 'Call ghostview on ' viewbasename '.ps? (y/n) '],'s');
        if strcmp(yn,'y') 
          cmd=[ '!ghostview ' viewbasename '.ps&' ];
          disp([ 'executing: '' ' cmd ' ''' ]);
          eval(cmd);
        end
      end
    end
  end
end

if ~directcall && iswarning
  showtext({'Watch the LaPrint messages in the command window!'},'add')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% functions used
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showtext(txt,add)

global LAPRINTHAN

txt=textwrap(LAPRINTHAN.helptext,txt);
if nargin==1
  set(LAPRINTHAN.helptext,'string','')
  set(LAPRINTHAN.helptext,'string',txt)
else
  txt0=get(LAPRINTHAN.helptext,'string');
  set(LAPRINTHAN.helptext,'string','')
  set(LAPRINTHAN.helptext,'string',{txt0{:},txt{:}})
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showsizes()

global LAPRINTOPT
global LAPRINTHAN

figpos=get(LAPRINTOPT.figno,'position');
latexwidth=LAPRINTOPT.width;
latexheight=latexwidth*figpos(4)/figpos(3);
epswidth=latexwidth/LAPRINTOPT.factor;
epsheight=latexheight/LAPRINTOPT.factor;

set(LAPRINTHAN.texsize,'string',[ 'latex figure size: ' num2str(latexwidth) ...
                    'cm x ' num2str(latexheight) 'cm' ])

set(LAPRINTHAN.epssize,'string',[ 'postscript figure size: ' ...
                    num2str(epswidth) ...
                    'cm x ' num2str(epsheight) 'cm' ])

% some warnings
txt1=' ';
txt2=' ';
txt3=' ';
if (epswidth<13) || (epsheight<13*0.75)
  txt1=['Warning: The size of the eps-figure is quite small. '...
        'Text objects might not be properly set. '];
  showtext({txt1},'add')
end
if LAPRINTOPT.factor<0.5
  txt2=['Warning: The ''factor'' is quite small. ' ...
	'The text size might be too small.'];
  showtext({txt2},'add')
end  
if ((figpos(3)-epswidth)/figpos(3)>0.1) && ~LAPRINTOPT.asonscreen
  txt3=['Warning: The size of the eps-figure is much smaller '...
        'than the figure on screen. '...
        'Consider using option ''as on sceen''.' ];
  showtext({txt3},'add')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fullnameext,basenameext,basename,dirname]= getfilenames(...
    filename,extension,verbose);
% appends an extension to a filename (as '/home/tom/tt') and determines  
%   fullnameext: filename with extension with dirname, as '/home/tom/tt.tex'
%   basenameext: filename with extension without dirname, as 'tt.tex'
%   basename   : filename without extension without dirname, as 'tt'
%   dirname    : dirname without filename, as '/home/tom/'
% In verbose mode, it asks if to overwrite or to modify.
%
[dirname, basename] = splitfilename(filename);
fullnameext = [ dirname basename '.' extension ];
basenameext = [ basename '.' extension ];
if verbose
  quest = (exist(fullnameext)==2);
  while quest
    yn=input([ fullnameext ' exists. Overwrite? (y/n) '],'s');
    if strcmp(yn,'y') 
      quest=0;
    else
      filename=input( ...
	  [ 'Please enter new filename (without extension .' ...
            extension '): ' ],'s');
      [dirname, basename] = splitfilename(filename);
      fullnameext = [ dirname basename '.' extension ];
      basenameext = [ basename '.' extension ];
      quest = (exist(fullnameext)==2);
    end
  end
end
if ( exist(dirname)~=7 && ~strcmp(dirname,[ '.' filesep ]) ...
     && ~strcmp(dirname,filesep) )
  fm_disp(['LaPrint Error: Directory ',dirname,' does not exist.'],2)
  return
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dirname,basename]=splitfilename(filename);
% splits filename into dir and base
slashpos=findstr(filename,filesep);
nslash=length(slashpos);
nfilename=length(filename);
if nslash
  dirname = filename(1:slashpos(nslash));
  basename = filename(slashpos(nslash)+1:nfilename);
else
  dirname = pwd;
  nn=length(dirname);
  if ~strcmp(dirname(nn),filesep)
    dirname = [ dirname filesep ];
  end   
  basename = filename;
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yesno=is3d(haxes);
% tries to figure out if axes is 3D
yesno=0;
CameraPosition=get(haxes,'CameraPosition');
CameraTarget=get(haxes,'CameraTarget');
CameraUpVector=get(haxes,'CameraUpVector');
if CameraPosition(1)~=CameraTarget(1)
  yesno=1;
end  
if CameraPosition(2)~=CameraTarget(2)
  yesno=1;
end  
if any(CameraUpVector~=[0 1 0])
  yesno=1;
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b=celltoarray(a);
% converts a cell of doubles to an array
if iscell(a),
  b=[];
  for i=1:length(a),
    b=[b a{i}]; 
  end  
else, 
  b=a(:)';
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b=chartocell(a)
% converts a character array into a cell array of characters

% convert to cell 
if isa(a,'char')
  n=size(a,1);
  b=cell(1,n);
  for j=1:n
    b{j}=a(j,:); 
  end  
else
  b=a;
end  
% convert to char
n=length(b);
for j=1:n
  if isa(b{j},'double')
    b{j}=num2str(b{j});
  end  
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b=overwritetail(a,k)
% overwrites tail of a by k
% a,b: strings
% k: integer
ks=int2str(k);
b = [ a(1:(length(a)-length(ks))) ks ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
