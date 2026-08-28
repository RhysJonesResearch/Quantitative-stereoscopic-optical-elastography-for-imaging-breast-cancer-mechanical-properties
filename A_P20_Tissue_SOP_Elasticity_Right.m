%% Set file path
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Right_20260513_15h39m59s\";

%% Input manually recorded distances
Stage_Window = 27.290;
Layer_Window = 21.866;
Sample_Window =23.172;

Layer_Thickness = Stage_Window - Layer_Window;
Sample_Thickness = Stage_Window - Sample_Window;
Expected_Total_Thickness = Layer_Thickness + Sample_Thickness;

Expected_Total_Contact_Point =  Stage_Window - Expected_Total_Thickness;
Actual_Total_Contact_Point =  Expected_Total_Contact_Point;

Image_Contact_Points = [17.888;18.888;19.888;20.888;21.888;18.025;19.025;20.024;21.025;18.517;19.52;20.52;21.52];
Compressed_Total_Thicknesses = Stage_Window - Image_Contact_Points;

%% Import distance maps
imRange = [4,6,8,10,12,14,16,18,20,22,24,26,28];
Distance_Maps = {};
for n = 1:size(imRange,2)
    load(imageFolder+'dist_map_hyp_'+string(imRange(n))+'.mat');
    Distance_Maps{end+1} = dist_map;
end
imRange = 1:size(imRange,2);
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
    Tru_Layer_Stress_Im{end+1} = True_Layer_Stress;

    Tru_Sample_E_Im{end+1} = True_Sample_Elasticity;
end

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
im = Distance_Maps{9};
SPACING_mm_pix = [0.001009*abs(mean2(im))+0.020954,0.001009*abs(mean2(im))+0.020954];
FOV_mm = SPACING_mm_pix .* size(im);
disp(FOV_mm)
%% Paper Figure 5
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 5, 5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
im = Tru_Sample_E_Im{13};
imagesc(im);
colormap(pmkmp(128,'CubicL'));
clim([0,30]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
colorbar;
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 3.25, 3.25];
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
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5e.pdf', 'ContentType', 'vector');

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 5, 5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
im = Tru_Sample_E_Im{9};
imagesc(im);
colormap(pmkmp(128,'CubicL'));
clim([0,30]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
colorbar;
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 3.25, 3.25];
hold on
ROI3_co = [145, 220, 50, 50];% [X_start, Y_start, width, height]
%ROI3_co = [125, 200, 50, 50];% [X_start, Y_start, width, height]
rectangle('Position', ROI3_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
ROI3 = im(ROI3_co(2):(ROI3_co(2)+ROI3_co(4)-1), ROI3_co(1):(ROI3_co(1)+ROI3_co(3)-1));
hold off
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5j.pdf', 'ContentType', 'vector');

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 5, 5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
im = -Tru_Layer_Stress_Im{13};
imagesc(im);
clim([0,6]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
colorbar;
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 3.25, 3.25];
hold on;
rectangle('Position', ROI1_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
sROI1 = im(ROI1_co(2):(ROI1_co(2)+ROI1_co(4)-1), ROI1_co(1):(ROI1_co(1)+ROI1_co(3)-1));
rectangle('Position', ROI2_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
sROI2 = im(ROI2_co(2):(ROI2_co(2)+ROI2_co(4)-1), ROI2_co(1):(ROI2_co(1)+ROI2_co(3)-1));
hold off
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5d.pdf', 'ContentType', 'vector');

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 5, 5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
im = -Tru_Layer_Stress_Im{9};
imagesc(im);
clim([0,6]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
colorbar;
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 3.25, 3.25];
hold on
rectangle('Position', ROI3_co, ...
          'EdgeColor', 'r', ...
          'LineWidth', 1.5, ...
          'HandleVisibility', 'off'); 
sROI3 = im(ROI3_co(2):(ROI3_co(2)+ROI3_co(4)-1), ROI3_co(1):(ROI3_co(1)+ROI3_co(3)-1));
hold off
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5i.pdf', 'ContentType', 'vector');
%%
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 7.75, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
e = Tru_Sample_E_Im{13};
j = Tru_Sample_E_Im{9};
all_rois = {e(:),j(:),ROI1(:),ROI2(:),ROI3(:)};
colors = [
    0.5 0.0 0.5;  % 
    0.5 0.0 0.5;  % 
    0.5 0.0 0.5;  % 
    0.5 0.0 0.5;  % 
    0.5 0.0 0.5]; %
daboxplot(all_rois,'outliers',0,'xtlabels',{'(e)','(j)','[1]','[2]','[3]'},'color',colors,'fill',0);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
xlim([0.5,5.5])
ylim([5,30])
ylabel('Elasticity (kPa)')
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 5.75, 4.25];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5l.pdf', 'ContentType', 'vector');

fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 7.75, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
e = -Tru_Layer_Stress_Im{13};
j = -Tru_Layer_Stress_Im{9};
sall_rois = {e(:),j(:),sROI1(:),sROI2(:),sROI3(:)};
colors = [
    0.9 0.9 0.0;  % 
    0.9 0.9 0.0;  % 
    0.9 0.9 0.0;  % 
    0.9 0.9 0.0;  % 
    0.9 0.9 0.0]; %
daboxplot(sall_rois,'outliers',0,'xtlabels',{'(d)','(i)','[1]','[2]','[3]'},'color',colors,'fill',0);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
xlim([0.5,5.5])
ylim([3,5])
ylabel('Stress (kPa)')
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 5.75, 4.25];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5k.pdf', 'ContentType', 'vector');
%%
disp(mean(sROI3)/mean(sROI2));
disp(mean(ROI3)/mean(ROI2));
%%
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
bars = {(mean(sROI3(:))-mean(sROI2(:)))/std(sROI2(:)),(mean(ROI3(:))-mean(ROI2(:)))/std(ROI2(:))};
colors = [
    0.0 0.7 0.0;  % 
    0.0 0.7 0.0;  % 
    0.0 0.7 0.0]; %
dabarplot(bars,'outliers',0,'xtlabels',{'Stress','Elasticity'},'color',colors);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
%xlim([0.5,3.5])
%ylim([3,5])
ylabel('CNR')
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5m.pdf', 'ContentType', 'vector');
%% Paper figure 5 b1
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 6.25, 6.25]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on

