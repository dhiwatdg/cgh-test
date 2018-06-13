// Loads function definitions from all subfolders of the global variable cgdhPath
//
// Example usage:
// cgdhPath = '../cgdhtools'; exec(strcat([cgdhPath, '/loadSubfolders.sce']));
folderList = dir(cgdhPath);
subfolders = folderList.name(folderList.isdir);
for i = 1:size(subfolders, 1)
  subfolderPath = strcat([cgdhPath, '/', subfolders(i)]);
  // mprintf('loading %s\n', subfolderPath); // print subfolder being loaded
  getd(subfolderPath);
end
