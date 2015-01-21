function [response,delay,error]=database_connect_microsoft(Longitude,Latitude,...
    PropagationModel,CullingThreshold,IncludeNonLicensed,...
    IncludeMicrophones,UseSRTM,UseGLOBE,UseLRBCast,my_path)
%DATABASE_CONNECT_MICROSOFT Script used in querying Microsoft WSDB.
% operators message size comparison compare the message size of multiple
% operators
%   Last update: 21 January 2015

% Reference:
%   P. Pawelczak et al. (2014), "Will Dynamic Spectrum Access Drain my
%   Battery?," submitted for publication.

%   Code development: Amjed Yousef Majid (amjadyousefmajid@student.tudelft.nl),
%                     Przemyslaw Pawelczak (p.pawelczak@tudelft.nl)

% Copyright (c) 2014, Embedded Software Group, Delft University of
% Technology, The Netherlands. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

error=false; %Default error value
delay=[]; %Default delay value

username='przemek'; %[replace by your own]
passwd='TUD3lfT'; %[replace by your own]

microsoft_query(username,passwd,Longitude,Latitude,PropagationModel,...
    CullingThreshold,IncludeNonLicensed,IncludeMicrophones,UseSRTM,...
    UseGLOBE,UseLRBCast);

server_name='"whitespaces.msresearch.us/WSWeb/driver.asmx"';
text_coding='"content-type: text/xml; charset=utf-8"';

my_path=regexprep(my_path,' ','\\ ');

cmnd=['/usr/bin/curl --header',' ',text_coding,' --data-binary @',my_path,'/soap.xml',' ',server_name,' -w %{time_total}'];

[status,response]=system(cmnd);
response = response(findstr(response , '<?') : end);
warning_microsoft='Server was unable to process request';

if ~isempty(findstr(response,warning_microsoft));
    error=true;
    'Microsoft Error'
else
    end_query_str='</soap:Envelope>';
    pos_end_query_str=findstr(response,end_query_str);
    length_end_query_str=length(end_query_str);
    delay=str2num(response(pos_end_query_str+length_end_query_str:end));
    response(pos_end_query_str+length_end_query_str:end)=[];
end
system('rm soap.xml');

function microsoft_query(username,passwd,Longitude,Latitude,PropagationModel,...
    CullingThreshold,IncludeNonLicensed,IncludeMicrophones,UseSRTM,...
    UseGLOBE,UseLRBCast)

request=['<?xml version="1.0" encoding="utf-8"?>',...
'<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',...
'<soap:Header>',...
'<AuthHeader xmlns="http://tempuri.org/">',...
'<username>',username,'</username>',...
'<passwd>',passwd,'</passwd>',...
'</AuthHeader>',...
'</soap:Header>',...
'<soap:Body>',...
'<GetSpectrumMap xmlns="http://tempuri.org/">',...
'<Latitude>',Latitude,'</Latitude>',...
'<Longitude>',Longitude,'</Longitude>',...
'<PropagationModel>',PropagationModel,'</PropagationModel>',...
'<CullingThreshold>',CullingThreshold,'</CullingThreshold>',...
'<IncludeNonLicensed>',IncludeNonLicensed,'</IncludeNonLicensed>',...
'<IncludeMicrophones>',IncludeMicrophones,'</IncludeMicrophones>',...
'<UseSRTM>',UseSRTM,'</UseSRTM>',...
'<UseGLOBE>',UseGLOBE,'</UseGLOBE>',...
'<UseLRBCast>',UseLRBCast,'</UseLRBCast>',...
'</GetSpectrumMap>',...
'</soap:Body>',...
'</soap:Envelope>'];

dlmwrite('soap.xml',request,'');