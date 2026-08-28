%% Set file path
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_ExpNew0_SO31_Inc_2mm_Diam_20260428_15h42m38s\";

%% Input manually recorded distances
Stage_Window = 27.222;
Layer_Window = 22.228;
Sample_Window =24.519;

Layer_Thickness = Stage_Window - Layer_Window;
Sample_Thickness = Stage_Window - Sample_Window;
Expected_Total_Thickness = Layer_Thickness + Sample_Thickness;
disp(Expected_Total_Thickness)
disp(Stage_Window-19.394)

Expected_Total_Contact_Point =  Stage_Window - Expected_Total_Thickness;
Actual_Total_Contact_Point =  Expected_Total_Contact_Point;

Image_Contact_Points = [21.06;21.06;21.06;21.83;21.83;21.83;22.60;22.60;22.60;23.37;23.37;23.37];
Compressed_Total_Thicknesses = Stage_Window - Image_Contact_Points;

%% Import distance maps
imRange = 1:12;
Distance_Maps = {};
for n = 1:size(imRange,2)
    load(imageFolder+'dist_map_hyp_'+string(imRange(n))+'.mat');
    Distance_Maps{end+1} = dist_map;
end
%createfigure(Distance_Maps{end})

%% Layer Mechanical Model (Mooney-Rivlin)
e_strain = -0.99:0.01:-0.01; %0.99; 

% Mooney-Rivlin engineering stress function
C1 = 1482.0400245692672;
C2 = 151.64479609154546;
e_stress_from_e_strain_func = @(e) 0.001*(2.0*(C1 + C2 ./ (1.0 + e)) .* ( (1.0 + e) - 1.0 ./ ((1.0 + e) .* (1.0 + e)) ) );

e_stress = e_stress_from_e_strain_func(e_strain);
t_strain = log(1 + e_strain);
t_stress = e_stress .* (1 + e_strain);

t_stress_from_e_strain_func = @(x) interp1(e_strain, t_stress, x, 'cubic');

%% Layer Mechanical Model (Engineering Linear)
e_strain = -0.99:0.01:-0.01; 

e_stress_from_e_strain_func = @(e) 18.26302673261*e;

e_stress = e_stress_from_e_strain_func(e_strain);
t_strain = log(1 + e_strain);
t_stress = e_stress .* (1 + e_strain);

t_stress_from_e_strain_func = @(x) interp1(e_strain, t_stress, x, 'cubic');

%% Layer Mechanical Model (True Linear)
e_strain = -0.99:0.01:0.99;
t_strain = log(1 + e_strain);

t_stress_from_e_strain_func = @(e) 7.526*log(1 + e);

t_stress = t_stress_from_e_strain_func(e_strain);
e_stress = t_stress ./ (1 + e_strain);

e_stress_from_e_strain_func = @(x) interp1(e_strain, e_stress, x, 'cubic');

%% Visualise mechanical model
figure;
plot(t_strain, t_stress_from_e_strain_func(e_strain), '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Tru Layer Strain');
ylabel('Tru Layer Stress (Expected)');
%xlim([-0.5 0.0]);
ylim([-50 10]);
grid on;

figure;
plot(e_strain, e_stress_from_e_strain_func(e_strain), '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Eng Layer Strain');
ylabel('Eng Layer Stress (Expected)');
%xlim([-0.5 0.0]);
ylim([-50 10]);
grid on;

%% Calculate

Eng_Sample_E = {};
Eng_Layer_E = {};
Eng_Layer_Strain = {};
Eng_Sample_Strain = {};
Eng_Layer_Stress = {};
Eng_Layer_Strain_Im = {};
Eng_Sample_Strain_Im = {};

Tru_Sample_E = {};
Tru_Layer_E = {};
Tru_Layer_Strain = {};
Tru_Layer_Strain_Im = {};
Tru_Sample_Strain = {};
Tru_Layer_Stress = {};
Tru_Sample_Strain_Im = {};
Tru_Layer_Stress_Im = {};
Tru_Sample_E_Im = {};

for n = imRange
    Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(imRange(n));
    Compressed_Layer_Thickness = Distance_Maps{n};
    Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;
    
    Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) / Sample_Thickness; % compressive strain is negative
    True_Sample_Strain = log(1+Engineering_Sample_Strain);
    
    Engineering_Layer_Strain = -(Layer_Thickness - Compressed_Layer_Thickness) / Layer_Thickness; % compressive strain is negative
    True_Layer_Strain = log(1+Engineering_Layer_Strain);
    
    Engineering_Layer_Stress = e_stress_from_e_strain_func(Engineering_Layer_Strain);
    
    True_Layer_Stress = t_stress_from_e_strain_func(Engineering_Layer_Strain);
    
    Engineering_Sample_Elasticity = Engineering_Layer_Stress ./ Engineering_Sample_Strain;
    True_Sample_Elasticity = True_Layer_Stress ./ True_Sample_Strain;
    
    Engineering_Layer_Elasticity = Engineering_Layer_Stress ./ Engineering_Layer_Strain;
    True_Layer_Elasticity = True_Layer_Stress ./ True_Layer_Strain;

    % Eng_Sample_Strain{end+1} = nanmean(nanmean(Engineering_Sample_Strain));
    % Eng_Layer_Strain{end+1} = nanmean(nanmean(Engineering_Layer_Strain));
    %Eng_Layer_Stress{end+1} = nanmean(nanmean(Engineering_Layer_Stress));
    %E%ng_Sample_E{end+1} = nanmean(nanmean(Engineering_Sample_Elasticity));
    %Eng_Layer_E{end+1} = nanmean(nanmean(Engineering_Layer_Elasticity));

    %Tr%u_Sample_Strain{end+1} = nanmean(nanmean(True_Sample_Strain));
    %T%ru_Layer_Strain{end+1} = nanmean(nanmean(True_Layer_Strain));
    %Tru_Layer_Stress{end+1} = nanmean(nanmean(True_Layer_Stress));
    %Tru_Sample_E{end+1} = nanmean(nanmean(True_Sample_Elasticity));
    %Tru_Layer_E{end+1} = nanmean(nanmean(True_Layer_Elasticity));

    Eng_Sample_Strain{end+1} = mean(mean(Engineering_Sample_Strain));
    Eng_Layer_Strain{end+1} = mean(mean(Engineering_Layer_Strain));
    Eng_Layer_Stress{end+1} = mean(mean(Engineering_Layer_Stress));
    Eng_Sample_E{end+1} = mean(mean(Engineering_Sample_Elasticity));
    Eng_Layer_E{end+1} = mean(mean(Engineering_Layer_Elasticity));

    Tru_Sample_Strain{end+1} = mean(mean(True_Sample_Strain));
    Tru_Layer_Strain{end+1} = mean(mean(True_Layer_Strain));
    Tru_Layer_Stress{end+1} = mean(mean(True_Layer_Stress));
    Tru_Sample_E{end+1} = mean(mean(True_Sample_Elasticity));
    Tru_Layer_E{end+1} = mean(mean(True_Layer_Elasticity));

    Eng_Sample_Strain_Im{end+1} = Engineering_Sample_Strain;
    Eng_Layer_Strain_Im{end+1} = Engineering_Layer_Strain;

    Tru_Sample_Strain_Im{end+1} = True_Sample_Strain;
    Tru_Layer_Strain_Im{end+1} = True_Layer_Strain;
    Tru_Layer_Stress_Im{end+1} = True_Layer_Stress;

    Tru_Sample_E_Im{end+1} = True_Sample_Elasticity;
