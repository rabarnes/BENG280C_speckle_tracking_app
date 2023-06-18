classdef SptrackController < handle
    properties %(Access = private)
        im_stack
        scale
        regions
        viewer SptrackViewer
        num_regions
    end
    methods
        %% Constructor
        function obj = SptrackController(interact_axes,display_axes,im_stack,scale)
            obj.im_stack = im_stack;
            obj.scale = scale;
            obj.regions = [];
            obj.viewer = SptrackViewer(interact_axes,display_axes,im_stack,scale);
            obj.num_regions = 0;
        end

        %% Add region
        function obj = add_region(obj,region_loc,win_size,win_overlap,d_method,d_vis,d_avg_vis,region_name)
            % Create new region with selected properties
            new_region = SptrackRegion(obj.im_stack, ...
                region_loc, ...
                win_size, ...
                win_overlap, ...
                d_method, ...
                obj.scale, ...
                region_name);
            % Add region to region array
            if isempty(obj.regions)
                obj.regions = new_region;
            else
                obj.regions = cat(1,obj.regions,new_region);
            end
           
            % Add region to viewer object
            obj.viewer.add_region(obj.regions(end),d_vis,d_avg_vis);
            % Update number of regions
            obj.num_regions = obj.num_regions + 1;
        end

        %% Update region
        function obj = update_region(obj,region_select,win_size,win_overlap,d_method,d_vis,d_avg_vis,region_name)
            for i = 1:length(obj.regions)
                % Check to see which region to work with
                if obj.regions(i).get_name==region_select
                    if region_name == ""
                        region_name = obj.regions(i).get_name;
                    end
                    % Replace region with new region with selected properties
                    obj.regions(i) = SptrackRegion(obj.im_stack, ...
                        obj.regions(i).get_region_loc, ...
                        win_size, ...
                        win_overlap, ...
                        d_method, ...
                        obj.scale, ...
                        region_name);
                    % Update viewer with new region
                    obj.viewer.update_region(region_select,obj.regions(i),d_vis,d_avg_vis);
                end
            end
        end
        
        %% Remove region
        function obj = remove_region(obj,region_select)
            % Find region to remove based on name
            for i = 1:length(obj.regions)
                if obj.regions(i).get_name==region_select
                    delete(obj.regions(i)); % replace with updated region
                    obj.regions(i) = []; % set to empty to fix vector size
                    obj.viewer.remove_region(region_select); % remove from viewer object
                    % Update number of regions
                    obj.num_regions = obj.num_regions - 1;
                    return;
                end
            end
        end

        %% Update frame
        function obj = update_frame(obj,new_frame)
            obj.viewer.update_frame(new_frame);
        end

        %% Show region window
        function obj = show_region(obj,region_select)
            obj.viewer.update_region_vis(region_select);
        end

        %% Update visibility settings
        % Region displacement field visibility
        function obj = update_d_vis(obj,region_select,d_vis,d_avg_vis)
            obj.viewer.update_d_vis(region_select,d_vis,d_avg_vis);
        end
        
        %% Getter functions
        function num_regions = get_num_regions(obj)
            num_regions = obj.num_regions;
        end
        function info = get_controller_info(obj)
            info.scale = obj.scale; % scale
            info.regions = obj.regions; % regions
        end
    end
end