hold off
xlabel('Bulk strain')
ylabel('Mean stress (kPa)')
lgd=legend('Location','northwest');
lgd.ItemTokenSize = [10, 18];
xlim([-1.0, 0.0]);
xticks(-1:0.2:0.0);
set(gca, 'XTickLabelRotation', 0);
ylim([-8, 0]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
grid off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 4.25, 4.25];
drawnow; 
pos = lgd.Position;
lgd.Location = 'none';
lgd.Position = [pos(1) - 0.02, pos(2) + 0.02, pos(3), pos(4)];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig5b1.pdf', 'ContentType', 'vector');
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = -Tru_Layer_Stress_Im{13};
imagesc(im); 
clim([0,6]);
hcb = colorbar;
hcb.FontSize = 12;
set(gca, 'XTick', [], 'YTick', []);
%title(string(mean(mean(im))))
disp(mean2(im));
disp(std2(im))
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = -Tru_Sample_Strain_Im{13};
imagesc(im); 
clim([0,0.6]);
hcb = colorbar;
hcb.FontSize = 12;
colorcet('L4');
set(gca, 'XTick', [], 'YTick', []);
%title(string(mean(mean(im))))
disp(mean2(im));
disp(std2(im))
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = imread(imageFolder+'im1_rect_image_'+string(19)+'.png');
im = imread(imageFolder+'im1_rect_image_'+string(27)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
imshow(im(r_start:r_end, c_start:c_end,:)); 
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = Tru_Sample_E_Im{9};
imagesc(im);
colormap(pmkmp(128,'CubicL'));
clim([0,30]);
hcb = colorbar;
hcb.FontSize = 12;
set(gca, 'XTick', [], 'YTick', []);
%title(string(mean(mean(im))))
disp(mean2(im));
disp(std2(im))
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = -Tru_Layer_Stress_Im{9};
imagesc(im); 
clim([0,6]);
hcb = colorbar;
hcb.FontSize = 12;
set(gca, 'XTick', [], 'YTick', []);
%title(string(mean(mean(im))))
disp(mean2(im));
disp(std2(im))
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = -Tru_Sample_Strain_Im{9};
imagesc(im); 
clim([0,0.6]);
hcb = colorbar;
hcb.FontSize = 12;
colorcet('L4');
set(gca, 'XTick', [], 'YTick', []);
%title(string(mean(mean(im))))
disp(mean2(im));
disp(std2(im))
axis equal;
axis tight;
%%
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
im = imread(imageFolder+'im1_rect_image_'+string(19)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
imshow(im(r_start:r_end, c_start:c_end,:)); 
set(gca, 'XTick', [], 'YTick', []);
axis equal;
axis tight;

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
col = 150;
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
xlim([-0.4,0])
ylim([-17,0])
%% UV, 4,6,8,10,12,14,16,18,20,22,24,26,28
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.6], 'Color', 'w');
t = tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = [3,5,7,11,13,15,17,19,21,23,25,27] %5:2:27
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    imshow(im(r_start:r_end, c_start:c_end,:)); 
    set(gca, 'XTick', [], 'YTick', []);
    axis equal;
    axis tight;
    %title(string((n+1)/2))
end
%%
im = Tru_Sample_E_Im{9};
figure;
imagesc(im)
clim([0,150]);
colorbar;
axis equal;
axis tight;
title(string(mean(mean(im))))
%%
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.6], 'Color', 'w');
t = tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = [1,2,3,5,6,7,8,9,10,11,12,13] %2:13
    nexttile;
    im = Tru_Sample_E_Im{n};
    imagesc(im); 
    clim([0,25]);
    colorbar;
    set(gca, 'XTick', [], 'YTick', []);
    axis equal;
    axis tight;
    title(string(mean(mean(im))))
end

%%
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.8], 'Color', 'w');
t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = 2:13
    nexttile;
    im = Eng_Sample_Strain_Im{n};
    imagesc(im); 
    clim([-0.6,0]);
    colorbar;
    set(gca, 'XTick', [], 'YTick', []);
    title(string(mean(mean(im))))
end

%% Calculate Location 2
imRange = 6:9;
Sample_Thickness = Stage_Window - 18.025 - Distance_Maps{6};

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
Tru_Sample_Strain = {};
Tru_Layer_Stress = {};
Tru_Sample_Strain_Im = {};
Tru_Layer_Stress_Im = {};
Tru_Sample_E_Im = {};

for n = imRange
    Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(n);
    Compressed_Layer_Thickness = Distance_Maps{n};
    Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;
    
    Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) ./ Sample_Thickness; % compressive strain is negative
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
%%
createfigure(Distance_Maps{6})
%%
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.65], 'Color', 'w');
t = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = 1:4
    nexttile;
    im = Tru_Sample_E_Im{n};
    imagesc(im); 
    clim([0,100]);
    colorbar;
    set(gca, 'XTick', [], 'YTick', []);
    title(string(mean(mean(im))))
end
%% UV, 4,6,8,10,12,14,16,18,20,22,24,26,28
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.65], 'Color', 'w');
t = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = [3,4,8,10] %13:2:19
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    imshow(im(r_start:r_end, c_start:c_end,:)); 
    set(gca, 'XTick', [], 'YTick', []);
    title(string(n)); %(n+1)/2))
end




