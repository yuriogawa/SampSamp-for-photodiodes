function [trigDetected, trigMoment] = trigDetect(timestamps, data, trigConfig)
        %trigDetect Detect if trigger event condition is met in acquired data
        %   [trigDetected, trigMoment] = trigDetect(app, data, trigConfig)
        %   Returns a detection flag (trigDetected) and the corresponding data point index
        %   (trigMoment) of the first data point which meets the trigger condition
        %   based on signal level and condition specified by the trigger parameters
        %   structure (trigConfig).
        %   The input data (data) is an M x N matrix corresponding to M acquired
        %   data scans from N channels.
        %   trigConfig.Channel = index of trigger channel in DAQ channels
        %   trigConfig.Level   = signal trigger level
        %   trigConfig.Condition = trigger condition ('Rising' or 'Falling')
            
            switch trigConfig.Condition
                case 'Rising'
                    % Logical array condition for signal trigger level
                    trigConditionMet = data(:, trigConfig.Channel) > str2double(trigConfig.Level);
                case 'Falling'
                    % Logical array condition for signal trigger level
                    trigConditionMet = data(:, trigConfig.Channel) < str2double(trigConfig.Level);
            end
            
            trigDetected = any(trigConditionMet);
            trigMoment = [];
            if trigDetected
                % Find time moment when trigger condition has been met
                trigMomentIndex = 1 + find(trigConditionMet==1, 1, 'first');
                trigMoment = timestamps(trigMomentIndex);
            end
            
