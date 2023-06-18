%% function: calc_ncc_d
% calculates displacement between two windows using standard NCC method,
% return as d = 1x2 array

function d = calc_ncc_d(w1,w2)
    % Calculate size of window
    win_size = size(w1);

    % Set up hanning window
    H = hanning(win_size(1)).*hanning(win_size(2))';

    % Initialize array to hold displacements
    d = zeros(1,2);

    % Compute fft2 of both windows
    W1 = fft2((w1-mean(w1(:))).*H);
    W2 = fft2((w2-mean(w2(:))).*H);

    % Normalized Cross Correlation
    NCC = (W2 .* conj(W1)) ./ (abs(W2 .* conj(W1)));
    NCC = ifft2(NCC, 'symmetric');
    NCC = fftshift(NCC);
%             cc(k) = max(NCC(:)); % Correlation Coefficients

    % Pixelwise displacement
    [~, max_NCC_index] = max(NCC(:));
    [d(1), d(2)] = ind2sub([win_size(1),win_size(2)],max_NCC_index);

    if d(1) < 1 || d(2) > win_size(1) || d(1) < 1 || d(2) > win_size(2)
        warning("Subwindow size is too small.");
    end

    % Move displacement to center
    d(1) = d(1) - floor(win_size(1)/2) - 1;
    d(2) = d(2) - floor(win_size(2)/2) - 1;
end