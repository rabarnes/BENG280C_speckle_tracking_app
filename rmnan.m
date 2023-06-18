function y = rmnan(x,order)
    % Remove NaNs by inter/extrapolation
    % see also INPAINTN
    % Written by Louis Le Tarnec, RUBIC, 2012
    
    sizx = size(x);
    W = isfinite(x);
    
    x(~W) = 0;
    W = W(:); x = x(:);
    
    missing_values = find(W==0)';
    
    % Matrix defined by Buckley (equation 23)
    % Biometrika (1994), 81, 2, pp. 247-58
    d = length(sizx);
    for i = 1:d
        n = sizx(i);
        e = ones(n,1);
        K = spdiags([e -2*e e],-1:1,n,n);
        K(1,1) = -1; K(n,n) = -1; %#ok
        M = 1;
        for j = 1:d
            if j==i, M = kron(K,M); end
            if j~=i
                m = sizx(j);
                I = spdiags(ones(1,m)',0,m,m);
                M = kron(I,M);
            end
        end
        if i==1, A = M; else, A = A+M; end
    end
    A = A^order;
    
    % Linear system to be solved
    x2 = -A*x;
    x2 = x2(missing_values);
    A = A(missing_values, missing_values);
    
    % Solution
    x2 = A\x2;
    x(missing_values) = x2;
    y = reshape(x,sizx);
end