end

%disp(mean(mean(Engineering_Layer_Elasticity)))
%disp(mean(mean(Engineering_Sample_Elasticity)))
%disp(mean(mean(True_Sample_Elasticity)))

Eng_Sample_Strain = cell2mat(Eng_Sample_Strain);
Eng_Layer_Strain = cell2mat(Eng_Layer_Strain);
Eng_Layer_Stress = cell2mat(Eng_Layer_Stress);
Eng_Sample_E = cell2mat(Eng_Sample_E);
Eng_Layer_E = cell2mat(Eng_Layer_E);

Tru_Sample_Strain = cell2mat(Tru_Sample_Strain);
Tru_Layer_Strain = cell2mat(Tru_Layer_Strain);
Tru_Layer_Stress = cell2mat(Tru_Layer_Stress);
Tru_Sample_E = cell2mat(Tru_Sample_E);
Tru_Layer_E = cell2mat(Tru_Layer_E);
%% Scale
im = Distance_Maps{11};
SPACING_mm_pix = [0.001009*abs(mean2(im))+0.020954,0.001009*abs(mean2(im))+0.020954];
FOV_mm = SPACING_mm_pix .* size(im);
disp(SPACING_mm_pix)
%%
for n = [1,4,8,11]
    im = Tru_Sample_E_Im{n};
    [W,S] = maxRegionEdgeResolution(im);
    disp(mean(W*SPACING_mm_pix))
end
%%
for n = [1,4,8,11]
    im = Tru_Sample_E_Im{n};
    [w, S] = maxRegionGradientFWHM(im, 'DerivSpan', 2, 'PeakMethod', 'gauss', 'Deconvolve', true);
    disp(mean(w*SPACING_mm_pix))
end

