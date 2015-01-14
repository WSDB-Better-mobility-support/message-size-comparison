
tic;
clear all;
close all;
clc;

%Switch which database you want to query
google_test=1; %Query Google database
spectrumbridge_test=1; %Query spectrumBridge database
ofcom_test= 1; %Query ofcom database

%%
%Create legend for the figures
legend_string={'Google','SpectrumBridge', 'ofcom'};
legend_flag=[google_test,spectrumbridge_test , ofcom_test];
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

%Location of start and finish query
%Query start location
WSDB_data{1}.latitude='34.047955';
WSDB_data{1}.longitude='-118.256013';

%Query finish location
WSDB_data{2}.latitude='34.047955';
WSDB_data{2}.longitude='-77.885639';

longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

longitude_interval=1;
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
end
if google_test==1
    %Clear old query results
    cd([my_path,'/google']);
    %Message size distribution (Google)
    disp('dir')
    list_dir=dir
    disp('rowb colb')
    [rowb,colb]=size({list_dir.bytes})
    disp('google_resp_size')
    google_resp_size=[]
    disp('for loop')
    for x=4:colb
        google_resp_size=[google_resp_size,list_dir(x).bytes]
    end
    %system('rm *');
    
end
if spectrumbridge_test==1
    %Clear old query results
    cd([my_path,'/spectrumbridge']);
    
    %Message size distribution (SpectrumBridge)
    list_dir=dir;
    [rowb,colb]=size({list_dir.bytes});
    spectrumbridge_resp_size=[];
    for x=4:colb
        spectrumbridge_resp_size=[spectrumbridge_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
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
            
        end
    end
end
if ofcom_test==1
    %Clear old query results
    cd([my_path,'/ofcom']);
    %Message size distribution (ofcom)
    list_dir=dir;
    [rowb,colb]=size({list_dir.bytes});
    ofcom_resp_size=[];
    for x=4:colb
        ofcom_resp_size=[ofcom_resp_size,list_dir(x).bytes];
    end
    %system('rm *');
    
end
%%
%Plot figure
if google_test==1
    figure('Position',[440 378 560 420/3]);
    [fg,xg]=ksdensity(google_resp_size,'support','positive');
    fg=fg./sum(fg);
    plot(xg,fg,'g-');
    grid on;
    box on;
    hold on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
if spectrumbridge_test==1
    %figure('Position',[440 378 560 420/2]);
    [fs,xs]=ksdensity(spectrumbridge_resp_size,'support','positive');
    fs=fs./sum(fs);
    plot(xs,fs,'k-.');
    grid on;
    box on;
    hold on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
if ofcom_test==1
    %figure('Position',[440 378 560 420/2]);
    [fo,xo]=ksdensity(ofcom_resp_size,'support','positive');
    fs=fo./sum(fo);
    plot(xo,fo,'r-.');
    grid on;
    box on;
    hold on;
    set(gca,'FontSize',ftsz);
    xlabel('Message size (bytes)','FontSize',ftsz);
    ylabel('Probability','FontSize',ftsz);
end
%Add common legend
legend(legend_string);

%%
%Calculate statistics of message sizes for each WSDB
%Mean
mean_spectrumbridge_resp_size=mean(spectrumbridge_resp_size)
mean_google_resp_size=mean(google_resp_size)
mean_ofcom_resp_size=mean(ofcom_resp_size)

%Variance
var_spectrumbridge_resp_size=var(spectrumbridge_resp_size)
var_google_resp_size=var(google_resp_size)
var_ofcom_resp_size=var(ofcom_resp_size)
%%
['Elapsed time: ',num2str(toc/60),' min']