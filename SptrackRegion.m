%% class: SptrackRegion
% im_stack = all image frames
% region_loc = [top_left_row, top_left_col, bot_right_row, bot_right_col]
% win_loc = n_windows x 4 to hold window locations (same format as region_loc dimensions)
% win_size = size of each window, [n_rows, n_cols]
% win_overlap = amount of overlap in each direction, [row_overlap, col_overlap]
% d = n_frames-1 x 2 x n_windows to hold displacements

classdef SptrackRegion < handle
    properties %(Access = private)
        name % region name
        region_loc % region location
        scale % scale for images as [x_scale y_scale]
        win_loc % window locations
        win_cen % window centers
        d % displacement vectors
        d_avg % average displacement vectors
        strain_info % strain vector for the region
    end
    methods (Access = public)
        function obj = SptrackRegion(im_stack, region_loc, win_size, win_overlap, d_method, scale, region_name)
            obj.name = region_name;
            obj.region_loc = region_loc;
            obj.scale = scale;
            obj.generate_windows(win_size,win_overlap);
            fprintf("windows generated\n");
            [obj.win_loc, obj.d] = calc_d(im_stack,obj.win_loc,obj.region_loc,win_overlap,d_method);
            obj.win_cen = [floor((obj.win_loc(:,1)+obj.win_loc(:,3))/2) floor((obj.win_loc(:,2)+obj.win_loc(:,4))/2)];
            obj.d_avg = mean(obj.d,3,"omitnan");
            fprintf("displacement calculation complete\n");
            obj.calc_strain_info;
            fprintf("Strain calculation complete\n");
        end

        %% Getter functions
        % Get displacement field
        function [d, d_avg] = get_d(obj)
            d = obj.d;
            d_avg = obj.d_avg;
        end
        % Get window locations
        function win_loc = get_win_loc(obj)
            win_loc = obj.win_loc;
        end
        % Get window centers
        function win_cen = get_win_cen(obj)
            win_cen = obj.win_cen;
        end
        % Get region location
        function region_loc = get_region_loc(obj)
            region_loc = obj.region_loc;
        end
        % Get name
        function name = get_name(obj)
            name = obj.name;
        end
        % Get strain
        function strain_info = get_strain_info(obj)
            strain_info = obj.strain_info;
        end
    end
    methods (Access = private)
        function obj = generate_windows(obj,win_size,win_overlap)
            % Determine amount to increment in row, col directions, prevent from being less than 1
            row_increment = max(win_size(1)-win_size(1)*win_overlap(1), 1);
            col_increment = max(win_size(2)-win_size(2)*win_overlap(2), 1);
            
            % Determine row/col start and end indices
            row_start = obj.region_loc(1):row_increment:obj.region_loc(3);
            row_end = row_start+win_size(1)-1;
            col_start = obj.region_loc(2):col_increment:obj.region_loc(4);
            col_end = col_start+win_size(2)-1;
            
%             % Optional: if window extends outside of image, remove
%             if (row_end(end)>obj.region_loc(3) || col_end(end)>obj.region_loc(4))
%                 row_start(end) = [];
%                 row_end(end) = [];
%                 col_start(end) = [];
%                 col_end(end) = [];
%             end
         
            % Determine window locations
            obj.win_loc = zeros(length(row_start)*length(col_start),4);
            k = 1; % initialize window counter
            for i = 1:length(row_start)
                for j = 1:length(col_start)
                    obj.win_loc(k,:) = [row_start(i) col_start(j) row_end(i) col_end(j)];
                    k = k+1;
                end
            end
            obj.d = []; % reset displacement
        end
        % Generate strain info
        function obj = calc_strain_info(obj)