%% circular ROI
data = Tru_Sample_E_Im{5};      % example 2D array (replace with your own data)
xc = 153;                % ROI center, x (column) in pixels
yc = 50;                % ROI center, y (row) in pixels
r  = 42.7;                 % ROI radius in pixels
% Build coordinate grids matching the array
[nRows, nCols] = size(data);
[X, Y] = meshgrid(1:nCols, 1:nRows);
% Create circular mask and extract ROI values
mask = (X - xc).^2 + (Y - yc).^2 <= r^2;
roiValues = data(mask);   % list of pixel values inside the circle
fprintf('Number of pixels in ROI: %d\n', numel(roiValues));
fprintf('Mean value in ROI: %.4f\n', mean(roiValues));
fprintf('Std of ROI: %.4f\n', std(roiValues));
figure;
imshow(data, []);
colormap(gca, parula);
colorbar;
hold on;
theta = linspace(0, 2*pi, 200);
xCircle = xc + r*cos(theta);
yCircle = yc + r*sin(theta);
plot(xCircle, yCircle, 'r-', 'LineWidth', 1.5);
plot(xc, yc, 'r+', 'MarkerSize', 10, 'LineWidth', 1.5);
hold off;
%% 
fig = figure;
fig.Units = 'centimeters';
%fig.Position = [5, 5, 5, 5]; % left, bot, width, height
%fig.GraphicsSmoothing = 'off';
im = Tru_Sample_E_Im{1};
imagesc(im);
%colormap(pmkmp(128,'CubicL'));
%clim([0,30]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
colorbar;
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
ax = gca();
ax.Units = 'centimeters';
%ax.Position = [0.5, 0.5, 3.25, 3.25];
hold on;
%ROI1_co = [100, 250, 50, 50];% [X_start, Y_start, width, height]
ROI1_co = [100, 200, 50, 50];% [X_start, Y_start, width, height]
rectangle('Position', ROI1_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
ROI1 = im(ROI1_co(2):(ROI1_co(2)+ROI1_co(4)-1), ROI1_co(1):(ROI1_co(1)+ROI1_co(3)-1));
%ROI2_co = [240, 290, 50, 50];% [X_start, Y_start, width, height]
ROI2_co = [240, 290, 50, 50];% [X_start, Y_start, width, height]
rectangle('Position', ROI2_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
ROI2 = im(ROI2_co(2):(ROI2_co(2)+ROI2_co(4)-1), ROI2_co(1):(ROI2_co(1)+ROI2_co(3)-1));
hold off
%set(gcf, 'Renderer', 'painters');
%exportgraphics(gcf, 'Fig4_test.pdf', 'ContentType', 'vector');


%%
% Least Squares Fit true stress strain regardless of y intercept over entire image and strain range
X = cat(3, Tru_Sample_Strain_Im{:});
Y = cat(3, Tru_Layer_Stress_Im{:});
n = size(X, 3);

sX  = sum(X, 3);
sY  = sum(Y, 3);
sXY = sum(X .* Y, 3);
sX2 = sum(X.^2, 3);

denom = (n * sX2 - sX.^2);
M_e = ((n * sXY - sX .* sY) ./ denom);
C_e = ((sY - M_e .* sX) / n);

disp(mean(mean(M_e)));
figure; imagesc(M_e); axis equal; axis tight; colorbar; title('True Elasticity Fit');
%%
figure;
histogram(M_e(:))
%% check fit
row = 200;
col = 200;
raw_strain = squeeze(X(row, col, :)); 
raw_stress = squeeze(Y(row, col, :));
slope = M_e(row, col);
intercept = C_e(row, col);
strain_range = [min(raw_strain), max(raw_strain)];
fit_line = slope * strain_range + intercept;

figure;
plot(raw_strain, raw_stress, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Raw Data'); 
hold on;
plot(strain_range, fit_line, 'b-', 'LineWidth', 2, 'DisplayName', 'Linear Fit');
grid on;
xlabel('Strain');
ylabel('Stress');
title(sprintf('Stress-Strain Fit at Pixel (%d, %d)', row, col));
legend('Location', 'best')
 
%% paper 3 figure 1.g
%figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.15, 0.2], 'Color', 'w');
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 3.0, 3.5]; % left, bot, width, height
im = imread(imageFolder+'im1_rect_image_'+string(2*11-1)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
imshow(im(r_start:r_end, c_start:c_end,:), 'InitialMagnification', 'fit'); 
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
exportgraphics(gcf, 'Fig1g.tif', 'Resolution', 600)

%% paper 3 figure 1.bc
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 3.0, 3.5]; % left, bot, width, height
im = imread(imageFolder+'im1_rect_image_'+string(2*11-1+1)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
imshow(im(r_start:r_end, c_start:c_end,:), 'InitialMagnification', 'fit'); 
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
exportgraphics(gcf, 'Fig1b.tif', 'Resolution', 600)

fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 3.0, 3.5]; % left, bot, width, height
im = imread(imageFolder+'im2_rect_image_'+string(2*11-1+1)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285-233;
c_end   = cols-window_radius-233;
imshow(im(r_start:r_end, c_start:c_end,:), 'InitialMagnification', 'fit'); 
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
exportgraphics(gcf, 'Fig1c.tif', 'Resolution', 600)

%%
load(imageFolder+'disp_map_'+string(11)+'.mat', 'disp_map');
createfigure(disp_map)
%% paper 3 figure 1.def
im = Tru_Sample_E_Im{11};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
colormap(pmkmp(128,'CubicL'));
clim([0,40]);
c = colorbar;
c.Ticks = [0,20,40]; % Explicit numbers to show
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
c_pos = c.Position; 
c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
set(gcf, 'Renderer', 'painters');
%exportgraphics(gcf, 'Fig1f.tif', 'Resolution', 600)
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig1f.pdf', 'ContentType', 'vector');

im = -Tru_Sample_Strain_Im{11};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
clim([0,1.0]);
c = colorbar;
c.Ticks = [0,0.5,1.0]; % Explicit numbers to show
%colorcet('L4');
colormap(flipud(colorcet('L4')));
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
c_pos = c.Position; 
c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
set(gcf, 'Renderer', 'painters');
%exportgraphics(gcf, 'Fig1e.tif', 'Resolution', 600)
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig1e.pdf', 'ContentType', 'vector');

im = -Tru_Layer_Stress_Im{11};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
imagesc(im)
clim([0,10]);
c = colorbar;
c.Ticks = [0,5,10]; % Explicit numbers to show
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
c_pos = c.Position; 
c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
%exportgraphics(gcf, 'Fig1d.tif', 'Resolution', 600)
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig1d.pdf', 'ContentType', 'vector');
%% Scale
im = Distance_Maps{11};
SPACING_mm_pix = [0.001009*abs(mean2(im))+0.020954,0.001009*abs(mean2(im))+0.020954];
FOV_mm = SPACING_mm_pix .* size(im);
disp(SPACING_mm_pix)
%% paper 3 figure 4 part 1
n = 11; % 1,4,8,11
im = Tru_Sample_E_Im{n};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
colormap(pmkmp(128,'CubicL'));
clim([0,40]);
c = colorbar;
c.Ticks = [0,20,40]; % Explicit numbers to show
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
c_pos = c.Position; 
c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
hold on
im = imgaussfilt(im,20);
[dIm_dx, dIm_dy] = gradient(im);
grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
L = del2(im);
target_gradient = 0.9 * max(grad_mag(:)); 
C = contourc(L,[0,0]);
if ~isempty(C)
    idx = 1;
    while idx < size(C, 2)
        contour_value = C(1, idx);
        num_points = C(2, idx);
        x_coords = C(1, idx+1 : idx+num_points);
        y_coords = C(2, idx+1 : idx+num_points);
        is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                    (abs(y_coords(1) - y_coords(end)) < 1e-3);
        if is_closed && (num_points > 420) 
            plot(x_coords, y_coords, 'r-', 'LineWidth', 0.5);
        end
        idx = idx + num_points + 1;
    end
end
hold off
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4g.pdf', 'ContentType', 'vector');
%% paper 3 figure 4 part 2
N = (2*[1,4,8,11]-1); % 1,4,8,11
n = N(4);
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
%imshow(rgb2gray(im(r_start:r_end, c_start:c_end,:)));
imshow(im(r_start:r_end, c_start:c_end,:)); 
set(gca, 'XTick', [], 'YTick', []);
im = Tru_Sample_E_Im{(n+1)/2};
hold on;
im = imgaussfilt(im,20);
L = del2(im);
C = contourc(L,[0,0]);
if ~isempty(C)
    idx = 1;
    while idx < size(C, 2)
        contour_value = C(1, idx);
        num_points = C(2, idx);
        x_coords = C(1, idx+1 : idx+num_points);
        y_coords = C(2, idx+1 : idx+num_points);
        is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                    (abs(y_coords(1) - y_coords(end)) < 1e-3);
        if is_closed && (num_points > 420) 
            plot(x_coords, y_coords, 'r-', 'LineWidth', 0.5);
        end
        idx = idx + num_points + 1;
    end
end
axis equal;
axis tight;
axis off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
hold off
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4h.pdf', 'ContentType', 'vector');
%% paper 3 figure 4
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
t = tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = [1,4,8,11]
    ax = nexttile;
    im = Tru_Sample_E_Im{n};
    imagesc(im);
    colormap(pmkmp(128,'CubicL'));
    hold on;
    clim([0,40]);
    colorbar;
    %axis equal;
    axis(ax, 'image');
    set(gca, 'XTick', [], 'YTick', []);

    % 2. Compute spatial gradients after smoothing
    im = imgaussfilt(im,20);
    [dIm_dx, dIm_dy] = gradient(im);
    
    % 3. Calculate Gradient Magnitude
    grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
    %imagesc(grad_mag)
    L = del2(im);
    % 4. Define a threshold for the "largest" gradient loop
    % We will look for a contour at 50% of the maximum gradient in this image.
    % You can adjust this fraction (e.g., 0.4 to 0.7) depending on your data.
    target_gradient = 0.9 * max(grad_mag(:)); 
    
    % 5. Extract contour lines mathematically without plotting them yet
    % contourc returns a contour matrix C
    C = contourc(L,[0,0]); %contourc(grad_mag, [target_gradient, target_gradient]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                plot(x_coords, y_coords, 'r-', 'LineWidth', 0.5);
                % --- NEW: Compute Average Inside and Outside the Loop ---
                [rows, cols] = size(im);
                
                % Create a binary mask where pixels inside the polygon are 1, outside are 0
                mask_inside = poly2mask(x_coords, y_coords, rows, cols);
                mask_outside = ~mask_inside; % Everything else
                %imagesc(mask_inside)
                % Extract the scalar values from the original image using logical indexing
                values_inside = im(mask_inside);
                values_outside = im(mask_outside);
                
                % Calculate the arithmetic means
                avg_inside = mean(values_inside);
                avg_outside = mean(values_outside);
                
                % Update the title to display both values (formatted to 1 decimal place)
                %title(sprintf('In: %.1f | Out: %.1f', avg_inside, avg_outside));
            end
            
            idx = idx + num_points + 1;
        end
    end

    %all_pixels = im(:);
    %sorted_pixels = sort(all_pixels, 'descend');
    %num_to_average = min(100, length(sorted_pixels));
    %top_100_avg = mean(sorted_pixels(1:num_to_average));
    %title(string(top_100_avg))
    %title(string(mean(mean(im))))
    hold off;
end
%% paper 3 figure
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
t = tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = (2*[1,4,8,11]-1) %1:2:23
    ax = nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    %imshow(rgb2gray(im(r_start:r_end, c_start:c_end,:)));
    imshow(im(r_start:r_end, c_start:c_end,:)); 
    set(gca, 'XTick', [], 'YTick', []);
    %title(string((n+1)/2))

    im = Tru_Sample_E_Im{(n+1)/2};
    hold on;
    axis(ax, 'image');

    % 2. Compute laplacian after smoothing
    im = imgaussfilt(im,20);
    L = del2(im);
    C = contourc(L,[0,0]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                plot(x_coords, y_coords, 'r-', 'LineWidth', 0.5);
            end
            idx = idx + num_points + 1;
        end
    end
end

%% paper 3 figure
%figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
%t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
avg_in = [];
avg_out = [];
std_in = [];
std_out = [];
avg2_in = [];
avg2_out = [];
std2_in = [];
std2_out = [];
std_ls = [];
max_in = [];
mls = [];
for n = 1:12
    %ax = nexttile;
    im = Tru_Sample_E_Im{n};
    im2 = Tru_Layer_Stress_Im{n};
    mls = [mls mean2(Tru_Layer_Strain_Im{n})];
    std_ls = [std_ls std2(Tru_Layer_Strain_Im{n})];
    %imagesc(im); 
    %hold on;
    %clim([0,40]);
    %colorbar;
    %axis equal;
    %axis(ax, 'image');
    %set(gca, 'XTick', [], 'YTick', []);

    % 2. Compute spatial gradients after smoothing
    im = imgaussfilt(im,20);
    [dIm_dx, dIm_dy] = gradient(im);
    
    % 3. Calculate Gradient Magnitude
    grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
    %imagesc(grad_mag)
    L = del2(im);
    % 4. Define a threshold for the "largest" gradient loop
    % We will look for a contour at 50% of the maximum gradient in this image.
    % You can adjust this fraction (e.g., 0.4 to 0.7) depending on your data.
    target_gradient = 0.9 * max(grad_mag(:)); 
    
    % 5. Extract contour lines mathematically without plotting them yet
    % contourc returns a contour matrix C
    C = contourc(L,[0,0]); %contourc(grad_mag, [target_gradient, target_gradient]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                %plot(x_coords, y_coords, 'r-', 'LineWidth', 1);
                % --- NEW: Compute Average Inside and Outside the Loop ---
                [rows, cols] = size(im);
                
                % Create a binary mask where pixels inside the polygon are 1, outside are 0
                mask_inside = poly2mask(x_coords, y_coords, rows, cols);
                mask_outside = ~mask_inside; % Everything else

                % erode by 500um on both regions from boundary
                exclusion_radius = 21; % pixels
                se = strel('disk', exclusion_radius);
                mask_inside = imerode(mask_inside, se);
                mask_outside = mask_outside & ~imdilate(mask_inside, se);

                %imagesc(mask_inside)
                % Extract the scalar values from the original image using logical indexing
                values_inside = im(mask_inside);
                values_outside = im(mask_outside);
                values_inside2 = im2(mask_inside);
                values_outside2 = im2(mask_outside);
                
                % Calculate the arithmetic means
                avg_inside = mean(values_inside);
                avg_outside = mean(values_outside);
                std_inside = std(values_inside);
                std_outside = std(values_outside);

                avg_inside2 = mean(values_inside2);
                avg_outside2 = mean(values_outside2);
                std_inside2 = std(values_inside2);
                std_outside2 = std(values_outside2);
                
                % Update the title to display both values (formatted to 1 decimal place)
                %title(sprintf('In: %.1f | Out: %.1f', avg_inside, avg_outside));
            end
            
            idx = idx + num_points + 1;
        end
    end

    all_pixels = im(:);
    sorted_pixels = sort(all_pixels, 'descend');
    num_to_average = min(100, length(sorted_pixels));
    top_100_avg = mean(sorted_pixels(1:num_to_average));
    %title(string(top_100_avg))
    %title(string(mean(mean(im))))
    %hold off;
    max_in = [ max_in top_100_avg ];
    avg_in = [ avg_in avg_inside ];
    avg_out = [ avg_out avg_outside ];
    std_in = [ std_in std_inside ];
    std_out = [ std_out std_outside ];
    avg2_in = [ avg2_in avg_inside2 ];
    avg2_out = [ avg2_out avg_outside2 ];
    std2_in = [ std2_in std_inside2 ];
    std2_out = [ std2_out std_outside2 ];
end

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
scatter(-log(1-0.2)*[1,1,1],-avg2_in(1:3),'square','green','HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],-avg2_in(4:6),'square','green','HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],-avg2_in(7:9),'square','green','HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],-avg2_in(10:12),'square','green','DisplayName','Column')

scatter(-log(1-0.2)*[1,1,1],-avg2_out(1:3),'blue','HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],-avg2_out(4:6),'blue','HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],-avg2_out(7:9),'blue','HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],-avg2_out(10:12),'blue','DisplayName','Background')
hold off
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
xlabel('System strain')
ylabel('Mean stress (kPa)')
%title(Materials{nM});
lgd=legend('Location','southeast','FontSize',11); %,'Position', [0.275,0.78,0.1,0.1]);
lgd.ItemTokenSize = [10, 18];
xlim([0,1]);
xticks(0:0.2:1);
set(gca, 'XTickLabelRotation', 0);
ylim([0,8]);
grid off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
drawnow; 
pos = lgd.Position;
lgd.Location = 'none';
lgd.Position = [pos(1) + 0.02, pos(2) - 0.02, pos(3), pos(4)];
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
fontsize(lgd,11,"points")
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4j.pdf', 'ContentType', 'vector'); %check erosion

%% paper 3 figure
%figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
%t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
avg_in = [];
avg_out = [];
std_in = [];
std_out = [];
avg2_in = [];
avg2_out = [];
std2_in = [];
std2_out = [];
avg3_in = [];
avg3_out = [];
std3_in = [];
std3_out = [];
std_ls = [];
max_in = [];
mls = [];
for n = 1:12
    %ax = nexttile;
    im = Tru_Sample_E_Im{n};
    im2 = Tru_Layer_Stress_Im{n};
    im3 = Tru_Sample_Strain_Im{n};
    mls = [mls mean2(Tru_Layer_Strain_Im{n})];
    std_ls = [std_ls std2(Tru_Layer_Strain_Im{n})];
    %imagesc(im); 
    %hold on;
    %clim([0,40]);
    %colorbar;
    %axis equal;
    %axis(ax, 'image');
    %set(gca, 'XTick', [], 'YTick', []);

    % 2. Compute spatial gradients after smoothing
    im = imgaussfilt(im,20);
    [dIm_dx, dIm_dy] = gradient(im);
    
    % 3. Calculate Gradient Magnitude
    grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
    %imagesc(grad_mag)
    L = del2(im);
    % 4. Define a threshold for the "largest" gradient loop
    % We will look for a contour at 50% of the maximum gradient in this image.
    % You can adjust this fraction (e.g., 0.4 to 0.7) depending on your data.
    target_gradient = 0.9 * max(grad_mag(:)); 
    
    % 5. Extract contour lines mathematically without plotting them yet
    % contourc returns a contour matrix C
    C = contourc(L,[0,0]); %contourc(grad_mag, [target_gradient, target_gradient]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                %plot(x_coords, y_coords, 'r-', 'LineWidth', 1);
                % --- NEW: Compute Average Inside and Outside the Loop ---
                [rows, cols] = size(im);
                
                % Create a binary mask where pixels inside the polygon are 1, outside are 0
                mask_inside = poly2mask(x_coords, y_coords, rows, cols);
                mask_outside = ~mask_inside; % Everything else

                % erode by 500um on both regions from boundary
                exclusion_radius = 21; % pixels
                se = strel('disk', exclusion_radius);
                mask_inside = imerode(mask_inside, se);
                mask_outside = mask_outside & ~imdilate(mask_inside, se);
                
                %imagesc(mask_inside)
                % Extract the scalar values from the original image using logical indexing
                values_inside = im(mask_inside);
                values_outside = im(mask_outside);
                values_inside2 = im2(mask_inside);
                values_outside2 = im2(mask_outside);
                values_inside3 = im3(mask_inside);
                values_outside3 = im3(mask_outside);
                
                % Calculate the arithmetic means
                avg_inside = mean(values_inside);
                avg_outside = mean(values_outside);
                std_inside = std(values_inside);
                std_outside = std(values_outside);

                avg_inside2 = mean(values_inside2);
                avg_outside2 = mean(values_outside2);
                std_inside2 = std(values_inside2);
                std_outside2 = std(values_outside2);

                avg_inside3 = mean(values_inside3);
                avg_outside3 = mean(values_outside3);
                std_inside3 = std(values_inside3);
                std_outside3 = std(values_outside3);
                
                % Update the title to display both values (formatted to 1 decimal place)
                %title(sprintf('In: %.1f | Out: %.1f', avg_inside, avg_outside));
            end
            
            idx = idx + num_points + 1;
        end
    end

    all_pixels = im(:);
    sorted_pixels = sort(all_pixels, 'descend');
    num_to_average = min(100, length(sorted_pixels));
    top_100_avg = mean(sorted_pixels(1:num_to_average));
    %title(string(top_100_avg))
    %title(string(mean(mean(im))))
    %hold off;
    max_in = [ max_in top_100_avg ];
    avg_in = [ avg_in avg_inside ];
    avg_out = [ avg_out avg_outside ];
    std_in = [ std_in std_inside ];
    std_out = [ std_out std_outside ];
    avg2_in = [ avg2_in avg_inside2 ];
    avg2_out = [ avg2_out avg_outside2 ];
    std2_in = [ std2_in std_inside2 ];
    std2_out = [ std2_out std_outside2 ];
    avg3_in = [ avg3_in avg_inside3 ];
    avg3_out = [ avg3_out avg_outside3 ];
    std3_in = [ std3_in std_inside3 ];
    std3_out = [ std3_out std_outside3 ];
end

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
scatter(-log(1-0.2)*[1,1,1],(avg_in(1:3)-avg_out(1:3))./std_out(1:3),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],(avg_in(4:6)-avg_out(4:6))./std_out(4:6),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],(avg_in(7:9)-avg_out(7:9))./std_out(7:9),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],(avg_in(10:12)-avg_out(10:12))./std_out(10:12),'*','MarkerEdgeColor', [0.5 0 0.5],'DisplayName','Elasticity')

scatter(-log(1-0.2)*[1,1,1],-(avg2_in(1:3)-avg2_out(1:3))./std2_out(1:3),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],-(avg2_in(4:6)-avg2_out(4:6))./std2_out(4:6),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],-(avg2_in(7:9)-avg2_out(7:9))./std2_out(7:9),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],-(avg2_in(10:12)-avg2_out(10:12))./std2_out(10:12),'o','MarkerEdgeColor',[0.8 0.8 0],'DisplayName','Stress')
hold off
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
xlabel('System strain')
ylabel('CNR')
%title(Materials{nM});
lgd=legend('Location','southwest','FontSize',11); %,'Position', [0.275,0.78,0.1,0.1]);
lgd.ItemTokenSize = [10, 18];
xlim([0,1]);
xticks(0:0.2:1);
set(gca, 'XTickLabelRotation', 0);
ylim([0, 10]);
grid off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
drawnow; 
pos = lgd.Position;
lgd.Location = 'none';
lgd.Position = [pos(1) - 0.02, pos(2) - 0.02, pos(3), pos(4)];
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
fontsize(lgd,11,"points")
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4l.pdf', 'ContentType', 'vector'); % check erosion
%%
disp(mean((avg_in-avg_out)./std_out))
disp(mean((avg2_in-avg2_out)./std2_out))

