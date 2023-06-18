%% Calculate displacement vector
% d = n_frames-1 x 2 x n_windows to hold displacements
% win_loc = n_windows x 4 in format [top_left_row, top_left_col, bot_right_row, bot_right_col]

function [win_loc,d] = calc_d(im_stack,initial_win_loc,region_loc, win_overlap,d_method)
    % Determine number of frames in image stack
    n_frames = size(im_stack,3);

    % Initialize win_loc array
    win_loc = [];

    im_size = size(im_stack,[1,2]);

    %% Compute window locations, displacement vectors
    switch d_method
        % Static window method
        case 1 % Static NCC
            k = 1;
            d = zeros(n_frames-1,2,size(initial_win_loc,1));
            for i = 1:size(initial_win_loc,1)
                win_stack = im_stack(initial_win_loc(i,1):initial_win_loc(i,3),initial_win_loc(i,2):initial_win_loc(i,4),:);
                % Skip if any values are NaN
                if any(isnan(win_stack(:))) || all(win_stack(:,:,1)==0,'all')
                    d(:,:,end) = [];
                % If no NaN values, calculate displacement
                else
                    win_loc = cat(1,win_loc,initial_win_loc(i,:));
                    % Iterate through all frames, isolate windows, calculate displacement vector
                    for j = 1:n_frames-1
                        % Compute displacement, update d
                        d(j,:,k) = calc_ncc_d(win_stack(:,:,j),win_stack(:,:,j+1));
                    end
                    k = k+1;
                end
            end

        % Dynamic window method
        case 2
            d = [];
            for i = 1:size(initial_win_loc,1)
                win_loc = cat(1,win_loc,initial_win_loc(i,:));
                next_win_loc = initial_win_loc(i,:);
                temp_d = [];
                for j = 1:n_frames-1
                    % Isolate w1, w2 windows
                    w1 = im_stack(next_win_loc(1):next_win_loc(3),next_win_loc(2):next_win_loc(4),j);
                    w2 = im_stack(next_win_loc(1):next_win_loc(3),next_win_loc(2):next_win_loc(4),j+1);

                    % Check if window outside of boundary
                    if any(isnan(w1(:))) || any(isnan(w2(:))) || all(w1(:)==0) || all(w2(:)==0)
                        temp_d = []; % delete displacement data
                        win_loc(end,:) = []; % remove window from win_loc
                        break;
                    end

                    % Compute displacement, update temp_d
                    temp_d = cat(1,temp_d,calc_ncc_d(w1,w2));

                    % Update next frame window location based on displacement vector for current frame
                    next_win_loc = next_win_loc+[temp_d(end,:) temp_d(end,:)];

                    % Check if window bounds are outside of image bounds, set to previous index if outside
                    if next_win_loc(1) < 1 || next_win_loc(3) > im_size(1)
                        next_win_loc(1) = initial_win_loc(i,1);
                        next_win_loc(3) = initial_win_loc(i,3);
                    end
                    if next_win_loc(2) < 1 || next_win_loc(4) > im_size(2)
                        next_win_loc(2) = initial_win_loc(i,2);
                        next_win_loc(4) = initial_win_loc(i,4);
                    end
                end
                if ~isempty(temp_d)
                    d = cat(3,d,temp_d);
                end
            end

        % MLBM
        case 3
            % windowSize = [12, 12; 11, 11; 10, 10; 9, 9; 8, 8];
            windowSize = [12, 12; 11, 11];
            smallest_win_size = windowSize(end, :);
            field_size = floor((im_size-smallest_win_size)./ceil(smallest_win_size.*(1-win_overlap)))+1;
            % create empty arrays for displacement fields, window locations.
            d_j  = zeros(n_frames-1, field_size(1), field_size(2)); d_i  = zeros(size(d_j));
            CC   = zeros(size(d_j));
            j_tl = zeros(size(d_j)); i_tl = zeros(size(d_j));
            j_br = zeros(size(d_j)); i_br = zeros(size(d_j));
            
            % Create ROI from region_loc
            ROI = zeros(size(im_stack(:,:,1)));
            ROI(region_loc(1):region_loc(3), region_loc(2):region_loc(4)) = 1;
            ROI = imbinarize(ROI);

            % Iterate through all frames, calculate displacement vectors
            for j = 1:n_frames-1
                [d_j(j,:,:), d_i(j,:,:), CC(j,:,:,:), j_tl(j,:,:), i_tl(j,:,:), j_br(j,:,:), i_br(j,:,:)] = calc_MLBM(im_stack(:,:,j:j+1), ROI, windowSize, win_overlap);
            end
            d_j = reshape(d_j, n_frames-1, 1, size(d_j,2)*size(d_j,3));
            d_i = reshape(d_i, n_frames-1, 1, size(d_i,2)*size(d_i,3));

            d_j(CC < 0.2) = NaN;
            d_i(CC < 0.2) = NaN;

            d = cat(2, d_i, d_j);
            clear d_j d_i;
            j_tl = squeeze(j_tl(1,:,:));
            i_tl = squeeze(i_tl(1,:,:));
            j_br = squeeze(j_br(1,:,:));
            i_br = squeeze(i_br(1,:,:));

            j_tl = reshape(j_tl, size(j_tl,1)*size(j_tl,2),1);
            i_tl = reshape(i_tl, size(i_tl,1)*size(i_tl,2),1);
            j_br = reshape(j_br, size(j_br,1)*size(j_br,2),1);
            i_br = reshape(i_br, size(i_br,1)*size(i_br,2),1);
            win_loc = cat(2, i_tl, j_tl, i_br, j_br);
            clear j_tl i_tl j_br i_br;
%             d(isnan(d)) = 0;
    end
end
