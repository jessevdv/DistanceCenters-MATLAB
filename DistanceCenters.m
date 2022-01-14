
%Specify directory
myFolder = 'Specify Directory Frames';
filePattern = fullfile(myFolder,'*.bmp');
images = dir(filePattern);
img_num = length(images); 

prompt = 'Do you want to check coordinates of fibre center? (Y/N)';
coordinates = input(prompt, 's');
prompt = 'Do you want to save data (Y/N)';
savedata = input(prompt, 's');

%Specify Output folder
if savedata == 'Y'
    folder_name = fullfile('Specify Output Directory');
    mkdir(folder_name)
    outputFolder = folder_name; 
end

%Pixels width of the wire
widthPixels = 29.5; %pixels
widthWire = 0.3; %mm
pixels_mm = widthPixels/widthWire;

pixels = ['Pixels/mm:', num2str(pixels_mm)];
disp(pixels)

%Coordinates of fibre center
X1 = 150;
Y1 = 181;

csvresults = {'ImageNumber','RadiusDistance'};

for i = 1:1
    %Read Image----------------
    baseFileName = images(i).name;
    fullFileName = fullfile(myFolder, baseFileName);
	img_original = imread(fullFileName);
    
    %Crop Image----------------
    start_row = 125;
    start_col = 340;
    
    crop_original = img_original(start_row:484, start_col:664, :);
    if coordinates == 'Y'
    imtool(crop_original)
    end
            
    %Binarize Image-------------
    I = im2gray(crop_original);
    BW = imbinarize(I);
    BW = ~BW;
    
    %Find center droplet--------
    [centers,radii] = imfindcircles(BW,[20 100],'ObjectPolarity','bright');
    xCenter = centers(1,1);
    yCenter = centers(1,2);
    
    %Calculate distance-------------------
    Distance = (sqrt((X1-centers(1))^2+(Y1-centers(2))^2));
    
    figure = imshow(BW); hold on;
    %Plot circle droplet
    viscircles(centers, radii, 'Color', 'b');
    %Plot center droplet
    plot(xCenter,yCenter,'yx','Color','b');
    %Plot center fibre
    plot(X1,Y1,'o','Color', 'y');
    %Plot line between centers
    plot([X1 xCenter],[Y1 yCenter],'Color','r')
    %Plot distance
    text(30, 30, (sprintf('%1.3f',Distance)),'Color','r','FontSize',14,'FontWeight','bold');

    %Display distance
    RadiusDistance = [num2str(i),' - ', num2str(Distance)];
    disp(RadiusDistance)

    csvresults = [csvresults;{i, Distance}];
    
    %Save figures
    if savedata == 'Y'
       fullFileName = fullfile(outputFolder, ['Analyzed' images(i).name]);
       saveas(figure,fullFileName) ;   
    end
    
    %Save csv
    if savedata == 'Y'
    writecell(csvresults, fullfile(outputFolder, 'Data.xls'));
    end

end