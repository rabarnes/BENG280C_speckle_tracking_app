classdef SptrackRegionViewer < handle
    properties %(Access = private)
        name % region name

        d_plots % displacement field plots
        d_avg_plots % average displacement plots
        d_vis % displacement field visibility
        d_avg_vis % average displacement visibility

        region_plot
    end

    methods (Access = public)
        %% Constructor
        function obj = SptrackRegionViewer(interact_axes,display_axes,new_region,d_vis,d_avg_vis)
            obj.name = new_region.get_name;
            obj.d_vis = d_vis;
            obj.d_avg_vis = d_avg_vis;

            % Get window centers, displacement vectors
            win_cen = new_region.get_win_cen;
            [d,d_avg] = new_region.get_d;

            % Get new plots for region
            [obj.region_plot, obj.d_plots, obj.d_avg_plots] = generate_region_plots(interact_axes,display_axes,win_cen,d,d_avg,new_region.get_region_loc);
        end

        %% Update frame
        function update_frame(obj,curr_frame)
            % If on first frame toggle all plots off
            if curr_frame == 1
                obj.vis_off;
                return
            end

            % If not on first frame and visibility toggled on, toggle displacement plots on for curr_frame
            if obj.d_vis == 1
                for i = 1:size(obj.d_plots,1)
                    for j = 1:size(obj.d_plots,2)
                        if i == curr_frame-1
                            obj.d_plots(i,j).Visible = "on";
                        else
                            obj.d_plots(i,j).Visible = "off";
                        end
                    end
                end
            else
                for i = 1:length(obj.d_plots(:))
                    obj.d_plots(i).Visible = "off";
                end
            end
            % If not on first frame and visibility toggled on, toggle average displacement plots on curr_frame
            if obj.d_avg_vis == 1
                for i = 1:length(obj.d_avg_plots)
                    if i <= curr_frame-1
                        obj.d_avg_plots(i).Visible = "on";
                    else
                        obj.d_avg_plots(i).Visible = "off";
                    end
                end
            else
                for i = 1:length(obj.d_avg_plots)
                    obj.d_avg_plots(i).Visible = "off";
                end
            end
        end

        %% Update visibility settings
        function obj = update_d_vis(obj,d_vis,d_avg_vis)
            obj.d_vis = d_vis;
            obj.d_avg_vis = d_avg_vis;
        end
        function obj = update_region_vis(obj,region_vis)
            if region_vis
                obj.region_plot.Visible = "on";
            else
                obj.region_plot.Visible = "off";
            end
        end

        %% Turn off all displacement plots
        function obj = vis_off(obj)
            for i = 1:length(obj.d_plots(:))
                obj.d_plots(i).Visible = "off"; % turn off all plots
            end
            for i = 1:length(obj.d_avg_plots)
                obj.d_avg_plots(i).Visible = "off"; % turn off all plots
            end
        end

        %% Destructor method
        function obj = delete(obj)
            obj.region_plot.Visible = "off"; % turn off region plot
            obj.vis_off;
        end

        %% Getter functions
        function name = get_name(obj)
            name = obj.name;
        end
    end
end