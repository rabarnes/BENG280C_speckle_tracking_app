classdef SptrackViewer < handle
    properties (Access = public)
        % Axes handles
        interact_axes           % holds axes for interactions
        display_axes            % holds axes for displaying image stack, displacements
        
        % Plots
        im_plots % imagesc plots, one for each frame
        regions  % holds region viewers for each region

        scale % image scale [x_scale y_scale]

        curr_frame % current frame that is visible
        n_frames   % number of frames in im_stack
    end

    methods (Access = public)
        %% Constructor
        function obj = SptrackViewer(interact_axes,display_axes,im_stack,scale)
            obj.interact_axes = interact_axes;
            obj.display_axes = display_axes;
            obj.scale = scale;
            obj.curr_frame = 1; % Set curr_frame to first frame by default
            obj.n_frames = size(im_stack,3);
            obj.generate_im_plots(im_stack);
            obj.regions = []; % initialize
            obj.refresh;
        end

        %% Add new region
        function obj = add_region(obj,new_region,d_vis,d_avg_vis)
            new_region_viewer = SptrackRegionViewer(obj.interact_axes,obj.display_axes,new_region,d_vis,d_avg_vis);
            if isempty(obj.regions)
                obj.regions = new_region_viewer;
            else
                obj.regions = cat(1,obj.regions,new_region_viewer);
            end
        end

        %% Update region
        function obj = update_region(obj,region_select,new_region,d_vis,d_avg_vis)
            new_region_viewer = SptrackRegionViewer(obj.interact_axes,obj.display_axes,new_region,d_vis,d_avg_vis);
            new_region_viewer.update_frame(obj.curr_frame);
            for i = 1:length(obj.regions)
                if obj.regions(i).get_name==region_select
                    delete(obj.regions(i));
                    obj.regions(i) = new_region_viewer;
                end
            end
        end

        %% Remove region
        function obj = remove_region(obj,region_select)
            for i = 1:length(obj.regions)
                if obj.regions(i).get_name==region_select
                    delete(obj.regions(i)); % delete region
                    obj.regions(i) = []; % empty array entry for region
                    return;
                end
            end
        end

        %% Methods to update plot visibilities
        function obj = update_frame(obj,new_frame)
            obj.curr_frame = new_frame;
            obj.refresh;
        end
        function obj = update_d_vis(obj,region_select,d_vis,d_avg_vis)
            for i = 1:length(obj.regions)
                if obj.regions(i).get_name==region_select
                    obj.regions(i).update_d_vis(d_vis,d_avg_vis);
                    obj.regions(i).update_frame(obj.curr_frame);
                end
            end
        end
        function obj = update_region_vis(obj,region_select)
            for i = 1:length(obj.regions)
                if obj.regions(i).get_name==region_select
                    obj.regions(i).update_region_vis(1);
                else
                    obj.regions(i).update_region_vis(0);
                end
            end
        end
    end

    methods (Access = private)
        %% Plot first frame on interact window, all frames on display window
        function obj = generate_im_plots(obj,im_stack)
            % imagesc for first frame
            imagesc(obj.interact_axes,im_stack(:,:,1));
            colormap(obj.interact_axes,gray(256));
            axis(obj.interact_axes,'tight');
            axis(obj.interact_axes,'ij');
            title(obj.interact_axes,"Interact Window, x scale = "+obj.scale(1)+"cm, y scale = "+obj.scale(2)+"cm");

            % imagesc for all frames, set visibility of all to off
            hold(obj.display_axes,'on');
            for i = 1:size(im_stack,3)
                new_im_plot = imagesc(obj.display_axes,im_stack(:,:,i));
                colormap(obj.display_axes,gray(256));
                new_im_plot.Visible = 'off';
                obj.im_plots = cat(1,obj.im_plots,new_im_plot);
            end
            axis(obj.display_axes,'tight');
            axis(obj.display_axes,'ij');
            hold(obj.display_axes,'off');
            title(obj.display_axes,"Display Window, x scale = "+obj.scale(1)+"cm, y scale = "+obj.scale(2)+"cm");
        end

        %% Refresh plots
        function obj = refresh(obj)
            for i = 1:length(obj.im_plots)
                if i == obj.curr_frame
                    obj.im_plots(i).Visible = "on";
                else
                    obj.im_plots(i).Visible = "off";
                end
            end
            for i = 1:length(obj.regions)
                obj.regions(i).update_frame(obj.curr_frame);
            end
        end
    end
end