%% Add Scripted_ncorr_2D_matlab to path
%% Add Inpaint_nans to path
%% 1. Undistort & Rectify
load('F:\Rhys\MATLAB Workspace\Probe_20\stereoParams.mat');
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe_20_DispDist_20260502_14h18m36s\";

imRange = 1:30; % must be increasing integers from 1
offset = 0; % used to change start of range in files
%imRange = [1];
for n = imRange
    left_fn = "im1_image_"+string(n+offset)+".png";
    right_fn = "im2_image_"+string(n+offset)+".png";
    left_fp = imageFolder+left_fn;
    right_fp = imageFolder+right_fn;
    left_img = imread(left_fp);
    right_img = imread(right_fp);

    [left_rect, right_rect] = rectifyStereoImages(left_img, right_img, stereoParams);

    imwrite(left_rect, imageFolder+"im1_rect_image_"+string(n+offset)+".png");
    imwrite(right_rect, imageFolder+"im2_rect_image_"+string(n+offset)+".png");
end

%% Visualise
figure
imshowpair(left_rect, right_rect, 'montage');
title('Rectified Stereo Pair with Horizontal Alignment Check');
hold on;
[height, width, ~] = size(left_rect);
yPositions = linspace(1, height, 10); % num lines at end
for i = 1:length(yPositions)
    line([0, 2*width], [yPositions(i), yPositions(i)], ...
         'Color', 'black', 'LineWidth', 0.8, 'LineStyle', '--');
end
hold off;
%% 2. Find Disparity

window_radius = 25; % used 25 for mc calibration
u_disp_array = {};

for n = imRange
    left_rect  = imread(imageFolder+"im1_rect_image_"+string(n+offset)+".png");
    right_rect = imread(imageFolder+"im2_rect_image_"+string(n+offset)+".png");
    
    [rows, cols, ~] = size(left_rect);
    r_start = 1+window_radius;
    r_end   = rows-window_radius;
    c_start = 285; % min = max(abs(disparity)), used 285 for mc calibration, will see error when plotting right image if too small
    c_end   = cols-window_radius;
    
    roi = false(rows, cols);
    roi(r_start:r_end, c_start:c_end) = true;
    
    global glob_row_m;
    glob_row_m = round(mean([r_start,r_end]));
    global glob_col_m;
    glob_col_m = round(mean([c_start,c_end]));
    rows = round(r_start+(r_end-r_start)/5):round((r_end-r_start)/5):(round(r_start+(r_end-r_start)*4/5)+1) ;
    cols = round(c_start+(c_end-c_start)/3):round((c_end-c_start)/3):(round(c_start+(c_end-c_start)*2/3)+1) ;
    global glob_seeds;
    glob_seeds = [[cols(1) rows(1)]; [cols(2) rows(1)];[cols(1) rows(2)]; [cols(2) rows(2)];[cols(1) rows(3)]; [cols(2) rows(3)];[cols(1) rows(4)]; [cols(2) rows(4)];];
    
    clear handles_ncorr
    handles_ncorr = ncorr;
    handles_ncorr.set_ref(left_rect)
    handles_ncorr.set_cur(right_rect)
    handles_ncorr.set_roi_ref(roi)
    sub_spacing = 0;
    handles_ncorr.set_dic_params(window_radius, sub_spacing)
    handles_ncorr.run_dic_auto()
    u_disp_array{end+1} = handles_ncorr.data_dic.displacements.plot_u_dic;
    handles_ncorr.close_auto()
    clear handles_ncorr
end
%% Visualise
n = 30;
u_disp = u_disp_array{n};
u_disp_nans = u_disp;
u_disp_nans(u_disp == 0) = NaN;
num_nans = sum(isnan(u_disp_nans(r_start:r_end,c_start:c_end)), 'all');
u_disp_no_nans = inpaint_nans(u_disp_nans(r_start:r_end,c_start:c_end),4);
createfigure(u_disp_no_nans)
avg_disp = round(mean2(u_disp_no_nans));
max_disp = -round(min(min(u_disp_no_nans)));
%% Visualise actual images ROI  (need to fix)
createfigure(left_rect(r_start:r_end,c_start:c_end))
createfigure(right_rect(r_start:r_end,c_start+avg_disp:c_end+avg_disp))