%%
fig = figure;
fig.GraphicsSmoothing = 'off';
hold on
scatter(log(1-0.2)*[1,1,1],(avg_in(1:3)-avg_out(1:3)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],(avg_in(4:6)-avg_out(4:6)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],(avg_in(7:9)-avg_out(7:9)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],(avg_in(10:12)-avg_out(10:12)),'*','MarkerEdgeColor', [0.5 0 0.5],'DisplayName','Elasticity')

scatter(log(1-0.2)*[1,1,1],-(avg2_in(1:3)-avg2_out(1:3)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],-(avg2_in(4:6)-avg2_out(4:6)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],-(avg2_in(7:9)-avg2_out(7:9)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],-(avg2_in(10:12)-avg2_out(10:12)),'o','yellow','DisplayName','Stress')

scatter(log(1-0.2)*[1,1,1],-(avg3_in(1:3)-avg3_out(1:3)),'x','green','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],-(avg3_in(4:6)-avg3_out(4:6)),'x','green','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],-(avg3_in(7:9)-avg3_out(7:9)),'x','green','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],-(avg3_in(10:12)-avg3_out(10:12)),'x','green','DisplayName','Stress')
hold off
xlabel('Bulk strain')
ylabel('contrast as difference')
grid on;
%%
fig = figure;
fig.GraphicsSmoothing = 'off';
hold on
scatter(log(1-0.2)*[1,1,1],std_out(1:3),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],std_out(4:6),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],std_out(7:9),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],std_out(10:12),'*','MarkerEdgeColor', [0.5 0 0.5],'DisplayName','Elasticity')

