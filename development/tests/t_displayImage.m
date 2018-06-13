addpath(genpath('../../cgdhtools'));
saveFiles = ~false;

% Scilab compatibility
imagUnit = sqrt(-1);
piNumber = pi;



%
% COMPLEX IMAGE
%
rng = -2:3;
rngSize = size(rng, 2);
img = repmat(rng, rngSize, 1) + sqrt(-1) * repmat((rng)', 1, rngSize);
fprintf('image row, real: %s\n\n', mat2str(real(img(1, :))));
fprintf('image column, imag: %s\n\n', mat2str(imag(img(:, 1))));

fprintf('angle of a complex matrix, should be the same as the following image\n');

if (saveFiles)
  dispTest(wrapTo2Pi(angle(img)), [0, 2*piNumber], 'angle.png');
  dispTest(img, 'phase', 'phase.png');
  dispTest(img, 'complex', 'complex.png');
  dispTest(img, 'complexReIm', 'complexReIm.png');
else
  dispTest(wrapTo2Pi(angle(img)), [0, 2*piNumber]);
  dispTest(img, 'phase');
  dispTest(img, 'complex');
  dispTest(img, 'complexReIm');
end

%
% REAL IMAGE
%
img = repmat(rng, rngSize, 1);
fprintf('image row: %s\n\n', mat2str(img(1, :)));

dispTest(img);

if (saveFiles)
  dispTest(img, 'positive', 'positive.png');
  dispTest(img, 'negative', 'negative.png');
  dispTest(img, 'symmetric', 'symmetric.png');
  dispTest(img, 'minmax', 'minmax.png');
  dispTest(img, [-1, 1], 'range.png');
else
  dispTest(img, 'positive');
  dispTest(img, 'negative');
  dispTest(img, 'symmetric');
  dispTest(img, 'minmax');
  dispTest(img, [-1, 1]);
end  

fprintf('FINISHED\n');