%% Treat data
X_cells = {};
X_no_smoothing = {};
for n = imRange
    u_disp_nans = u_disp_array{n};
    u_disp_nans(u_disp_array{n} == 0) = NaN;
    u_disp_no_nans = inpaint_nans(u_disp_nans(r_start:r_end,c_start:c_end),4);
    X_no_smoothing{end+1} = u_disp_no_nans;
    X_cells{end+1} = imgaussfilt(u_disp_no_nans, 15); % gaussian smooth size 15 for mc
end

%% Save disp_map_n
for n = 1:size(imRange,2)
    disp_map = X_cells{n};
    save(imageFolder+'disp_map_'+string(imRange(n))+'.mat', 'disp_map');
end
%% load disp_maps
imRange = 1:29;
X_cells = {};
for n = 1:30
    if n == 1
        continue
    end
    load(imageFolder+'disp_map_'+string(n)+'.mat', 'disp_map');
    X_cells{end+1} = disp_map;
end

%% 
% Y is distance of particles from window through silicone and X is measured 2D disparity images
Y_vals = 27.252 - [27.252;21.946;22.45;22.95;23.45;23.95;24.45;24.95;25.45;25.95;27.252;21.933;22.43;22.93;23.43;23.93;24.43;24.93;25.43;25.93;27.252;22.042;22.54;23.04;23.54;24.04;24.54;25.04;25.54;26.04];
Y_vals = 27.252 - [21.946;22.45;22.95;23.45;23.95;24.45;24.95;25.45;25.95;27.252;21.933;22.43;22.93;23.43;23.93;24.43;24.93;25.43;25.93;27.252;22.042;22.54;23.04;23.54;24.04;24.54;25.04;25.54;26.04];

X_stack = cat(3, X_cells{imRange}); % Rows x Cols x 10

%% Least squares linear fit
% Sums across the 3rd dimension
sum_X  = sum(X_stack, 3);
sum_X2 = sum(X_stack.^2, 3);

% We reshape Y_vals to (1x1x10) so it "broadcasts" across Rows x Cols.
Y_vec = reshape(Y_vals, 1, 1, imRange(end));
sum_XY = sum(X_stack .* Y_vec, 3);
sum_Y  = sum(Y_vals);

% Apply the Least Squares Formula (Vectorized)
denominator = (imRange(end) * sum_X2 - sum_X.^2);

% Calculate M (Slope Matrix)
M = (imRange(end) * sum_XY - sum_X * sum_Y) ./ denominator;

% Calculate C (Intercept Matrix)
C = (sum_Y - M .* sum_X) / imRange(end);

%% Visualise fit
% 1. Define your coordinate
row = 200; 
col = 100;

x_pixel_data = squeeze(X_stack(row, col, :)); 
y_pixel_data = Y_vals;
m_fit = M(row, col);
c_fit = C(row, col);

x_fit_line = [min(x_pixel_data), max(x_pixel_data)];
y_fit_line = m_fit * x_fit_line + c_fit;

