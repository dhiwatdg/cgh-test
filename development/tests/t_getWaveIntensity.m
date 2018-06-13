addpath(genpath('../../cgdhtools'));
addpath('../testUtils');

wave = [3 4];
fnTestFloat(getWaveIntensity(wave), 12.5, 1);

[mn, mx] = getWaveIntensity(wave);
fnTestFloat(mn, 12.5, 2);
fnTestFloat(mx, 16, 3);

fprintf('ALL TESTS PASSED\n');

