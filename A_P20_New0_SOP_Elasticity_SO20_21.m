%% Set file path
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_ExpNew0_SO20_21_20260428_14h02m07s\";

%% Input manually recorded distances
Stage_Window = 27.197;
Layer_Window = 22.365;
Sample_Window =21.551;

Layer_Thickness = Stage_Window - Layer_Window;
Sample_Thickness = Stage_Window - Sample_Window;
Expected_Total_Thickness = Layer_Thickness + Sample_Thickness;

Expected_Total_Contact_Point =  Stage_Window - Expected_Total_Thickness;
Actual_Total_Contact_Point =  Expected_Total_Contact_Point;

Image_Contact_Points = [18.82;18.82;18.82;19.89;19.89;19.89;20.91;20.91;20.91;21.96;21.96;21.96];
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

%% Paper Figure
figure('Units', 'normalized', 'Position', [0.0, 0.0, 0.4, 0.4], 'Color', 'w');
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = 10:12
    nexttile;
    im = Eng_Layer_Strain_Im{n};
    imagesc(im);
    %clim([0,60]);
    hcb = colorbar;
    hcb.FontSize = 12;
    set(gca, 'XTick', [], 'YTick', []);
    %title(string(mean(mean(im))))
    disp(mean2(im));
    disp(std2(im))
    axis equal;
    axis tight;
end
%% Scale
im = Distance_Maps{10};
SPACING_mm_pix = [0.001009*abs(mean2(im))+0.020954,0.001009*abs(mean2(im))+0.020954];
FOV_mm = SPACING_mm_pix .* size(im);
disp(FOV_mm)
%% Paper figures
im = Tru_Sample_E_Im{10};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
colormap(pmkmp(128,'CubicL'));
clim([0,60]);
%c = colorbar;
%c.Ticks = [0,20,40,60]; % Explicit numbers to show
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
%c_pos = c.Position; 
%c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
%exportgraphics(gcf, 'Fig1f.tif', 'Resolution', 600)
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig3g.pdf', 'ContentType', 'vector');

im = Tru_Sample_E_Im{11};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
colormap(pmkmp(128,'CubicL'));
clim([0,60]);
%c = colorbar;
%c.Ticks = [0,20,40]; % Explicit numbers to show
axis equal;
axis tight;
axis off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [0.5, 0.5, 2, 2.5];
%c_pos = c.Position; 
%c.Position = [c_pos(1) - 0.06, c_pos(2), c_pos(3), c_pos(4)];
%exportgraphics(gcf, 'Fig1f.tif', 'Resolution', 600)
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig3h.pdf', 'ContentType', 'vector');

im = Tru_Sample_E_Im{12};
fig = figure();
fig.Units = 'centimeters';
fig.Position = [5, 5, 4.0, 4.5]; % left, bot, width, height
imagesc(im)
colormap(pmkmp(128,'CubicL'));
clim([0,60]);
c = colorbar;
c.Ticks = [0,20,40,60]; % Explicit numbers to show
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
exportgraphics(gcf, 'Fig3i.pdf', 'ContentType', 'vector');

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
xlim([-0.3,0])
ylim([-14,0])
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
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8], 'Color', 'w');
t = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for n = 1:12
    nexttile;
    im = Tru_Sample_E_Im{n};
    imagesc(im); 
    clim([0,100]);
    colorbar;
    set(gca, 'XTick', [], 'YTick', []);
    title(string(mean(mean(im))))
end
%%
createfigure(Eng_Sample_Strain_Im{10})
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




