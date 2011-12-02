function [res,head] = xlsread2xlsread8(filename,numer,type,sh)

% xlsread8 to xlsread converter for use with RankGO.
% numer and type are virtual arguments for compatibility

if nargin<2
    numer=2;
    type='cell';
    sh='';
elseif nargin<3
    type='cell';
    sh='';
elseif nargin<4
        sh='';
end

[num,txt,raw]=xlsread(filename);

head=raw(1,:)';
res=raw(2:end,:);

