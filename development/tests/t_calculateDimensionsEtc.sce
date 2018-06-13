cgdhPath = '../../cgdhtools'; exec(strcat([cgdhPath, '/loadSubfolders.sce']));
getd('../testUtils');

mprintf('Testing calculateDimension:\n');

fnTestFloat(calculateDimension(1, 1), 0, 1);
fnTestFloat(calculateDimension(3, 1), 2, 2);
fnTestFloat(calculateDimension([3, 3], 1), [2, 2], 3);
fnTestFloat(calculateDimension([3, 4], 1), [2, 3], 4);
fnTestFloat(calculateDimension([3, 4], [1, 1]), [2, 3], 5);
fnTestFloat(calculateDimension([3, 4], [1, 2]), [2, 6], 6);

//%

mprintf('Testing calculateDelta:\n');

fnTestFloat(calculateDelta(2, 1), 1, 1);
fnTestFloat(calculateDelta(3, 1), 0.5, 2);
fnTestFloat(calculateDelta([3, 3], 1), [0.5, 0.5], 3);
fnTestFloat(calculateDelta([3, 3], [1, 1]), [0.5, 0.5], 4);
fnTestFloat(calculateDelta([5, 3], [1, 1]), [0.25, 0.5], 5);
fnTestFloat(calculateDelta([5, 3], [2, 1]), [0.5, 0.5], 6);

//%

mprintf('Testing calculateSamples:\n');

fnTestFloat(calculateSamples(1, 1), 2, 1);
fnTestFloat(calculateSamples(1, 0.5), 3, 2);
fnTestFloat(calculateSamples(1, 0.6), 3, 3);

[s, adj] = calculateSamples(1, 0.6);
fnTestFloat(s, 3, 4);
fnTestFloat(adj, 1.2, 5);

[s, adj] = calculateSamples(1, 0.6, 'dimension');
fnTestFloat(s, 3, 6);
fnTestFloat(adj, 1.2, 7);

[s, adj] = calculateSamples(1, 0.6, 'delta');
fnTestFloat(s, 3, 8);
fnTestFloat(adj, 0.5, 9);

fnTestFloat(calculateSamples([1, 2], 0.6), [3, 5], 10);

[s, adj] = calculateSamples([1, 2], 0.6);
fnTestFloat(s, [3, 5], 11);
fnTestFloat(adj, [1.2, 2.4], 12);

[s, adj] = calculateSamples([1, 2], 0.6, 'delta');
fnTestFloat(s, [3, 5], 13);
fnTestFloat(adj, [0.5, 0.5], 14);

fnTestFloat(calculateSamples([1, 2], [0.4, 0.6]), [4, 5], 15);

[s, adj] = calculateSamples([1, 2], [0.4, 0.6], 'dimension');
fnTestFloat(s, [4, 5], 16);
fnTestFloat(adj, [1.2, 2.4], 17);

[s, adj] = calculateSamples([1, 2], [0.4, 0.6], 'delta');
fnTestFloat(s, [4, 5], 18);
fnTestFloat(adj, [1/3, 0.5], 19);

//%

mprintf('Testing centerToMin:\n');

fnTestFloat(centerToMin([0, 0, 0], [3, 5], 1), [-2, -1, 0], 1);
fnTestFloat(centerToMin([0, 0, 0], [3, 5], [1, 0.5]), [-1, -1, 0], 2);

//%

mprintf('Testing minToCenter:\n');

fnTestFloat(minToCenter([-2, -1, 0], [3, 5], 1), [0, 0, 0], 1);
fnTestFloat(minToCenter([-1, -1, 0], [3, 5], [1, 0.5]), [0, 0, 0], 2);

minCoord = [1, 2, 3];
delta = [4, 5];
s = [6, 7];
fnTestFloat(...
  centerToMin(minToCenter(minCoord, s, delta), s, delta), ...
  minCoord, 3);

mprintf('ALL TESTS PASSED\n');