scatter(log(1-0.2)*[1,1,1],std2_out(1:3),'o','yellow','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],std2_out(4:6),'o','yellow','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],std2_out(7:9),'o','yellow','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],std2_out(10:12),'o','yellow','DisplayName','Stress')

scatter(log(1-0.2)*[1,1,1],std3_out(1:3),'x','green','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],std3_out(4:6),'x','green','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],std3_out(7:9),'x','green','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],std3_out(10:12),'x','green','DisplayName','Stress')
hold off
xlabel('Bulk strain')
ylabel('Noise')
grid on;
%%
fig = figure;
fig.GraphicsSmoothing = 'off';
hold on
scatter(log(1-0.2)*[1,1,1],(avg_in(1:3)./avg_out(1:3)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],(avg_in(4:6)./avg_out(4:6)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],(avg_in(7:9)./avg_out(7:9)),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],(avg_in(10:12)./avg_out(10:12)),'*','MarkerEdgeColor', [0.5 0 0.5],'DisplayName','Elasticity')

scatter(log(1-0.2)*[1,1,1],-(avg2_in(1:3)./avg2_out(1:3)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],-(avg2_in(4:6)./avg2_out(4:6)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],-(avg2_in(7:9)./avg2_out(7:9)),'o','yellow','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],-(avg2_in(10:12)./avg2_out(10:12)),'o','yellow','DisplayName','Stress')
hold off
xlabel('Bulk strain')
ylabel('Contrast as ratio')
grid on;
%%
fig = figure;
hold on
scatter(log(1-0.2)*[1,1,1],(avg_in(1:3)-avg_out(1:3))./std_out(1:3),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],(avg_in(4:6)-avg_out(4:6))./std_out(4:6),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],(avg_in(7:9)-avg_out(7:9))./std_out(7:9),'*','MarkerEdgeColor', [0.5 0 0.5],'HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],(avg_in(10:12)-avg_out(10:12))./std_out(10:12),'*','MarkerEdgeColor', [0.5 0 0.5],'DisplayName','Elasticity')