figure; hold on; grid on;
plot(x_pixel_data, y_pixel_data, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Data Points');
plot(x_fit_line, y_fit_line, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Fit: y = %.2fx + %.2f', m_fit, c_fit));
xlabel(sprintf('Disparity at (%d, %d)', row, col));
ylabel('Distance (mm)');
title(sprintf('Linear Fit at Pixel Coordinate (%d, %d)', row, col));
legend('Location', 'best');
hold off;

%%
n = 1;
createfigure(M.*X_cells{n}+C) % should be flat for any n

%% Save M and C
save('F:\Rhys\MATLAB Workspace\Probe_17\M.mat', 'M');
save('F:\Rhys\MATLAB Workspace\Probe_17\C.mat', 'C');
MC_window = window_radius;
save('F:\Rhys\MATLAB Workspace\Probe_17\MC_window.mat', 'MC_window');
MC_roi = [r_start, r_end, c_start, c_end];
save('F:\Rhys\MATLAB Workspace\Probe_17\MC_roi.mat', 'MC_roi');

%% Hyperbolic fit
[rows, cols, N] = size(X_stack);

% Initialize Output Matrices
A_mat = zeros(rows, cols);
B_mat = zeros(rows, cols);
C_mat = zeros(rows, cols);

% Define the Model Function
% p(1) = a, p(2) = b, p(3) = c
model = @(p, x) p(1) ./ (x + p(2)) + p(3);

% Initial Guess [a, b, c]
% Non-linear solvers need a starting point. Adjust these based on your data scale.
p0 = [1, 150, -3]; 

% 5. Optimization Options (Silence output for speed)
options = optimoptions('lsqcurvefit', 'Display', 'off');

% 6. Loop over every pixel
% Note: This can be slow for large images. Consider 'parfor' if you have Parallel Toolbox.
parfor r = 1:rows
    for c = 1:cols
        % Extract the X values for this specific pixel across all images
        x_data = squeeze(X_stack(r, c, :));
        
        % Perform the fit
        [p_fit, ~] = lsqcurvefit(model, p0, x_data, Y_vals, [], [], options);
        
        % Store results
        A_mat(r, c) = p_fit(1);
        B_mat(r, c) = p_fit(2);
        C_mat(r, c) = p_fit(3);
    end
end

%% Visualise Hyperbolic Fit
plot_r = round(rows/2); % Example: Middle row
plot_c = round(cols/2); % Example: Middle column

% 1. Extract the raw data for this specific pixel
x_raw = squeeze(X_stack(plot_r, plot_c, :));
y_raw = Y_vals;

% 2. Extract the fitted parameters for this specific pixel
a_f = A_mat(plot_r, plot_c);
b_f = B_mat(plot_r, plot_c);
c_f = C_mat(plot_r, plot_c);

% 3. Create a smooth range for the fitted line
x_fit = linspace(min(x_raw), max(x_raw), 100);
y_fit = a_f ./ (x_fit + b_f) + c_f;

% 4. Generate the Plot
figure('Color', 'w');
plot(x_raw, y_raw, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Measured Data');
hold on;
plot(x_fit, y_fit, 'b-', 'LineWidth', 2, 'DisplayName', 'Rational Fit');

% Formatting
xlabel('Disparity (X)');
ylabel('Distance (Y)');
title(['Fit for Pixel (', num2str(plot_r), ', ', num2str(plot_c), ')']);
subtitle(sprintf('y = %.2f / (x + %.2f) + %.2f', a_f, b_f, c_f));
grid on;
legend('Location', 'best');
hold off;
%%
n = 6;
createfigure(A_mat./(X_cells{n}+B_mat)+C_mat)

%% Save A, B and C
save('F:\Rhys\MATLAB Workspace\Probe_17\A_mat.mat', 'A_mat');
save('F:\Rhys\MATLAB Workspace\Probe_17\B_mat.mat', 'B_mat');
save('F:\Rhys\MATLAB Workspace\Probe_17\C_mat.mat', 'C_mat');
MC_window = window_radius;
save('F:\Rhys\MATLAB Workspace\Probe_17\MC_window.mat', 'MC_window');
MC_roi = [r_start, r_end, c_start, c_end];
save('F:\Rhys\MATLAB Workspace\Probe_17\MC_roi.mat', 'MC_roi');

%% Hyperbolic fit 2
[rows, cols, N] = size(X_stack);

% Initialize Output Matrices
A_mat = zeros(rows, cols);
C_mat = zeros(rows, cols);

% Define the Model Function
% p(1) = a, p(2) = c
model = @(p, x) p(1) ./ (x) + p(2);

% Initial Guess [a, c]
% Non-linear solvers need a starting point. Adjust these based on your data scale.
p0 = [1, -3]; 

% 5. Optimization Options (Silence output for speed)
options = optimoptions('lsqcurvefit', 'Display', 'off');

% 6. Loop over every pixel
% Note: This can be slow for large images. Consider 'parfor' if you have Parallel Toolbox.
parfor r = 1:rows
    for c = 1:cols
        % Extract the X values for this specific pixel across all images
        x_data = squeeze(X_stack(r, c, :));
        
        % Perform the fit
        [p_fit, ~] = lsqcurvefit(model, p0, x_data, Y_vals, [], [], options);
        
        % Store results
        A_mat(r, c) = p_fit(1);
        C_mat(r, c) = p_fit(2);
    end
end

%% Hyperbolic fit 2 with Outlier Removal
[rows, cols, N] = size(X_stack);

AC_mat = zeros(rows, cols, 2);
R2_threshold = 0.95; % Set your desired R2 here
min_points = 5;      % Don't drop so many points that the fit becomes meaningless

model = @(p, x) p(1) ./ (x) + p(2);
p0 = [1, -3]; 
options = optimoptions('lsqcurvefit', 'Display', 'off');

parfor r = 1:rows
    for c = 1:cols
        % Local copies for the loop
        current_x = squeeze(X_stack(r, c, :));
        current_y = Y_vals(:); % Ensure it's a column vector
        
        valid_fit = false;
        
        while length(current_x) >= min_points
            % 1. Perform Fit
            [AC_mat(r, c,:), resnorm, residual] = lsqcurvefit(model, p0, current_x, current_y, [], [], options);
            
            % 2. Calculate R2
            % resnorm is the sum of squared residuals (RSS)
            tss = sum((current_y - mean(current_y)).^2);
            r2 = 1 - (resnorm / tss);
            
            if r2 >= R2_threshold
                valid_fit = true;
                break; 
            else
                % 3. Identify and remove the worst outlier
                % We look for the largest absolute residual
                [~, max_idx] = max(abs(residual));
                current_x(max_idx) = [];
                current_y(max_idx) = [];
            end
        end
    end
end

A_mat = AC_mat(:,:,1);
C_mat = AC_mat(:,:,2);
%% Visualise Hyperbolic Fit 2
plot_r = 200; %round(rows/2); % Example: Middle row
plot_c = 100; %round(cols/2); % Example: Middle column

% 1. Extract the raw data for this specific pixel
x_raw = squeeze(X_stack(plot_r, plot_c, :));
y_raw = Y_vals;

% 2. Extract the fitted parameters for this specific pixel
a_f = A_mat(plot_r, plot_c);
c_f = C_mat(plot_r, plot_c);

% 3. Create a smooth range for the fitted line
x_fit = linspace(min(x_raw), max(x_raw), 100);
y_fit = a_f ./ (x_fit) + c_f;

% 4. Generate the Plot
figure('Color', 'w');
plot(x_raw, y_raw, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Measured Data');
hold on;
plot(x_fit, y_fit, 'b-', 'LineWidth', 2, 'DisplayName', 'Rational Fit');

% Formatting
xlabel('Disparity (X)');
ylabel('Distance (Y)');
title(['Fit for Pixel (', num2str(plot_r), ', ', num2str(plot_c), ')']);
subtitle(sprintf('y = %.2f / (x) + %.2f', a_f, c_f));
grid on;
legend('Location', 'best');
hold off;
%%
for n = 1:30
    im = A_mat./(X_cells{n})+C_mat;
    if max(max(im))-min(min(im)) > 0.2
        disp(n)
    end
end
%%
n = 5; % 5
createfigure(A_mat./(X_cells{n})+C_mat)

%% Save A and C
save('F:\Rhys\MATLAB Workspace\Probe_20\A2_mat.mat', 'A_mat');
save('F:\Rhys\MATLAB Workspace\Probe_20\C2_mat.mat', 'C_mat');
%%
MC_window = window_radius;
save('F:\Rhys\MATLAB Workspace\Probe_20\MC_window.mat', 'MC_window');
MC_roi = [r_start, r_end, c_start, c_end];
save('F:\Rhys\MATLAB Workspace\Probe_20\MC_roi.mat', 'MC_roi');

%% See A and C
createfigure(A_mat)
createfigure(C_mat)


