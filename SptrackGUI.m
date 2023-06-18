classdef SptrackGUI < matlab.apps.AppBase & handle
    % Properties that correspond to app components
    properties (Access = public)
        uifig                          matlab.ui.Figure
        grid_layout                    matlab.ui.container.GridLayout
        left_panel                     matlab.ui.container.Panel
        
        region_options_panel           matlab.ui.container.Panel
        subwindow_panel                matlab.ui.container.Panel

        width_overlap_text             matlab.ui.control.NumericEditField
        height_overlap_text            matlab.ui.control.NumericEditField
        height_text                    matlab.ui.control.NumericEditField
        width_text                     matlab.ui.control.NumericEditField

        height_overlap_label           matlab.ui.control.Label
        width_overlap_label            matlab.ui.control.Label
        height_text_label              matlab.ui.control.Label
        width_text_label               matlab.ui.control.Label

        tracking_method_dd             matlab.ui.control.DropDown
        tracking_method_label          matlab.ui.control.Label

        region_name                    matlab.ui.control.EditField
        region_name_text_label         matlab.ui.control.Label

        d_avg_cb                       matlab.ui.control.CheckBox
        d_field_cb                     matlab.ui.control.CheckBox
        
        frame_slider_panel             matlab.ui.container.Panel
        frame_down_btn                 matlab.ui.control.Button
        frame_up_btn                   matlab.ui.control.Button
        frame_label                    matlab.ui.control.Label
        frame_slider                   matlab.ui.control.Slider
        name_label                     matlab.ui.control.Label
        log_label                      matlab.ui.control.Label
        add_panel                      matlab.ui.container.Panel
        draw_btn                       matlab.ui.control.Button
        cancel_btn                     matlab.ui.control.Button
        add_region_btn                 matlab.ui.control.Button
        update_panel                   matlab.ui.container.Panel
        update_regionvis_btn           matlab.ui.control.Button
        remove_btn                     matlab.ui.control.Button
        region_select_dd               matlab.ui.control.DropDown
        region_label                   matlab.ui.control.Label
        update_region_btn              matlab.ui.control.Button
        
        % additional properties
        name
        n_frames
        curr_frame
        controller                     SptrackController
        user_rect

        interact_axes                  
        display_axes                   
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SptrackGUI(name,im_stack,scale)
            app.name = name;
            app.n_frames = size(im_stack,3);

            % Create UIFigure and components
            app.create_components;

            % Initialize SptrackController object