scatter(log(1-0.2)*[1,1,1],-(avg2_in(1:3)-avg2_out(1:3))./std2_out(1:3),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],-(avg2_in(4:6)-avg2_out(4:6))./std2_out(4:6),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],-(avg2_in(7:9)-avg2_out(7:9))./std2_out(7:9),'o','MarkerEdgeColor',[0.8 0.8 0],'HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],-(avg2_in(10:12)-avg2_out(10:12))./std2_out(10:12),'o','MarkerEdgeColor',[0.8 0.8 0],'DisplayName','Stress')

scatter(log(1-0.2)*[1,1,1],(avg3_in(1:3)-avg3_out(1:3))./std3_out(1:3),'x','green','HandleVisibility','off')
scatter(log(1-0.3)*[1,1,1],(avg3_in(4:6)-avg3_out(4:6))./std3_out(4:6),'x','green','HandleVisibility','off')
scatter(log(1-0.4)*[1,1,1],(avg3_in(7:9)-avg3_out(7:9))./std3_out(7:9),'x','green','HandleVisibility','off')
scatter(log(1-0.5)*[1,1,1],(avg3_in(10:12)-avg3_out(10:12))./std3_out(10:12),'x','green','DisplayName','Strain')
hold off
xlabel('Bulk strain')
ylabel('CNR (with strain)')
legend('Location','southwest'); %,'Position', [0.275,0.78,0.1,0.1]);
grid on;


