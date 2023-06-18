classdef PatientGUI < matlab.apps.AppBase & handle
    % Properties that correspond to app components
    properties (Access = public)
        uifig                    matlab.ui.Figure
        main_panel               matlab.ui.container.Panel
        results_panel            matlab.ui.container.Panel
        result_2                 matlab.ui.control.Label
        result_1                 matlab.ui.control.Label
        calculate_strain_btn     matlab.ui.control.Button
        region16_dd              matlab.ui.control.DropDown
        apicallateralLabel       matlab.ui.control.Label
        region15_dd              matlab.ui.control.DropDown
        apicalinferiorLabel      matlab.ui.control.Label
        region14_dd              matlab.ui.control.DropDown
        apicalseptalLabel        matlab.ui.control.Label
        region13_dd              matlab.ui.control.DropDown
        apicalanteriorLabel      matlab.ui.control.Label
        region12_dd              matlab.ui.control.DropDown
        midanterolateralLabel    matlab.ui.control.Label
        region11_dd              matlab.ui.control.DropDown
        midinferolateralLabel_2  matlab.ui.control.Label
        region10_dd              matlab.ui.control.DropDown
        midinferiorLabel         matlab.ui.control.Label
        region9_dd               matlab.ui.control.DropDown
        midLabel                 matlab.ui.control.Label
        region8_dd               matlab.ui.control.DropDown
        midinferolateralLabel    matlab.ui.control.Label
        region7_dd               matlab.ui.control.DropDown
        midanteroseptalLabel     matlab.ui.control.Label
        region6_dd               matlab.ui.control.DropDown
        midanteriorLabel         matlab.ui.control.Label
        region5_dd               matlab.ui.control.DropDown
        basalanterolateralLabel  matlab.ui.control.Label
        region4_dd               matlab.ui.control.DropDown
        basalinferiorLabel       matlab.ui.control.Label
        region3_dd               matlab.ui.control.DropDown
        basalinferoseptalLabel   matlab.ui.control.Label
        region2_dd               matlab.ui.control.DropDown
        basalanteroseptalLabel   matlab.ui.control.Label
        region1_dd               matlab.ui.control.DropDown
        BasalAnteriorLabel       matlab.ui.control.Label
        refresh_btn              matlab.ui.control.Button
        create_view_panel        matlab.ui.container.Panel
        view_name                matlab.ui.control.EditField
        viewnameEditFieldLabel   matlab.ui.control.Label
        create_view_btn          matlab.ui.control.Button
        y_scale                  matlab.ui.control.EditField
        yscaleEditFieldLabel     matlab.ui.control.Label
        file_name                matlab.ui.control.Label
        x_scale                  matlab.ui.control.EditField
        xscaleEditFieldLabel     matlab.ui.control.Label
        file_select              matlab.ui.control.Button
        patient_name             matlab.ui.control.Label
        log_text                 matlab.ui.control.Label

        patient_global_name
        views
        regions
        region_scales
        region_names

        bullseye_fig
        strain_fig

        file_path

        max_strain_data
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create uifig and hide until all components are created
            app.uifig = uifigure('Visible', 'off');
            app.uifig.Color = [1 1 1];
            app.uifig.Position = [100 100 637 748];
            app.uifig.Name = 'MATLAB App';

            % Create patient_name
            app.patient_name = uilabel(app.uifig);
            app.patient_name.Position = [14 718 568 22];
            app.patient_name.Text =  app.patient_global_name;

            % Create create_view_panel
            app.create_view_panel = uipanel(app.uifig);
            app.create_view_panel.Title = 'Create view';
            app.create_view_panel.BackgroundColor = [0.8 0.9098 1];
            app.create_view_panel.Position = [14 489 609 215];

            % Create file_select
            app.file_select = uibutton(app.create_view_panel, 'push');
            app.file_select.BackgroundColor = [1 1 1];
            app.file_select.Position = [19 148 221 36];
            app.file_select.Text = 'File Select';
            app.file_select.ButtonPushedFcn = createCallbackFcn(app,@file_select_btn_pushed,true);

            % Create xscaleEditFieldLabel
            app.xscaleEditFieldLabel = uilabel(app.create_view_panel);
            app.xscaleEditFieldLabel.HorizontalAlignment = 'right';
            app.xscaleEditFieldLabel.Position = [4 114 70 22];
            app.xscaleEditFieldLabel.Text = 'x-scale [cm]';
            % Create x_scale
            app.x_scale = uieditfield(app.create_view_panel, 'text');
            app.x_scale.Position = [89 114 100 22];

            % Create file_name
            app.file_name = uilabel(app.create_view_panel);
            app.file_name.Position = [255 155 333 22];
            app.file_name.Text = '';

            % Create yscaleEditFieldLabel
            app.yscaleEditFieldLabel = uilabel(app.create_view_panel);
            app.yscaleEditFieldLabel.HorizontalAlignment = 'right';
            app.yscaleEditFieldLabel.Position = [223 114 70 22];
            app.yscaleEditFieldLabel.Text = 'y-scale [cm]';
            % Create y_scale
            app.y_scale = uieditfield(app.create_view_panel, 'text');
            app.y_scale.Position = [308 114 100 22];

            % Create viewnameEditFieldLabel
            app.viewnameEditFieldLabel = uilabel(app.create_view_panel);
            app.viewnameEditFieldLabel.HorizontalAlignment = 'right';
            app.viewnameEditFieldLabel.Position = [12 79 62 22];
            app.viewnameEditFieldLabel.Text = 'view name';
            % Create view_name
            app.view_name = uieditfield(app.create_view_panel, 'text');
            app.view_name.Position = [89 79 499 22];

            % Create create_view_btn
            app.create_view_btn = uibutton(app.create_view_panel, 'push');
            app.create_view_btn.BackgroundColor = [1 1 1];
            app.create_view_btn.Position = [19 11 569 52];
            app.create_view_btn.Text = 'Create View';
            app.create_view_btn.ButtonPushedFcn = createCallbackFcn(app,@create_view_btn_pushed,true);     

            % Create main_panel
            app.main_panel = uipanel(app.uifig);
            app.main_panel.Title = 'Panel';
            app.main_panel.BackgroundColor = [0.8 0.9098 1];
            app.main_panel.Position = [14 13 609 462];

            % Create refresh_btn
            app.refresh_btn = uibutton(app.main_panel, 'push');
            app.refresh_btn.BackgroundColor = [1 1 1];
            app.refresh_btn.Position = [19 365 569 63];
            app.refresh_btn.Text = 'Refresh options (push before adjusting below options)';
            app.refresh_btn.ButtonPushedFcn = createCallbackFcn(app,@refresh_btn_pushed,true);

            % Create BasalAnteriorLabel
            app.BasalAnteriorLabel = uilabel(app.main_panel);
            app.BasalAnteriorLabel.HorizontalAlignment = 'right';
            app.BasalAnteriorLabel.Position = [34 330 78 22];
            app.BasalAnteriorLabel.Text = 'basal anterior';

            % Create region1_dd
            app.region1_dd = uidropdown(app.main_panel);
            app.region1_dd.Items = {};
            app.region1_dd.BackgroundColor = [1 1 1];
            app.region1_dd.Position = [127 330 100 22];
            app.region1_dd.Value = {};

            % Create basalanteroseptalLabel
            app.basalanteroseptalLabel = uilabel(app.main_panel);
            app.basalanteroseptalLabel.HorizontalAlignment = 'right';
            app.basalanteroseptalLabel.Position = [9 303 103 22];
            app.basalanteroseptalLabel.Text = 'basal anteroseptal';

            % Create region2_dd
            app.region2_dd = uidropdown(app.main_panel);
            app.region2_dd.Items = {};
            app.region2_dd.BackgroundColor = [1 1 1];
            app.region2_dd.Position = [127 303 100 22];
            app.region2_dd.Value = {};

            % Create basalinferoseptalLabel
            app.basalinferoseptalLabel = uilabel(app.main_panel);
            app.basalinferoseptalLabel.HorizontalAlignment = 'right';
            app.basalinferoseptalLabel.Position = [13 276 99 22];
            app.basalinferoseptalLabel.Text = 'basal inferoseptal';

            % Create region3_dd
            app.region3_dd = uidropdown(app.main_panel);
            app.region3_dd.Items = {};
            app.region3_dd.BackgroundColor = [1 1 1];
            app.region3_dd.Position = [127 276 100 22];
            app.region3_dd.Value = {};

            % Create basalinferiorLabel
            app.basalinferiorLabel = uilabel(app.main_panel);
            app.basalinferiorLabel.HorizontalAlignment = 'right';
            app.basalinferiorLabel.Position = [38 249 74 22];
            app.basalinferiorLabel.Text = 'basal inferior';

            % Create region4_dd
            app.region4_dd = uidropdown(app.main_panel);
            app.region4_dd.Items = {};
            app.region4_dd.BackgroundColor = [1 1 1];
            app.region4_dd.Position = [127 249 100 22];
            app.region4_dd.Value = {};

            % Create basalanterolateralLabel
            app.basalanterolateralLabel = uilabel(app.main_panel);
            app.basalanterolateralLabel.HorizontalAlignment = 'right';
            app.basalanterolateralLabel.Position = [13 222 99 22];
            app.basalanterolateralLabel.Text = 'basal inferolateral';

            % Create region5_dd
            app.region5_dd = uidropdown(app.main_panel);
            app.region5_dd.Items = {};
            app.region5_dd.BackgroundColor = [1 1 1];
            app.region5_dd.Position = [127 222 100 22];
            app.region5_dd.Value = {};

            % Create midanteriorLabel
            app.midanteriorLabel = uilabel(app.main_panel);
            app.midanteriorLabel.HorizontalAlignment = 'right';
            app.midanteriorLabel.Position = [9 195 103 22];
            app.midanteriorLabel.Text = 'basal anterolateral';

            % Create region6_dd
            app.region6_dd = uidropdown(app.main_panel);
            app.region6_dd.Items = {};
            app.region6_dd.BackgroundColor = [1 1 1];
            app.region6_dd.Position = [127 195 100 22];
            app.region6_dd.Value = {};

            % Create midanteroseptalLabel
            app.midanteroseptalLabel = uilabel(app.main_panel);
            app.midanteroseptalLabel.HorizontalAlignment = 'right';
            app.midanteroseptalLabel.Position = [384 330 69 22];
            app.midanteroseptalLabel.Text = 'mid anterior';

            % Create region7_dd
            app.region7_dd = uidropdown(app.main_panel);
            app.region7_dd.Items = {};
            app.region7_dd.BackgroundColor = [1 1 1];
            app.region7_dd.Position = [468 330 100 22];
            app.region7_dd.Value = {};

            % Create midinferolateralLabel
            app.midinferolateralLabel = uilabel(app.main_panel);
            app.midinferolateralLabel.HorizontalAlignment = 'right';
            app.midinferolateralLabel.Position = [358 303 95 22];
            app.midinferolateralLabel.Text = 'mid anteroseptal';

            % Create region8_dd
            app.region8_dd = uidropdown(app.main_panel);
            app.region8_dd.Items = {};
            app.region8_dd.BackgroundColor = [1 1 1];
            app.region8_dd.Position = [468 303 100 22];
            app.region8_dd.Value = {};

            % Create midLabel
            app.midLabel = uilabel(app.main_panel);
            app.midLabel.HorizontalAlignment = 'right';
            app.midLabel.Position = [362 276 91 22];
            app.midLabel.Text = 'mid inferoseptal';

            % Create region9_dd
            app.region9_dd = uidropdown(app.main_panel);
            app.region9_dd.Items = {};
            app.region9_dd.BackgroundColor = [1 1 1];
            app.region9_dd.Position = [468 276 100 22];
            app.region9_dd.Value = {};

            % Create midinferiorLabel
            app.midinferiorLabel = uilabel(app.main_panel);
            app.midinferiorLabel.HorizontalAlignment = 'right';
            app.midinferiorLabel.Position = [388 249 65 22];
            app.midinferiorLabel.Text = 'mid inferior';

            % Create region10_dd
            app.region10_dd = uidropdown(app.main_panel);
            app.region10_dd.Items = {};
            app.region10_dd.BackgroundColor = [1 1 1];
            app.region10_dd.Position = [468 249 100 22];
            app.region10_dd.Value = {};

            % Create midinferolateralLabel_2
            app.midinferolateralLabel_2 = uilabel(app.main_panel);
            app.midinferolateralLabel_2.HorizontalAlignment = 'right';
            app.midinferolateralLabel_2.Position = [362 222 91 22];
            app.midinferolateralLabel_2.Text = 'mid inferolateral';

            % Create region11_dd
            app.region11_dd = uidropdown(app.main_panel);
            app.region11_dd.Items = {};
            app.region11_dd.BackgroundColor = [1 1 1];
            app.region11_dd.Position = [468 222 100 22];
            app.region11_dd.Value = {};

            % Create midanterolateralLabel
            app.midanterolateralLabel = uilabel(app.main_panel);
            app.midanterolateralLabel.HorizontalAlignment = 'right';
            app.midanterolateralLabel.Position = [358 195 95 22];
            app.midanterolateralLabel.Text = 'mid anterolateral';

            % Create region12_dd
            app.region12_dd = uidropdown(app.main_panel);
            app.region12_dd.Items = {};
            app.region12_dd.BackgroundColor = [1 1 1];
            app.region12_dd.Position = [468 195 100 22];
            app.region12_dd.Value = {};

            % Create apicalanteriorLabel
            app.apicalanteriorLabel = uilabel(app.main_panel);
            app.apicalanteriorLabel.HorizontalAlignment = 'right';
            app.apicalanteriorLabel.Position = [79 148 81 22];
            app.apicalanteriorLabel.Text = 'apical anterior';

            % Create region13_dd
            app.region13_dd = uidropdown(app.main_panel);
            app.region13_dd.Items = {};
            app.region13_dd.BackgroundColor = [1 1 1];
            app.region13_dd.Position = [175 148 100 22];
            app.region13_dd.Value = {};

            % Create apicalseptalLabel
            app.apicalseptalLabel = uilabel(app.main_panel);
            app.apicalseptalLabel.HorizontalAlignment = 'right';
            app.apicalseptalLabel.Position = [87 121 73 22];
            app.apicalseptalLabel.Text = 'apical septal';

            % Create region14_dd
            app.region14_dd = uidropdown(app.main_panel);
            app.region14_dd.Items = {};
            app.region14_dd.BackgroundColor = [1 1 1];
            app.region14_dd.Position = [175 121 100 22];
            app.region14_dd.Value = {};

            % Create apicalinferiorLabel
            app.apicalinferiorLabel = uilabel(app.main_panel);
            app.apicalinferiorLabel.HorizontalAlignment = 'right';
            app.apicalinferiorLabel.Position = [296 148 77 22];
            app.apicalinferiorLabel.Text = 'apical inferior';

            % Create region15_dd
            app.region15_dd = uidropdown(app.main_panel);
            app.region15_dd.Items = {};
            app.region15_dd.BackgroundColor = [1 1 1];
            app.region15_dd.Position = [388 148 100 22];
            app.region15_dd.Value = {};

            % Create apicallateralLabel
            app.apicallateralLabel = uilabel(app.main_panel);
            app.apicallateralLabel.HorizontalAlignment = 'right';
            app.apicallateralLabel.Position = [300 121 73 22];
            app.apicallateralLabel.Text = 'apical lateral';

            % Create region16_dd
            app.region16_dd = uidropdown(app.main_panel);
            app.region16_dd.Items = {};
            app.region16_dd.BackgroundColor = [1 1 1];
            app.region16_dd.Position = [388 121 100 22];
            app.region16_dd.Value = {};

            % Create calculate_strain_btn
            app.calculate_strain_btn = uibutton(app.main_panel, 'push');
            app.calculate_strain_btn.BackgroundColor = [1 1 1];
            app.calculate_strain_btn.Position = [13 10 273 89];
            app.calculate_strain_btn.Text = 'Calculate Strain';
            app.calculate_strain_btn.ButtonPushedFcn = createCallbackFcn(app,@calculate_strain_btn_pushed,true);

            % Create results_panel
            app.results_panel = uipanel(app.main_panel);
            app.results_panel.Title = 'Results (values)';
            app.results_panel.BackgroundColor = [1 1 1];
            app.results_panel.Position = [296 10 302 89];

            % Create result_1
            app.result_1 = uilabel(app.results_panel);
            app.result_1.Position = [4 42 288 22];
            app.result_1.Text = '';

            % Create result_2
            app.result_2 = uilabel(app.results_panel);
            app.result_2.Position = [4 8 288 22];
            app.result_2.Text = '';

            % Create log_text
            app.log_text = uilabel(app.uifig);
            app.log_text.Position = [286 718 333 22];
            app.log_text.Text = '';

            % Show the figure after all components are created
            app.uifig.Visible = 'on';
        end
    end

    %% App creation and deletion
    methods (Access = public)
        % Construct app
        function app = PatientGUI(name)
            if ~exist('name','var')
                app.patient_global_name = "unnamed patient";
            else
                app.patient_global_name = name;
            end
            % Create UIFigure and components
            createComponents(app);

            app.views = [];
            app.regions = [];
            app.region_scales = [];
            app.region_names = "";

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            for i = 1:length(app.views)
                delete(app.views(i));
            end
            % Delete UIFigure when app is deleted
            delete(app.uifig)
        end
    end
    
    %% Callback functions
    methods (Access = private)
        % Button pushed function: file_select_pushed
        function file_select_btn_pushed(app,event)
            [name,path] = uigetfile('*.dcm;*.dicom;*.nii;*.nii.gz');
            if isequal(name,0)
                app.file_name.Text = "User selected cancel";
                return;
            end
            [~,~,ext] = fileparts(name);
            % If valid file type, save filepath; else, cancel
            if (ext==".dcm" || ext==".dicom" || ext==".nii" || contains(name,".nii.gz"))
                app.file_path = string(path)+string(name);
                app.file_name.Text = string(name);
            else
                app.file_name.Text = "Invalid file type. Choose new file";
            end
        end

        % Button pushed function: create_view_btn
        function create_view_btn_pushed(app,event)
            % Check for empty filepath
            if isempty(app.file_path)
                app.log_text.Text = "LOG: no file selected, view creation canceled";
                return;
            end

            % Check for empty view name
            if isempty(app.view_name.Value)
                app.log_text.Text = "LOG: empty view name, view creation canceled";
                return;
            else
                name = app.view_name.Value;
            end

            % Check for empty scale
            if (isempty(app.x_scale.Value) || isempty(app.y_scale.Value))
                app.log_text.Text = "LOG: empty scale, view creation canceled";
                return;
            else
                scale = [double(string(app.x_scale.Value)) double(string(app.y_scale.Value))];
            end

            % If valid file type create, else cancel
            [~,~,ext] = fileparts(app.file_path);                    
            if (ext==".dcm" || ext==".dicom")
                info = dicominfo(app.file_path);
                temp_im_stack = dicomread(info);
                im_stack = [];
                for i = 1:size(temp_im_stack,4)
                    im_stack = cat(3,im_stack,rgb2gray(temp_im_stack(:,:,:,i)));
                end
                im_stack = double(im_stack);
            elseif (ext==".nii" || contains(app.file_path,".nii.gz"))
                im_stack = niftiread(app.file_path);
            else
                app.log_text.Text = "LOG: invalid file selected, view canceled";
                return;
            end

            new_view = SptrackGUI(name,im_stack,scale);
            app.views = cat(1,app.views,new_view);

            app.file_path = "";
            app.file_name.Text = "";
            app.view_name.Value = "";
        end

        % Button pushed function: refresh_btn_pushed
        function refresh_btn_pushed(app,event)
            app.regions = [];
            app.region_scales = [];
            app.region_names = [];
            
            % Obtain info from each controller, update all regions
            k = 1;
            for i = 1:length(app.views)
                % If view closed, continue
                if ~isgraphics(app.views(k).uifig)
                    app.views(k) = [];
                    continue;
                end
                % Get controller info for current view
                view_info = app.views(k).get_controller_info;
                for j = 1:length(view_info.regions)
                    % Add scale, region to arrays
                    app.regions = cat(1,app.regions,view_info.regions(j));
                    app.region_scales = cat(1,app.region_scales,view_info.scale);
                    app.region_names = cat(1,app.region_names,view_info.regions(j).get_name);
                end
                k = k+1;
            end

            % Set to empty string if no regions exist
            if isempty(app.region_names)
                app.region_names = "";
            end

            % Update all region dropdown menus
            app.region1_dd.Items = app.region_names;
            app.region1_dd.ItemsData = app.region_names;

            app.region2_dd.Items = app.region_names;
            app.region2_dd.ItemsData = app.region_names;

            app.region3_dd.Items = app.region_names;
            app.region3_dd.ItemsData = app.region_names;

            app.region4_dd.Items = app.region_names;
            app.region4_dd.ItemsData = app.region_names;

            app.region5_dd.Items = app.region_names;
            app.region5_dd.ItemsData = app.region_names;

            app.region6_dd.Items = app.region_names;
            app.region6_dd.ItemsData = app.region_names;

            app.region7_dd.Items = app.region_names;
            app.region7_dd.ItemsData = app.region_names;

            app.region8_dd.Items = app.region_names;
            app.region8_dd.ItemsData = app.region_names;

            app.region9_dd.Items = app.region_names;
            app.region9_dd.ItemsData = app.region_names;

            app.region10_dd.Items = app.region_names;
            app.region10_dd.ItemsData = app.region_names;

            app.region11_dd.Items = app.region_names;
            app.region11_dd.ItemsData = app.region_names;

            app.region12_dd.Items = app.region_names;
            app.region12_dd.ItemsData = app.region_names;

            app.region13_dd.Items = app.region_names;
            app.region13_dd.ItemsData = app.region_names;

            app.region14_dd.Items = app.region_names;
            app.region14_dd.ItemsData = app.region_names;

            app.region15_dd.Items = app.region_names;
            app.region15_dd.ItemsData = app.region_names;
            
            app.region16_dd.Items = app.region_names;
            app.region16_dd.ItemsData = app.region_names;
        end
        
        % Button pushed function: calculate_strain_btn_pushed
        function calculate_strain_btn_pushed(app,event)
            delete(app.bullseye_fig);
            delete(app.strain_fig);

            app.max_strain_data = zeros(1,16);
            for i = 1:length(app.regions)
                strain_info = app.regions(i).get_strain_info;
                switch app.regions(i).get_name
                    case app.region1_dd.Value
                        app.max_strain_data(12) = strain_info.max_strain;
                    case app.region2_dd.Value
                        app.max_strain_data(11) = strain_info.max_strain;
                    case app.region3_dd.Value
                        app.max_strain_data(16) = strain_info.max_strain;
                    case app.region4_dd.Value
                        app.max_strain_data(15) = strain_info.max_strain;
                    case app.region5_dd.Value
                        app.max_strain_data(14) = strain_info.max_strain;
                    case app.region6_dd.Value
                        app.max_strain_data(13) = strain_info.max_strain;
                    case app.region7_dd.Value
                        app.max_strain_data(6) = strain_info.max_strain;
                    case app.region8_dd.Value
                        app.max_strain_data(5) = strain_info.max_strain;
                    case app.region9_dd.Value
                        app.max_strain_data(10) = strain_info.max_strain;
                    case app.region10_dd.Value
                        app.max_strain_data(9) = strain_info.max_strain;
                    case app.region11_dd.Value
                        app.max_strain_data(8) = strain_info.max_strain;
                    case app.region12_dd.Value
                        app.max_strain_data(7) = strain_info.max_strain;
                    case app.region13_dd.Value
                        app.max_strain_data(1) = strain_info.max_strain;
                    case app.region14_dd.Value
                        app.max_strain_data(4) = strain_info.max_strain;
                    case app.region15_dd.Value
                        app.max_strain_data(3) = strain_info.max_strain;
                    case app.region16_dd.Value
                        app.max_strain_data(2) = strain_info.max_strain;
                end
            end
            app.bullseye_fig = bullseye_plot(app.max_strain_data,'aha',1,'labels',1);

            app.strain_fig = figure('Position',[232 328 1620 767]);
            max_strain_val = 0;
            min_strain_val = 0;
            for i = 1:length(app.regions)
                strain_info = app.regions(i).get_strain_info;
                if max(strain_info.strain > max_strain_val)
                    max_strain_val = max(strain_info.strain);
                end
                if min(strain_info.strain < min_strain_val)
                    min_strain_val = min(strain_info.strain);
                end

                switch app.regions(i).get_name
                    case app.region1_dd.Value
                        subplot(3,6,1);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal anterior strain");
                        hold off;
                    case app.region2_dd.Value
                        subplot(3,6,2);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal anteroseptal strain");
                        hold off;                        
                    case app.region3_dd.Value
                        subplot(3,6,3);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal inferoseptal strain");
                        hold off;
                    case app.region4_dd.Value
                        subplot(3,6,4);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal inferior strain");
                        hold off;  
                    case app.region5_dd.Value
                        subplot(3,6,5);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal inferolateral strain");
                        hold off;  
                    case app.region6_dd.Value
                        subplot(3,6,6);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("basal anterolateral strain");
                        hold off;  
                    case app.region7_dd.Value
                        subplot(3,6,7);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid anterior strain");
                        hold off;  
                    case app.region8_dd.Value
                        subplot(3,6,8);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid anteroseptal strain");
                        hold off;  
                    case app.region9_dd.Value
                        subplot(3,6,9);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid inferoseptal strain");
                        hold off;  
                    case app.region10_dd.Value
                        subplot(3,6,10);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid inferior strain");
                        hold off;  
                    case app.region11_dd.Value
                        subplot(3,6,11);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid inferolateral strain");
                        hold off;  
                    case app.region12_dd.Value
                        subplot(3,6,12);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("mid anterolateral strain");
                        hold off;  
                    case app.region13_dd.Value
                        subplot(3,6,13);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("apical anterior strain");
                        hold off;  
                    case app.region14_dd.Value
                        subplot(3,6,14);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("apical septal strain");
                        hold off;  
                    case app.region15_dd.Value
                        subplot(3,6,15);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("apical inferior strain");
                        hold off;  
                    case app.region16_dd.Value
                        subplot(3,6,16);
                        hold on;
                        plot(1:length(strain_info.strain),strain_info.strain);
                        title("apical lateral strain");
                        hold off;
                end
                for j = 1:16
                    subplot(3,6,j);
                    axis tight;
%                     ylim([min_strain_val-(0.1*abs(min_strain_val)) max_strain_val+(0.1*abs(max_strain_val))]);
                end
            end
            global_strain = mean(app.max_strain_data);
            app.result_1.Text = "Global strain: "+string(global_strain);
        end
    end
end