%this scripts processes all the jpg and png images in the input path and outputs
%them to the output path
%this is to make it easier to process a large set of images all at once
filejpg = fullfile('./input', '*.jpg');
filepng = fullfile('./input', '*.png');
filesjpg = dir(filejpg);
filespng = dir(filepng);

outputPath = pwd+"\output";
 for i=1:length(filesjpg)
    filename = filesjpg(i);
    filename.name
    rock_segment(filename.name); 
 end
 for i=1:length(filespng)
    filename = filespng(i);
    filename.name
    rock_segment(filename.name); 
end