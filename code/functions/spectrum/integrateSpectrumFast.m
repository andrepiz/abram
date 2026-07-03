function integratedDataOut = integrateSpectrumFast(lambdaIn, spectralDataIn, lambdaOut, responseOut, method_interp, method_extrap)
% integrateSpectrumFast Fast and memory-aware version of integrateSpectrum

nin  = numel(lambdaIn);
nout = numel(lambdaOut);

if ndims(spectralDataIn) == 3
    sz = size(spectralDataIn);
    if sz(1) == 1 && sz(3) == nin          % [1 x N x nc]
        spectralDataIn = permute(spectralDataIn, [3 2 1]);
    elseif sz(1) == 1 && sz(2) == nin      % [1 x nc x N]
        spectralDataIn = permute(spectralDataIn, [2 3 1]);
    else
        spectralDataIn = reshape(spectralDataIn, sz(1), []);
    end
end
if size(spectralDataIn, 1) ~= nin
    if size(spectralDataIn, 2) == nin
        spectralDataIn = spectralDataIn.';
    else
        error('integrateSpectrum:dimensionMismatch', ...
              'Cannot match spectral dimension (nc=%d) to spectralDataIn of size [%s].', ...
              nin, num2str(size(spectralDataIn)));
    end
end

if ~issorted(lambdaIn)
    [lambdaIn, ixsSortIn] = sort(lambdaIn(:));
    spectralDataIn = spectralDataIn(ixsSortIn, :);
end

if ~issorted(lambdaOut)
    [lambdaOut, ixsSortOut] = sort(lambdaOut(:));
    responseOut = responseOut(ixsSortOut);
end

% Compute weights
if nout == 1
    % Trapezoidal rule is undefined for a single point
    w = 1;   % [1 x np]
else
    dl = diff(lambdaOut(:)).';
    trapWeights = [dl(1), dl(1:end-1)+dl(2:end), dl(end)] / 2;  % [1 x nout]
    % Precompute trapezoidal weights (1 x nout) — fixed for given lambdaOut
    denom = trapWeights * responseOut(:); 
    assert(denom > 0, 'integrateSpectrum:zeroDenominator', ...
        'Response integral is zero: check responseOut and lambdaOut inputs.');
    % Absorb response and normalisation into weight vector, then single multiply
    w = (trapWeights .* responseOut(:).') / denom;    % [1 x nout]
end

% ── 2. Build interpolation basis  W [nout x nin] ─────────────────────────
if strcmpi(method_interp, 'linear') && (strcmpi(method_extrap, 'linear') || strcmpi(method_extrap, 'nearest'))
    W = buildLinearBasis(lambdaIn(:), lambdaOut(:), nin, nout, method_extrap);
else
    error('Fast version of integrateSpectrum only allows for linear interpolation and linear or nearest extrapolation')
end
 
% ── 3. Contract weights and integrate ────────────────────────────────────
%   c [1 x nin] = w [1 x nout] * W [nout x nin]
%   integratedDataOut [1 x np] = c * spectralDataIn [nin x np]
c = w * W;
integratedDataOut = c * spectralDataIn;
 
end 

% =========================================================================
function W = buildLinearBasis(lambdaIn, lambdaOut, nin, nout, method_extrap)
% Sparse [nout x nin] piecewise-linear interpolation matrix.
%
% discretize() returns k such that lambdaIn(k) <= lambdaOut < lambdaIn(k+1),
% with k=NaN outside the range.
 
k = double(discretize(lambdaOut, lambdaIn));   % [nout x 1], NaN for OOR
 
% Clamp to valid bracket for in-range points (will be overwritten for OOR)
kSafe = max(1, min(nin-1, k));
kSafe(isnan(k)) = 1;   % placeholder
 
% Fractional position within bracket
t = (lambdaOut - lambdaIn(kSafe)) ./ (lambdaIn(kSafe+1) - lambdaIn(kSafe));
 
leftOf  = lambdaOut < lambdaIn(1);
rightOf = lambdaOut > lambdaIn(end);
 
% Default: in-range linear weights
wL = 1 - t;
wR =     t;
jL = kSafe;
jR = kSafe + 1;
 
% ---- Extrapolation handling --------------------------------------------
if strcmpi(method_extrap, 'nearest')
    % Clamp to endpoint
    wL(leftOf)  = 1;  wR(leftOf)  = 0;  jL(leftOf)  = 1;    jR(leftOf)  = 1;
    wL(rightOf) = 1;  wR(rightOf) = 0;  jL(rightOf) = nin;  jR(rightOf) = nin;
 
else
    % 'extrap' — linear extrapolation using the first/last bracket
    t_extrap = t;   % already computed with unclamped t outside [0,1]
    % Left: use bracket [1, 2]
    if any(leftOf)
        t_extrap(leftOf) = (lambdaOut(leftOf) - lambdaIn(1)) ./ ...
                           (lambdaIn(2)        - lambdaIn(1));
        jL(leftOf) = 1;  jR(leftOf) = 2;
        wL(leftOf) = 1 - t_extrap(leftOf);
        wR(leftOf) =     t_extrap(leftOf);
    end
    % Right: use bracket [nin-1, nin]
    if any(rightOf)
        t_extrap(rightOf) = (lambdaOut(rightOf) - lambdaIn(nin-1)) ./ ...
                            (lambdaIn(nin)       - lambdaIn(nin-1));
        jL(rightOf) = nin-1;  jR(rightOf) = nin;
        wL(rightOf) = 1 - t_extrap(rightOf);
        wR(rightOf) =     t_extrap(rightOf);
    end
end
 
% Sparse assembly: 2 nonzeros per row
rows = (1:nout).';
W = sparse([rows; rows], [jL; jR], [wL; wR], nout, nin);
 
end 

% 
% [lambdaInMin, ixsLambdaInMin] = min(lambdaIn);
% [lambdaInMax, ixsLambdaInMax] = max(lambdaIn);
% 
% integratedDataOut = 0;
% for ix = 1:nout
%     if isnumeric(method_extrap)
%         spectralDataOut_temp = interp1(lambdaIn, spectralDataIn, lambdaOut(ix), method_interp, method_extrap); % [1 x np]
%     elseif strcmp(method_extrap, 'nearest')
%         if lambdaOut(ix) < lambdaInMin
%             spectralDataOut_temp = spectralDataIn(ixsLambdaInMin, :);
%         elseif lambdaOut(ix) > lambdaInMax
%             spectralDataOut_temp = spectralDataIn(ixsLambdaInMax, :);
%         else
%             spectralDataOut_temp = interp1(lambdaIn, spectralDataIn, lambdaOut(ix), method_interp); % [1 x np]           
%         end
%     else
%         spectralDataOut_temp = interp1(lambdaIn, spectralDataIn, lambdaOut(ix), method_interp, 'extrap'); % [1 x np]
%     end
%     integratedDataOut = integratedDataOut + w(ix) * spectralDataOut_temp;           % [1 x np]
% end
% 
% end