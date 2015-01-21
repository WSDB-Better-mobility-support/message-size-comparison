% operators message size comparison compare the message size of multiple
% operators
%   Last update: 17 January 2015

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
tic;
clear all;
close all;
clc;

%Switch which database you want to query
google_test=1; %Query Google database
spectrumbridge_test=1; %Query spectrumBridge database
ofcom_test= 1; %Query ofcom database
microsoft_test=1; %Query Microsoft database

%%
%Create legend for the figures
legend_string={'Google','SpectrumBridge','MSR','Ofcom'};
legend_flag=[google_test,spectrumbridge_test,microsoft_test,ofcom_test];
legend_string(find(~legend_flag))=[];

%%
%Plot parameters
ftsz=16;

%%
%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';

%%
% ----->>> US
%General querying parameters

%Global Google parameters (refer to https://developers.google.com/spectrum/v1/paws/getSpectrum)
type='"AVAIL_SPECTRUM_REQ"';
height='30.0'; %In meters; Note: 'height' needs decimal value
agl='"AMSL"';

%Global SpectrumBridge parameters (refer to WSDB_TVBD_Interface_v1.0.pdf [provided by Peter Stanforth])
AntennaHeight='30'; %In meters; Ignored for personal/portable devices
DeviceType='3'; %Examples: 8-Fixed, 3-40 mW Mode II personal/portable; 4-100 mW Mode II personal/portable

%Global Microsoft parameters (refer to http://whitespaces.msresearch.us/api.html)
PropagationModel='"Rice"';
CullingThreshold='-114'; %In dBm
IncludeNonLicensed='true';
IncludeMicrophones='true';
UseSRTM='false';
UseGLOBE='true';
UseLRBCast='true';

%Location of start and finish query
%Query start location (New York)
 
WSDB_data{1}.latitude='40.725952';
WSDB_data{1}.longitude='-74.665983';


%Query finish location (Tulsa)
WSDB_data{2}.latitude='36.115164 ';
WSDB_data{2}.longitude='-95.891569';

longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

longitude_interval=40;
longitude_step=(longitude_end-longitude_start)/longitude_interval;

in=0; %Initialize request number counter
%Initialize Google API request counter [important: it needs initliazed
%manually every time as limit of 1e3 queries per API is enforced. Check
%your Google API console to check how many queries are used already]
ggl_cnt=0;

for xx=longitude_start:longitude_step:longitude_end
    in=in+1;
    fprintf('Query no.: %d\n',in)
    
    %Fetch location data
    latitude=WSDB_data{1}.latitude;
    longitude=num2str(xx);
    
    instant_clock=clock; %Save clock for file name (if both WSDBs are queried)
    if google_test==1
        %Query Google
        ggl_cnt=ggl_cnt+1;
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/google']);
        [msg_google,~,error_google_tmp]=database_connect_google(type,latitude,longitude,height,agl,[my_path,'/google'],ggl_cnt);
        var_name=(['google_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Google\n');
        if error_google_tmp==0
            dlmwrite([var_name,'.txt'],msg_google,'');
        end
    end
    if spectrumbridge_test==1
        %Query SpectrumBridge
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/spectrumbridge']);
        if DeviceType=='8'
            [msg_spectrumbridge,~]=database_connect_spectrumbridge_register(...
                AntennaHeight,DeviceType,Latitude,Longitude,[my_path,'/spectrumbridge']);
        end
        [msg_spectrumbridge,~,error_spectrumbridge_tmp]=database_connect_spectrumbridge(DeviceType,latitude,longitude);
        var_name=(['spectrumbridge_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('SpectrumBridge\n')
        if error_spectrumbridge_tmp==0
            dlmwrite([var_name,'.txt'],msg_spectrumbridge,'');
        end
    end
    if microsoft_test==1
        %Query Microsoft
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/microsoft']);
        [msg_microsoft,~,error_microsoft_tmp]=...
            database_connect_microsoft(longitude,latitude,PropagationModel,...
            CullingThreshold,IncludeNonLicensed,IncludeMicrophones,...
            UseSRTM,UseGLOBE,UseLRBCast,[my_path,'/microsoft']);
        var_name=(['microsoft_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Microsoft\n')
        if error_microsoft_tmp==0
            dlmwrite([var_name,'.txt'],msg_microsoft,'');
        end
    end
end
%% ------->> UK
%Global Ofcom parameters
request_type='"AVAIL_SPECTRUM_REQ"';
orientation= 45;
semiMajorAxis = 50;
SemiMinorAxis = 50;
start_freq = 470000000;
stop_freq = 790000000;
height=7.5;
heightType = '"AGL"';


%Location of start and finish query
WSDB_data{1}.latitude='51.785840';
WSDB_data{1}.longitude='0.28895';


%Query finish location
WSDB_data{2}.latitude='51.785840';
WSDB_data{2}.longitude='-2.062151';


longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

%longitude_step=(longitude_end-longitude_start)/longitude_interval;
longitude_step=(longitude_end-longitude_start)/20;

in=0;

for xx=longitude_start:longitude_step:longitude_end
    in=in+1;
    fprintf('Query no.: %d\n',in)
    
    %Fetch location data
    latitude=WSDB_data{1}.latitude;
    longitude=num2str(xx);
    
    instant_clock=clock; %Save clock for file name (if both WSDBs are queried)
    if ofcom_test==1
        %Query Ofcom
        
        %Query Ofcom
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/ofcom']);
        
        [msg_ofcom,~,error_ofcom_tmp]=...
            database_connect_ofcom(request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType,[my_path,'/ofcom']);
        
        var_name=(['ofcom_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Ofcom\n')
        if error_ofcom_tmp==0
            dlmwrite([var_name,'.txt'],msg_ofcom,'');
            
        end
    end
end
%% 
%US + UK results calculations
if google_test==1
    %Clear old query results
    cd([my_path,'/google']);
    %Message size distribution (Google)
    list_dir=dir;
    [rowb,colbg]=size({list_dir.bytes});
    google_resp_size=[];
    for x=4:colbg
        google_resp_size=[google_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
    
end
if spectrumbridge_test==1
    %Clear old query results
    cd([my_path,'/spectrumbridge']);
    
    %Message size distribution (SpectrumBridge)
    list_dir=dir;
    [rowb,colbs]=size({list_dir.bytes});
    spectrumbridge_resp_size=[];
    for x=4:colbs
        spectrumbridge_resp_size=[spectrumbridge_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
end
if microsoft_test==1
    %Clear old query results
    cd([my_path,'/microsoft']);
    
    %Message size distribution (Microsoft)
    list_dir=dir;
    [rowb,colbm]=size({list_dir.bytes});
    microsoft_resp_size=[];
    for x=4:colbm
        microsoft_resp_size=[microsoft_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
end
if ofcom_test==1
    %Clear old query results
    cd([my_path,'/ofcom']);
    
    %Message size distribution (ofcom)
    list_dir=dir;
    [rowb,colbo]=size({list_dir.bytes})
    ofcom_resp_size=[];
    for x=4:colbo
        ofcom_resp_size=[ofcom_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
end
%%
%Plot figure
if google_test==1
    figure('Position',[440 378 560 620/3]);
    [fg,xg]=ksdensity(google_resp_size,'support','positive');
    fg=fg./sum(fg);
    plot(xg,fg,'g-' , 'LineWidth' ,1.5);
    grid on;
    box on;
    hold on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
if spectrumbridge_test==1
    [fs,xs]=ksdensity(spectrumbridge_resp_size,'support','positive');
    fs=fs./sum(fs);
    plot(xs,fs,'k-.' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
if microsoft_test==1
    [fm,xm]=ksdensity(microsoft_resp_size,'support','positive');
    fm=fm./sum(fm);
    plot(xm,fm,'b--');
    grid on;
    box on;
    hold on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
if ofcom_test==1
    [fo,xo]=ksdensity(ofcom_resp_size,'support','positive');
    fs=fo./sum(fo);
    plot(xo,fo,'r-.' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
    hold off
end
%Add common legend
legend(legend_string);
%%
% eCDF
[xg,fg] = ecdf(google_resp_size);
[xs,fs] = ecdf(spectrumbridge_resp_size);
[xm,fm] = ecdf(microsoft_resp_size);
[xo,fo] = ecdf(ofcom_resp_size);
figure('Position',[440 378 560 620/3]);
plot(fg,xg,'g-',fs,xs,'k-.',fm,xm,'b--',fo ,xo,'r-.','LineWidth',1.5);
grid on;
box on;
set(gca,'FontSize',ftsz);
xlabel('Message size (bytes)','FontSize',ftsz);
ylabel('Probability','FontSize',ftsz);
legend(legend_string);
%%
%Calculate statistics of message sizes for each WSDB
%Mean
mean_spectrumbridge_resp_size=mean(spectrumbridge_resp_size)
mean_google_resp_size=mean(google_resp_size)
mean_microsoft_resp_size=mean(microsoft_resp_size)
mean_ofcom_resp_size=mean(ofcom_resp_size)

%Variance
var_spectrumbridge_resp_size=var(spectrumbridge_resp_size)
var_google_resp_size=var(google_resp_size)
var_microsoft_resp_size=var(microsoft_resp_size)
var_ofcom_resp_size=var(ofcom_resp_size)
cd([my_path]);
save('operators-message-size-comaprison')
%%
['Elapsed time: ',num2str(toc/60),' min']