%% Find transform from white light at 0% strain to 30% strain
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Right_20260513_15h39m59s\";
im = imread(imageFolder+'im1_rect_image_'+string(27)+'.png'); % The zoomed/translated one, 19
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
moving = im(r_start:r_end, c_start:c_end,:);
%moving = imsharpen(moving);
im = imread(imageFolder+'im1_rect_image_'+string(21)+'.png');   % The reference, 13
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
fixed = im(r_start:r_end, c_start:c_end,:);

% Assume 'moving' is the image to be adjusted and 'fixed' is the target
adjustedFixed = zeros(size(fixed), 'like', fixed);

for channel = 1:3
    % Get the current channel
    mChan = double(moving(:,:,channel));
    fChan = double(fixed(:,:,channel));
    
    % Calculate Mean and Std
    meanM = mean2(mChan);
    stdM = std2(mChan);
    
    meanF = mean2(fChan);
    stdF = std2(fChan);
    
    % Match: Subtract mean, scale by std ratio, add target mean
    % Formula: ((Moving - MeanM) * (StdF / StdM)) + MeanF
    adjustedChan = ((fChan - meanF) * (stdM / stdF)) + meanM;
    
    % Clip values to valid range [0, 255] and store
    adjustedFixed(:,:,channel) = uint8(max(0, min(255, adjustedChan)));
end
%figure
%imshowpair(fixed, adjustedFixed, 'montage');
%title('Original vs Brightness/Contrast Matched');

fixed = adjustedFixed; %imsharpen(fixed);
% 1. Detect feature points
ptsMoving = detectKAZEFeatures(rgb2gray(moving),...
    'Threshold', 0.00001, 'Diffusion', 'sharpedge', ...    % Ignore weak features
    'NumOctaves', 8, ...      % Search through 4 levels of downsampling
    'NumScaleLevels', 4);     % Sub-levels within each octave
ptsFixed = detectKAZEFeatures(rgb2gray(fixed),...
    'Threshold', 0.00001, 'Diffusion', 'sharpedge', ...    % Ignore weak features
    'NumOctaves', 8, ...      % Search through 4 levels of downsampling
    'NumScaleLevels', 4);     % Sub-levels within each octave
[~, idx] = sort(ptsMoving.Scale, 'descend');
PtsMoving = ptsMoving(idx(1:round(end*0.5)));
[~, idx] = sort(ptsFixed.Scale, 'descend');
PtsFixed = ptsFixed(idx(1:round(end*0.5)));

% 2. Extract feature descriptors
[featuresMoving, validPtsMoving] = extractFeatures(rgb2gray(moving), ptsMoving);
[featuresFixed, validPtsFixed] = extractFeatures(rgb2gray(fixed), ptsFixed);

% 3. Match features
indexPairs = matchFeatures(featuresMoving, featuresFixed, ...
    'MaxRatio', 0.9, 'Unique',true, 'MatchThreshold', 30);
% Retrieve locations of matched points
matchedMoving = validPtsMoving(indexPairs(:,1));
matchedFixed = validPtsFixed(indexPairs(:,2));
% Note: The outputs 'inlierIdx' are logical arrays (true for good matches).
[tform, inlierIdx] = estimateGeometricTransform2D(...
    matchedMoving, matchedFixed, 'affine', ...
    'MaxNumTrials', 20000, ...  % Default is often 1000
    'MaxDistance', 20);         % Default is 1.5; higher is more "forgiving"
% 2. Use those logical indices to extract the actual coordinates
actualInlierMoving = matchedMoving(inlierIdx, :);
actualInlierFixed = matchedFixed(inlierIdx, :);
% 3. Now pass the actual coordinates to the visualization function
figure;
showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
title('Corrected Inlier Matches');
%%
[h, w, ~] = size(moving);
cornersMoving = [1, 1; w, 1; w, h; 1, h];
% Transform those corners to the original image's coordinate system
cornersOnFixed = transformPointsForward(tform, cornersMoving);
figure;
imshow(fixed);
hold on;
x = cornersOnFixed(:, 1);
y = cornersOnFixed(:, 2);
x_box = [x; x(1)];
y_box = [y; y(1)];
plot(x_box, y_box, 'g-', 'LineWidth', 3); % Green line
plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circles at corners
title('Overlap Area on Original Image');
hold off;
%%
figure;
showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
title('Overlap Bounding Box on Montage');
[h, w, ~] = size(moving);
cornersMoving = [1, 1; w, 1; w, h; 1, h];
cornersOnFixed = transformPointsForward(tform, cornersMoving);
shiftX = size(moving, 2);
x_montage = cornersOnFixed(:, 1) + shiftX;
y_montage = cornersOnFixed(:, 2);
x_box = [x_montage; x_montage(1)];
y_box = [y_montage; y_montage(1)];
hold on;
plot(x_box, y_box, 'y-', 'LineWidth', 3); % Yellow line for visibility
plot(x_montage, y_montage, 'ro', 'MarkerSize', 8); 
hold off;
%%
tformInverse = invert(tform);
movingRef = imref2d(size(moving));
fixedHeightMap = Stage_Window - 18.025 - Distance_Maps{6};
%fixedHeightMap = Stage_Window - 19.025 - Distance_Maps{7};
warpedLayerMap = imwarp(Distance_Maps{6}, tformInverse, 'OutputView', movingRef);
warpedHeightMap = imwarp(fixedHeightMap, tformInverse, 'OutputView', movingRef);
figure;
subplot(1,2,1); imshow(fixedHeightMap, []); title('Original Height Map'); clim([3.4,4.1]);
subplot(1,2,2); imshow(warpedHeightMap, []); title('Moving Img');clim([3.4,4.1]);
Sample_Thickness1 = warpedHeightMap;
%%
n=9;
Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(n);
Compressed_Layer_Thickness = Distance_Maps{n};
Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;

Engineering_Layer_Strain = -(Layer_Thickness - Compressed_Layer_Thickness) / Layer_Thickness; % compressive strain is negative
True_Layer_Strain = log(1+Engineering_Layer_Strain);

