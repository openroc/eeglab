% pop_studyerp() - create a simple design for ERP analysis
%
% Usage:
%       >> [STUDY ALLEEG] = pop_studyerp; % pop up interface
%
% Outputs:
%   STUDY        - an EEGLAB STUDY set of loaded EEG structures
%   ALLEEG       - ALLEEG vector of one or more loaded EEG dataset structures
%
% Author: Arnaud Delorme, SCCN, UCSD, 2011-
%
% See also: eeg_checkset()

% Copyright (C) 15 Feb 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [STUDY ALLEEG com ] = pop_studyerp;

if 0
    warndlg2( [ 'This graphic interfaces bypass STUDY creation,' 10 ...
            'STUDY design, and precomputing measure steps.' 10 ...
            'It is only intended at computing grand average' 10 ...
            'ERP in one or two conditions (assuming that each' 10 ...
            'condition is contained in a separate dataset).' 10 ...
            'For more complex designs, create the STUDY using' 10 ...
            'the STUDY editor.' ]);
end;

% first GUI, get the number of conditions and subjects
% ----------------------------------------------------
textinfo = [ 'This graphic interfaces bypass STUDY creation,' 10 ...
        'STUDY design, and precomputing measure steps.' 10 ...
        'It is only intended at computing grand average' 10 ...
        'ERP in one or two conditions (assuming that each' 10 ...
        'condition is contained in a separate dataset).' 10 ...
        'For more complex designs, create the STUDY using' 10 ...
        'the STUDY editor.' ];
guispec = { ...
    {'style' 'text' 'string' 'ERP STUDY simplified interface' ...
     'FontWeight' 'Bold' 'fontsize', 12} ...
    { 'style' 'text' 'string' textinfo } ...
    {'style' 'text' 'string' 'Number of conditions:' } ...
    {'style' 'edit' 'string' '1' 'tag' 'cond' } { } ...
    {'style' 'text' 'string' 'Maximum number of subjects:' } ...
    {'style' 'edit' 'string' '15' 'tag' 'subjects' } { } };
guigeom = { [1] [1] [1 0.3 0.4] [1 0.3 0.4] };

optiongui = { 'geometry', guigeom, 'uilist'  , guispec, ...
              'geomvert', [ 1 5 1 1], ...
              'helpcom' , 'pophelp(''pop_studyerp'')', ...
              'title'   , 'Create a new STUDY set -- pop_studyerp()' };
[result, userdat2, strhalt, outstruct] = inputgui(optiongui{:});    
if isempty(result), return; end;

nSubjects = str2num(outstruct.subjects);
nConds    = str2num(outstruct.cond);

% second GUI, enter the datasets
% ------------------------------
guispec = { ...
    {'style' 'text' 'string' 'Simplified interface for creating grand average ERP STUDY' ...
     'FontWeight' 'Bold' 'fontsize', 12} ...
    {} ...
    {} {'style' 'text' 'string' 'STUDY set name:' } { 'style' 'edit' 'string' '' 'tag' 'study_name' } ...
    {} };
guigeom = { [1]  [1] [0.2 1 3.5] [1] };

% define conditions
% -----------------
guigeom{end+1} = [];
for icond = 1:nConds
    if icond == 1, guigeom{end} = [ guigeom{end} 1 0.2];
    else           guigeom{end} = [ guigeom{end} 0.1 1 0.2];
    end;
    if icond > 1, guispec{end+1} = {}; end;
    guispec = { guispec{:}, {'style' 'text' 'string' [ 'Name of condition ' num2str(icond) ' (optional)'] } {} };
end;

% edit boxes for conditions
% -------------------------
guigeom{end+1} = [];
for icond = 1:nConds
    if icond == 1, guigeom{end} = [ guigeom{end} 1 0.2];
    else           guigeom{end} = [ guigeom{end} 0.1 1 0.2];
    end;
    if icond > 1, guispec{end+1} = {}; end;
    guispec = { guispec{:}, {'style' 'edit' 'string' '' 'tag' [ 'cond' num2str(icond) ] } {} };
end;
guispec{end+1} = {};
guigeom{end+1} = [1];

% define dataset headers
% ----------------------
guigeom{end+1} = [];
for icond = 1:nConds
    if icond == 1, guigeom{end} = [ guigeom{end} 1 0.2];
    else           guigeom{end} = [ guigeom{end} 0.1 1 0.2];
    end;
    if icond > 1, guispec{end+1} = {}; end;
    guispec = { guispec{:}, {'style' 'text' 'string' ['Dataset filenames for condition ' num2str(icond) ] } {} };
