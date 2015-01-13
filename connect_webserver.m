function [delay]=connect_webserver(selector)
%CONNECT_WEBSERVER Script used in comparing querying delays of WSDB with
%general www services [1]. 
%
%   Reference: [1] Will Dynamic Spectrum Access Drain my Battery?

%   Code development: 

%   Last update: 11 June 2014

%   This work is licensed under a Creative Commons Attribution 3.0 Unported
%   License. Link to license: http://creativecommons.org/licenses/by/3.0/

if selector==1 %Query bing.com
    cmnd=['/usr/bin/curl https://www.bing.com -H "Content-Type: application/json; charset=utf-8" -w %{time_total}'];
elseif selector==2 %Query google.nl
    cmnd=['/usr/bin/curl https://www.google.nl -H "Content-Type: application/json; charset=utf-8" -w %{time_total}'];
elseif selector==3 %Query spectrumbridge.com
    cmnd=['/usr/bin/curl http://www.spectrumbridge.com/Home.aspx -H "Content-Type: application/json; charset=utf-8" -w %{time_total}'];
end

[status,response]=system(cmnd); %Run command

%Extract delay from a query
end_query_str='</html>';
pos_end_query_str=findstr(response,end_query_str);
length_end_query_str=length(end_query_str);
delay=str2num(response(pos_end_query_str+length_end_query_str:end));