%             % Compute strain in x-direction
%             mid = 0.5*(obj.region_loc(4)+obj.region_loc(2));
%             win_cen1 = [];
%             d_1 = [];
%             d_2 = [];
% 
%             win_cen2 = [];
%             for i = 1:size(obj.win_cen,1)
%                 if obj.win_cen(i,2)>mid
%                     d_1 = cat(3,d_1,obj.d(:,:,i));
%                 else
%                     d_2 = cat(3,d_2,obj.d(:,:,i));
%                 end
%             end
% 
%             d_1_avg = cumsum(mean(d_1,3,"omitnan"),1);
%             d_2_avg = cumsum(mean(d_2,3,"omitnan"),1);
% 
%             d_win = 0.5*(obj.region_loc(2)+obj.region_loc(4));
%             dd = d_1_avg(:,2)-d_2_avg(:,2);
% 
% 
%             dx = -dd./d_win;
% 
%             dx = 0;
% 
%             % Compute strain in y-direction
%             mid = 0.5*(obj.region_loc(3)+obj.region_loc(1));
%             win_cen1 = [];
%             d_1 = [];
%             d_2 = [];
% 
%             win_cen2 = [];
%             for i = 1:size(obj.win_cen,1)
%                 if obj.win_cen(i,1)>mid
%                     d_1 = cat(3,d_1,obj.d(:,:,i));
%                 else
%                     d_2 = cat(3,d_2,obj.d(:,:,i));
%                 end
%             end
% 
%             obj.strain_info.d_1 = d_1;
%             obj.strain_info.d_2 = d_2;
% 
%             d_1_avg = cumsum(mean(d_1,3,"omitnan"),1);
%             d_2_avg = cumsum(mean(d_2,3,"omitnan"),1);
% 
%             d_win = 0.5*(obj.region_loc(1)+obj.region_loc(3));
%             dd = d_1_avg(:,1)-d_2_avg(:,1);
% 
% 
%             dy = -dd./d_win;
% 
%             strain = -(((dx.^2)+(dy.^2)).^0.5);
%             max_strain = min(strain);
% 
%             obj.strain_info.strain = strain;
%             obj.strain_info.max_strain = max_strain;

            

% 
%             x = mean(sum(obj.d.^2,2),1); % calculate average displacement magnitude for each window
%             [~,ind] = maxk(x,20); % get index for 100 largest displacements
%             ind = squeeze(ind); % fix dimensions
%             d_new = obj.d(:,:,ind);
%             win_cen_new = obj.win_cen(ind,:);
% 
%             obj.strain_info.d_new = d_new;
%             obj.strain_info.win_cen_new = win_cen_new;
% 
%             strain = [];
% %             cum_d = d_new;
%             cum_d = cumsum(d_new,1,"omitnan");
% 
%             % For each window, compute strain
%             for i = 1:size(d_new,3)/2
%                 % Get window centers as initial distance
%                 win_cen_i = win_cen_new(i,:); % get current window center
%                 win_cen_else = [win_cen_new(1:i-1,:); win_cen_new(i+1:end,:)]; % get window center for all others
%                 obj.strain_info.win_cen_i = win_cen_i;
%                 obj.strain_info.win_cen_else = win_cen_else;
% 
%                 % Take cumulative sum to compute total strain from start
%                 d_i = cum_d(:,:,i);
%                 d_else = cat(3,cum_d(:,:,1:i-1),cum_d(:,:,i+1:end));
% 
%                 obj.strain_info.d_i = d_i;
%                 obj.strain_info.d_else = d_else;
%                 
%                 % [dx dy] for all pairs
%                 d0 = win_cen_i-win_cen_else;
%                 d0 = repmat(d0,[1,1,size(d_else,1)]);
%                 d0 = permute(d0,[3,2,1]);
% 
%                 % [ddx ddy] for all pairs
%                 d1 = d_i-d_else;
% 
%                 % Compute strain as average of pairwise strain measurements
%                 new_strain = d1./d0;
%                 new_strain(abs(new_strain)==inf) = NaN;
%                 new_strain = mean(new_strain,3,"omitnan");
% 
% %                 new_strain = cumsum(new_strain,3,"omitnan");
% 
%                 % Add to array
%                 strain = cat(3,strain,new_strain);
%             end
%             strain = mean(strain,3,"omitnan"); % average across all windows again to get regional strain
% 
%             obj.strain_info.strain = -100*(sum(strain.^2,2,"omitnan").^0.5); % compute magnitude of strain
%             obj.strain_info.max_strain = min(obj.strain_info.strain); % compute max strain value

%             
            obj.strain_info.strain = cumsum(obj.d_avg(:,1).*obj.scale(2));
            obj.strain_info.max_strain = min(obj.strain_info.strain(:));
        end
    end
end