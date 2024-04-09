function DAQ = configureDAQ(app)

% Inputs to this function:
% app = contains handles to all SampSamp properties
% ai = Array corresponding to analogue inputs 0-7 and which to turn on
% d = Handle to the DAQ object, allowing us to change our recording
% settings
% sampleFrequency = Frequency (Hz) at which DAQ device will sample at


% Obtain variables from app properties
ai              = app.analogueInputChoice;
d               = daq(app.daqType);
sampleFrequency = app.freq.Value;


% When you add channels you need the number of the
% port to sample from to activate it, under this a vector is created
% which elements represent 

for i=0:7
    if ai(i+1) == 1
        % If selected, add a channel to be recorded to DAQ object
        addinput(d, app.daqConnection, i, "Voltage");
    end
end

%-------------------Specific properties for trigger------------------------

% Configure DAQ ScansAvailableFcn callback function
d.ScansAvailableFcn = @(src,event) scansAvailable_Callback(app, src, event);

% Sets sample rate of ai will be rounded off to closest possible sampling rate 
%(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
d.Rate = sampleFrequency;

DAQ = d;