%% paper 3 figure
%figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
%t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
avg_in = [];
std_in = [];
std_out = [];
std_ls = [];
avg_out = [];
max_in = [];
mls = [];
for n = 1:12
    %ax = nexttile;
    im = Tru_Sample_E_Im{n};
    mls = [mls mean2(Tru_Layer_Strain_Im{n})];
    std_ls = [std_ls std2(Tru_Layer_Strain_Im{n})];
    %imagesc(im); 
    %hold on;
    %clim([0,40]);
    %colorbar;
    %axis equal;
    %axis(ax, 'image');
    %set(gca, 'XTick', [], 'YTick', []);

    % 2. Compute spatial gradients after smoothing
    im = imgaussfilt(im,20);
    [dIm_dx, dIm_dy] = gradient(im);
    
    % 3. Calculate Gradient Magnitude
    grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
    %imagesc(grad_mag)
    L = del2(im);
    % 4. Define a threshold for the "largest" gradient loop
    % We will look for a contour at 50% of the maximum gradient in this image.
    % You can adjust this fraction (e.g., 0.4 to 0.7) depending on your data.
    target_gradient = 0.9 * max(grad_mag(:)); 
    
    % 5. Extract contour lines mathematically without plotting them yet
    % contourc returns a contour matrix C
    C = contourc(L,[0,0]); %contourc(grad_mag, [target_gradient, target_gradient]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                %plot(x_coords, y_coords, 'r-', 'LineWidth', 1);
                % --- NEW: Compute Average Inside and Outside the Loop ---
                [rows, cols] = size(im);
                
                % Create a binary mask where pixels inside the polygon are 1, outside are 0
                mask_inside = poly2mask(x_coords, y_coords, rows, cols);
                mask_outside = ~mask_inside; % Everything else

                % erode by 500um on both regions from boundary
                exclusion_radius = 21; % pixels
                se = strel('disk', exclusion_radius);
                mask_inside = imerode(mask_inside, se);
                mask_outside = mask_outside & ~imdilate(mask_inside, se);

                %imagesc(mask_inside)
                % Extract the scalar values from the original image using logical indexing
                values_inside = im(mask_inside);
                values_outside = im(mask_outside);
                
                % Calculate the arithmetic means
                avg_inside = mean(values_inside);
                avg_outside = mean(values_outside);
                std_inside = std(values_inside);
                std_outside = std(values_outside);
                
                % Update the title to display both values (formatted to 1 decimal place)
                %title(sprintf('In: %.1f | Out: %.1f', avg_inside, avg_outside));
            end
            
            idx = idx + num_points + 1;
        end
    end

    all_pixels = im(:);
    sorted_pixels = sort(all_pixels, 'descend');
    num_to_average = min(100, length(sorted_pixels));
    top_100_avg = mean(sorted_pixels(1:num_to_average));
    %title(string(top_100_avg))
    %title(string(mean(mean(im))))
    %hold off;
    max_in = [ max_in top_100_avg ];
    avg_in = [ avg_in avg_inside ];
    avg_out = [ avg_out avg_outside ];
    std_in = [ std_in std_inside ];
    std_out = [ std_out std_outside ];
end

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
%scatter(0.2*[1,1,1],max_in(1:3),'*','red','HandleVisibility','off')
%scatter(0.3*[1,1,1],max_in(4:6),'*','red','HandleVisibility','off')
%scatter(0.4*[1,1,1],max_in(7:9),'*','red','HandleVisibility','off')
%scatter(0.5*[1,1,1],max_in(10:12),'*','red','DisplayName','Max 100 Pixels')

scatter(-log(1-0.2)*[1,1,1],avg_in(1:3),'square','green','HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],avg_in(4:6),'square','green','HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],avg_in(7:9),'square','green','HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],avg_in(10:12),'square','green','DisplayName','Column')
%scatter(mls,avg_in,'square','green','DisplayName','Column')
%eb=errorbar(mls,avg_in, std_in, std_in, std_ls, std_ls,'HandleVisibility','off');
%eb.LineStyle = 'none';

scatter(-log(1-0.2)*[1,1,1],avg_out(1:3),'blue','HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],avg_out(4:6),'blue','HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],avg_out(7:9),'blue','HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],avg_out(10:12),'blue','DisplayName','Background')
%scatter(mls,avg_out,'blue','DisplayName','Background')
%eb=errorbar(mls,avg_out, std_out, std_out, std_ls, std_ls,'HandleVisibility','off');
%eb.LineStyle = 'none';

hold off
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
xlabel('System strain')
ylabel('Mean elasticity (kPa)')
%title(Materials{nM});
lgd=legend('Location','southwest','FontSize',11); %,'Position', [0.275,0.78,0.1,0.1]);
lgd.ItemTokenSize = [10, 18];
xlim([0,1]);
xticks(0:0.2:1);
set(gca, 'XTickLabelRotation', 0);
ylim([0, 30]);
grid off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
drawnow; 
pos = lgd.Position;
lgd.Location = 'none';
lgd.Position = [pos(1) - 0.02, pos(2) - 0.02, pos(3), pos(4)];
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
fontsize(lgd,11,"points")
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4k.pdf', 'ContentType', 'vector'); %check erosion
%%
disp(mean(avg_in))
disp(mean(avg_out))
disp(std(avg_in))
disp(std(avg_out))
%% paper 3 figure segmentation acc

%figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
%t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
avg_in = [];
avg_out = [];
mask_acc = [];
mask_masd = [];
for n = 1:12
    %ax = nexttile;
    im = Tru_Sample_E_Im{n};
    %imagesc(im); 
    %hold on;
    %clim([0,40]);
    %colorbar;
    %axis equal;
    %axis(ax, 'image');
    %set(gca, 'XTick', [], 'YTick', []);

    % 2. Compute spatial gradients after smoothing
    im = imgaussfilt(im,20);
    [dIm_dx, dIm_dy] = gradient(im);
    
    % 3. Calculate Gradient Magnitude
    grad_mag = sqrt(dIm_dx.^2 + dIm_dy.^2);
    %imagesc(grad_mag)
    L = del2(im);
    % 4. Define a threshold for the "largest" gradient loop
    % We will look for a contour at 50% of the maximum gradient in this image.
    % You can adjust this fraction (e.g., 0.4 to 0.7) depending on your data.
    target_gradient = 0.9 * max(grad_mag(:)); 
    
    % 5. Extract contour lines mathematically without plotting them yet
    % contourc returns a contour matrix C
    C = contourc(L,[0,0]); %contourc(grad_mag, [target_gradient, target_gradient]);
    
    % 6. Parse the contour matrix to find and plot the loops
    if ~isempty(C)
        idx = 1;
        while idx < size(C, 2)
            contour_value = C(1, idx);
            num_points = C(2, idx);
            
            x_coords = C(1, idx+1 : idx+num_points);
            y_coords = C(2, idx+1 : idx+num_points);
            
            % Check if the contour is a closed loop
            % (First point is approximately equal to the last point)
            is_closed = (abs(x_coords(1) - x_coords(end)) < 1e-3) && ...
                        (abs(y_coords(1) - y_coords(end)) < 1e-3);
            
            % Plot the loop if it's closed and large enough to not be noise
            if is_closed && (num_points > 420) 
                %plot(x_coords, y_coords, 'r-', 'LineWidth', 1);
                % --- NEW: Compute Average Inside and Outside the Loop ---
                [irows, icols] = size(im);
                
                % Create a binary mask where pixels inside the polygon are 1, outside are 0
                mask_inside = poly2mask(x_coords, y_coords, irows, icols);
                mask_outside = ~mask_inside; % Everything else
                %imagesc(mask_inside)
                % Extract the scalar values from the original image using logical indexing
                values_inside = im(mask_inside);
                values_outside = im(mask_outside);
                
                % Calculate the arithmetic means
                avg_inside = mean(values_inside);
                avg_outside = mean(values_outside);
                
                % Update the title to display both values (formatted to 1 decimal place)
                %title(sprintf('In: %.1f | Out: %.1f', avg_inside, avg_outside));
            end
            
            idx = idx + num_points + 1;
        end
    end

    %all_pixels = im(:);
    %sorted_pixels = sort(all_pixels, 'descend');
    %num_to_average = min(100, length(sorted_pixels));
    %top_100_avg = mean(sorted_pixels(1:num_to_average));
    %title(string(top_100_avg))
    %title(string(mean(mean(im))))
    %hold off;

    avg_in = [ avg_in avg_inside ];
    avg_out = [ avg_out avg_outside];

    im = imread(imageFolder+'im1_rect_image_'+string(2*n-1)+'.png');
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    im_gray = double(rgb2gray(im(r_start:r_end, c_start:c_end,:)));
    background = imgaussfilt(im_gray, 50);
    im_gray = im_gray - background;
    im_gray = medfilt2(im_gray, [10 10], 'symmetric');
    max_val = max(im_gray(:));
    min_val = min(im_gray(:));
    binary_cutoff = (max_val + min_val) / 2;
    mask = im_gray >= binary_cutoff;
    data_im = Tru_Sample_E_Im{n};
    [~, max_idx] = max(data_im(:));
    [seed_y, seed_x] = ind2sub(size(data_im), max_idx);
    mask = bwselect(mask, seed_x, seed_y, 8);
    mask = imfill(mask, 'holes');

    masd_pixels = calculateMASD(mask_inside, mask);
    %disp(masd_pixels)
    mask_masd = [mask_masd masd_pixels];
    mask_acc = [mask_acc sum(sum(mask==mask_inside))/(irows*icols)];
