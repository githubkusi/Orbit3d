function r = mod1(a,b)
%MOD1 modulo 1-indexed
%   a modulo version which fits better into Matlab due to its 1-indexed
%   nature
%
%   Example: math.mod1(3,3)==3
%            math.mod1(4,3)==1
%
%   Keywords: mod modulo 0-indexed 1-indexed 0indexed 1indexed

r = mod(a-1,b)+1;