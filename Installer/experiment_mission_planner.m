classdef experiment_mission_planner < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        MissionconfigurationTab         matlab.ui.container.Tab
        TextArea                        matlab.ui.control.TextArea
        OnboardexperimentparametersLabel  matlab.ui.control.Label
        ExperimenttransmitterparametersLabel  matlab.ui.control.Label
        T_idleminEditField              matlab.ui.control.NumericEditField
        T_idleminEditFieldLabel         matlab.ui.control.Label
        T_offmsEditField                matlab.ui.control.NumericEditField
        T_offmsEditFieldLabel           matlab.ui.control.Label
        T_tcmsEditField                 matlab.ui.control.NumericEditField
        T_tctmmsLabel                   matlab.ui.control.Label
        T_onmsEditField                 matlab.ui.control.NumericEditField
        T_onmsEditFieldLabel            matlab.ui.control.Label
        BeamAperture                    matlab.ui.control.EditField
        BeamApertureLabel               matlab.ui.control.Label
        HourEditField                   matlab.ui.control.EditField
        HourEditFieldLabel              matlab.ui.control.Label
        DateDatePicker                  matlab.ui.control.DatePicker
        DateDatePickerLabel             matlab.ui.control.Label
        RequiredEbNoRx                  matlab.ui.control.EditField
        RequiredEbNodBLabel             matlab.ui.control.Label
        GaintoNoiseTemperatureratioRx   matlab.ui.control.EditField
        GaintoNoiseTemperatureratiodBKLabel  matlab.ui.control.Label
        PreReceiverLossRx               matlab.ui.control.EditField
        PreReceiverLossdBEditFieldLabel  matlab.ui.control.Label
        SystemLoss                      matlab.ui.control.EditField
        SystemLossdBEditFieldLabel      matlab.ui.control.Label
        satAntenna                      matlab.ui.control.DropDown
        AntennaDropDownLabel            matlab.ui.control.Label
        satMountingAnglesTxRx           matlab.ui.control.EditField
        MountingAnglesmLabel            matlab.ui.control.Label
        satPowerTx                      matlab.ui.control.EditField
        PowerdBWLabel                   matlab.ui.control.Label
        satBitRateTx                    matlab.ui.control.EditField
        BitRateMbpsLabel                matlab.ui.control.Label
        FrequencyHzLabel                matlab.ui.control.Label
        satFrequencyTx                  matlab.ui.control.EditField
        satMountingLocationTxRx         matlab.ui.control.EditField
        MountingLocationmLabel          matlab.ui.control.Label
        satNameTxRx                     matlab.ui.control.EditField
        NameEditFieldLabel              matlab.ui.control.Label
        ButtonGroup                     matlab.ui.container.ButtonGroup
        CommsDownLinkButton             matlab.ui.control.RadioButton
        CommsUpLinkButton               matlab.ui.control.RadioButton
        RunSimulationButton             matlab.ui.control.Button
        gsInfo                          matlab.ui.control.EditField
        SelectxlsxfileButton            matlab.ui.control.Button
        tleInfo                         matlab.ui.control.EditField
        SelecttlefileButton             matlab.ui.control.Button
        GroundsegmentdataLabel          matlab.ui.control.Label
        OrbitalplatformdataLabel        matlab.ui.control.Label
        ExperimentreceiverparametersLabel  matlab.ui.control.Label
        MissionparametersLabel          matlab.ui.control.Label
        SimulationconfigurationTab      matlab.ui.container.Tab
        ScenaryDurationhEditField       matlab.ui.control.EditField
        ScenaryDurationhEditFieldLabel  matlab.ui.control.Label
        SampletimesEditField            matlab.ui.control.EditField
        SampletimesEditFieldLabel       matlab.ui.control.Label
        ShowantennaradiationpatternsCheckBox  matlab.ui.control.CheckBox
        FocusscenarycamerainorbitalplatformCheckBox  matlab.ui.control.CheckBox
        OtherparametersLabel            matlab.ui.control.Label
        SimulationparametersLabel       matlab.ui.control.Label
        ShowgroundtrackCheckBox         matlab.ui.control.CheckBox
        SimulationrepresentationButtonGroup  matlab.ui.container.ButtonGroup
        Button_2D                       matlab.ui.control.ToggleButton
        Button_3D                       matlab.ui.control.ToggleButton
        ResultsTab                      matlab.ui.container.Tab
        GeneratemissionplanButton       matlab.ui.control.Button
        ExporttocsvfileButton           matlab.ui.control.Button
        ExporttoxlsxfileButton          matlab.ui.control.Button
        UITable                         matlab.ui.control.Table
        InformationTab                  matlab.ui.container.Tab
        CompanyThalesAleniaSpaceSpainLabel  matlab.ui.control.Label
        UniversityReyJuanCarlosUniversityLabel  matlab.ui.control.Label
        SoftwareVersionv12Label         matlab.ui.control.Label
        DegreeAerospaceEngineeringinNavigationLabel  matlab.ui.control.Label
        AuthorCsarBoraoMoratinosLabel   matlab.ui.control.Label
        Image                           matlab.ui.control.Image
        EXPERIMENTMISSIONPLANNERLabel   matlab.ui.control.Label
        ContextMenu                     matlab.ui.container.ContextMenu
        Menu                            matlab.ui.container.Menu
        Menu2                           matlab.ui.container.Menu
    end

    % Private properties that correspond to app components
    properties (Access = private)
        tleFile = ''
        gsFile = ''
        raw       
        gs 
        startTime
        stopTime
        duration
    end

    methods (Access = private)

        % Create a new mission scenario
        function sc = createScenario(app)
            try
                % Set mission and simulation configuration
                date = app.DateDatePicker.Value;
                hour = app.HourEditField.Value;
                hour = datetime(hour, 'InputFormat', 'HH:mm:ss');
                app.startTime = datetime(date.Year, date.Month, date.Day, hour.Hour, hour.Minute, hour.Second);

                app.duration = hours(str2double(app.ScenaryDurationhEditField.Value));
                sampleTime = str2double(app.SampletimesEditField.Value);
                app.stopTime = app.startTime + app.duration;
            
                % Create new mission scenario
                sc = satelliteScenario(app.startTime,app.stopTime,sampleTime); 
            catch e
                fprintf(1,'Error: %s\n',e.message);
                app.TextArea.Value = "Error: " + e.message;
                return 
            end
        end
        
        % Create orbital platform object from .tle file
        function sat = SatFromTle(app,sc)

            try 
                %Create satellite object
                sat = satellite(sc,app.tleFile);
                assignin('base','sat',sat)

                %Create if there is only one satellite in the file (not a constellation)
                if size(sat,2) ~= 1
                    disp(strcat('Error: File "',app.tleInfo.Value ,'" includes a satellite constellation. Program works with an GsFromXlsxunique satellite')); 
                    error("More than one satellite included in .tle file")
                end
                
            catch e
                fprintf(1,'Error: %s\n',e.message);
                app.TextArea.Value = "Error: " + e.message;
                return 
            end
            
        end
    
        % Create ground segment objects from .xlsx file
        function gs = GsFromXlsx(app,sc)
           
            % Read gs .xlsx file content
            try
                [~,~,app.raw] = xlsread(app.gsFile);
                assignin('base','raw',app.raw);

                % Create Ground station objects
                for i = 2:size(app.raw,2)
                    gsName = app.raw{1,i};
                    gsLat = app.raw{2,i};
                    gsLon = app.raw{3,i};
                    gsMinElevationAngle = app.raw{4,i};
                    gs(i-1) = groundStation(sc,"Name",gsName,"Latitude",gsLat,"Longitude",gsLon,"MinElevationAngle",gsMinElevationAngle);
                end
                
                assignin('base','gs',gs)
                app.gs = gs;
            catch e
                fprintf(1,'Error: %s\n',e.message);
                app.TextArea.Value = "Error: In " + app.gsFile + ". " + e.message;
                return
            end
        end

        % Add RF equipment to the on-board experiment 
        function [satRFEquipment, RFtype] = addSatRFEquipment(app, sat)

            % If is Downlink calculation, equipment is Transmitter
            if app.CommsDownLinkButton.Value == true
        
                % Satellite transmitter creation
                try
                    satTx = transmitter(sat, ...
                                    "Name", app.satNameTxRx.Value, ...
                                    "MountingLocation", str2num(app.satMountingLocationTxRx.Value), ... 
                                    "MountingAngles", str2num(app.satMountingAnglesTxRx.Value), ... 
                                    "SystemLoss", str2double(app.SystemLoss.Value), ...
                                    "Frequency",str2double(app.satFrequencyTx.Value), ...    
                                    "BitRate",str2double(app.satBitRateTx.Value), ...
                                    "Power",str2double(app.satPowerTx.Value));  
                
                catch e
                    fprintf(1,'Error: %s\n',e.message);
                    app.TextArea.Value = "Error: In on-board experiment (transmitter). " + e.message;
                end 

                satRFEquipment = satTx;
                RFtype = "Tx";
                
            % If is Uplink calculation, satellite equipment is Receiver
            elseif app.CommsUpLinkButton.Value == true
    
                % Satellite receiver creation
                try
                    satRx = receiver(sat, ...
                                    "Name", app.satNameTxRx.Value, ...
                                    "MountingLocation", str2num(app.satMountingLocationTxRx.Value), ... 
                                    "MountingAngles", str2num(app.satMountingAnglesTxRx.Value), ...
                                    "RequiredEbNo", str2double(app.RequiredEbNoRx.Value), ...
                                    "SystemLoss", str2double(app.SystemLoss.Value), ...
                                    "PreReceiverLoss", str2double(app.PreReceiverLossRx.Value), ...
                                    "GainToNoiseTemperatureRatio", str2double(app.GaintoNoiseTemperatureratioRx.Value), ...
                                    "RequiredEbNo", str2double(app.RequiredEbNoRx.Value));    

                catch e
                    fprintf(1,'Error: %s\n',e.message);
                    app.TextArea.Value = "Error: In on-board experiment (receiver). " + e.message;
                end

                satRFEquipment = satRx;
                RFtype = "Rx";
            end
        end

        % Add RF equipment to each ground station
        function [gsRFEquipment, RFtype] = addGsRFEquipment(app, gs, sat)

            % If is Downlink calculation, equipment is Receiver
            if app.CommsDownLinkButton.Value == true

                % Add receiver for each gs
                for i = 2:size(app.raw,2)
                    
                    % Gimbal configuration
                    gimbalMountingLocation = app.raw{5,i};
                    gimbalMountingAngles = app.raw{6,i};
                    if isnan(gimbalMountingLocation)
                        current = gs(i-1);
                    else
                        gsGimbal = gimbal(gs(i-1), ...
                                        "MountingLocation",str2num(gimbalMountingLocation), ...
                                        "MountingAngles",str2num(gimbalMountingAngles));
                  
                        % Set the gimbals to track the satellite.
                        current = gsGimbal;
                        pointAt(current,sat);
                    end  
                    
                    % GS Antenna configuration
                    gsAntennaRx = app.raw{12,i};
                    if isnan(gsAntennaRx)
                        gsAntennaRx = 'Gaussian';
                    end
    
                    gsAntennaApertureRx = app.raw{13,i};
                    if isnan(gsAntennaApertureRx)
                        gsAntennaApertureRx = 70;
                    end

                    % Set GS receiver parameters
                    gsMountingAnglesRx = str2double(app.raw{7,i});
                    if isnan(gsMountingAnglesRx)
                        gsMountingAnglesRx = double([0;180;0]);
                    end
                    gsGainToNoiseTemperatureRatioRx = app.raw{8,i};
                    if isnan(gsGainToNoiseTemperatureRatioRx)
                        gsGainToNoiseTemperatureRatioRx = 3;
                    end
                    gsRequiredEbNoRx = app.raw{9,i};
                    if isnan(gsRequiredEbNoRx)
                        gsRequiredEbNoRx = 10;
                    end
                    gsReceiverSystemLossRx = app.raw{10,i};
                    if isnan(gsReceiverSystemLossRx)
                        gsReceiverSystemLossRx = 5;
                    end
                    gsPreReceiverLossRx = app.raw{11,i};
                    if isnan(gsPreReceiverLossRx)
                        gsPreReceiverLossRx = 3;
                    end
                    
                    % Create receiver object
                    try
                        gsRx(i-1) = receiver(current, ...
                                        "Name", strcat(gs(i-1).Name, ' Rx'), ...
                                        "GainToNoiseTemperatureRatio",gsGainToNoiseTemperatureRatioRx, ... 
                                        "RequiredEbNo",gsRequiredEbNoRx, ...
                                        "SystemLoss",gsReceiverSystemLossRx,...
                                        "PreReceiverLoss",gsPreReceiverLossRx); 
                        if isnan(gimbalMountingLocation)
                            gsRx(i-1).MountingAngles = gsMountingAnglesRx;
                        end
    
                        % Configure Antenna properties
                        if strcmp(gsAntennaRx,'Gaussian')
                            lambda = 3*10^8/str2double(app.satFrequencyTx.Value); 
                            [d,~] = calculateDishDiameter(app,gsAntennaApertureRx,lambda,0.65);
                            gaussianAntenna(gsRx(i-1),"DishDiameter",d);
                        end
                    catch e
                        fprintf(1,'Error: %s\n',e.message);
                        app.TextArea.Value = "Error: In GS receiver. " + e.message;
                    end
                    gsRFEquipment(i-1) = gsRx(i-1);
                    RFtype = 'Rx';                             
                end

            % If is Uplink calculation, equipment is Transmitter
            elseif app.CommsUpLinkButton.Value == true

                % Add transmitter for each gs
                for i = 2:size(app.raw,2)

                    % Gimbal configuration 
                    gimbalMountingLocation = app.raw{5,i};
                    gimbalMountingAngles = app.raw{6,i};
                    if isnan(gimbalMountingLocation)
                        current = gs(i-1);
                    else
                        gsGimbal = gimbal(gs(i-1), ...
                                    "MountingLocation",str2num(gimbalMountingLocation), ...
                                    "MountingAngles",str2num(gimbalMountingAngles));
                    
                        % Set the gimbals to track the satellite.
                        current = gsGimbal;
                        pointAt(current,sat);
                    end 

                    % Antenna configuration
                    gsAntennaTx = str2num(app.raw{12,i});
                    if isnan(gsAntennaTx)
                        gsAntennaTx = 'Gaussian';
                    end

                    gsAntennaApertureTx = app.raw{13,i};
                    if isnan(gsAntennaApertureTx)
                        gsAntennaApertureTx = 70;
                    end  

                    % Set transmitter configuration
                    gsMountingAnglesTx = str2double(app.raw{7,i});
                    if isnan(gsMountingAnglesTx)
                        gsMountingAnglesTx = double([0;180;0]);
                    end
                    gsSystemLossTx = app.raw{14,i};
                    if isnan(gsSystemLossTx)
                        gsSystemLossTx = 5;
                    end
                    gsFrequencyTx = app.raw{15,i};
                    if isnan(gsFrequencyTx)
                        gsFrequencyTx = 14e9;
                    end
                    gsBitRateTx = app.raw{16,i};
                    if isnan(gsBitRateTx)
                        gsBitRateTx = 10;
                    end
                    gsPowerTx = app.raw{17,i};
                    if isnan(gsPowerTx)
                        gsPowerTx = 12;
                    end
    
                    % Creating transmitter
                    try
                        gsTx(i-1) = transmitter(current, ...
                                            "Name", strcat(gs(i-1).Name, ' Tx'), ...
                                            "SystemLoss",gsSystemLossTx, ... 
                                            "Frequency",gsFrequencyTx, ...
                                            "BitRate",gsBitRateTx,...
                                            "Power",gsPowerTx);                                                          
                        if isnan(gimbalMountingLocation)
                            gsTx(i-1).MountingAngles = gsMountingAnglesTx;
                        end

                        % Configure Antenna
                        if strcmp(gsAntennaTx,'Gaussian')
                            lambda = 3*10^8./gsFrequencyTx;
                            [d,~] = calculateDishDiameter(app,gsAntennaApertureTx,lambda,0.65);
                            gaussianAntenna(gsTx(i-1),"DishDiameter",d);
                        end

                    catch e
                        fprintf(1,'Error: %s\n',e.message);
                        app.TextArea.Value = "Error: In GS transmitter. " + e.message;
                    end

                    gsRFEquipment(i-1) = gsTx(i-1);
                    RFtype = 'Tx';
                end
            end      
        end

        % Create communications link between on-board experiment and ground stations
        function createLink(app, satRFEquipment, gsRFEquipment)
            % Create link
            if app.CommsDownLinkButton.Value == true     
                lnk = link(satRFEquipment,gsRFEquipment);
            elseif app.CommsUpLinkButton.Value == true
                lnk = link(gsRFEquipment,satRFEquipment);   
            end

            % Show active link intervals
            intervals = linkIntervals(lnk);

            % Store results in Results tab
            currentData = app.UITable.Data;
            newData = vertcat(currentData, intervals);
            app.UITable.Data = newData;
            app.ExporttoxlsxfileButton.Visible = true;
            app.ExporttocsvfileButton.Visible = true;
            app.GeneratemissionplanButton.Visible = true;

            assignin('base','UITable',app.UITable.DisplayData)
        end
        
        % Calculate gaussian antenna parameters from antenna beam aperture
        % and frequency
        function [d, gain] = calculateDishDiameter(~,aperture,lambda,efficiency)
            d = (70*lambda)/aperture;
            gain = efficiency*((pi*d/lambda)^2);
        end
        
        % Configure on-board experiment antenna
        function configureSatAntenna(app,satRFEquipment)
            if app.CommsUpLinkButton.Value == true
                if app.satAntenna.Value == "Gaussian Antenna"
                    lambda = 3*10^8/app.raw{15,2};
                    [d,~] = calculateDishDiameter(app,str2double(app.BeamAperture.Value),lambda,0.65);
                    gaussianAntenna(satRFEquipment,"DishDiameter",d); % meters
                end
            elseif app.CommsDownLinkButton.Value == true
                if app.satAntenna.Value == "Gaussian Antenna"
                    lambda = 3*10^8/str2double(app.satFrequencyTx.Value);
                    [d,~] = calculateDishDiameter(app,str2double(app.BeamAperture.Value),lambda,0.65);
                    gaussianAntenna(satRFEquipment,"DishDiameter",d); % meters
                end       
            end
        end

        % get gimbal object of a GS
        function [gimbal, index] = getGimbalFromRFEquipment(app, equipment)
            for i = 1:size(app.gs, 2)
                if app.CommsUpLinkButton.Value == true
                    if any(app.gs(i).Gimbals.Transmitters.Name == equipment)
                        gimbal = app.gs(i).Gimbals;
                        index = i;
                        return;
                    elseif any(app.gs(i).Transmitters.Name == equipment)
                        gimbal = '';
                        index = i;
                        return;
                    end
                elseif app.CommsDownLinkButton.Value == true
                    if any(app.gs(i).Gimbals.Receivers.Name == equipment)
                        gimbal = app.gs(i).Gimbals;
                        index = i;
                        return;
                    elseif any(app.gs(i).Receivers.Name == equipment)
                        gimbal = '';
                        index = i;
                        return;
                    end
                end
            end
            gimbal = '';
            index = 0;
        end
        
        % Formatter of Duration objects
        function formatted_duration = durationFormatter(~, duration_milliseconds)
            diff_milliseconds = duration_milliseconds;
            hours = floor(diff_milliseconds / (1000 * 60 * 60));
            minutes = floor((diff_milliseconds - hours * 1000 * 60 * 60) / (1000 * 60));
            seconds = floor((diff_milliseconds - hours * 1000 * 60 * 60 - minutes * 1000 * 60) / 1000);
            milliseconds = mod(diff_milliseconds, 1000);
            format = '%02d:%02d:%02d.%03d';
            formatted_duration = sprintf(format, hours, minutes, seconds, milliseconds);
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Result table initialization
            app.UITable.ColumnName = ["Source","Target","IntervalNumber","StartTime","EndTime","Duration","StartOrbit","EndOrbit"];
            app.UITable.Visible = true;
            app.UITable.Data = [];
            
        end

        % Button pushed function: RunSimulationButton
        function RunSimulationButtonPushed(app, event)

            app.TextArea.Visible = true;
            app.TextArea.Value = "Running simulation...";

            % Remove previous results
            app.UITable.Data = [];

            % Create mission scenario 
            sc = createScenario(app);
            
            % Create orbital platform data from selected .tle file
            sat = SatFromTle(app,sc);
            
            % Add RF satellite experiment equipment
            [satRFEquipment, ~] = addSatRFEquipment(app,sat);
            
            % Create ground stations data from selected .xlsx file 
            app.gs = GsFromXlsx(app, sc);
            
            % Add RF ground stations equipment
            [gsRFEquipment, ~] = addGsRFEquipment(app,app.gs,sat);
            
            configureSatAntenna(app,satRFEquipment)

            % Create Link
            createLink(app,satRFEquipment,gsRFEquipment)

            % Sorting table chronologically
            app.UITable.Data = sortrows(app.UITable.Data, 'StartTime');

            % Visualization extra options
            if app.ShowantennaradiationpatternsCheckBox.Value == true
                if app.CommsDownLinkButton.Value == true
                   pattern(satRFEquipment);
                   for i = 1:size(gsRFEquipment,2)
                       pattern(gsRFEquipment(i),satRFEquipment.Frequency);
                   end

                elseif app.CommsUpLinkButton.Value == true
                   pattern(satRFEquipment,app.raw{15,2});
                   for i = 1:size(gsRFEquipment,2)
                       pattern(gsRFEquipment(i));
                   end
                end
            end

            if app.Button_2D.Value == true
                dimension = '2D';
            else
                dimension = '3D';
            end    
            scv = satelliteScenarioViewer(sc,Dimension=dimension);
             
            if app.ShowgroundtrackCheckBox.Value == true
                groundTrack(sat,LeadTime=3600);
            end
            
            if app.FocusscenarycamerainorbitalplatformCheckBox.Value == true
                camtarget(scv,sat);
            end

            app.TextArea.Value = "Simulation completed!";

        end

        % Button pushed function: SelecttlefileButton
        function SelecttlefileButtonPushed(app, event)
            % Select a file
            [fileName,filePath] = uigetfile();

            % Check if file has name
            if fileName ~= 0
                fullFileName = fullfile(filePath,fileName);
                [~,fileNameNoExt,fileExt] = fileparts(fullFileName);

                % Check if file extension is .tle
                if strcmp(fileExt,'.tle')
                    app.tleInfo.Value = [fileNameNoExt fileExt];
                    assignin('base','tleSelectedFile',fullFileName);
                    app.tleFile = fullFileName; 

                    if ~isempty(app.gsFile)
                        app.RunSimulationButton.Visible = true;
                    end
                else
                    app.tleInfo.Value = 'Error: selected file is not .tle';
                    app.RunSimulationButton.Visible = false;
                    app.tleFile = '';
                end
            end
        end

        % Button pushed function: SelectxlsxfileButton
        function SelectxlsxfileButtonPushed(app, event)
            % Select a file
            [fileName,filePath] = uigetfile();

            % Check if file has name
            if fileName ~= 0
                fullFileName = fullfile(filePath,fileName);
                [~,fileNameNoExt,fileExt] = fileparts(fullFileName);

                % Check if file extension is .xlsx
                if strcmp(fileExt,'.xlsx')
                    app.gsInfo.Value = [fileNameNoExt fileExt];
                    app.gsFile = fullFileName;
                    assignin('base','gsSelectedFile',fullFileName);

                    if ~isempty(app.tleFile)
                        app.RunSimulationButton.Visible = true;
                    end
                else
                    app.gsInfo.Value = 'Error: selected file is not .xlsx';
                    app.RunSimulationButton.Visible = false;
                    app.gsFile = '';
                end
            end            
        end

        % Button down function: ButtonGroup
        function ButtonGroupButtonDown(app, event)
            if app.CommsDownLinkButton.Value == true
                app.NameEditFieldLabel.Visible = true;
                app.satNameTxRx.Visible = true;
            end  
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            if app.CommsDownLinkButton.Value == true
                app.ExperimenttransmitterparametersLabel.Visible = true;
                app.ExperimentreceiverparametersLabel.Visible = false;

                app.satFrequencyTx.Visible = true;
                app.FrequencyHzLabel.Visible = true;
                app.satBitRateTx.Visible = true;
                app.BitRateMbpsLabel.Visible = true;
                app.satPowerTx.Visible = true;
                app.PowerdBWLabel.Visible = true;
               
                app.SystemLoss.Visible = true;
                app.SystemLossdBEditFieldLabel.Visible = true;
                app.PreReceiverLossRx.Visible = true;
                app.PreReceiverLossdBEditFieldLabel.Visible = false;
                app.GaintoNoiseTemperatureratioRx.Visible = false;
                app.GaintoNoiseTemperatureratiodBKLabel.Visible = false;
                app.RequiredEbNoRx.Visible = false;
                app.RequiredEbNodBLabel.Visible = false;

            end 
            if app.CommsUpLinkButton.Value == true
                app.ExperimenttransmitterparametersLabel.Visible = false;
                app.ExperimentreceiverparametersLabel.Visible = true;

                app.satFrequencyTx.Visible = false;
                app.FrequencyHzLabel.Visible = false;
                app.satBitRateTx.Visible = false;
                app.BitRateMbpsLabel.Visible = false;
                app.satPowerTx.Visible = false;
                app.PowerdBWLabel.Visible = false;

                app.SystemLoss.Visible = true;
                app.SystemLossdBEditFieldLabel.Visible = true;
                app.PreReceiverLossRx.Visible = true;
                app.PreReceiverLossdBEditFieldLabel.Visible = true;
                app.GaintoNoiseTemperatureratioRx.Visible = true;
                app.GaintoNoiseTemperatureratiodBKLabel.Visible = true;
                app.RequiredEbNoRx.Visible = true; 
                app.RequiredEbNodBLabel.Visible = true;
                
            end   
        end

        % Button pushed function: ExporttoxlsxfileButton
        function ExporttoxlsxfileButtonPushed(app, event)
            [fileName, pathName] = uiputfile('*.xlsx','Save as');
            if fileName == 0
                return;
            end
            fullPath = fullfile(pathName, fileName);
            writetable(app.UITable.Data, fullPath, "AutoFitWidth",false);

        end

        % Button pushed function: ExporttocsvfileButton
        function ExporttocsvfileButtonPushed(app, event)
            [file, path] = uiputfile('*.csv', 'Save as');
            if file == 0
                return
            end
            
            filename = fullfile(path, file);
            writetable(app.UITable.Data, filename);
            
        end

        % Button pushed function: GeneratemissionplanButton
        function GeneratemissionplanButtonPushed(app, event)
            [file, path] = uiputfile('*.txt', 'Save as');
            if file == 0
                return
            end
            
            fileId = fopen(fullfile(path, file), 'w');
            fprintf(fileId,'--------------------------------------------------------------------------------------\n');
            fprintf(fileId,'MISSION PLAN\n--------------------------------------------------------------------------------------\n\n');
            fprintf(fileId,'Generation date: %s\n',datetime("now"));
            fprintf(fileId,'\n--------------------------------------------------------------------------------------\n');
            fprintf(fileId,'Mission Parameters: \n\n');
            fprintf(fileId,'\tUTC Start Time: %s\n',app.startTime);
            fprintf(fileId,'\tUTC End Time: %s\n\n',app.stopTime);
            fprintf(fileId,'Experiment Parameters: \n\n');
            fprintf(fileId,'\tEstimated 𝜏_tc/tm: %d ms\n',app.T_tcmsEditField.Value);
            fprintf(fileId,'\tT_on: %d ms\n',app.T_onmsEditField.Value);
            fprintf(fileId,'\tT_off: %d ms\n',app.T_offmsEditField.Value);
            fprintf(fileId,'\tT_idle: %d minutes\n\n',app.T_idleminEditField.Value);
            
            if app.CommsDownLinkButton.Value == true
                type = "Downlink";
            else
                type = "Uplink";
            end
            fprintf(fileId,'Experiment link type: %s\n',type);

            fprintf(fileId,'\n--------------------------------------------------------------------------------------\n\n');

            startTime_index = strcmp(app.UITable.ColumnName, 'StartTime');
            EndTime_index = strcmp(app.UITable.ColumnName, 'EndTime');
            source_index = strcmp(app.UITable.ColumnName, 'Source');
            target_index = strcmp(app.UITable.ColumnName, 'Target');
            duration_index = strcmp(app.UITable.ColumnName, 'Duration');
            startOrbit_index = strcmp(app.UITable.ColumnName, 'StartOrbit');

            T_on = milliseconds(app.T_tcmsEditField.Value);
            T_tc = milliseconds(app.T_tcmsEditField.Value);
            T_idle = minutes(app.T_idleminEditField.Value);

            T0_time = datetime(app.startTime, 'Format', 'dd-MMM-y HH:mm:ss.SSS','TimeZone','UTC');
            last_tc_received = T0_time;
            fprintf(fileId,'[T+00:00:00.000] %s MISSION START\n\n', last_tc_received); 

            total_duration = 0;
            last_orbit = 0;

            for i = 1:size(app.UITable.Data,1)

                current_orbit = app.UITable.Data{i, startOrbit_index}; 
                if current_orbit ~= last_orbit
                    last_orbit = current_orbit;
                    fprintf(fileId,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
                    fprintf(fileId,'%% ORBIT NUMBER %d %%\n',current_orbit);
                    fprintf(fileId,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n');
                end   
 
                startTimeData = app.UITable.Data{i, startTime_index}; 
                startTimeData = datetime(startTimeData, 'Format', 'dd-MMM-y HH:mm:ss.SSS', 'TimeZone','UTC');

                EndTimeData = app.UITable.Data{i, EndTime_index}; 
                EndTimeData = datetime(EndTimeData, 'Format', 'dd-MMM-y HH:mm:ss.SSS', 'TimeZone','UTC');

                source = app.UITable.Data{i, source_index};
                target = app.UITable.Data{i, target_index}; 
                Duration = seconds(app.UITable.Data{i, duration_index}); 
                total_duration = total_duration + Duration;

                new_tc_received = startTimeData;
 
                if minutes(new_tc_received - last_tc_received) > minutes(T_idle)
                    if i ~= 1
                        % Turn off ULTRON experiment
                        mission_timestamp = durationFormatter(app, milliseconds(last_tc_received-T0_time));
                        fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: Send TC_Off\n\n', mission_timestamp, last_tc_received);
                    end

                    % Turn on ULTRON experiment
                    mission_timestamp = durationFormatter(app, milliseconds((startTimeData -2*T_tc -T_on)-T0_time));
                    fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: Send TC_On\n\n', mission_timestamp, startTimeData -2*T_tc -T_on);
                end
               
                if app.CommsUpLinkButton.Value == true 
                    mission_timestamp = durationFormatter(app, milliseconds((startTimeData -T_tc)-T0_time));
                    fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: if TM_IdleMode received, then Send TC_StartRx\n\n', mission_timestamp, startTimeData -T_tc);

                    [gimbal, index] = getGimbalFromRFEquipment(app,source);
                    
                    if ~isempty(gimbal)
                        try
                            time = datetime(startTimeData.Year, startTimeData.Month, startTimeData.Day, startTimeData.Hour, startTimeData.Minute, startTimeData.Second);
                            [az,el] = gimbalAngles(gimbal,time);
                        catch e
                            fprintf(1,'Error: %s\n',e.message);
                            app.TextArea.Value = "Error: " + e.message;
                            return 
                        end
                        mission_timestamp = durationFormatter(app, milliseconds(startTimeData-T0_time));
                        printf(fileId,'[T+%s] %s\tGS OPERATOR: Point "%s" gs gimbal to azimuth=%.3f° and elevation=%.3f°\n', mission_timestamp, startTimeData, app.gs(index).Name, az, el);
                    end

                    mission_timestamp = durationFormatter(app, milliseconds(startTimeData -T0_time));
                    fprintf(fileId,'[T+%s] %s\tGS OPERATOR: Start Tx in "%s" ground station\n', mission_timestamp, startTimeData, app.gs(index).Name);
                    fprintf(fileId,'\t\t\t\t\t\t\t\t\t\t\t> Uplink started between "%s" and "%s"\n', source, target);
                    fprintf(fileId,'\t\t\t\t\t\t\t\t\t\t\t> Window duration: %s\n\n', Duration);
                    
                    mission_timestamp = durationFormatter(app, milliseconds((EndTimeData -T_tc)-T0_time));
                    fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: if TM_RxMode received, then Send TC_EndRx\n\n', mission_timestamp, EndTimeData -T_tc);

                    mission_timestamp = durationFormatter(app, milliseconds(EndTimeData-T0_time));
                    fprintf(fileId,'[T+%s] %s\tGS OPERATOR: End Rx in "%s" ground station\n\n', mission_timestamp, EndTimeData, app.gs(index).Name);

                elseif app.CommsDownLinkButton.Value == true
                    mission_timestamp = durationFormatter(app, milliseconds((startTimeData -T_tc)-T0_time));
                    fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: if TM_IdleMode received, then Send TC_StartTx\n\n', mission_timestamp, startTimeData -T_tc);

                     [gimbal, index] = getGimbalFromRFEquipment(app,target);
                     if ~isempty(gimbal)
                        try
                            time = datetime(startTimeData.Year, startTimeData.Month, startTimeData.Day, startTimeData.Hour, startTimeData.Minute, startTimeData.Second);
                            [az,el] = gimbalAngles(gimbal,time);
                        catch e
                            fprintf(1,'Error: %s\n',e.message);
                            app.TextArea.Value = "Error: " + e.message;
                            return 
                        end    
                        mission_timestamp = durationFormatter(app, milliseconds(startTimeData -T0_time));
                        fprintf(fileId,'[T+%s] %s\tGS OPERATOR: Point "%s" gs gimbal to azimuth=%.3f° and elevation=%.3f°\n', mission_timestamp, startTimeData, app.gs(index).Name, az, el);
                     end
    
                    mission_timestamp = durationFormatter(app, milliseconds(startTimeData -T0_time));
                    fprintf(fileId,'[T+%s] %s\tGS OPERATOR: Start Rx in "%s" ground station\n', mission_timestamp, startTimeData, target);
                    fprintf(fileId,'\t\t\t\t\t\t\t\t\t\t\t> Downlink started between "%s" and "%s"\n', target, source);
                    fprintf(fileId,'\t\t\t\t\t\t\t\t\t\t\t> Window duration: %s\n\n', Duration);
                    
                    mission_timestamp = durationFormatter(app, milliseconds((EndTimeData -T_tc) -T0_time));
                    fprintf(fileId,'[T+%s] %s\tPLATFORM OPERATOR: if TM_TxMode received, then Send TC_EndTx\n\n', mission_timestamp, EndTimeData -T_tc);

                    mission_timestamp = durationFormatter(app, milliseconds(EndTimeData-T0_time));
                    fprintf(fileId,'[T+%s] %s\tGS OPERATOR: End Rx in "%s" ground station\n\n', mission_timestamp, EndTimeData, app.gs(index).Name);
                end

                last_tc_received = EndTimeData;
            end
 
            fprintf(fileId,'\n--------------------------------------------------------------------------------------\n\n');
            fprintf(fileId,'MISSION PLAN SUMMARY\n\n');

            fid=fopen(app.tleFile);
            fprintf(fileId,'\t> Orbital platform: \n\t\t%s\n\n',fgetl(fid));
            fclose(fid);

            fprintf(fileId,'\t> Ground stations accessed: \n');
            if app.CommsUpLinkButton.Value == true
                source_index = strcmp(app.UITable.ColumnName, 'Source');
            else
                source_index = strcmp(app.UITable.ColumnName, 'Target');
            end
            [names, ~, index] = unique(app.UITable.Data{:, source_index});
            repeats = accumarray(index, 1);

            for i = 1:numel(names)
                fprintf(fileId, '\t\t%s: %d\n', names{i}, repeats(i));
            end

             fprintf(fileId, '\n\tTotal time of active link: %.3f minutes\n', minutes(total_duration));
            
            fclose(fileId);

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 639 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create EXPERIMENTMISSIONPLANNERLabel
            app.EXPERIMENTMISSIONPLANNERLabel = uilabel(app.UIFigure);
            app.EXPERIMENTMISSIONPLANNERLabel.HorizontalAlignment = 'center';
            app.EXPERIMENTMISSIONPLANNERLabel.WordWrap = 'on';
            app.EXPERIMENTMISSIONPLANNERLabel.FontName = 'Arial';
            app.EXPERIMENTMISSIONPLANNERLabel.FontSize = 20;
            app.EXPERIMENTMISSIONPLANNERLabel.FontWeight = 'bold';
            app.EXPERIMENTMISSIONPLANNERLabel.FontColor = [0.1216 0.1451 0.4627];
            app.EXPERIMENTMISSIONPLANNERLabel.Position = [156 413 330 52];
            app.EXPERIMENTMISSIONPLANNERLabel.Text = 'EXPERIMENT MISSION PLANNER';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [511 396 100 86];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'logo.png');

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 640 394];

            % Create MissionconfigurationTab
            app.MissionconfigurationTab = uitab(app.TabGroup);
            app.MissionconfigurationTab.Title = 'Mission configuration';
            app.MissionconfigurationTab.ForegroundColor = [0.1216 0.149 0.4588];

            % Create MissionparametersLabel
            app.MissionparametersLabel = uilabel(app.MissionconfigurationTab);
            app.MissionparametersLabel.FontName = 'Arial Unicode MS';
            app.MissionparametersLabel.FontSize = 14;
            app.MissionparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.MissionparametersLabel.Position = [23 328 127 22];
            app.MissionparametersLabel.Text = 'Mission parameters';

            % Create ExperimentreceiverparametersLabel
            app.ExperimentreceiverparametersLabel = uilabel(app.MissionconfigurationTab);
            app.ExperimentreceiverparametersLabel.FontName = 'Arial Unicode MS';
            app.ExperimentreceiverparametersLabel.FontSize = 14;
            app.ExperimentreceiverparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.ExperimentreceiverparametersLabel.Position = [426 328 205 22];
            app.ExperimentreceiverparametersLabel.Text = 'Experiment receiver parameters';

            % Create OrbitalplatformdataLabel
            app.OrbitalplatformdataLabel = uilabel(app.MissionconfigurationTab);
            app.OrbitalplatformdataLabel.FontName = 'Arial Unicode MS';
            app.OrbitalplatformdataLabel.FontSize = 14;
            app.OrbitalplatformdataLabel.FontColor = [0.1216 0.1451 0.4627];
            app.OrbitalplatformdataLabel.Position = [23 224 132 22];
            app.OrbitalplatformdataLabel.Text = 'Orbital platform data';

            % Create GroundsegmentdataLabel
            app.GroundsegmentdataLabel = uilabel(app.MissionconfigurationTab);
            app.GroundsegmentdataLabel.FontName = 'Arial Unicode MS';
            app.GroundsegmentdataLabel.FontSize = 14;
            app.GroundsegmentdataLabel.FontColor = [0.1216 0.1451 0.4627];
            app.GroundsegmentdataLabel.Position = [23 128 140 22];
            app.GroundsegmentdataLabel.Text = 'Ground segment data';

            % Create SelecttlefileButton
            app.SelecttlefileButton = uibutton(app.MissionconfigurationTab, 'push');
            app.SelecttlefileButton.ButtonPushedFcn = createCallbackFcn(app, @SelecttlefileButtonPushed, true);
            app.SelecttlefileButton.Position = [25 191 100 23];
            app.SelecttlefileButton.Text = 'Select .tle file';

            % Create tleInfo
            app.tleInfo = uieditfield(app.MissionconfigurationTab, 'text');
            app.tleInfo.FontName = 'Arial Unicode MS';
            app.tleInfo.BackgroundColor = [0.9412 0.9412 0.9412];
            app.tleInfo.Enable = 'off';
            app.tleInfo.Position = [25 156 100 22];

            % Create SelectxlsxfileButton
            app.SelectxlsxfileButton = uibutton(app.MissionconfigurationTab, 'push');
            app.SelectxlsxfileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectxlsxfileButtonPushed, true);
            app.SelectxlsxfileButton.Position = [27 95 100 23];
            app.SelectxlsxfileButton.Text = 'Select .xlsx file';

            % Create gsInfo
            app.gsInfo = uieditfield(app.MissionconfigurationTab, 'text');
            app.gsInfo.FontName = 'Arial Unicode MS';
            app.gsInfo.BackgroundColor = [0.9412 0.9412 0.9412];
            app.gsInfo.Enable = 'off';
            app.gsInfo.Position = [27 60 100 22];

            % Create RunSimulationButton
            app.RunSimulationButton = uibutton(app.MissionconfigurationTab, 'push');
            app.RunSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunSimulationButtonPushed, true);
            app.RunSimulationButton.FontWeight = 'bold';
            app.RunSimulationButton.FontColor = [0.1216 0.1451 0.4627];
            app.RunSimulationButton.Visible = 'off';
            app.RunSimulationButton.Position = [240 44 124 24];
            app.RunSimulationButton.Text = 'Run Simulation';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.MissionconfigurationTab);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.ButtonDownFcn = createCallbackFcn(app, @ButtonGroupButtonDown, true);
            app.ButtonGroup.Position = [198 120 156 55];

            % Create CommsUpLinkButton
            app.CommsUpLinkButton = uiradiobutton(app.ButtonGroup);
            app.CommsUpLinkButton.Text = 'Comms UpLink';
            app.CommsUpLinkButton.Position = [11 29 104 22];
            app.CommsUpLinkButton.Value = true;

            % Create CommsDownLinkButton
            app.CommsDownLinkButton = uiradiobutton(app.ButtonGroup);
            app.CommsDownLinkButton.Text = 'Comms DownLink';
            app.CommsDownLinkButton.Position = [11 7 119 22];

            % Create NameEditFieldLabel
            app.NameEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.NameEditFieldLabel.HorizontalAlignment = 'right';
            app.NameEditFieldLabel.Position = [462 299 37 22];
            app.NameEditFieldLabel.Text = 'Name';

            % Create satNameTxRx
            app.satNameTxRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satNameTxRx.HorizontalAlignment = 'right';
            app.satNameTxRx.Position = [514 299 100 22];
            app.satNameTxRx.Value = 'experiment';

            % Create MountingLocationmLabel
            app.MountingLocationmLabel = uilabel(app.MissionconfigurationTab);
            app.MountingLocationmLabel.HorizontalAlignment = 'right';
            app.MountingLocationmLabel.Position = [369 273 130 22];
            app.MountingLocationmLabel.Text = 'Mounting Location (m)';

            % Create satMountingLocationTxRx
            app.satMountingLocationTxRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satMountingLocationTxRx.HorizontalAlignment = 'right';
            app.satMountingLocationTxRx.Position = [514 273 100 22];
            app.satMountingLocationTxRx.Value = '[0;0;0]';

            % Create satFrequencyTx
            app.satFrequencyTx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satFrequencyTx.HorizontalAlignment = 'right';
            app.satFrequencyTx.Visible = 'off';
            app.satFrequencyTx.Position = [516 116 99 22];
            app.satFrequencyTx.Value = '2e9';

            % Create FrequencyHzLabel
            app.FrequencyHzLabel = uilabel(app.MissionconfigurationTab);
            app.FrequencyHzLabel.HorizontalAlignment = 'right';
            app.FrequencyHzLabel.Visible = 'off';
            app.FrequencyHzLabel.Position = [412 116 87 22];
            app.FrequencyHzLabel.Text = 'Frequency (Hz)';

            % Create BitRateMbpsLabel
            app.BitRateMbpsLabel = uilabel(app.MissionconfigurationTab);
            app.BitRateMbpsLabel.HorizontalAlignment = 'right';
            app.BitRateMbpsLabel.Visible = 'off';
            app.BitRateMbpsLabel.Position = [397 181 99 22];
            app.BitRateMbpsLabel.Text = 'Bit Rate (Mbps)';

            % Create satBitRateTx
            app.satBitRateTx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satBitRateTx.HorizontalAlignment = 'right';
            app.satBitRateTx.Visible = 'off';
            app.satBitRateTx.Position = [514 181 99 22];
            app.satBitRateTx.Value = '1';

            % Create PowerdBWLabel
            app.PowerdBWLabel = uilabel(app.MissionconfigurationTab);
            app.PowerdBWLabel.HorizontalAlignment = 'right';
            app.PowerdBWLabel.Visible = 'off';
            app.PowerdBWLabel.Position = [423 149 76 22];
            app.PowerdBWLabel.Text = 'Power (dBW)';

            % Create satPowerTx
            app.satPowerTx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satPowerTx.HorizontalAlignment = 'right';
            app.satPowerTx.Visible = 'off';
            app.satPowerTx.Position = [514 149 100 22];
            app.satPowerTx.Value = '8';

            % Create MountingAnglesmLabel
            app.MountingAnglesmLabel = uilabel(app.MissionconfigurationTab);
            app.MountingAnglesmLabel.HorizontalAlignment = 'right';
            app.MountingAnglesmLabel.Position = [382 245 117 22];
            app.MountingAnglesmLabel.Text = 'Mounting Angles (º)';

            % Create satMountingAnglesTxRx
            app.satMountingAnglesTxRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.satMountingAnglesTxRx.HorizontalAlignment = 'right';
            app.satMountingAnglesTxRx.Position = [514 245 100 22];
            app.satMountingAnglesTxRx.Value = '[0;0;0]';

            % Create AntennaDropDownLabel
            app.AntennaDropDownLabel = uilabel(app.MissionconfigurationTab);
            app.AntennaDropDownLabel.HorizontalAlignment = 'right';
            app.AntennaDropDownLabel.Position = [442 87 55 22];
            app.AntennaDropDownLabel.Text = 'Antenna';

            % Create satAntenna
            app.satAntenna = uidropdown(app.MissionconfigurationTab);
            app.satAntenna.Items = {'Gaussian Antenna'};
            app.satAntenna.Position = [515 87 99 22];
            app.satAntenna.Value = 'Gaussian Antenna';

            % Create SystemLossdBEditFieldLabel
            app.SystemLossdBEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.SystemLossdBEditFieldLabel.HorizontalAlignment = 'right';
            app.SystemLossdBEditFieldLabel.Position = [398 211 103 22];
            app.SystemLossdBEditFieldLabel.Text = 'System Loss (dB)';

            % Create SystemLoss
            app.SystemLoss = uieditfield(app.MissionconfigurationTab, 'text');
            app.SystemLoss.HorizontalAlignment = 'right';
            app.SystemLoss.Position = [514 213 100 22];
            app.SystemLoss.Value = '3';

            % Create PreReceiverLossdBEditFieldLabel
            app.PreReceiverLossdBEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.PreReceiverLossdBEditFieldLabel.HorizontalAlignment = 'right';
            app.PreReceiverLossdBEditFieldLabel.Position = [369 181 130 22];
            app.PreReceiverLossdBEditFieldLabel.Text = 'PreReceiver Loss (dB)';

            % Create PreReceiverLossRx
            app.PreReceiverLossRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.PreReceiverLossRx.HorizontalAlignment = 'right';
            app.PreReceiverLossRx.Position = [514 181 100 22];
            app.PreReceiverLossRx.Value = '2';

            % Create GaintoNoiseTemperatureratiodBKLabel
            app.GaintoNoiseTemperatureratiodBKLabel = uilabel(app.MissionconfigurationTab);
            app.GaintoNoiseTemperatureratiodBKLabel.HorizontalAlignment = 'right';
            app.GaintoNoiseTemperatureratiodBKLabel.Position = [366 141 133 30];
            app.GaintoNoiseTemperatureratiodBKLabel.Text = {'Gain to Noise '; 'Temperature ratio (dB/K)'};

            % Create GaintoNoiseTemperatureratioRx
            app.GaintoNoiseTemperatureratioRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.GaintoNoiseTemperatureratioRx.HorizontalAlignment = 'right';
            app.GaintoNoiseTemperatureratioRx.Position = [514 149 100 22];
            app.GaintoNoiseTemperatureratioRx.Value = '3';

            % Create RequiredEbNodBLabel
            app.RequiredEbNodBLabel = uilabel(app.MissionconfigurationTab);
            app.RequiredEbNodBLabel.HorizontalAlignment = 'right';
            app.RequiredEbNodBLabel.Position = [370 117 130 22];
            app.RequiredEbNodBLabel.Text = 'Required Eb/No (dB)';

            % Create RequiredEbNoRx
            app.RequiredEbNoRx = uieditfield(app.MissionconfigurationTab, 'text');
            app.RequiredEbNoRx.HorizontalAlignment = 'right';
            app.RequiredEbNoRx.Position = [515 117 100 22];
            app.RequiredEbNoRx.Value = '10';

            % Create DateDatePickerLabel
            app.DateDatePickerLabel = uilabel(app.MissionconfigurationTab);
            app.DateDatePickerLabel.HorizontalAlignment = 'right';
            app.DateDatePickerLabel.Position = [23 295 31 22];
            app.DateDatePickerLabel.Text = 'Date';

            % Create DateDatePicker
            app.DateDatePicker = uidatepicker(app.MissionconfigurationTab);
            app.DateDatePicker.Position = [69 295 97 22];
            app.DateDatePicker.Value = datetime([2025 5 5]);

            % Create HourEditFieldLabel
            app.HourEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.HourEditFieldLabel.HorizontalAlignment = 'right';
            app.HourEditFieldLabel.Position = [23 259 31 22];
            app.HourEditFieldLabel.Text = 'Hour';

            % Create HourEditField
            app.HourEditField = uieditfield(app.MissionconfigurationTab, 'text');
            app.HourEditField.HorizontalAlignment = 'right';
            app.HourEditField.Position = [69 259 97 22];
            app.HourEditField.Value = '07:00:00';

            % Create BeamApertureLabel
            app.BeamApertureLabel = uilabel(app.MissionconfigurationTab);
            app.BeamApertureLabel.HorizontalAlignment = 'right';
            app.BeamApertureLabel.Position = [398 56 103 22];
            app.BeamApertureLabel.Text = 'Beam Aperture (º)';

            % Create BeamAperture
            app.BeamAperture = uieditfield(app.MissionconfigurationTab, 'text');
            app.BeamAperture.HorizontalAlignment = 'right';
            app.BeamAperture.Position = [515 56 99 22];
            app.BeamAperture.Value = '45';

            % Create T_onmsEditFieldLabel
            app.T_onmsEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.T_onmsEditFieldLabel.HorizontalAlignment = 'right';
            app.T_onmsEditFieldLabel.Position = [194 295 59 22];
            app.T_onmsEditFieldLabel.Text = 'T_on (ms)';

            % Create T_onmsEditField
            app.T_onmsEditField = uieditfield(app.MissionconfigurationTab, 'numeric');
            app.T_onmsEditField.Position = [273 295 81 22];
            app.T_onmsEditField.Value = 1500;

            % Create T_tctmmsLabel
            app.T_tctmmsLabel = uilabel(app.MissionconfigurationTab);
            app.T_tctmmsLabel.HorizontalAlignment = 'right';
            app.T_tctmmsLabel.Position = [194 230 71 22];
            app.T_tctmmsLabel.Text = '𝜏_tc/tm (ms)';

            % Create T_tcmsEditField
            app.T_tcmsEditField = uieditfield(app.MissionconfigurationTab, 'numeric');
            app.T_tcmsEditField.Position = [273 230 81 22];
            app.T_tcmsEditField.Value = 2;

            % Create T_offmsEditFieldLabel
            app.T_offmsEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.T_offmsEditFieldLabel.HorizontalAlignment = 'right';
            app.T_offmsEditFieldLabel.Position = [194 262 59 22];
            app.T_offmsEditFieldLabel.Text = 'T_off (ms)';

            % Create T_offmsEditField
            app.T_offmsEditField = uieditfield(app.MissionconfigurationTab, 'numeric');
            app.T_offmsEditField.Position = [273 262 81 22];
            app.T_offmsEditField.Value = 1000;

            % Create T_idleminEditFieldLabel
            app.T_idleminEditFieldLabel = uilabel(app.MissionconfigurationTab);
            app.T_idleminEditFieldLabel.HorizontalAlignment = 'right';
            app.T_idleminEditFieldLabel.Position = [194 198 68 22];
            app.T_idleminEditFieldLabel.Text = 'T_idle (min)';

            % Create T_idleminEditField
            app.T_idleminEditField = uieditfield(app.MissionconfigurationTab, 'numeric');
            app.T_idleminEditField.Position = [273 198 81 22];
            app.T_idleminEditField.Value = 20;

            % Create ExperimenttransmitterparametersLabel
            app.ExperimenttransmitterparametersLabel = uilabel(app.MissionconfigurationTab);
            app.ExperimenttransmitterparametersLabel.FontName = 'Arial Unicode MS';
            app.ExperimenttransmitterparametersLabel.FontSize = 14;
            app.ExperimenttransmitterparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.ExperimenttransmitterparametersLabel.Visible = 'off';
            app.ExperimenttransmitterparametersLabel.Position = [426 328 201 22];
            app.ExperimenttransmitterparametersLabel.Text = 'Experiment transmitter parameters';

            % Create OnboardexperimentparametersLabel
            app.OnboardexperimentparametersLabel = uilabel(app.MissionconfigurationTab);
            app.OnboardexperimentparametersLabel.FontName = 'Arial Unicode MS';
            app.OnboardexperimentparametersLabel.FontSize = 14;
            app.OnboardexperimentparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.OnboardexperimentparametersLabel.Position = [194 328 213 22];
            app.OnboardexperimentparametersLabel.Text = 'On-board experiment parameters';

            % Create TextArea
            app.TextArea = uitextarea(app.MissionconfigurationTab);
            app.TextArea.Editable = 'off';
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TextArea.Visible = 'off';
            app.TextArea.Position = [194 9 214 25];

            % Create SimulationconfigurationTab
            app.SimulationconfigurationTab = uitab(app.TabGroup);
            app.SimulationconfigurationTab.Title = 'Simulation configuration';
            app.SimulationconfigurationTab.ForegroundColor = [0.1216 0.149 0.4588];

            % Create SimulationrepresentationButtonGroup
            app.SimulationrepresentationButtonGroup = uibuttongroup(app.SimulationconfigurationTab);
            app.SimulationrepresentationButtonGroup.ForegroundColor = [0.1216 0.1451 0.4627];
            app.SimulationrepresentationButtonGroup.BorderType = 'none';
            app.SimulationrepresentationButtonGroup.Title = 'Simulation representation';
            app.SimulationrepresentationButtonGroup.FontName = 'Arial Unicode MS';
            app.SimulationrepresentationButtonGroup.FontSize = 14;
            app.SimulationrepresentationButtonGroup.Position = [29 114 175 106];

            % Create Button_3D
            app.Button_3D = uitogglebutton(app.SimulationrepresentationButtonGroup);
            app.Button_3D.Text = '3D';
            app.Button_3D.Position = [10 51 100 23];
            app.Button_3D.Value = true;

            % Create Button_2D
            app.Button_2D = uitogglebutton(app.SimulationrepresentationButtonGroup);
            app.Button_2D.Text = '2D';
            app.Button_2D.Position = [11 23 100 23];

            % Create ShowgroundtrackCheckBox
            app.ShowgroundtrackCheckBox = uicheckbox(app.SimulationconfigurationTab);
            app.ShowgroundtrackCheckBox.Text = 'Show ground track';
            app.ShowgroundtrackCheckBox.Position = [329 291 122 22];
            app.ShowgroundtrackCheckBox.Value = true;

            % Create SimulationparametersLabel
            app.SimulationparametersLabel = uilabel(app.SimulationconfigurationTab);
            app.SimulationparametersLabel.FontName = 'Arial Unicode MS';
            app.SimulationparametersLabel.FontSize = 14;
            app.SimulationparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.SimulationparametersLabel.Position = [23 320 145 22];
            app.SimulationparametersLabel.Text = 'Simulation parameters';

            % Create OtherparametersLabel
            app.OtherparametersLabel = uilabel(app.SimulationconfigurationTab);
            app.OtherparametersLabel.FontName = 'Arial Unicode MS';
            app.OtherparametersLabel.FontSize = 14;
            app.OtherparametersLabel.FontColor = [0.1216 0.1451 0.4627];
            app.OtherparametersLabel.Position = [328 320 115 22];
            app.OtherparametersLabel.Text = 'Other parameters';

            % Create FocusscenarycamerainorbitalplatformCheckBox
            app.FocusscenarycamerainorbitalplatformCheckBox = uicheckbox(app.SimulationconfigurationTab);
            app.FocusscenarycamerainorbitalplatformCheckBox.Text = 'Focus scenary camera in orbital platform';
            app.FocusscenarycamerainorbitalplatformCheckBox.Position = [329 264 241 22];

            % Create ShowantennaradiationpatternsCheckBox
            app.ShowantennaradiationpatternsCheckBox = uicheckbox(app.SimulationconfigurationTab);
            app.ShowantennaradiationpatternsCheckBox.Text = 'Show antenna radiation patterns';
            app.ShowantennaradiationpatternsCheckBox.Position = [328 237 196 22];

            % Create SampletimesEditFieldLabel
            app.SampletimesEditFieldLabel = uilabel(app.SimulationconfigurationTab);
            app.SampletimesEditFieldLabel.HorizontalAlignment = 'right';
            app.SampletimesEditFieldLabel.Position = [29 265 109 22];
            app.SampletimesEditFieldLabel.Text = 'Sample time (s)';

            % Create SampletimesEditField
            app.SampletimesEditField = uieditfield(app.SimulationconfigurationTab, 'text');
            app.SampletimesEditField.HorizontalAlignment = 'right';
            app.SampletimesEditField.Position = [157 265 89 22];
            app.SampletimesEditField.Value = '30';

            % Create ScenaryDurationhEditFieldLabel
            app.ScenaryDurationhEditFieldLabel = uilabel(app.SimulationconfigurationTab);
            app.ScenaryDurationhEditFieldLabel.HorizontalAlignment = 'right';
            app.ScenaryDurationhEditFieldLabel.Position = [22 295 115 22];
            app.ScenaryDurationhEditFieldLabel.Text = 'Scenary Duration (h)';

            % Create ScenaryDurationhEditField
            app.ScenaryDurationhEditField = uieditfield(app.SimulationconfigurationTab, 'text');
            app.ScenaryDurationhEditField.HorizontalAlignment = 'right';
            app.ScenaryDurationhEditField.Position = [157 295 89 22];
            app.ScenaryDurationhEditField.Value = '72';

            % Create ResultsTab
            app.ResultsTab = uitab(app.TabGroup);
            app.ResultsTab.Title = 'Results';
            app.ResultsTab.ForegroundColor = [0.1216 0.1451 0.4627];

            % Create UITable
            app.UITable = uitable(app.ResultsTab);
            app.UITable.ColumnName = {'asd'; 'asd'; 'asd'; 'asd'};
            app.UITable.RowName = {};
            app.UITable.Visible = 'off';
            app.UITable.Position = [13 9 617 324];

            % Create ExporttoxlsxfileButton
            app.ExporttoxlsxfileButton = uibutton(app.ResultsTab, 'push');
            app.ExporttoxlsxfileButton.ButtonPushedFcn = createCallbackFcn(app, @ExporttoxlsxfileButtonPushed, true);
            app.ExporttoxlsxfileButton.Visible = 'off';
            app.ExporttoxlsxfileButton.Position = [12 340 109 23];
            app.ExporttoxlsxfileButton.Text = 'Export to .xlsx file';

            % Create ExporttocsvfileButton
            app.ExporttocsvfileButton = uibutton(app.ResultsTab, 'push');
            app.ExporttocsvfileButton.ButtonPushedFcn = createCallbackFcn(app, @ExporttocsvfileButtonPushed, true);
            app.ExporttocsvfileButton.Visible = 'off';
            app.ExporttocsvfileButton.Position = [130 340 107 23];
            app.ExporttocsvfileButton.Text = 'Export to .csv file';

            % Create GeneratemissionplanButton
            app.GeneratemissionplanButton = uibutton(app.ResultsTab, 'push');
            app.GeneratemissionplanButton.ButtonPushedFcn = createCallbackFcn(app, @GeneratemissionplanButtonPushed, true);
            app.GeneratemissionplanButton.FontColor = [0.1216 0.1451 0.4627];
            app.GeneratemissionplanButton.Visible = 'off';
            app.GeneratemissionplanButton.Position = [492 340 135 23];
            app.GeneratemissionplanButton.Text = 'Generate mission plan';

            % Create InformationTab
            app.InformationTab = uitab(app.TabGroup);
            app.InformationTab.Title = 'Information';
            app.InformationTab.ForegroundColor = [0.1216 0.1451 0.4627];

            % Create AuthorCsarBoraoMoratinosLabel
            app.AuthorCsarBoraoMoratinosLabel = uilabel(app.InformationTab);
            app.AuthorCsarBoraoMoratinosLabel.Position = [28 291 171 22];
            app.AuthorCsarBoraoMoratinosLabel.Text = 'Author: César Borao Moratinos';

            % Create DegreeAerospaceEngineeringinNavigationLabel
            app.DegreeAerospaceEngineeringinNavigationLabel = uilabel(app.InformationTab);
            app.DegreeAerospaceEngineeringinNavigationLabel.Position = [28 259 250 22];
            app.DegreeAerospaceEngineeringinNavigationLabel.Text = 'Degree: Aerospace Engineering in Navigation';

            % Create SoftwareVersionv12Label
            app.SoftwareVersionv12Label = uilabel(app.InformationTab);
            app.SoftwareVersionv12Label.Position = [30 156 125 22];
            app.SoftwareVersionv12Label.Text = 'Software Version: v1.2';

            % Create UniversityReyJuanCarlosUniversityLabel
            app.UniversityReyJuanCarlosUniversityLabel = uilabel(app.InformationTab);
            app.UniversityReyJuanCarlosUniversityLabel.Position = [30 224 210 22];
            app.UniversityReyJuanCarlosUniversityLabel.Text = 'University: Rey Juan Carlos University';

            % Create CompanyThalesAleniaSpaceSpainLabel
            app.CompanyThalesAleniaSpaceSpainLabel = uilabel(app.InformationTab);
            app.CompanyThalesAleniaSpaceSpainLabel.Position = [29 191 208 22];
            app.CompanyThalesAleniaSpaceSpainLabel.Text = 'Company: Thales Alenia Space Spain';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = experiment_mission_planner

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end