Engineering_Layer_Stress = e_stress_from_e_strain_func(Engineering_Layer_Strain);
True_Layer_Stress = t_stress_from_e_strain_func(Engineering_Layer_Strain);

Init_True_Layer_Stress = t_stress_from_e_strain_func( -(Layer_Thickness - warpedLayerMap) / Layer_Thickness );
Init_True_Layer_Stress(Init_True_Layer_Stress > 0) = 0;
Sample_Thickness = Sample_Thickness1 - (Compressed_Sample_Thickness-Sample_Thickness1)./(True_Layer_Stress-Init_True_Layer_Stress).*Init_True_Layer_Stress;

Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) ./ Sample_Thickness; % compressive strain is negative
True_Sample_Strain = log(1+Engineering_Sample_Strain);

Engineering_Sample_Elasticity = Engineering_Layer_Stress ./ Engineering_Sample_Strain;
True_Sample_Elasticity = True_Layer_Stress ./ True_Sample_Strain;

Engineering_Layer_Elasticity = Engineering_Layer_Stress ./ Engineering_Layer_Strain;
True_Layer_Elasticity = True_Layer_Stress ./ True_Layer_Strain;
%%
im = True_Sample_Elasticity;
%im = Engineering_Sample_Strain;
%im = Sample_Thickness;
%im = Distance_Maps{7};
%im = Init_True_Layer_Stress;
%im = -(Layer_Thickness - warpedLayerMap) / Layer_Thickness;
figure;
imagesc(im)
%clim([3.35,4]);
colorbar;
axis equal;
axis tight;
title(string(mean(mean(im))))
%%
n = 13; % 19
im = imread(imageFolder+'im1_rect_image_'+string(n)+'.png');
window_radius = 25;
[rows, cols, ~] = size(im);
r_start = 1+window_radius;
r_end   = rows-window_radius;
c_start = 285;
c_end   = cols-window_radius;
im = im(r_start:r_end, c_start:c_end,:);
figure;
imshow(im)
axis equal;
axis tight;

