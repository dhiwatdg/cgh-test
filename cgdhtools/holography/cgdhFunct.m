% Calculate a function useful in various holography tasks
% in both spatial and frequency domains
%
% Inputs:
% funcType
%  - type of the function to be calculated, can be
%    in the spatial domain:
%      'SphericalWave'
%      'RayleighSommerfeldExact'
%      'RayleighSommerfeldSimple'
%      'FresnelXY'
%    in the frequency domain:
%      'AngularSpectrumExact'
%      'AngularSpectrumNoEvanescent'
%      'FresnelFXFY'
% xx, yy
%  - coordinates generated using meshgrid()
%  - note that for frequency domain function, they should be better named fxx, fyy
% params
%  - additional parameters used in the function calculation
%  - [lambda, z0] for spatial domain functions
%  - [lambda, z0, px, py] for frequency domain functions, where px and py
%    create additional linear phase
% lfMaxYX (optional)
%  - maximum acceptable local frequency in Y and X axes
%
% Outputs:
% out
%  - Matrix with calculated function values
% lfxRange, lfyRange (optional)
%  - Vectors [min, max] for minimum and maximum X (Y) coordinate
%    that results to maximum acceptable local frequency
% lfx, lfy (optional)
%  - Matrix with calculated local frequency values
%
% TODO
% - Check backpropagation behavoiur (function, local frequency limits)
% - Fix local frequency limits if the function does not alias at all
%
% ---------------------------------------------
%
%  CGDH TOOLS
%  Petr Lobaz, lobaz@kiv.zcu.cz
%  Faculty of Applied Sciences, University of West Bohemia 
%  Pilsen, Czech Republic
%
%  Check http://holo.zcu.cz for more details and scripts.
%
% ---------------------------------------------
function [out, lfxRange, lfyRange, lfx, lfy] = cgdhFunct(funcType, xx, yy, params, lfMaxYX)
  if (nargout == 5)
    calculateLF = true;
  else
    calculateLF = false;
  end

  % calculate local frequency limits in X and Y axes?
  if ((nargin < 5) || (nargout == 1))
    calculateLFRange = false;
    lfxRange = [];
    lfyRange = [];
  else
    calculateLFRange = true;
    lfxMax = lfMaxYX(2);
    lfyMax = lfMaxYX(1);
  end
    
  % Scilab compatibility
  imagUnit = sqrt(-1);
  piNumber = pi;

  lambda = params(1);
  z0 = params(2);
  k = 2*piNumber/lambda;

  %
  %
  % Spatial domain functions
  %
  %
  
  %
  % Spherical and Rayleigh-Sommerfeld type
  %
  if (isequalString(funcType, 'SphericalWave') || ...
      isequalString(funcType, 'RayleighSommerfeldExact') || ...
      isequalString(funcType, 'RayleighSommerfeldSimple'))
    % aliasing-free zone
    if (calculateLFRange)
      xLimit = lambda*lfxMax*abs(z0)/sqrt(1-lambda^2 * lfxMax^2);
      yLimit = lambda*lfyMax*abs(z0)/sqrt(1-lambda^2 * lfyMax^2);
      lfxRange = [-xLimit, xLimit];
      lfyRange = [-yLimit, yLimit];
    end
  
    % output function
    r = sqrt(xx.*xx + yy.*yy + z0.*z0);
    switch (funcType)
      case 'SphericalWave'
        out = exp(sign(z0)*imagUnit*2*piNumber/lambda.*r) ./ r;
      case 'RayleighSommerfeldExact'
        out = -1/(2*piNumber)*(imagUnit*k - 1./r).*exp(sign(z0)*imagUnit*k*r)./r .* z0./r;
      case 'RayleighSommerfeldSimple'
        out = -1/(2*piNumber)*(imagUnit*k).*exp(sign(z0)*imagUnit*k*r)./r .* z0./r;
    end

    % local frequencies
    if (calculateLF)
      lfx = abs(xx ./ (lambda * r));
      lfy = abs(yy ./ (lambda * r));
    end
    
  %
  % Fresnel type
  %
  elseif (isequalString(funcType, 'FresnelXY'))
    % aliasing-free zone
    if (calculateLFRange)
      xLimit = abs(lambda*lfxMax*z0);
      yLimit = abs(lambda*lfyMax*z0);
      lfxRange = [-xLimit, xLimit];
      lfyRange = [-yLimit, yLimit];
    end
  
    % output function
    out = exp(imagUnit*k*z0)/(imagUnit*lambda*z0).*exp(imagUnit*k*(xx.*xx + yy.*yy)./(2*z0)); 
    
    % local frequencies
    if (calculateLF)
      lfx = abs(xx / (lambda * z0));
      lfy = abs(yy / (lambda * z0));
    end
  %
  %
  % Frequency domain functions
  % Note that xx, yy should be better named fxx, fyy
  %
  %
  
  %
  % Angular spectrum transfer type
  %
  elseif (isequalString(funcType, 'AngularSpectrumExact') || ...
          isequalString(funcType, 'AngularSpectrumNoEvanescent'))
    px = params(3);
    py = params(4);

    % aliasing-free zone
    if (calculateLFRange)
      xLimitA = (px - lfxMax) / (lambda  * sqrt(z0^2 + (lfxMax - px)^2));
      xLimitB = (px + lfxMax) / (lambda  * sqrt(z0^2 + (lfxMax + px)^2));
      yLimitA = (py - lfyMax) / (lambda  * sqrt(z0^2 + (lfxMax - py)^2));
      yLimitB = (py + lfyMax) / (lambda  * sqrt(z0^2 + (lfxMax + py)^2));
      lfxRange = [xLimitA, xLimitB];
      lfyRange = [yLimitA, yLimitB];
    end

    % output function
    switch (funcType)
      case 'AngularSpectrumExact'
        out = exp(imagUnit*2*piNumber*(z0*sqrt(1/lambda^2 - xx.^2 - yy.^2) ...
                     + (xx * px + yy * py)));
      case 'AngularSpectrumNoEvanescent'
        fz = 1/lambda^2 - xx.^2 - yy.^2;
        out = exp(imagUnit*2*piNumber*(z0*sqrt(fz) ...
                     + (xx * px + yy * py)));
        out(fz < 0) = 0;
    end
    
    % local frequencies
    if (calculateLF)
      lfx = abs(-z0 .* xx ./sqrt(max(0, 1/lambda^2 - xx.^2 - yy.^2)) + px);
      lfy = abs(-z0 .* yy ./sqrt(max(0, 1/lambda^2 - xx.^2 - yy.^2)) + py);
    end

  %
  % Fresnel transfer type
  %
  elseif (isequalString(funcType, 'FresnelFXFY'))
    px = params(3);
    py = params(4);

    % aliasing-free zone
    if (calculateLFRange)
      xLimitA = (-lfxMax + px) / (lambda * z0);
      xLimitB = (lfxMax + px) / (lambda * z0);
      yLimitA = (-lfyMax + py) / (lambda * z0);
      yLimitB = (lfyMax + py) / (lambda * z0);
      lfxRange = [xLimitA, xLimitB];
      lfyRange = [yLimitA, yLimitB];
    end

    % output function
    out = exp(imagUnit * 2 * piNumber * ...
               (z0 / lambda * (1 - (xx * lambda).^2/2 - (yy * lambda).^2/2) + ...
               xx*px + yy*py));

    % local frequencies                            
    if (calculateLF)
      lfx = abs(-z0 * lambda * xx + px);
      lfy = abs(-z0 * lambda * yy + py);
    end

  %
  % Unrecognized type
  %
  else
    error(sprintf('Unknown function type: %s', funcType));      
  end
end