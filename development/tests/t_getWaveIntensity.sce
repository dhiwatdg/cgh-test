cgdhPath = '../../cgdhtools'; exec(strcat([cgdhPath, '/loadSubfolders.sce']));
getd('../testUtils');

wave = [3 4];
fnTestFloat(getWaveIntensity(wave), 12.5, 1);

[mn, mx] = getWaveIntensity(wave);
fnTestFloat(mn, 12.5, 2);
fnTestFloat(mx, 16, 3);

mprintf('ALL TESTS PASSED\n');

