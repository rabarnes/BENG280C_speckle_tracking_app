function [d_j, d_i, cc, j_topLeft, i_topLeft, j_bottomRight, i_bottomRight] = calc_MLBM(img, ROI, windowSize, overlap, verbose)
    %%%  FFT-based Phase Correlation Block Matching Speckle Tracking
    % Using:
    % https://en.wikipedia.org/wiki/Phase_correlation
    % Current Time-Domain Methods for Assessing Tissue Motion by Analysis from Reflected Ultrasound Echoes-A Review
    % Back to basics in ultrasound velocimetry: tracking speckles by using a standard PIV algorithm
    
    % M, N are size of full original image.
    % m, n are size of a sub-window.
    % i_topLeft, j_topLeft are the coordinates of the top-left of the sub-window.
    % i_center, j_center are the coordinates of the center of the sub-window.
    % i_increment, j_increment are size by which to increment the i_topLeft,j_topLeft cordinates.
    %   These will be smaller than m,n because we overlap the sub-window/blocks.
    % (i_topLeft, j_topLeft) -> (vertical, horizontal) ->  (Column, Row)

    arguments
        img
        ROI
        windowSize
        overlap
        verbose {mustBeNonempty} = false
    end
    [M, N, P] = size(img);
    % Set pixels outside of the ROI to NaN.
    img(repmat(~ROI,[1 1 P])) = NaN;
    
    
    for z = 1:size(windowSize,1) % Multi-Level Block Matching (MLBM) loop start
        
        if z > 1 % 2nd+ level of block matching
            % Window centers from last round
            ic0 = (2*i_topLeft+m-1)/2;
            jc0 = (2*j_topLeft+n-1)/2;
    
            % Size of the Sub-Window
            m = windowSize(z, 1);
            n = windowSize(z, 2);
    
            % Increntental movement for creation of overlapping sub-window
            i_increment = ceil(m*(1-overlap(2)));
            j_increment = ceil(n*(1-overlap(1)));
            % Coordinates of the (top left corner of the) sub-windows
            [j_topLeft, i_topLeft] = meshgrid(1:j_increment:N-n+1, 1:i_increment:M-m+1);
            j_bottomRight = j_topLeft + n;
            i_bottomRight = i_topLeft + m;
    
            % Size of the displacement-field matrix
            disp_field_size = floor([(M-m)/i_increment (N-n)/j_increment])+1;
    
            % Coordinates of the (center of the) sub-windows. TODO: check that these are correct locations.
            i_center = (2*i_topLeft+m)/2-1;
            j_center = (2*j_topLeft+n)/2-1;  
    
            % Interpolation onto the new grid
            d_i = interp2(jc0, ic0, d_i, j_center, i_center, 'cubic');
            d_j = interp2(jc0, ic0, d_j, j_center, i_center, 'cubic');
            
            % Extrapolation (remove NaNs)
            d_j = rmnan(d_i+1i*d_j,2);
            d_i = real(d_j); d_j = imag(d_j);
            d_i = round(d_i); d_j = round(d_j);
    
        else
            % Size of the Sub-Window
            m = windowSize(z, 1);
            n = windowSize(z, 2);
    
            % Increntental movement for creation of overlapping sub-window
            i_increment = ceil(m*(1-overlap(2)));
            j_increment = ceil(n*(1-overlap(1)));
            % Coordinates of the (top left corner of the) sub-windows
            [j_topLeft, i_topLeft] = meshgrid(1:j_increment:N-n+1, 1:i_increment:M-m+1);
            j_bottomRight = j_topLeft + n;
            i_bottomRight = i_topLeft + m;

            % Size of the displacement-field matrix
            disp_field_size = floor([(M-m)/i_increment (N-n)/j_increment])+1;
    
            % Coordinates of the (center of the) sub-windows. TODO: check that these are correct locations.
            i_center = (2*i_topLeft+m)/2-1;
            j_center = (2*j_topLeft+n)/2-1;  
    
            % Initialize Displacement-Field Matrix & Correlation Coefficients Matrix
            d_i = zeros(disp_field_size);
            d_j = zeros(disp_field_size);
        end
    
        % Hanning window same size as the sub-window
        H = (hanning(n)'.*hanning(m))/2 + 0.5;
        % H = hanning(n)'.*hanning(m);
        
        % Initialize Correlation Coefficients Matrix
        cc  = zeros(disp_field_size);
    
    
        for k = 1:numel(i_topLeft)
            if i_topLeft(k)+m-1 <= M && j_topLeft(k)+n-1 <= N
                w_k1 = img(i_topLeft(k):i_topLeft(k)+m-1, j_topLeft(k):j_topLeft(k)+n-1, 1);
                % w_k2 = img(i_topLeft(k):i_topLeft(k)+m-1, j_topLeft(k):j_topLeft(k)+n-1, 2);
                w_k2 = img(i_topLeft(k)+d_i(k):i_topLeft(k)+d_i(k)+m-1, j_topLeft(k)+d_j(k):j_topLeft(k)+d_j(k)+n-1, 2);
            else
                d_i(k) = NaN; 
                d_j(k) = NaN;
                continue
            end
        
            if any(isnan([w_k1(:) w_k2(:)]))
                d_i(k) = NaN; 
                d_j(k) = NaN;
                continue
            end
            
            % FFT-based cross-correlation
            W_k1 = fft2((w_k1-mean(w_k1(:))).*H);
            W_k2 = fft2((w_k2-mean(w_k1(:))).*H);
            % W_k2 = fft2((w_k2-mean(w_k2(:))).*H);
        
            % Normalized Cross Correlation
            NCC_k = (W_k2 .* conj(W_k1)) ./ (abs(W_k2 .* conj(W_k1)));
            NCC_k = ifft2(NCC_k, 'symmetric');
            NCC_k = fftshift(NCC_k);
            cc(k) = max(NCC_k(:)); % Correlation Coefficients
            
            % Pixelwise Displacement
            [~, max_NCC_index] = max(NCC_k(:));
            [di0, dj0] = ind2sub([n, m],max_NCC_index);
    
            if di0 < 1 || di0 > m || dj0 < 1 || dj0 > n
                warning("Subwindow size is too small. \n")
            end
    
            if isnan(cc(k))
                d_i(k) = NaN; 
                d_j(k) = NaN;
                if verbose, warning("No Corr (cc=0)"); end
                continue
            end
    
            % Move Displacement to center
            d_i(k) = d_i(k) + di0 - floor(m/2) - 1;
            d_j(k) = d_j(k) + dj0 - floor(n/2) - 1;
        
            % Using Lucas–Kanade differential method for subpixel-motion correction:
            %   https://en.wikipedia.org/wiki/Lucas%E2%80%93Kanade_method
            %   https://www.mathworks.com/matlabcentral/fileexchange/48745-lucas-kanade-tutorial-example-2
        
            if i_topLeft(k)+d_i(k)>0 && j_topLeft(k)+d_j(k)>0 && i_topLeft(k)+d_i(k)+m-2<M && j_topLeft(k)+d_j(k)+n-2<N
                w_k2_wMovement = img(i_topLeft(k)+d_i(k):i_topLeft(k)+d_i(k)+m-1, j_topLeft(k)+d_j(k):j_topLeft(k)+d_j(k)+n-1, 2);
    
                Ix_m = conv2(w_k1, [-1 1; -1 1], 'valid'); % partial derivative on x
                Iy_m = conv2(w_k1, [-1 -1; 1 1], 'valid'); % partial derivative on y
                It_m = conv2(w_k1, ones(2), 'valid') + conv2(w_k2_wMovement, -ones(2), 'valid'); % partial derivative on t
                Ix = Ix_m(:);
                Iy = Iy_m(:);
                b = -It_m(:);
                A = [Ix Iy];
                tmp = lsqminnorm(A, b);
                if verbose
                    if tmp(2) > 2
                        warning("Large Subpixel Motion Correction: di = "+ num2str(tmp(2)));
                    end
                    if tmp(1) > 2
                        warning("Large Subpixel Motion Correction: dj = "+ num2str(tmp(1)));
                    end
                end
                if ~isnan(tmp(2)), d_i(k) = d_i(k) + tmp(2); end
                if ~isnan(tmp(1)), d_j(k) = d_j(k) + tmp(1); end
                
                w_k1_subpixel = img(i_topLeft(k):i_topLeft(k)+m-1, j_topLeft(k):j_topLeft(k)+n-1, 1);
                w_k2_subpixel = img(i_topLeft(k)+round(d_i(k)):i_topLeft(k)+round(d_i(k))+m-1, j_topLeft(k)+round(d_j(k)):j_topLeft(k)+round(d_j(k))+n-1, 2);
                % FFT-based cross-correlation
                W_k1_subpixel = fft2((w_k1_subpixel-mean(w_k1_subpixel(:))).*H);
                W_k2_subpixel = fft2((w_k2_subpixel-mean(w_k1_subpixel(:))).*H);
    
                % Normalized Cross Correlation
                NCC_W_k2_subpixel_k = (W_k2_subpixel .* conj(W_k1_subpixel)) ./ (abs(W_k2_subpixel .* conj(W_k1_subpixel)));
                NCC_W_k2_subpixel_k = ifft2(NCC_W_k2_subpixel_k, 'symmetric');
                NCC_W_k2_subpixel_k = fftshift(NCC_W_k2_subpixel_k);
                cc(k) = max(NCC_W_k2_subpixel_k(:)); % Correlation Coefficients
            else
                % w1 = 'Lucas–Kanade Sub-pixel Movement error. \n';
                % w2 = append('i_topLeft(k)+d_i(k)>0 = ', num2str(i_topLeft(k)+d_i(k)), ' \n');
                % w3 = append('j_topLeft(k)+d_j(k)>0 = ', num2str(j_topLeft(k)+d_j(k)), ' \n');
                % w4 = append('i_topLeft(k)+d_i(k)+m-2<',num2str(M),' = ', num2str(i_topLeft(k)+d_i(k)+m-2), ' \n');
                % w5 = append('j_topLeft(k)+d_j(k)+n-2<',num2str(N),' = ', num2str(j_topLeft(k)+d_j(k)+n-2), ' \n');
                % warning(sprintf(append(w1,w2,w3,w4,w5)));
                warning('Lucas–Kanade Sub-pixel Movement error.');
            end
        end
        if z ~= size(windowSize,1)
            d_i(cc < 0.2) = 0; 
            d_j(cc < 0.2) = 0;
        end
        % d_i(cc < 0.1) = 0; 
        % d_j(cc < 0.1) = 0;
    
        % % % Turn off warning messages for SMOOTHN
        % % warn01 = warning('off','MATLAB:smoothn:MaxIter'); 
        % % warn02 = warning('off','MATLAB:smoothn:SLowerBound');
        % % warn03 = warning('off','MATLAB:smoothn:SUpperBound');
        % % 
        % % %-- Weighted robust smoothing
        % % cc(isnan(cc)) = 0; 
        % % if z == size(windowSize,1), options.TolZ = 0.001; end
        % % if z ~= size(windowSize,1), options.TolZ = 0.1; end
        % % d_j = smoothn({d_i,d_j},sqrt(cc),'robust',options);
        % % d_i = d_j{1}; d_j = d_j{2};
        % % 
        % % % Return to previous warning states
        % % warning(warn01.state,'MATLAB:smoothn:MaxIter'); 
        % % warning(warn02.state,'MATLAB:smoothn:SLowerBound');
        % % warning(warn03.state,'MATLAB:smoothn:SUpperBound');
    end % Multi-Level Block Matching (MLBM) loop end
    
    
    %%% Need to add some method of smoothing
    cc(cc == 0) = NaN; 
    d_i(isnan(cc)) = NaN; 
    d_j(isnan(cc)) = NaN;
    
    % d_i(cc < 0.2) = NaN; % Experimental **
    % d_j(cc < 0.2) = NaN; % Experimental **

    [j_ROI, i_ROI] = meshgrid(1:N,1:M);
    ROI = interp2(j_ROI, i_ROI, ROI, j_center, i_center, 'nearest');
    d_i(~ROI) = NaN;
    d_j(~ROI) = NaN;

end