%% Full process - account for surface roughness - loc 2
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Right_20260513_15h39m59s\";
n1 = 6;
%n2 = 4;
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.65], 'Color', 'w');
t = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n2 = [7,8,9]
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n2*2+1)+'.png'); % The zoomed/translated one, 19
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    moving = im(r_start:r_end, c_start:c_end,:);
    %moving = imsharpen(moving);
    im = imread(imageFolder+'im1_rect_image_'+string(13)+'.png');   % The reference, 13
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    fixed = im(r_start:r_end, c_start:c_end,:);
    fixed = imsharpen(fixed);

    % Assume 'moving' is the image to be adjusted and 'fixed' is the target
    adjustedFixed = zeros(size(fixed), 'like', fixed);
    for channel = 1:3
        mChan = double(moving(:,:,channel));
        fChan = double(fixed(:,:,channel));
        meanM = mean2(mChan);
        stdM = std2(mChan);
        meanF = mean2(fChan);
        stdF = std2(fChan);
        % Match: Subtract mean, scale by std ratio, add target mean
        % Formula: ((Moving - MeanM) * (StdF / StdM)) + MeanF
        adjustedChan = ((fChan - meanF) * (stdM / stdF)) + meanM;
        % Clip values to valid range [0, 255] and store
        adjustedFixed(:,:,channel) = uint8(max(0, min(255, adjustedChan)));
    end
    %figure
    %imshowpair(fixed, adjustedFixed, 'montage');
    %title('Original vs Brightness/Contrast Matched');

    %figure
    %imshowpair(moving, fixed, 'montage');
    %title('moving vs fixed');

    fixed = adjustedFixed;

    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(fixed, [], 3));
    [coeff, score] = pca(X);
    fixed_mono = mat2gray(reshape(score(:, 1), size(fixed, 1), size(fixed, 2)));
    fixed_final_prepped = adapthisteq(imgaussfilt(fixed_mono,0.5));
    PtsFixed = detectKAZEFeatures(fixed_final_prepped, 'Threshold', 0.00005);
    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(moving, [], 3));
    [coeff, score] = pca(X);
    %score = X*coeff;
    moving_mono = mat2gray(reshape(score(:, 1), size(moving, 1), size(moving, 2)));
    moving_final_prepped = adapthisteq(imgaussfilt(moving_mono,1.0));
    PtsMoving = detectKAZEFeatures(moving_final_prepped, 'Threshold', 0.00005);

    %figure
    %imshow(fixed_final_prepped)
    %hold on
    %plot(PtsFixed)
    %hold off
    %figure
    %imshow(moving_final_prepped)
    %hold on
    %plot(PtsMoving)
    %hold off
    
    % Extract features
    [featuresMoving, validPtsMoving] = extractFeatures(moving_final_prepped, PtsMoving);
    [featuresFixed, validPtsFixed] = extractFeatures(fixed_final_prepped, PtsFixed);
    
    % Match features
    [indexPairs,matchMetrics] = matchFeatures(featuresMoving, featuresFixed, ...
        'MaxRatio', 0.99, 'Unique',true, 'MatchThreshold', 15);
    % Retrieve locations of matched points
    matchedMoving = validPtsMoving(indexPairs(:,1));
    matchedFixed = validPtsFixed(indexPairs(:,2));

    gridSize = 20; 
    maxMatchesPerGrid = 2; % Keep only the best 2 matches per grid block
    locs = matchedMoving.Location; 
    gridX = floor(locs(:,1) / gridSize);
    gridY = floor(locs(:,2) / gridSize);
    [~, ~, gridIDs] = unique([gridX, gridY], 'rows'); 
    keepIdx = [];
    for i = 1:max(gridIDs)
        cellIdx = find(gridIDs == i);
        if ~isempty(cellIdx)
            [~, sortOrder] = sort(matchMetrics(cellIdx), 'ascend');
            numToKeep = min(length(cellIdx), maxMatchesPerGrid);
            keepIdx = [keepIdx; cellIdx(sortOrder(1:numToKeep))];
        end
    end
    spreadMoving = matchedMoving(keepIdx);
    spreadFixed = matchedFixed(keepIdx);   %put these back to reduce clusters

    [tform, inlierIdx] = estimateGeometricTransform2D(...
        spreadMoving, spreadFixed, 'affine', ...
        'MaxNumTrials', 10000, ...  % Default 1000
        'Confidence', 99, ...
        'MaxDistance', 10);         % Default 1.5; higher is more "forgiving"
    % Use logical indices to extract the actual coordinates
    actualInlierMoving = spreadMoving(inlierIdx, :);
    actualInlierFixed = spreadFixed(inlierIdx, :);
    % Pass actual coordinates to visualization
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Corrected Inlier Matches');
    
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    % Transform corners to original image's coordinate system
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    %figure;
    %imshow(fixed);
    %hold on;
    x = cornersOnFixed(:, 1);
    y = cornersOnFixed(:, 2);
    x_box = [x; x(1)];
    y_box = [y; y(1)];
    %plot(x_box, y_box, 'g-', 'LineWidth', 3); % Green line
    %plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circles at corners
    %title('Overlap Area on Original Image');
    %hold off;
    
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Overlap Bounding Box on Montage');
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    shiftX = size(moving, 2);
    x_montage = cornersOnFixed(:, 1) + shiftX;
    y_montage = cornersOnFixed(:, 2);
    x_box = [x_montage; x_montage(1)];
    y_box = [y_montage; y_montage(1)];
    %hold on;
    %plot(x_box, y_box, 'y-', 'LineWidth', 3); % Yellow line for visibility
    %plot(x_montage, y_montage, 'ro', 'MarkerSize', 8); 
    %hold off;
    
    tformInverse = invert(tform);
    movingRef = imref2d(size(moving));
    fixedHeightMap = Stage_Window - Image_Contact_Points(n1) - Distance_Maps{n1};
    warpedLayerMap = imwarp(Distance_Maps{n1}, tformInverse, 'OutputView', movingRef);
    warpedHeightMap = imwarp(fixedHeightMap, tformInverse, 'OutputView', movingRef);
    %figure;
    %subplot(1,2,1); imagesc(fixedHeightMap); title('Original Height Map'); clim([3,4.3]);axis equal;axis tight;
    %subplot(1,2,2); imagesc(warpedHeightMap); title('Moving Img');clim([3,4.3]);axis equal;axis tight;
    Sample_Thickness1 = warpedHeightMap;
    
    %n2=4;
    Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(n2);
    Compressed_Layer_Thickness = Distance_Maps{n2};
    Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;
    
    Engineering_Layer_Strain = -(Layer_Thickness - Compressed_Layer_Thickness) / Layer_Thickness; % compressive strain is negative
    True_Layer_Strain = log(1+Engineering_Layer_Strain);
    
    Engineering_Layer_Stress = e_stress_from_e_strain_func(Engineering_Layer_Strain);
    True_Layer_Stress = t_stress_from_e_strain_func(Engineering_Layer_Strain);
    
    Init_True_Layer_Stress = t_stress_from_e_strain_func( -(Layer_Thickness - warpedLayerMap) / Layer_Thickness );
    Init_True_Layer_Stress(Init_True_Layer_Stress > 0) = 0;
    %next line is dodgey and should probably change
    %Sample_Thickness = Sample_Thickness1 - (Compressed_Sample_Thickness-Sample_Thickness1)./(True_Layer_Stress-Init_True_Layer_Stress).*Init_True_Layer_Stress;
    ToAdd = (Layer_Thickness - warpedLayerMap);
    ToAdd(ToAdd < 0) = 0;
    Sample_Thickness = Sample_Thickness1 + ToAdd; % Assumes mechanically matched layer and sample
    %Sample_Thickness = Sample_Thickness1; % Assumes sample infinitely stiff

    Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) ./ Sample_Thickness; % compressive strain is negative
    True_Sample_Strain = log(1+Engineering_Sample_Strain);
    
    Engineering_Sample_Elasticity = Engineering_Layer_Stress ./ Engineering_Sample_Strain;
    True_Sample_Elasticity = True_Layer_Stress ./ True_Sample_Strain;
    
    Engineering_Layer_Elasticity = Engineering_Layer_Stress ./ Engineering_Layer_Strain;
    True_Layer_Elasticity = True_Layer_Stress ./ True_Layer_Strain;
    
    im = True_Sample_Elasticity;
    %im = True_Layer_Stress;
    %im = Compressed_Sample_Thickness;
    %im = Distance_Maps{7};
    %im = -(Layer_Thickness - warpedLayerMap); % / Layer_Thickness; % 0 image layer strain
    %im = Sample_Thickness1;
    %figure;
    imagesc(im)
    clim([0,50]);
    colorbar;
    axis equal;
    axis tight;
    title(string(mean(mean(im))))
end