%             app.controller = SptrackController(app.interact_axes,app.display_axes,im_stack,scale);
            f1 = figure(Position=[537 883 1065 420]);
            app.interact_axes = subplot(1,2,1);
            app.display_axes = subplot(1,2,2);
            app.controller = SptrackController(app.interact_axes,app.display_axes,im_stack,scale);
            

            % Update frame
            app.controller.update_frame(app.frame_slider.Value);

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.controller)
            delete(app.uifig)
        end

        % Get controller info
        function info = get_controller_info(app)
            info = app.controller.get_controller_info;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function app = create_components(app)
            % Create uifig and hide until all components are created
            app.uifig = uifigure('Visible', 'off');
            app.uifig.Color = [1 1 1];
            app.uifig.Position = [68 651 468 702];
            app.uifig.Name = 'MATLAB App';

            % Create grid_layout
            app.grid_layout = uigridlayout(app.uifig);
            app.grid_layout.ColumnWidth = {466, '1x'};
            app.grid_layout.RowHeight = {'1x'};
            app.grid_layout.ColumnSpacing = 0;
            app.grid_layout.RowSpacing = 0;
            app.grid_layout.Padding = [0 0 0 0];
            app.grid_layout.Scrollable = 'on';

            % Create left_panel
            app.left_panel = uipanel(app.grid_layout);
            app.left_panel.BackgroundColor = [1 1 1];
            app.left_panel.Layout.Row = 1;
            app.left_panel.Layout.Column = 1;

            % Create update_win_panel
            app.update_panel = uipanel(app.left_panel);
            app.update_panel.Title = 'Update or remove existing region with selected options';
            app.update_panel.BackgroundColor = [0.851 0.9333 0.9882];
            app.update_panel.Position = [17 403 431 138];

            % Create update_region_btn
            app.update_region_btn = uibutton(app.update_panel, 'push');
            app.update_region_btn.ButtonPushedFcn = createCallbackFcn(app, @update_region_btn_pushed, true);
            app.update_region_btn.BackgroundColor = [0.6 1 1];
            app.update_region_btn.Position = [82 6 163 67];
            app.update_region_btn.Text = 'Fully update region';

            % Create region_label
            app.region_label = uilabel(app.update_panel);
            app.region_label.HorizontalAlignment = 'right';
            app.region_label.Position = [11 87 43 22];
            app.region_label.Text = 'Region';

            % Create region_select_dd
            app.region_select_dd = uidropdown(app.update_panel);
            app.region_select_dd.Position = [69 87 350 22];
            app.region_select_dd.Items = {''};
            app.region_select_dd.ItemsData = "";
            app.region_select_dd.ValueChangedFcn = createCallbackFcn(app, @region_select_dd_callback, true);

            % Create remove_btn
            app.remove_btn = uibutton(app.update_panel, 'push');
            app.remove_btn.BackgroundColor = [1 0.451 0.451];
            app.remove_btn.Position = [14 6 55 67];
            app.remove_btn.Text = {'Remove'; 'region'};
            app.remove_btn.ButtonPushedFcn = createCallbackFcn(app, @remove_btn_pushed, true);

            % Create update_regionvis_btn
            app.update_regionvis_btn = uibutton(app.update_panel, 'push');
            app.update_regionvis_btn.BackgroundColor = [0.6 1 1];
            app.update_regionvis_btn.Position = [253 6 163 67];
            app.update_regionvis_btn.Text = 'Update region visibility';
            app.update_regionvis_btn.ButtonPushedFcn = createCallbackFcn(app, @update_regionvis_btn_pushed, true);

            % Create add_win_panel
            app.add_panel = uipanel(app.left_panel);
            app.add_panel.Title = 'Add new region with selected options';
            app.add_panel.BackgroundColor = [0.851 0.9294 0.9882];
            app.add_panel.Position = [17 552 431 109];

            % Create add_region_btn
            app.add_region_btn = uibutton(app.add_panel, 'push');
            app.add_region_btn.BackgroundColor = [0.6 1 1];
            app.add_region_btn.Position = [177 12 242 67];
            app.add_region_btn.Text = 'Add region';
            app.add_region_btn.ButtonPushedFcn = createCallbackFcn(app, @add_btn_pushed, true);

            % Create cancel_btn
            app.cancel_btn = uibutton(app.add_panel, 'push');
            app.cancel_btn.BackgroundColor = [1 0.451 0.451];
            app.cancel_btn.Position = [12 12 148 20];
            app.cancel_btn.Text = 'Cancel';
            app.cancel_btn.ButtonPushedFcn = createCallbackFcn(app, @cancel_btn_pushed, true);

            % Create draw_btn
            app.draw_btn = uibutton(app.add_panel, 'push');
            app.draw_btn.BackgroundColor = [0.6 1 1];
            app.draw_btn.Position = [12 38 147 41];
            app.draw_btn.Text = 'Draw region';
            app.draw_btn.ButtonPushedFcn = createCallbackFcn(app, @draw_btn_pushed, true);

            % Create name_label
            app.name_label = uilabel(app.left_panel);
            app.name_label.FontSize = 12;
            app.name_label.HorizontalAlignment = 'center';
            app.name_label.Position = [4 687 457 17];
            app.name_label.Text = app.name;

            % Create log_label
            app.log_label = uilabel(app.left_panel);
            app.log_label.Position = [7 663 454 22];
            app.log_label.Text = '';

            % Create frame_slider_panel
            app.frame_slider_panel = uipanel(app.left_panel);
            app.frame_slider_panel.Title = 'Frame slider';
            app.frame_slider_panel.BackgroundColor = [0.9608 0.9216 1];
            app.frame_slider_panel.Position = [17 28 431 103];

            % Create frame_slider
            app.frame_slider = uislider(app.frame_slider_panel);
            app.frame_slider.Limits = [1 app.n_frames];
            app.frame_slider.ValueChangedFcn = createCallbackFcn(app, @frame_slider_value_changed, true);
            app.frame_slider.Position = [10 70 409 3];
            app.frame_slider.MajorTicks = 1:(max([1, floor(app.n_frames/10)])):app.n_frames;
            app.frame_slider.MajorTickLabels = string(1:(max([1, floor(app.n_frames/10)])):app.n_frames);

            % Create frame_label
            app.frame_label = uilabel(app.frame_slider_panel);
            app.frame_label.HorizontalAlignment = 'center';
            app.frame_label.Position = [167 10 98 22];
            app.frame_label.Text = '';

            % Create frame_up_btn
            app.frame_up_btn = uibutton(app.frame_slider_panel, 'push');
            app.frame_up_btn.ButtonPushedFcn = createCallbackFcn(app, @frame_up_btn_pushed, true);
            app.frame_up_btn.BackgroundColor = [0.8392 0.6588 0.9686];
            app.frame_up_btn.Position = [324 6 97 23];
            app.frame_up_btn.Text = '+';

            % Create frame_down_btn
            app.frame_down_btn = uibutton(app.frame_slider_panel, 'push');
            app.frame_down_btn.ButtonPushedFcn = createCallbackFcn(app, @frame_down_btn_pushed, true);
            app.frame_down_btn.BackgroundColor = [0.8392 0.6588 0.9686];
            app.frame_down_btn.Position = [10 6 97 23];
            app.frame_down_btn.Text = '-';

            % Create region_options_panel
            app.region_options_panel = uipanel(app.left_panel);
            app.region_options_panel.Title = 'Region options';
            app.region_options_panel.BackgroundColor = [0.851 0.9294 0.9882];
            app.region_options_panel.Position = [17 142 431 247];

            % Create region_name_text_label
            app.region_name_text_label = uilabel(app.region_options_panel);
            app.region_name_text_label.HorizontalAlignment = 'right';
            app.region_name_text_label.Position = [12 191 78 22];
            app.region_name_text_label.Text = 'Region Name';

            % Create d_field_cb
            app.d_field_cb = uicheckbox(app.region_options_panel);
            app.d_field_cb.Text = 'Displacement field visibility';
            app.d_field_cb.Position = [12 7 167 22];

            % Create d_avg_field_cb
            app.d_avg_cb = uicheckbox(app.region_options_panel);
            app.d_avg_cb.Text = 'Total displacement visibility';
            app.d_avg_cb.Position = [251 7 169 22];

            % Create region_name
            app.region_name = uieditfield(app.region_options_panel, 'text');
            app.region_name.Position = [105 189 314 25];

            % Create subwindow_panel
            app.subwindow_panel = uipanel(app.region_options_panel);
            app.subwindow_panel.Title = 'Subwindow size and overlap';
            app.subwindow_panel.BackgroundColor = [0.5843 0.8039 0.9412];
            app.subwindow_panel.Position = [12 37 407 106];

            % Create tracking_method_dd
            app.tracking_method_dd = uidropdown(app.region_options_panel);
            app.tracking_method_dd.Items = {'Static NCC','Dynamic NCC','Multi-level Block Matching'};
            app.tracking_method_dd.ItemsData = [1 2 3];
            app.tracking_method_dd.Position = [122 153 143 22];
            app.tracking_method_dd.Value = 3;
            % Create tracking_method_label
            app.tracking_method_label = uilabel(app.region_options_panel);
            app.tracking_method_label.HorizontalAlignment = 'right';
            app.tracking_method_label.Position = [12 153 95 22];
            app.tracking_method_label.Text = 'Tracking method';

            % Create width_text
            app.width_text = uieditfield(app.subwindow_panel, 'numeric');
            app.width_text.Position = [70 45 78 33];
            % Create width_text_label
            app.width_text_label = uilabel(app.subwindow_panel);
            app.width_text_label.HorizontalAlignment = 'right';
            app.width_text_label.Position = [18 51 37 22];
            app.width_text_label.Text = 'Width';
            
            % Create height_text
            app.height_text = uieditfield(app.subwindow_panel, 'numeric');
            app.height_text.Position = [70 6 78 33];
            % Create height_text_label
            app.height_text_label = uilabel(app.subwindow_panel);
            app.height_text_label.HorizontalAlignment = 'right';
            app.height_text_label.Position = [15 12 40 22];
            app.height_text_label.Text = 'Height';

            % Create width_overlap_text
            app.width_overlap_text = uieditfield(app.subwindow_panel, 'numeric');
            app.width_overlap_text.Position = [311 45 78 33];
            % Create width_overlap_label
            app.width_overlap_label = uilabel(app.subwindow_panel);
            app.width_overlap_label.HorizontalAlignment = 'right';
            app.width_overlap_label.Position = [203 46 93 30];
            app.width_overlap_label.Text = {'% width overlap'; '(decimal)'};

            % Create height_overlap_text
            app.height_overlap_text = uieditfield(app.subwindow_panel, 'numeric');
            app.height_overlap_text.Position = [311 6 78 33];
            % Create height_overlap_label
            app.height_overlap_label = uilabel(app.subwindow_panel);
            app.height_overlap_label.HorizontalAlignment = 'right';
            app.height_overlap_label.Position = [199 7 97 30];
            app.height_overlap_label.Text = {'% height overlap'; '(decimal)'};

            % Show the figure after all components are created
            app.uifig.Visible = 'on';
        end
    end


    %% Callbacks that handle component events
    methods (Access = private)
        % Button pushed function: draw_btn
        function draw_btn_pushed(app, event)
            hold(app.interact_axes,'on');
            app.user_rect = drawrectangle(app.interact_axes,'color',[0.4 0.8 1]);
            hold(app.interact_axes,'off');
            app.log_label.Text = "LOG: Draw region in interact window";
        end

        % Button pushed function: cancel_btn
        function cancel_btn_pushed(app, event)
            if ~isempty(app.user_rect)
                app.user_rect.Visible = "off";
                app.user_rect = [];
            end
            app.log_label.Text = "LOG: Drawing canceled";
        end

        % Button pushed function: add_btn
        function add_btn_pushed(app,event)
            % Check if rectangle exists
            if isempty(app.user_rect)
                app.log_label.Text = "LOG: no region selected";
                return;
            end

            % Obtain region location from rectangle data
            region_loc = [round(app.user_rect.Position(2))
                round(app.user_rect.Position(1))
                round(app.user_rect.Position(2)+app.user_rect.Position(4))
                round(app.user_rect.Position(1)+app.user_rect.Position(3))];
            win_size = [app.width_text.Value app.height_text.Value];
            win_overlap = [app.width_overlap_text.Value app.height_overlap_text.Value];

            if (win_size(1)<=0)||(win_size(2)<=0)
                app.log_label.Text = "LOG: invalid window size (must be nonzero)";
                return;
            end
            
            if (win_overlap(1)>1)||(win_overlap(2)>1)
                app.log_label.Text = "LOG: invalid window overlap (must be < 1)";
                return;
            end

            % Set default name if no name available
            if isempty(app.region_name.Value)
                name_val = "region "+string(app.controller.get_num_regions);
                app.log_label.Text = "LOG: default name selected";
            else
                name_val = string(app.region_name.Value);
            end

            app.log_label.Text = "LOG: adding region (this may take a moment)...";
            % Add region if window size, overlap values are valid
            app.controller.add_region(region_loc, ...
                win_size, ...
                win_overlap, ...
                app.tracking_method_dd.Value, ...
                app.d_field_cb.Value, ...
                app.d_avg_cb.Value, ...
                name_val);

            % Reset region drawing
            app.user_rect.Visible = "off";
            app.user_rect = [];

            app.controller.update_frame(app.frame_slider.Value); % update visibility

            app.log_label.Text = "LOG: Region added";

            app.region_select_dd.Items = [app.region_select_dd.Items name_val];
            app.region_select_dd.ItemsData = [app.region_select_dd.ItemsData name_val];

            app.region_name.Value = ''; % empty region name option, leave the others the same

            app.controller.show_region(app.region_select_dd.Value); % update region shown
        end

        % Button pushed function: remove_btn
        function remove_btn_pushed(app, event)
            if app.region_select_dd.Value == ""
                app.log_label.Text = "LOG: No regions removed";
                return;
            end

            app.controller.remove_region(app.region_select_dd.Value);

            % Update region select dropdown menu
            removed_name = app.region_select_dd.Value;
            app.region_select_dd.Items(find(app.region_select_dd.ItemsData==removed_name)) = [];
            app.region_select_dd.ItemsData(find(app.region_select_dd.ItemsData==removed_name)) = [];

            app.log_label.Text = "LOG: Region removed"; % log message

            app.controller.show_region(app.region_select_dd.Value); % update region shown
            app.log_label.Text = "LOG: region added successfully";
        end

        % Button pushed function: update_vis_btn
        function update_regionvis_btn_pushed(app,event)
            app.controller.update_d_vis(app.region_select_dd.Value,app.d_field_cb.Value,app.d_avg_cb.Value);
            app.log_label.Text = "LOG: visibility update successful";
        end

        % Dropdown menu changed function: region_select_dd
        function region_select_dd_callback(app,event)
            app.controller.show_region(app.region_select_dd.Value);
        end
        
        % Value changed function: frame_slider
        function frame_slider_value_changed(app, event)
            value = app.frame_slider.Value;
            value = round(value);
            % move the slider to that option
            event.Source.Value = value;
            
            app.frame_label.Text = "frame: "+value;

            app.controller.update_frame(app.frame_slider.Value);
        end

        % Button pushed function: update_region_btn
        function update_region_btn_pushed(app, event)
            win_size = [app.width_text.Value app.height_text.Value];
            win_overlap = [app.width_overlap_text.Value app.height_overlap_text.Value];

            % Check for valid window selections
            if (win_size(1)<=0)||(win_size(2)<=0)
                app.log_label.Text = "LOG: invalid window size (must be nonzero)";
                return;
            end
            if (win_overlap(1)>1)||(win_overlap(2)>1)
                app.log_label.Text = "LOG: invalid window overlap (must be < 1)";
                return;
            end

            app.log_label.Text = "LOG: updating region (this may take a moment)...";
            % Update region with selected parameters
            app.controller.update_region(app.region_select_dd.Value, ...
                win_size, ...
                win_overlap, ...
                app.tracking_method_dd.Value, ...
                app.d_field_cb.Value, ...
                app.d_avg_cb.Value, ...
                app.region_name.Value);
            
            % Update region name in list if necessary
            if ~isempty(app.region_name.Value)
                app.region_select_dd.Items(find(app.region_select_dd.ItemsData==app.region_select_dd.Value)) = {app.region_name.Value};
                app.region_select_dd.ItemsData(find(app.region_select_dd.ItemsData==app.region_select_dd.Value)) = app.region_name.Value;
            end
            
            app.controller.update_frame(app.frame_slider.Value); % refresh plots
            app.controller.show_region(app.region_select_dd.Value); % update interact window if necessary
            app.log_label.Text = "LOG: region update successful";
        end

        % Button pushed function: frame_up_btn
        function frame_up_btn_pushed(app, event)
            app.frame_slider.Value = min(round(app.frame_slider.Value+1),app.frame_slider.Limits(2));
            app.frame_label.Text = "frame: "+app.frame_slider.Value;
            app.controller.update_frame(app.frame_slider.Value);
        end

        % Button pushed function: frame_down_btn
        function frame_down_btn_pushed(app, event)
            app.frame_slider.Value = max(round(app.frame_slider.Value-1),app.frame_slider.Limits(1));
            app.frame_label.Text = "frame: "+app.frame_slider.Value;
            app.controller.update_frame(app.frame_slider.Value);
        end

%         % Changes arrangement of the app based on UIFigure width
%         function updateAppLayout(app, event)
%             currentFigureWidth = app.uifig.Position(3);
%             if(currentFigureWidth <= app.onePanelWidth)
%                 % Change to a 2x1 grid
%                 app.grid_layout.RowHeight = {711, 711};
%                 app.grid_layout.ColumnWidth = {'1x'};
%                 app.right_panel.Layout.Row = 2;
%                 app.right_panel.Layout.Column = 1;
%             else
%                 % Change to a 1x2 grid
%                 app.grid_layout.RowHeight = {'1x'};
%                 app.grid_layout.ColumnWidth = {466, '1x'};
%                 app.right_panel.Layout.Row = 1;
%                 app.right_panel.Layout.Column = 2;
%             end
%         end
    end
end