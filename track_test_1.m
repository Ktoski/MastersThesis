% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the face detector.
% E:\TBBT Training Set Data\Set\l1.mp4
%videoFileReader = vision.VideoFileReader('tilted_face.avi');
%videoFileReader = vision.VideoFileReader('E:\\TBBT Training Set Data\\Set\\l1.mp4');
%videoFileReader = vision.VideoFileReader('E:\\TBBT Training Set Data\\Set\\l3.png');  % with deteced features
videoFileReader = vision.VideoFileReader('E:\TBBT Training Set Data\video_test3.mp4');
% videoFileReader = vision.VideoFileReader('E:\TBBT Training Set Data\Set\two.png');
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);

% Draw the returned bounding box around the detected face.
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
figure; imshow(videoFrame); title('Detected face');

% Convert the first box into a list of 4 points
% This is needed to be able to visualize the rotation of the object.
bboxPoints = bbox2points(bbox(1, :));
%bboxPoinstArray = need to create an array of those objects probably


disp(bbox);
sizeHolder = size(bbox);
numberOfDetectedFaces = sizeHolder(1);
disp("numberOfDetectedFaces: " + numberOfDetectedFaces)
bboxPointsArray = zeros(0);
for i=1:numberOfDetectedFaces
   bboxPointsArray = [bboxPointsArray, bbox2points(bbox(i, :))] 
end
disp(bboxPointsArray);
% Detect feature points in the face region.
% points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);
points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox(1,:));
points2 = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox(2,:));
%disp(points(1));  % points two demenion array ??

%  facesC = cornerPoints.empty(13,0);
 faces = {};
 for i = 1:numberOfDetectedFaces
     face = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox(i,:));
     faces{i} = face;   
 end 

disp("FACES");
disp(faces);
disp("FACES SIZE");
disp(size(faces,2));
% Display the detected points.
figure, imshow(videoFrame), hold on, title('Detected features');
%plot(points);
%plot(points2);

for i=1:size(faces,2)
    plot(faces{i});
end
%facesPointsList = cornerPoints.empty(0);
%for i= 1:size(faces)
%    facesPointsList(i) = faces(i);
%end
%plot(pointsList);
 
% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Initialize the tracker with the initial point locations and the initial
% TODO chnage to loop for dynamic number of faces
% video frame.
points = points.Location;
points2 = points2.Location;
points3 = vertcat(points, points2);
% initialize(pointTracker, points, videoFrame);
initialize(pointTracker, points3, videoFrame);

videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);


% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
% oldPoints = points;
oldPoints = points3;

while ~isDone(videoFileReader)
    % get the next frame
    videoFrame = step(videoFileReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    %visiblePoints = points3(isFound, :);
    oldInliers = oldPoints(isFound, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
        %for i=1:numberOfDetectedFaces
        % Apply the transformation to the bounding box points  bboxPointsArray
        bboxPoints = transformPointsForward(xform, bboxPoints);
        %bboxPointsArray(i) = transformPointsForward(xform, bboxPointsArray(i));
                
        % Insert a bounding box around the object being tracked
        bboxPolygon = reshape(bboxPoints', 1, []);
        %bboxPolygon = reshape(bboxPointsArray(1)', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, ...
            'LineWidth', 2);
                
        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
            'Color', 'white');       
        
        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);   
        
    end
    
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
end

% Clean up
release(videoFileReader);
release(videoPlayer);
release(pointTracker);