end;

% create edit boxes
% -----------------
for index = 1:nSubjects
    guigeom{end+1} = [];
    for icond = 1:nConds
        if icond == 1, guigeom{end} = [ guigeom{end} 1 0.2];
        else           guigeom{end} = [ guigeom{end} 0.1 1 0.2];
        end;
        select_com = ['[inputname, inputpath] = uigetfile2(''*.set;*.SET'', ''Choose dataset to add to STUDY -- pop_study()'');'...
                      'if inputname ~= 0,' ...
                      '   guiind = findobj(''parent'', gcbf, ''tag'', ''set' int2str(icond) '_' int2str(index) ''');' ...
                      '   set( guiind,''string'', fullfile(inputpath, inputname));' ...
                      'end; clear inputname inputpath;'];
        if icond > 1, guispec{end+1} = {}; end;
        guispec = { guispec{:}, ...
                {'style' 'edit'       'string' ''    'tag' [ 'set' int2str(icond) '_' int2str(index) ] }, ...
                {'style' 'pushbutton' 'string' '...' 'Callback' select_com } };
    end;
end;

% last text
% ---------
textinfo = [  'Datasets on each line must correspond to the same subjects (when using more than 1 condition).' ];   
guispec = { guispec{:}, {}, {'style' 'text' 'string' textinfo } };
guigeom = { guigeom{:} [1] [1] };

optiongui = { 'geometry', guigeom, ...
              'uilist'  , guispec, ...
              'helpcom' , 'pophelp(''pop_studyerp'')', ...
              'title'   , 'Create a new STUDY set -- pop_studyerp()' };
[result, userdat2, strhalt, outstruct] = inputgui(optiongui{:});    
if isempty(result), return; end;

% decode outstruct and build call to std_editset
% ----------------------------------------------
options  = { 'name' outstruct.study_name 'updatedat' 'off' };
commands = {};
for icond = 1:nConds
    
    % check that condition name is defined
    tagCond = ['cond' int2str(icond) ];
    if isempty(outstruct.(tagCond))
        outstruct.(tagCond) = [ 'condition ' int2str(icond) ];
    end;
    
    for index = 1:nSubjects
        tagSet  = [ 'set' int2str(icond) '_' int2str(index) ];
        subject  = sprintf('S%2.2d', index);

        if ~isempty(outstruct.(tagSet))
            commands = { commands{:}, {'index' nConds*index+icond-1 'load' outstruct.(tagSet)  'subject' subject 'condition' outstruct.(tagCond) } };
        end;
    end;
end;
options = { options{:}, 'commands', commands };

% call std_editset to create the STUDY
% ------------------------------------
STUDY  = [];
ALLEEG = [];
com1 = sprintf( '[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, %s );', vararg2str(options) );
if ~isfield(STUDY, 'history'), STUDY.history = ''; end;
STUDY.history = sprintf('%s\n%s', STUDY.history, com1);
[STUDY ALLEEG] = std_editset(STUDY, ALLEEG, options{:});

% call std_precomp for ERP (channels)
% -----------------------------------
com2 = '[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, ''channels'', ''interpolate'', ''on'', ''recompute'',''on'',''erp'',''on'');';
STUDY.history = sprintf('%s\n%s', STUDY.history, com2);
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'channels','interp', 'on', 'recompute','on','erp','on');

% call std_erpplot to plot ERPs (channels)
% ----------------------------------------
com3 = 'tmpchanlocs = ALLEEG(1).chanlocs; STUDY = std_erpplot(STUDY, ALLEEG, ''channels'', { tmpchanlocs.labels }, ''plotconditions'', ''together'');';
STUDY.history = sprintf('%s\n%s', STUDY.history, com3);
tmpchanlocs = ALLEEG(1).chanlocs;
STUDY = std_erpplot(STUDY, ALLEEG, 'channels', { tmpchanlocs.labels }, 'plotconditions', 'together');
pos = get(gcf, 'position');
set(gcf, 'position', [10 pos(2) pos(3)*2 pos(4)*2]);

% call the STUDY plotting interface
% ---------------------------------
disp('Press OK to close plotting interface and save the STUDY');
disp('If you press CANCEL, the whole STUDY will be lost.');
[STUDY com4] = pop_chanplot(STUDY, ALLEEG); 

com = sprintf('%s\n%s\n%s\n%s', com1, com2, com3, com4);
    