%% Full process - account for surface roughness - loc 3
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Right_20260513_15h39m59s\";
n1 = 10;
%n2 = 4;
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.65], 'Color', 'w');
t = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n2 = [11,12,13]
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n2*2+1)+'.png'); % The zoomed/translated one, 19
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    moving = im(r_start:r_end, c_start:c_end,:);
    %moving = imsharpen(moving);
    im = imread(imageFolder+'im1_rect_image_'+string(n1*2+1)+'.png');   % The reference, 13
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    fixed = im(r_start:r_end, c_start:c_end,:);
    fixed = imsharpen(fixed);

    % Assume 'moving' is the image to be adjusted and 'fixed' is the target
    adjustedFixed = zeros(size(fixed), 'like', fixed);
    for channel = 1:3
        mChan = double(moving(:,:,channel));
        fChan = double(fixed(:,:,channel));
        meanM = mean2(mChan);
        stdM = std2(mChan);
        meanF = mean2(fChan);
        stdF = std2(fChan);
        % Match: Subtract mean, scale by std ratio, add target mean
        % Formula: ((Moving - MeanM) * (StdF / StdM)) + MeanF
        adjustedChan = ((fChan - meanF) * (stdM / stdF)) + meanM;
        % Clip values to valid range [0, 255] and store
        adjustedFixed(:,:,channel) = uint8(max(0, min(255, adjustedChan)));
    end
    %figure
    %imshowpair(fixed, adjustedFixed, 'montage');
    %title('Original vs Brightness/Contrast Matched');

    %figure
    %imshowpair(moving, fixed, 'montage');
    %title('moving vs fixed');

    fixed = adjustedFixed;

    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(fixed, [], 3));
    [coeff, score] = pca(X);
    fixed_mono = mat2gray(reshape(score(:, 1), size(fixed, 1), size(fixed, 2)));
    fixed_final_prepped = adapthisteq(imgaussfilt(fixed_mono,0.5));
    PtsFixed = detectKAZEFeatures(fixed_final_prepped, 'Threshold', 0.00005);
    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(moving, [], 3));
    [coeff, score] = pca(X);
    %score = X*coeff;
    moving_mono = mat2gray(reshape(score(:, 1), size(moving, 1), size(moving, 2)));
    moving_final_prepped = adapthisteq(imgaussfilt(moving_mono,1.0));
    PtsMoving = detectKAZEFeatures(moving_final_prepped, 'Threshold', 0.00005);

    %figure
    %imshow(fixed_final_prepped)
    %hold on
    %plot(PtsFixed)
    %hold off
    %figure
    %imshow(moving_final_prepped)
    %hold on
    %plot(PtsMoving)
    %hold off
    
    % Extract features
    [featuresMoving, validPtsMoving] = extractFeatures(moving_final_prepped, PtsMoving);
    [featuresFixed, validPtsFixed] = extractFeatures(fixed_final_prepped, PtsFixed);
    
    % Match features
    [indexPairs,matchMetrics] = matchFeatures(featuresMoving, featuresFixed, ...
        'MaxRatio', 0.99, 'Unique',true, 'MatchThreshold', 15);
    % Retrieve locations of matched points
    matchedMoving = validPtsMoving(indexPairs(:,1));
    matchedFixed = validPtsFixed(indexPairs(:,2));

    gridSize = 20; 
    maxMatchesPerGrid = 2; % Keep only the best 2 matches per grid block
    locs = matchedMoving.Location; 
    gridX = floor(locs(:,1) / gridSize);
    gridY = floor(locs(:,2) / gridSize);
    [~, ~, gridIDs] = unique([gridX, gridY], 'rows'); 
    keepIdx = [];
    for i = 1:max(gridIDs)
        cellIdx = find(gridIDs == i);
        if ~isempty(cellIdx)
            [~, sortOrder] = sort(matchMetrics(cellIdx), 'ascend');
            numToKeep = min(length(cellIdx), maxMatchesPerGrid);
            keepIdx = [keepIdx; cellIdx(sortOrder(1:numToKeep))];
        end
    end
    spreadMoving = matchedMoving(keepIdx);
    spreadFixed = matchedFixed(keepIdx);   %put these back to reduce clusters

    [tform, inlierIdx] = estimateGeometricTransform2D(...
        spreadMoving, spreadFixed, 'affine', ...
        'MaxNumTrials', 10000, ...  % Default 1000
        'Confidence', 99, ...
        'MaxDistance', 10);         % Default 1.5; higher is more "forgiving"
    % Use logical indices to extract the actual coordinates
    actualInlierMoving = spreadMoving(inlierIdx, :);
    actualInlierFixed = spreadFixed(inlierIdx, :);
    % Pass actual coordinates to visualization
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Corrected Inlier Matches');
    
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    % Transform corners to original image's coordinate system
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    %figure;
    %imshow(fixed);
    %hold on;
    x = cornersOnFixed(:, 1);
    y = cornersOnFixed(:, 2);
    x_box = [x; x(1)];
    y_box = [y; y(1)];
    %plot(x_box, y_box, 'g-', 'LineWidth', 3); % Green line
    %plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circles at corners
    %title('Overlap Area on Original Image');
    %hold off;
    
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Overlap Bounding Box on Montage');
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    shiftX = size(moving, 2);
    x_montage = cornersOnFixed(:, 1) + shiftX;
    y_montage = cornersOnFixed(:, 2);
    x_box = [x_montage; x_montage(1)];
    y_box = [y_montage; y_montage(1)];
    %hold on;
    %plot(x_box, y_box, 'y-', 'LineWidth', 3); % Yellow line for visibility
    %plot(x_montage, y_montage, 'ro', 'MarkerSize', 8); 
    %hold off;
    
    tformInverse = invert(tform);
    movingRef = imref2d(size(moving));
    fixedHeightMap = Stage_Window - Image_Contact_Points(n1) - Distance_Maps{n1};
    warpedLayerMap = imwarp(Distance_Maps{n1}, tformInverse, 'OutputView', movingRef);
    warpedHeightMap = imwarp(fixedHeightMap, tformInverse, 'OutputView', movingRef);
    %figure;
    %subplot(1,2,1); imagesc(fixedHeightMap); title('Original Height Map'); clim([3,4.3]);axis equal;axis tight;
    %subplot(1,2,2); imagesc(warpedHeightMap); title('Moving Img');clim([3,4.3]);axis equal;axis tight;
    Sample_Thickness1 = warpedHeightMap;
    
    %n2=4;
    Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(n2);
    Compressed_Layer_Thickness = Distance_Maps{n2};
    Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;
    
    Engineering_Layer_Strain = -(Layer_Thickness - Compressed_Layer_Thickness) / Layer_Thickness; % compressive strain is negative
    True_Layer_Strain = log(1+Engineering_Layer_Strain);
    
    Engineering_Layer_Stress = e_stress_from_e_strain_func(Engineering_Layer_Strain);
    True_Layer_Stress = t_stress_from_e_strain_func(Engineering_Layer_Strain);
    
    Init_True_Layer_Stress = t_stress_from_e_strain_func( -(Layer_Thickness - warpedLayerMap) / Layer_Thickness );
    Init_True_Layer_Stress(Init_True_Layer_Stress > 0) = 0;
    %next line is dodgey and should probably change
    %Sample_Thickness = Sample_Thickness1 - (Compressed_Sample_Thickness-Sample_Thickness1)./(True_Layer_Stress-Init_True_Layer_Stress).*Init_True_Layer_Stress;
    ToAdd = (Layer_Thickness - warpedLayerMap);
    ToAdd(ToAdd < 0) = 0;
    Sample_Thickness = Sample_Thickness1 + ToAdd; % Assumes mechanically matched layer and sample
    %Sample_Thickness = Sample_Thickness1; % Assumes sample infinitely stiff

    Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) ./ Sample_Thickness; % compressive strain is negative
    True_Sample_Strain = log(1+Engineering_Sample_Strain);
    
    Engineering_Sample_Elasticity = Engineering_Layer_Stress ./ Engineering_Sample_Strain;
    True_Sample_Elasticity = True_Layer_Stress ./ True_Sample_Strain;
    
    Engineering_Layer_Elasticity = Engineering_Layer_Stress ./ Engineering_Layer_Strain;
    True_Layer_Elasticity = True_Layer_Stress ./ True_Layer_Strain;
    
    im = True_Sample_Elasticity;
    %im = True_Layer_Stress;
    %im = Compressed_Sample_Thickness;
    %im = Distance_Maps{7};
    %im = -(Layer_Thickness - warpedLayerMap); % / Layer_Thickness; % 0 image layer strain
    %im = Sample_Thickness1;
    %figure;
    imagesc(im)
    clim([0,50]);
    colorbar;
    axis equal;
    axis tight;
    title(string(mean(mean(im))))
