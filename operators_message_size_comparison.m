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
%%
%Switch which database you want to query
google_test=1; %Query Google database
spectrumbridge_test=1; %Query spectrumBridge database
microsoft_test=1; %Query Microsoft database
ofcom_test= 1; %Query ofcom database
csir_test = 1 ;
nominet_test = 1;
fairspectrum_test = 1 ;

longitude_interval=100; % How many steps to be taken . It is any specified nunmber + 1
%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';
%Plot parameters
ftsz=16;

ggl_err=0;
sbi_err=0;
mrs_err=0;
ofc_err=0;
nom_err=0;
csi_err=0;
fai_err=0;

%%
%Create legend for the figures
legend_string={'GGL','SBI','MSR','SBO','NOM','CSI','FAI'};
legend_flag=[google_test,spectrumbridge_test,microsoft_test,ofcom_test,csir_test,nominet_test,fairspectrum_test];
legend_string(find(~legend_flag))=[];

%% --------------------------->>> US

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
    
    if google_test==1
        %Query Google
        ggl_cnt=ggl_cnt+1;
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/google']);
        [msg_google,delay,error_google_tmp]=database_connect_google(type,latitude,longitude,height,agl,[my_path,'/google'],ggl_cnt);
        var_name=(['google_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Google\n');
        if error_google_tmp==0
            dlmwrite([var_name,'.txt'],msg_google,'');
        else
            ggl_err = ggl_err + 1;
         %   dlmwrite(['error/' , var_name,'.txt'],msg_google,'');
        end
    end
    if spectrumbridge_test==1
        %Query SpectrumBridge
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/spectrumbridge']);
        if DeviceType=='3'
            [msg_spectrumbridge,~]=database_connect_spectrumbridge_register(...
                AntennaHeight,DeviceType,latitude,longitude,[my_path,'/spectrumbridge']);
            disp(msg_spectrumbridge)
            disp('msg_spectrumbridge')
            
        end
        [msg_spectrumbridge,delay,error_spectrumbridge_tmp]=database_connect_spectrumbridge(DeviceType,latitude,longitude);
        var_name=(['spectrumbridge_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('SpectrumBridge\n')
        if error_spectrumbridge_tmp==0
            dlmwrite([var_name,'.txt'],msg_spectrumbridge,'');
        else
            sbi_err = sbi_err+1;
        %    dlmwrite(['error/',var_name,'.txt'],msg_spectrumbridge,'');
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
        else
            mrs_err = mrs_err + 1;
      %      dlmwrite(['error/',var_name,'.txt'],msg_microsoft,'');
        end
    end
end
%% ---------------------------------------->> UK
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

longitude_step=(longitude_end-longitude_start)/longitude_interval;

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
        else
            ofc_err = ofc_err + 1;
            dlmwrite(['error/' , var_name,'.txt'],msg_ofcom,'');
        end
    end
    if nominet_test==1
        %Query Ofcom
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/nominet']);
        
        [msg_nominet,delay,error_ofcom_tmp]=...
            database_connect_nominet(latitude,longitude,[my_path,'/nominet']);
        
        var_name=(['nominet_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('nominet\n')
        if error_ofcom_tmp==0
            dlmwrite([var_name,'.txt'],msg_nominet,'');
        else
            nom_err = nom_err + 1;
     %       dlmwrite(['error/',var_name,'.txt'],msg_nominet,'');
        end
    end
end

%% South Africa ----->
%Global CSIR parameters

%Location of start and finish query
WSDB_data{1}.latitude='-24.1';
WSDB_data{1}.longitude='24.1';


%Query finish location
WSDB_data{2}.latitude='-22.2';
WSDB_data{2}.longitude='26.3';


longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

longitude_step=(longitude_end-longitude_start)/longitude_interval;

in=0;

for xx=longitude_start:longitude_step:longitude_end
    in=in+1;
    fprintf('Query no.: %d\n',in)
    
    %Fetch location data
    latitude=WSDB_data{1}.latitude;
    longitude=num2str(xx);
    
    instant_clock=clock; %Save clock for file name (if both WSDBs are queried)
    if csir_test==1
        
        %Query csir
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/csir']);
        
        [msg_csir,error_csir_delay,error_csir]=...
            database_connect_csir(latitude,longitude,[my_path,'/csir']);
        
        var_name=(['csir_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('csir\n')
        if error_csir==0
            dlmwrite([var_name,'.txt'],msg_csir,'');
        else
            csi_err = csi_err +  1;
     %       dlmwrite(['error/',var_name,'.txt'],msg_csir,'');
        end
    end
end
%% Finland????????????????  -------------->

%Location of start and finish query
WSDB_data{1}.latitude='51.50727';
WSDB_data{1}.longitude='0.127659';

%Query finish location
WSDB_data{2}.latitude='52.50727';
WSDB_data{2}.longitude='1.227659';

longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

longitude_step=(longitude_end-longitude_start)/longitude_interval;

in=0;

for xx=longitude_start:longitude_step:longitude_end
    in=in+1;
    fprintf('Query no.: %d\n',in)
    
    %Fetch location data
    latitude=WSDB_data{1}.latitude;
    longitude=num2str(xx);
    
    if fairspectrum_test==1
        
        %Query fairspectrum
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/fairspectrum']);
        
        [msg_fairspectrum,delay,error_fairspectrum]=...
            database_connect_fairspectrum(latitude,longitude,[my_path,'/fairspectrum']);
        
        var_name=(['fairspectrum_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('fairspectrum\n')
        if error_fairspectrum==0
            dlmwrite([var_name,'.txt'],msg_fairspectrum,'');
        else
            csi_err = csi_err +  1;
    %        dlmwrite(['error/',var_name,'.txt'],msg_fairspectrum,'');
        end
    end
end
%% Results calculations -------------->
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
end
if nominet_test==1
    %Clear old query results
    cd([my_path,'/nominet']);
    
    %Message size distribution (ofcom)
    list_dir=dir;
    [rowb,colbo]=size({list_dir.bytes})
    nominet_resp_size=[];
    for x=4:colbo
        nominet_resp_size=[nominet_resp_size,list_dir(x).bytes];
    end
end
if csir_test==1
    %Clear old query results
    cd([my_path,'/csir']);
    
    %Message size distribution (ofcom)
    list_dir=dir;
    [rowb,colbo]=size({list_dir.bytes})
    csir_resp_size=[];
    for x=4:colbo
        csir_resp_size=[csir_resp_size,list_dir(x).bytes];
    end
end
if fairspectrum_test==1
    %Clear old query results
    cd([my_path,'/fairspectrum']);
    
    %Message size distribution (ofcom)
    list_dir=dir;
    [rowb,colbo]=size({list_dir.bytes})
    fairspectrum_resp_size=[];
    for x=4:colbo
        fairspectrum_resp_size=[fairspectrum_resp_size,list_dir(x).bytes];
    end
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
    [xg,fg] = ecdf(google_resp_size); % CDF
    mean_google_resp_size=mean(google_resp_size) % stats
    var_google_resp_size=var(google_resp_size)
    ggl_err_rate = ggl_err/(longitude_interval+1)
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
    [xs,fs] = ecdf(spectrumbridge_resp_size); % CDF
    mean_spectrumbridge_resp_size=mean(spectrumbridge_resp_size) % stats
    var_spectrumbridge_resp_size=var(spectrumbridge_resp_size)
     sbi_err_rate = sbi_err/(longitude_interval+1)
    
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
    [xm,fm] = ecdf(microsoft_resp_size); %CDF
    mean_microsoft_resp_size=mean(microsoft_resp_size) % stats
    var_microsoft_resp_size=var(microsoft_resp_size)
     mrs_err_rate = mrs_err/(longitude_interval+1)
end
if ofcom_test==1
    [fo,xo]=ksdensity(ofcom_resp_size,'support','positive');
    fo=fo./sum(fo);
    plot(xo,fo,'r-.' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
    [xo,fo] = ecdf(ofcom_resp_size); %CDF
    mean_ofcom_resp_size=mean(ofcom_resp_size) % stats
    var_ofcom_resp_size=var(ofcom_resp_size)
    ofc_err_rate = ofc_err/(longitude_interval+1)
end
if nominet_test==1
    [fn,xn]=ksdensity(nominet_resp_size,'support','positive');
    fn=fn./sum(fn);
    plot(xn,fn,'k--' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
    [xn,fn] = ecdf(nominet_resp_size); %CDF
    mean_nominet_resp_size=mean(nominet_resp_size) % stats
    var_nominet_resp_size=var(nominet_resp_size)
    nom_err_rate = nom_err/(longitude_interval+1)
end

if csir_test==1
    [fc,xc]=ksdensity(csir_resp_size,'support','positive');
    fc=fc./sum(fc);
    plot(xc,fc,'y-' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
    [xc,fc] = ecdf(csir_resp_size);
    mean_csir_resp_size=mean(csir_resp_size) % stats
    var_csir_resp_size=var(csir_resp_size)
    csi_err_rate = csi_err/(longitude_interval+1)
end

if fairspectrum_test==1
    [ff,xf]=ksdensity(fairspectrum_resp_size,'support','positive');
    ff=ff./sum(ff);
    plot(xf,ff,'m--' , 'LineWidth' ,1.5);
    grid on;
    box on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
    hold off
    [xf,ff] = ecdf(fairspectrum_resp_size);
    mean_fairspectrum_resp_size=mean(fairspectrum_resp_size) % stats
    var_fairspectrum_resp_size=var(fairspectrum_resp_size)
    fai_err_rate = fai_err/(longitude_interval+1)
end

%Add common legend
legend(legend_string);

%%
figure('Position',[440 378 560 620/3]);
plot(fg,xg,'g-',fs,xs,'k:',fm,xm,'b-.',fo ,xo,'r--',fn,xn,'k-',fc,xc,'c-.',ff,xf,'m--','LineWidth',1.5);
grid on;
box on;
set(gca,'FontSize',ftsz);
xlabel('Message size (bytes)','FontSize',ftsz);
ylabel('Probability','FontSize',ftsz);
leg=legend(legend_string);
set(leg,'FontSize', (ftsz-2) );
%%
%Save statistics of message sizes for each WSDBDs
cd([my_path]);
save('operators-message-size-comaprison')
% display the results 
disp('*******************************************')
fprintf('Google: average size: %d variance: %d , error rate: %d \n', mean_google_resp_size , var_google_resp_size ,ggl_err_rate )
fprintf('spectrumbridge: average size: %d variance: %d , error rate: %d \n', mean_spectrumbridge_resp_size , var_spectrumbridge_resp_size ,sbi_err_rate )
fprintf('Microsoft: average size: %d variance: %d , error rate: %d \n', mean_microsoft_resp_size , var_microsoft_resp_size ,mrs_err_rate )
fprintf('Ofcom: average size: %d variance: %d , error rate: %d \n', mean_ofcom_resp_size , var_ofcom_resp_size ,ofc_err_rate )
fprintf('nominet: average size: %d variance: %d , error rate: %d \n', mean_nominet_resp_size , var_nominet_resp_size ,nom_err_rate )
fprintf('CSIR: average size: %d variance: %d , error rate: %d \n', mean_csir_resp_size , var_csir_resp_size ,csi_err_rate )
fprintf('Fairspectrum: average size: %d variance: %d , error rate: %d \n', mean_fairspectrum_resp_size , var_fairspectrum_resp_size ,fai_err_rate )

%%
['Elapsed time: ',num2str(toc/60),' min']