% vectdata() - vector data interpolation with optional moving 
%              average.
%
% Usage:
%   >> [interparray timesout] = vectdata( array, timesin, 'key', 'val', ... );
%
% Inputs:
%   array      - 1-D or 2-D float array. If 2-D, the second dimension
%                only is interpolated.
%   timesin    - [float vector] time point indices. Same dimension as
%                the interpolated dimension in array.
%
% Optional inputs
%   'timesout' - [float vector] time point indices for interpolating
%                data.
%   'method'   - method for interpolation
%        'linear'    -> Triangle-based linear interpolation (default).
%        'cubic'     -> Triangle-based cubic interpolation.
%        'nearest'   -> Nearest neighbor interpolation.
%        'v4'        -> MATLAB 4 griddata method.
%   'average'  - [real] moving average in the dimension of timesin
%                note that extreme values might be inacurate (see 'borders'). 
%                Default none or [].
%   'avgtype'  - ['const'|'gauss'] use a const value when averaging (array of 
%                ones) or a gaussian window. Default is 'const'.
%   'border'   - ['on'|'off'] correct border effect when smoothing.
%                default is 'off'.
%
% Outputs:
%   interparray - interpolated array
%   timesout    - output time points
%
% Author: Arnaud Delorme, CNL / Salk Institute, 20 Oct 2002
%
% See also: griddata()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
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

% $Log: not supported by cvs2svn $
% Revision 1.12  2004/02/06 23:31:22  arno
% implementing new option 'avgtype'
%
% Revision 1.11  2004/02/06 22:36:23  arno
% new option 'border'
%
% Revision 1.10  2004/02/06 00:55:28  arno
% conv2 -> convolve
%
% Revision 1.9  2004/02/05 23:11:51  arno
% remove debug msg
%
% Revision 1.8  2004/02/05 23:11:13  arno
% minspace problem
%
% Revision 1.7  2003/10/15 18:48:54  arno
% *** empty log message ***
%
% Revision 1.6  2003/07/04 00:04:39  arno
% same
%
% Revision 1.5  2003/07/04 00:01:09  arno
% newanglevalless constraint for uniform data (on precision)
%
% Revision 1.4  2002/10/21 15:52:16  arno
% debug indices
%
% Revision 1.3  2002/10/21 15:30:19  arno
% updating message
%
% Revision 1.2  2002/10/21 15:22:17  arno
% update.m
%
% Revision 1.1  2002/10/21 14:53:04  arno
% Initial revision
%

function [interparray, timesout] = vectdata( array, timevect, varargin );

if nargin < 3
    help vectdata;
    return;
end;

g = finputcheck( varargin, { 'timesout'   'real'  []           [];
                             'average'    'real'  []           [];
                             'gauss'      'real'  []           [];
                             'border'     'string' { 'on' 'off' } 'off';
                             'avgtype'    'string' { 'const' 'gauss' } 'const';
                             'method'     'string' { 'linear' 'cubic' 'nearest' 'v4' } 'linear'});
if isstr(g), error(g); end;

if size(array,2) == 1
    array = transpose(array);
end;

if ~isempty(g.average)
    timediff = timevect(2:end) -timevect(1:end-1);
    if any( (timediff - mean(timediff)) > 1e-8 ) % not uniform values
        fprintf('Data has to be interpolated uniformly for moving average\n');
        minspace = mean(timediff);
        newtimevect = linspace(timevect(1), timevect(end), ceil((timevect(end)-timevect(1))/minspace)); 
        array = interpolate( array, timevect, newtimevect, g.method);
        timevect = newtimevect;
    end;
    oldavg = g.average;
    g.average = round(g.average/(timevect(2)-timevect(1)));
    if oldavg ~= g.average
        fprintf('Moving average updated from %3.2f to %3.2f (=%d points)\n', ...
                oldavg, g.average*(timevect(2)-timevect(1)), g.average);
    end;
    if strcmpi(g.border, 'on')
        if strcmpi(g.avgtype, 'const')
            array = convolve(array, ones(1, g.average));
        else
            convolution = gauss2d(1,g.average,1,round(0.15*g.average));
            array = convolve(array, convolution);
        end;
    else
        if strcmpi(g.avgtype, 'const')
            array = conv2(array, ones(1, g.average)/g.average, 'same');
        else
            convolution = gauss2d(1,g.average,1,round(0.15*g.average));
            array = conv2(array, convolution/sum(convolution), 'same');
        end;
    end;
end;

interparray = interpolate( array, timevect, g.timesout, g.method);
timesout = g.timesout;

% interpolation function
% ----------------------
function [interparray] = interpolate( array, timesin, timesout, method);
    interparray = zeros(size(array,1), length(timesout));
    for index = 1:size(array,1)
        tmpa = [array(index,:) ; array(index,:)];
        
        [Xi,Yi,Zi] = griddata(timesin, [1 2]', tmpa, timesout, [1 2]', method); % Interpolate data
        interparray(index,:) = Zi(1,:);
    end;
