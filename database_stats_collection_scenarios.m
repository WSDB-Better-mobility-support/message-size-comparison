%DATABASE_STATS_COLLECTION_SCENARIOS Script used in generating numerical
%results of [1, Section IV-B] 
%
%   Reference: [1] Will Dynamic Spectrum Access Drain my Battery?

%   Code development: 

%   Last update: 28 July 2014

%   This work is licensed under a Creative Commons Attribution 3.0 Unported
%   License. Link to license: http://creativecommons.org/licenses/by/3.0/

tic;
clear all;
close all;
clc;

%Switch which database you want to query
microsoft_test=1; %Query Microsoft database

%%
%Create legend for the figures
legend_string={'Google','MSR','SpectrumBridge'};
legend_flag=[google_test,microsoft_test,spectrumbridge_test];
legend_string(find(~legend_flag))=[];

%%
%Select which scenario to test
message_size_distribution=1;

%%
%Plot parameters
ftsz=16;

%%
%Path to save files (select your own)
my_path='/Users/przemek/Documents/Research/Research experiments and papers/White Space Databases/SVN/analysis/Matlab/WSDB access/WSDB responses';

%%
%General querying parameters

%Global Microsoft parameters (refer to http://whitespaces.msresearch.us/api.html)
PropagationModel='"Rice"';
CullingThreshold='-114'; %In dBm
IncludeNonLicensed='true';
IncludeMicrophones='true';
UseSRTM='false';
UseGLOBE='true';
UseLRBCast='true';


if message_size_distribution==1
    
    %Location of start and finish query
    %Query start location
    WSDB_data{1}.name='LA'; %Los Aneles, CA, USA (Wilshire Blvd 1) [downtown]
    WSDB_data{1}.latitude='34.047955';
    WSDB_data{1}.longitude='-118.256013';
    WSDB_data{1}.delay_microsoft=[];
    WSDB_data{1}.delay_google=[];
    
    %Query finish location
    WSDB_data{2}.name='CB'; %Carolina Beach, NC, USA [ocean coast]
    WSDB_data{2}.latitude='34.047955';
    WSDB_data{2}.longitude='-77.885639';
    WSDB_data{2}.delay_microsoft=[];
    WSDB_data{2}.delay_google=[];
    
    longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
    longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory
    
    longitude_interval=100;
    longitude_step=(longitude_end-longitude_start)/longitude_interval;
    
    delay_microsoft=[];

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

        if microsoft_test==1
            %Query Microsoft
            instant_clock=clock; %Start clock again if scanning only one database
            cd([my_path,'/microsoft']);
            [msg_microsoft,delay_microsoft_tmp,error_microsoft_tmp]=...
                database_connect_microsoft(longitude,latitude,PropagationModel,...
                CullingThreshold,IncludeNonLicensed,IncludeMicrophones,...
                UseSRTM,UseGLOBE,UseLRBCast,[my_path,'/microsoft']);
            var_name=(['microsoft_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
            fprintf('Microsoft\n')
            if error_microsoft_tmp==0
                dlmwrite([var_name,'.txt'],msg_microsoft,'');
                delay_microsoft=[delay_microsoft,delay_microsoft_tmp];
            end
        end
    end
    if microsoft_test==1
        %Clear old query results
        cd([my_path,'/microsoft']);
        
        %Message size distribution (Microsoft)
        list_dir=dir;
        [rowb,colb]=size({list_dir.bytes});
        microsoft_resp_size=[];
        for x=4:colb
            microsoft_resp_size=[microsoft_resp_size,list_dir(x).bytes];
        end
        %system('rm *');
    end
    
    %%
    %Plot figure
    if microsoft_test==1
        %figure('Position',[440 378 560 420/2]);
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
    %Add common legend
    legend(legend_string);
    
    %%
    %Calculate statistics of message sizes for each WSDB
    
    %Mean
    mean_spectrumbridge_resp_size=mean(spectrumbridge_resp_size)
    mean_microsoft_resp_size=mean(microsoft_resp_size)
    mean_google_resp_size=mean(google_resp_size)
    
    %Variance
    var_spectrumbridge_resp_size=var(spectrumbridge_resp_size)
    var_microsoft_resp_size=var(microsoft_resp_size)
    var_google_resp_size=var(google_resp_size)
    
end


%%
['Elapsed time: ',num2str(toc/60),' min']