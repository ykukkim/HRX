%% Real Time HS Detection using Kinematic Data.
clear; clc; close all;

N = 400;
heel = zeros(N,1);
toe = zeros(N,1);
mid = zeros(N,1);
RTCentre = zeros(N,1);
RTVel = zeros(N,1);
error=false;

Rightdata = false;
stat = false;
%% VICON Set Up
TransmitMulticast = false;
%% A dialog to stop the loop
MessageBox = msgbox( 'Stop DataStream Client', 'Vicon DataStream SDK For Trigger' );

%% Load the SDK
Client.LoadViconDataStreamSDK();

%% Program options
HostName = 'localhost:801';

%% Make a new client
MyClient = Client();

%% Connect to a server
while ~MyClient.IsConnected().Connected
    % Direct connection
    MyClient.Connect( HostName );
end

MyClient.EnableMarkerData(); % Enable Data from Markers
fprintf( 'Marker Data Enabled: %s\n',AdaptBool( MyClient.IsMarkerDataEnabled().Enabled ));

MyClient.SetStreamMode( StreamMode.ClientPullPreFetch);

%% Set the global up axis Remaps the 3D axis.
MyClient.SetAxisMapping( Direction.Forward,Direction.Left, Direction.Up );    % Z-up

%% Get the current Axis mapping.
Output_GetAxisMapping = MyClient.GetAxisMapping();

if TransmitMulticast
    MyClient.StartTransmittingMulticast( 'localhost', '224.0.0.0' );
end

Counter = 1;
ts = 100;
while ishandle( MessageBox )

    Counter = Counter + 1;
    ts = ts + 1;
    %% Get a frame
    while MyClient.GetFrame().Result.Value ~= Result.Success
    end
    OutputGMC = MyClient.GetMarkerCount(MyClient.GetSubjectName(1).SubjectName);
    %     fprintf('ts = %d \n',ts);
    %% Checking the marker name
    if (strcmp(MyClient.GetMarkerName(MyClient.GetSubjectName(1).SubjectName,19).MarkerName,'RHEE') && strcmp(MyClient.GetMarkerName(MyClient.GetSubjectName(1).SubjectName,21).MarkerName,'RTO3'))...
            || (strcmp(MyClient.GetMarkerName(MyClient.GetSubjectName(1).SubjectName,33).MarkerName,'LHEE') && strcmp(MyClient.GetMarkerName(MyClient.GetSubjectName(1).SubjectName,35).MarkerName,'LTO3'))
        heelGBC = MyClient.GetMarkerGlobalTranslation(MyClient.GetSubjectName(1).SubjectName,'RHEE');
        toeGBC = MyClient.GetMarkerGlobalTranslation(MyClient.GetSubjectName(1).SubjectName,'RTO3');
        midGBC = MyClient.GetMarkerGlobalTranslation(MyClient.GetSubjectName(1).SubjectName,'RTO3');
        heel(1:N-1) = heel(2:N);
        heel(N,:) = heelGBC.Translation(3,1);
        toe(1:N-1) = toe(2:N);
        toe(N,:) = toeGBC.Translation(3,1);
        mid(1:N-1) = mid(2:N);
        mid(N,:) = midGBC.Trnalsation(3,1);

        %% Acquiring data for x seconds for threshold and to find out the trend of gait
        if ts == 500
            zCoordfootcentre = 1/2 * (heel + toe);
            zfootVel = diff(zCoordfootcentre) ./ transpose(diff(1:length(zCoordfootcentre)));
            thre  = min(heel)+ (0.2* (max(heel) - min(heel)));
            minheel = min(heel);
            minheel_centre = minheel + 0.3*minheel;
            fprintf('Data Acquring Done \n');
            Rightdata = true;
        end
        %% Stimulus Condition
        if Rightdata == true
            t = timer('TimerFcn', 'stat=false; disp(''Reset!'')','StartDelay',randi([9 15]));
            RTCentre(1:N-1) = RTCentre(2:N);
            RTVel(1:N-1) = RTVel(2:N);
            RTCentre(N,:) = 1/2 *(heelGBC.Translation(3,1) + toeGBC.Translation(3,1));
            RTVel(N,:) = RTCentre(N,:)-RTCentre(N-1,:);
            if  (heelGBC.Translation(3,1) <= thre) && (heelGBC.Translation(3,1) >= (0.5*thre))...
                    && (RTVel(N,:) <= 0.1) && (RTVel(N,:) >= -0.1)...
                    && stat == false
                fprintf('Triggered! %d\n',Counter);
                start(t);
                stat = true;
            end
        end
    else
        fprintf('Please Check the Marker index \n');
    end
end

if TransmitMulticast
    MyClient.StopTransmittingMulticast();
end

stop (t);
%% Disconnect and dispose
MyClient.Disconnect();

%% Unload the SDK
fprintf( 'Unloading SDK...' );
Client.UnloadViconDataStreamSDK();
fprintf( 'done\n' );
