%initialize DAQ-In/Output device
dev = daq.getDevices();                                 % Discover Devices
so = daq.createSession('ni');                           % Create a session
so.addAnalogOutputChannel(dev.ID, 'ao0', 'Voltage');    % Add analog output channels 0 to the session
so.IsContinuous = true;                                 % Generate the output signal in the background

% timer for 8 second window
t = timer('TimerFcn', 'stat=false; disp(''Triggered!'')','StartDelay', 5);
stat = false;

while (~so.IsDone)
    if stat == false
        outputSingleScan(so,[2]);                           % A value of 2V is output to analo output channel 0
        outputSingleScan(so,[0]);                           % A value of 0V is output to analo output channel 0
        start(t);
        stat = true;
    end
end

so.stop();
delete (so);