end

%% Full process - account for surface roughness - loc 1
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Right_20260513_15h39m59s\";
n1 = 1;
%n2 = 4;
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.35, 0.65], 'Color', 'w');
t = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n2 = [2,3,4]
    nexttile;
    im = imread(imageFolder+'im1_rect_image_'+string(n2*2+1)+'.png'); % The zoomed/translated one, 19
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    moving = im(r_start:r_end, c_start:c_end,:);
    %moving = imsharpen(moving);
    im = imread(imageFolder+'im1_rect_image_'+string(3)+'.png');   % The reference, 13
    window_radius = 25;
    [rows, cols, ~] = size(im);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285;
    c_end   = cols-window_radius;
    fixed = im(r_start:r_end, c_start:c_end,:);
    fixed = imsharpen(fixed);

    % Assume 'moving' is the image to be adjusted and 'fixed' is the target
    adjustedFixed = zeros(size(fixed), 'like', fixed);
    for channel = 1:3
        mChan = double(moving(:,:,channel));
        fChan = double(fixed(:,:,channel));
        meanM = mean2(mChan);
        stdM = std2(mChan);
        meanF = mean2(fChan);
        stdF = std2(fChan);
        % Match: Subtract mean, scale by std ratio, add target mean
        % Formula: ((Moving - MeanM) * (StdF / StdM)) + MeanF
        adjustedChan = ((fChan - meanF) * (stdM / stdF)) + meanM;
        % Clip values to valid range [0, 255] and store
        adjustedFixed(:,:,channel) = uint8(max(0, min(255, adjustedChan)));
    end
    %figure
    %imshowpair(fixed, adjustedFixed, 'montage');
    %title('Original vs Brightness/Contrast Matched');

    %figure
    %imshowpair(moving, fixed, 'montage');
    %title('moving vs fixed');

    fixed = adjustedFixed;

    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(fixed, [], 3));
    [coeff, score] = pca(X);
    fixed_mono = mat2gray(reshape(score(:, 1), size(fixed, 1), size(fixed, 2)));
    fixed_final_prepped = adapthisteq(imgaussfilt(fixed_mono,0.5));
    PtsFixed = detectKAZEFeatures(fixed_final_prepped, 'Threshold', 0.00005);
    % Maximize contrast using PCA, adaptive hist, then detect feats
    X = double(reshape(moving, [], 3));
    [coeff, score] = pca(X);
    %score = X*coeff;
    moving_mono = mat2gray(reshape(score(:, 1), size(moving, 1), size(moving, 2)));
    moving_final_prepped = adapthisteq(imgaussfilt(moving_mono,1.0));
    PtsMoving = detectKAZEFeatures(moving_final_prepped, 'Threshold', 0.00005);

    %figure
    %imshow(fixed_final_prepped)
    %hold on
    %plot(PtsFixed)
    %hold off
    %figure
    %imshow(moving_final_prepped)
    %hold on
    %plot(PtsMoving)
    %hold off
    
    % Extract features
    [featuresMoving, validPtsMoving] = extractFeatures(moving_final_prepped, PtsMoving);
    [featuresFixed, validPtsFixed] = extractFeatures(fixed_final_prepped, PtsFixed);
    
    % Match features
    [indexPairs,matchMetrics] = matchFeatures(featuresMoving, featuresFixed, ...
        'MaxRatio', 0.99, 'Unique',true, 'MatchThreshold', 15);
    % Retrieve locations of matched points
    matchedMoving = validPtsMoving(indexPairs(:,1));
    matchedFixed = validPtsFixed(indexPairs(:,2));

    gridSize = 20; 
    maxMatchesPerGrid = 2; % Keep only the best 2 matches per grid block
    locs = matchedMoving.Location; 
    gridX = floor(locs(:,1) / gridSize);
    gridY = floor(locs(:,2) / gridSize);
    [~, ~, gridIDs] = unique([gridX, gridY], 'rows'); 
    keepIdx = [];
    for i = 1:max(gridIDs)
        cellIdx = find(gridIDs == i);
        if ~isempty(cellIdx)
            [~, sortOrder] = sort(matchMetrics(cellIdx), 'ascend');
            numToKeep = min(length(cellIdx), maxMatchesPerGrid);
            keepIdx = [keepIdx; cellIdx(sortOrder(1:numToKeep))];
        end
    end
    spreadMoving = matchedMoving(keepIdx);
    spreadFixed = matchedFixed(keepIdx);   %put these back to reduce clusters

    [tform, inlierIdx] = estimateGeometricTransform2D(...
        spreadMoving, spreadFixed, 'affine', ...
        'MaxNumTrials', 30000, ...  % Default 1000
        'Confidence', 95, ...
        'MaxDistance', 20);         % Default 1.5; higher is more "forgiving"
    % Use logical indices to extract the actual coordinates
    actualInlierMoving = spreadMoving(inlierIdx, :);
    actualInlierFixed = spreadFixed(inlierIdx, :);
    % Pass actual coordinates to visualization
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Corrected Inlier Matches');
    
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    % Transform corners to original image's coordinate system
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    %figure;
    %imshow(fixed);
    %hold on;
    x = cornersOnFixed(:, 1);
    y = cornersOnFixed(:, 2);
    x_box = [x; x(1)];
    y_box = [y; y(1)];
    %plot(x_box, y_box, 'g-', 'LineWidth', 3); % Green line
    %plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Red circles at corners
    %title('Overlap Area on Original Image');
    %hold off;
    
    %figure;
    %showMatchedFeatures(moving, fixed, actualInlierMoving, actualInlierFixed, 'montage');
    %title('Overlap Bounding Box on Montage');
    [h, w, ~] = size(moving);
    cornersMoving = [1, 1; w, 1; w, h; 1, h];
    cornersOnFixed = transformPointsForward(tform, cornersMoving);
    shiftX = size(moving, 2);
    x_montage = cornersOnFixed(:, 1) + shiftX;
    y_montage = cornersOnFixed(:, 2);
    x_box = [x_montage; x_montage(1)];
    y_box = [y_montage; y_montage(1)];
    %hold on;
    %plot(x_box, y_box, 'y-', 'LineWidth', 3); % Yellow line for visibility
    %plot(x_montage, y_montage, 'ro', 'MarkerSize', 8); 
    %hold off;
    
    tformInverse = invert(tform);
    movingRef = imref2d(size(moving));
    fixedHeightMap = Stage_Window - Image_Contact_Points(n1) - Distance_Maps{n1};
    warpedLayerMap = imwarp(Distance_Maps{n1}, tformInverse, 'OutputView', movingRef);
    warpedHeightMap = imwarp(fixedHeightMap, tformInverse, 'OutputView', movingRef);
    %figure;
    %subplot(1,2,1); imagesc(fixedHeightMap); title('Original Height Map'); clim([3,4.3]);axis equal;axis tight;
    %subplot(1,2,2); imagesc(warpedHeightMap); title('Moving Img');clim([3,4.3]);axis equal;axis tight;
    Sample_Thickness1 = warpedHeightMap;
    
    %n2=4;
    Compressed_Total_Thickness = Stage_Window - Image_Contact_Points(n2);
    Compressed_Layer_Thickness = Distance_Maps{n2};
    Compressed_Sample_Thickness = Compressed_Total_Thickness - Compressed_Layer_Thickness;
    
    Engineering_Layer_Strain = -(Layer_Thickness - Compressed_Layer_Thickness) / Layer_Thickness; % compressive strain is negative
    True_Layer_Strain = log(1+Engineering_Layer_Strain);
    
    Engineering_Layer_Stress = e_stress_from_e_strain_func(Engineering_Layer_Strain);
    True_Layer_Stress = t_stress_from_e_strain_func(Engineering_Layer_Strain);
    
    Init_True_Layer_Stress = t_stress_from_e_strain_func( -(Layer_Thickness - warpedLayerMap) / Layer_Thickness );
    Init_True_Layer_Stress(Init_True_Layer_Stress > 0) = 0;
    %next line is dodgey and should probably change
    %Sample_Thickness = Sample_Thickness1 - (Compressed_Sample_Thickness-Sample_Thickness1)./(True_Layer_Stress-Init_True_Layer_Stress).*Init_True_Layer_Stress;
    ToAdd = (Layer_Thickness - warpedLayerMap);
    ToAdd(ToAdd < 0) = 0;
    Sample_Thickness = Sample_Thickness1 + ToAdd; % Assumes mechanically matched layer and sample
    %Sample_Thickness = Sample_Thickness1; % Assumes sample infinitely stiff

    Engineering_Sample_Strain = -(Sample_Thickness - Compressed_Sample_Thickness) ./ Sample_Thickness; % compressive strain is negative
    True_Sample_Strain = log(1+Engineering_Sample_Strain);
    
    Engineering_Sample_Elasticity = Engineering_Layer_Stress ./ Engineering_Sample_Strain;
    True_Sample_Elasticity = True_Layer_Stress ./ True_Sample_Strain;
    
    Engineering_Layer_Elasticity = Engineering_Layer_Stress ./ Engineering_Layer_Strain;
    True_Layer_Elasticity = True_Layer_Stress ./ True_Layer_Strain;
    
    im = True_Sample_Elasticity;
    %im = True_Layer_Stress;
    %im = Compressed_Sample_Thickness;
    %im = Distance_Maps{7};
    %im = -(Layer_Thickness - warpedLayerMap); % / Layer_Thickness; % 0 image layer strain
    %im = Sample_Thickness1;
    %figure;
    imagesc(im)
    clim([0,50]);
    colorbar;
    axis equal;
    axis tight;
    title(string(mean(mean(im))))
end