end

spacing = [];
for i = [1,4,7,10]
    im = Distance_Maps{i};
    SPACING_mm_pix = [0.001009*abs(mean2(im))+0.020954,0.001009*abs(mean2(im))+0.020954];
    FOV_mm = SPACING_mm_pix .* size(im);
    spacing = [spacing SPACING_mm_pix];
end

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
scatter(-log(1-0.2)*[1,1,1],1000*mask_masd(1:3)*spacing(1),'blue','HandleVisibility','off')
scatter(-log(1-0.3)*[1,1,1],1000*mask_masd(4:6)*spacing(2),'blue','HandleVisibility','off')
scatter(-log(1-0.4)*[1,1,1],1000*mask_masd(7:9)*spacing(3),'blue','HandleVisibility','off')
scatter(-log(1-0.5)*[1,1,1],1000*mask_masd(10:12)*spacing(4),'blue','HandleVisibility','off')
hold off
xlabel('System strain')
ylabel('MAD (\mum)')
%title(Materials{nM});
%legend('Location', 'best');
xlim([0,1]);
xticks(0:0.2:1);
set(gca, 'XTickLabelRotation', 0);
ylim([50, 150]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
grid off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig4i.pdf', 'ContentType', 'vector');
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.18, 0.28], 'Color', 'w');
hold on
scatter(0.2*[1,1,1],100*mask_acc(1:3),'blue','HandleVisibility','off')
scatter(0.3*[1,1,1],100*mask_acc(4:6),'blue','HandleVisibility','off')
scatter(0.4*[1,1,1],100*mask_acc(7:9),'blue','HandleVisibility','off')
scatter(0.5*[1,1,1],100*mask_acc(10:12),'blue','HandleVisibility','off')
hold off
xlabel('Combined system engineering strain')
ylabel('Segmentation accuracy (%)')
%title(Materials{nM});
%legend('Location', 'best');
xlim([0, 0.6]);
ylim([96.5, 100]);
grid on;

%%
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = 1:2:23
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    im_gray = double(rgb2gray(im(r_start:r_end, c_start:c_end,:)));
    background = imgaussfilt(im_gray, 50);
    im_gray = im_gray - background;
    im_gray = medfilt2(im_gray, [10 10], 'symmetric');
    max_val = max(im_gray(:));
    min_val = min(im_gray(:));
    binary_cutoff = (max_val + min_val) / 2;
    mask = im_gray >= binary_cutoff;
    data_im = Tru_Sample_E_Im{(n+1)/2};
    [~, max_idx] = max(data_im(:));
    [seed_y, seed_x] = ind2sub(size(data_im), max_idx);
    mask = bwselect(mask, seed_x, seed_y, 8);
    mask = imfill(mask, 'holes');
    imshow(mask);
    set(gca, 'XTick', [], 'YTick', []);
    title(string(sum(sum(data_im(mask)))/sum(sum(mask))))
end
%%
createfigure(Eng_Sample_Strain_Im{11})
%%
createfigure(Tru_Sample_E_Im{1})
%%
createfigure(-Tru_Layer_Stress_Im{2})
%%
createfigure(Engineering_Layer_Strain)
%%
createfigure(Engineering_Sample_Strain)
%%
figure;
plot(Tru_Sample_Strain, Tru_Sample_E, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Tru Sample Strain');
ylabel('Tru Sample Elasticity');
grid on;
%%
figure;
plot(Eng_Sample_Strain, Eng_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Eng Sample Strain');
ylabel('Eng Layer Stress');
grid on;
%%
figure;
plot(Tru_Sample_Strain, Tru_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Tru Sample Strain');
ylabel('Tru Layer Stress');
grid on;
%%
figure;
plot(Eng_Sample_Strain, Eng_Sample_E, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Eng Sample Strain');
ylabel('Eng Sample Elasticity');
grid on;
%%
figure;
plot(Eng_Layer_Strain, Eng_Sample_Strain, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Eng Layer Strain');
ylabel('Eng Sample Strain');
grid on;
%%
figure;
plot(Tru_Layer_Strain, Tru_Sample_Strain, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('True Layer Strain');
ylabel('True Sample Strain');
grid on;
%%
figure;
plot(Eng_Layer_Strain, Tru_Sample_E, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Engineering Layer Strain');
ylabel('True Sample Elasticity');
grid on;
%%
figure;
plot(Stage_Window - Image_Contact_Points, Eng_Sample_Strain, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Total Compressed Thickness');
ylabel('Engineering Sample Strain');
grid on;
%%
figure;
plot(Stage_Window - Image_Contact_Points, Eng_Layer_Strain, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Total Compressed Thickness');
ylabel('Engineering Layer Strain');
grid on;
%%
createfigure(Engineering_Sample_Elasticity)


