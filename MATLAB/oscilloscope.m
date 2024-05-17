function oscilloscope(portIn)

    close all;
    Fs = 100; % sampling rate is 100 hz
    windowWidth = 10.0; % 10 seconds along x axis
    drawEvery = round(Fs / 20); % draw 20 times per second
    
    s = serial(portIn, 'BaudRate', 9600);
    fopen(s);

    % fires when main function terminates
    function cleanMeUp()
        disp('Closing all serial ports');
        fclose(instrfind);
    end

    onCleanup(@cleanMeUp);
    
    datapoints = []; % array of data
    time = []; % array of times
    points = [];

    figure % new figure each time, can comment out

    % ignore spurious first line
    ignore = fscanf(s);
    
    disp('Logging data, hit Ctrl + C to halt...')

    threshold = 57000;
    t1 = -1; % initialize time to a negative number to show it is unused
    onPeak = false; % keep track of whether or not we are above the threshold or not
    maxIndex = 1; % keep track of the index of our peak
    maxValue = 0; % keep track of the maximum value of our peak
    calculated = true; % keep track of whether or not we've calculated IHR for a given peak
            
    while(true)
        
        datapoint = fscanf(s, '%f'); % get datapoint, one per line

        datapoints = [datapoints, datapoint]; % save datapoint
        numPoints = length(datapoints);
        

              
        now = (numPoints - 1) / Fs;
        
        time = [time, now]; % update time array
            
        % don't draw every sample
        if mod(numPoints, drawEvery) == 0
            
            % plot
            plot(time, datapoints, 'b');
            title('Serial log: Hit Ctrl + C to halt')
            xlabel('Time (s)')
            ylabel('Voltage (V)')
            hold on
            
            if now < windowWidth
                xlim([0, windowWidth])
            else
                xlim([now-windowWidth, now])
            end
            
            drawnow
            
        end

        
        if (datapoint > threshold)
            onPeak = true;
        
            if (maxValue < datapoint)
        
                maxValue = datapoint;
                maxIndex = now;
                calculated = false; 
            end 

        
        % YOUR CODE HERE
    
    
        % if our signal is below the threshold, update onPeak, calculated
        % accordingly, and decide whether or not to plot and calculate IHR
        else
            if (onPeak && ~calculated)
                points = [points; maxIndex,maxValue];

                plot(points(:,1), points(:,2), 'o-');


                
                if t1>=0
                    IHR = ihr(t1, maxIndex)
                end
                t1 = now;
                maxValue = -9000000;
                onPeak = false;
                calculated = true; 
            end

        end
        
    end

end

function heartRate = ihr(t1,t2)
    heartRate = 1/(t2 - t1)*60;
end