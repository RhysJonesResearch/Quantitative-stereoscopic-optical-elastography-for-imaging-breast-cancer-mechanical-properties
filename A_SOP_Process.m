%% Add Scripted_ncorr_2D_matlab to path

%% 1. Undistort & Rectify
load('F:\Rhys\MATLAB Workspace\Probe_20\stereoParams.mat');
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_Tissue_Left_20260513_16h09m09s\";
white_then_UV_flag = 0;
imRange = 1:10;
%imRange = 1:13; % use half max if white then UV
%imRange = [1,5,10];
for n = imRange
    if white_then_UV_flag
        n_s = 2*n;
    else
        n_s = n;
    end
    left_fn = "im1_image_"+string(n_s)+".png";
    right_fn = "im2_image_"+string(n_s)+".png";
    left_fp = imageFolder+left_fn;
    right_fp = imageFolder+right_fn;
    left_img = imread(left_fp);
    right_img = imread(right_fp);

    [left_rect, right_rect] = rectifyStereoImages(left_img, right_img, stereoParams);

    imwrite(left_rect, imageFolder+"im1_rect_image_"+string(n_s)+".png");
    imwrite(right_rect, imageFolder+"im2_rect_image_"+string(n_s)+".png");
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
    if white_then_UV_flag
        n_s = 2*n;
    else
        n_s = n;
    end
    left_rect  = imread(imageFolder+"im1_rect_image_"+string(n_s)+".png");
    right_rect = imread(imageFolder+"im2_rect_image_"+string(n_s)+".png");
    
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
%%
imageFolder = 'F:\Rhys\MATLAB Workspace\Probe_19\Scans\Probe19_DispDist_20260423_17h19m41s\';
%% Visualise
n_s = 3;
left_rect  = imread(imageFolder+"im1_image_"+string(n_s)+".png");
right_rect = imread(imageFolder+"im2_image_"+string(n_s)+".png");
%left_rect = left_rect(r_start:r_end,c_start:c_end,:);
%est_disp = 230;
%right_rect = right_rect(r_start:r_end,(c_start-est_disp):(c_end-est_disp),:);
figure
imshowpair(left_rect, right_rect, 'montage');
title('Rectified Stereo Pair with Horizontal Alignment Check');
hold on;
[height, width, ~] = size(left_rect);
xPositions = linspace(1, 2*width, 11); % num lines at end
yPositions = linspace(1, height, 10); % num lines at end
for i = 1:length(xPositions)
    %line([xPositions(i), xPositions(i)], [0,height], ...
         %'Color', 'black', 'LineWidth', 0.8, 'LineStyle', '--');
end
for i = 1:length(yPositions)
    %line([0, 2*width], [yPositions(i), yPositions(i)], ...
         %'Color', 'black', 'LineWidth', 0.8, 'LineStyle', '--');
end
hold off;
%% Treat data
Disp_cells = {};
Disp_no_smoothing = {};
for n = 1:size(imRange,2)
    u_disp_nans = u_disp_array{n};
    u_disp_nans(u_disp_array{n} == 0) = NaN;
    u_disp_no_nans = inpaint_nans(u_disp_nans(r_start:r_end,c_start:c_end),4);
    Disp_no_smoothing{end+1} = u_disp_no_nans;
    Disp_cells{end+1} = imgaussfilt(u_disp_no_nans, 5); % gaussian smooth size 15 for mc
end

%% Visualise
n = 1;
disp_map = Disp_cells{n};
createfigure(disp_map)

%% Save disp_map_n
for n = 1:size(imRange,2)
    disp_map = Disp_cells{n};
    save(imageFolder+'disp_map_'+string(imRange(n))+'.mat', 'disp_map');
end

%% Load other existing disparity maps (DON'T RUN)
imageFolder = "F:\Rhys\MATLAB Workspace\Probe_20\Scans\Probe20_ExpNew0_SO31_113_20260428_14h55m32s\";
imRange = 1:12;
Disp_cells = {};
for n = 1:size(imRange,2)
    load(imageFolder+'disp_map_'+string(imRange(n))+'.mat', 'disp_map');
    Disp_cells{n} = disp_map;
end

%% Disparity to Distance Mapping (LINEAR)
load('F:\Rhys\MATLAB Workspace\Probe_15\M.mat');
load('F:\Rhys\MATLAB Workspace\Probe_15\C.mat');
load('F:\Rhys\MATLAB Workspace\Probe_15\MC_window.mat');
load('F:\Rhys\MATLAB Workspace\Probe_15\MC_roi.mat');
im1_roi = [r_start, r_end, c_start, c_end];
for n = 1:size(imRange,2)
    disp_map = Disp_cells{n};

    if isequal(size(M), size(disp_map)) && sum(MC_roi==im1_roi)==4
            dist_map = M .* disp_map + C;
    elseif (size(M,1) > size(disp_map,1)) && (size(M,2) > size(disp_map,2))
        disp('Warning: Interpolating 2D disparity to displacement map');
        yy = linspace(MC_roi(1), MC_roi(2)+1, MC_roi(2)+1-MC_roi(1));
        xx = linspace(MC_roi(3), MC_roi(4)+1, MC_roi(4)+1-MC_roi(3));
        [X, Y] = meshgrid(xx, yy);
        points = [X(:), Y(:)];
        m_points = M(:);
        c_points = C(:);
        
        yy = linspace(im1_roi(1), im1_roi(2)+1, im1_roi(2)+1-im1_roi(1));
        xx = linspace(im1_roi(3), im1_roi(4)+1, im1_roi(4)+1-im1_roi(3));
        [X, Y] = meshgrid(xx, yy);
        
        m_new = griddata(points(:,1), points(:,2), m_points, X, Y, 'linear');
        c_new = griddata(points(:,1), points(:,2), c_points, X, Y, 'linear');
        
        dist_map = m_new .* disp_map + c_new;
    else
        disp('Error in image '+string(imRange(n))+': Check image sizes and ROIs');
    end

    save(imageFolder+'dist_map_'+string(imRange(n))+'.mat', 'dist_map');

end

%% Disparity to Distance Mapping (HYPERBOLIC)
load('F:\Rhys\MATLAB Workspace\Probe_17\A_mat.mat');
load('F:\Rhys\MATLAB Workspace\Probe_17\B_mat.mat');
load('F:\Rhys\MATLAB Workspace\Probe_17\C_mat.mat');
load('F:\Rhys\MATLAB Workspace\Probe_17\MC_window.mat'); % same window and roi for this method as the MC method
load('F:\Rhys\MATLAB Workspace\Probe_17\MC_roi.mat');
im1_roi = [r_start, r_end, c_start, c_end];
for n = 1:size(imRange,2)
    disp_map = Disp_cells{n};

    if isequal(size(A_mat), size(disp_map)) && sum(MC_roi==im1_roi)==4
            dist_map = A_mat ./ (disp_map + B_mat) + C_mat;
    elseif (size(A_mat,1) > size(disp_map,1)) && (size(A_mat,2) > size(disp_map,2))
        disp('Warning: Interpolating 2D disparity to displacement map');
        yy = linspace(MC_roi(1), MC_roi(2)+1, MC_roi(2)+1-MC_roi(1));
        xx = linspace(MC_roi(3), MC_roi(4)+1, MC_roi(4)+1-MC_roi(3));
        [X, Y] = meshgrid(xx, yy);
        points = [X(:), Y(:)];
        A_mat_points = A_mat(:);
        B_mat_points = B_mat(:);
        C_mat_points = C_mat(:);
        
        yy = linspace(im1_roi(1), im1_roi(2)+1, im1_roi(2)+1-im1_roi(1));
        xx = linspace(im1_roi(3), im1_roi(4)+1, im1_roi(4)+1-im1_roi(3));
        [X, Y] = meshgrid(xx, yy);
        
        A_mat_new = griddata(points(:,1), points(:,2), A_mat_points, X, Y, 'linear');
        B_mat_new = griddata(points(:,1), points(:,2), B_mat_points, X, Y, 'linear');
        C_mat_new = griddata(points(:,1), points(:,2), C_mat_points, X, Y, 'linear');
        
        dist_map = A_mat_new ./ (disp_map + B_mat_new) + C_mat_new;
    else
        disp('Error in image '+string(imRange(n))+': Check image sizes and ROIs');
    end

    save(imageFolder+'dist_map_hyp_'+string(imRange(n))+'.mat', 'dist_map');

end

%% Visualise
n = 1;
load(imageFolder+'dist_map_hyp_'+string(n)+'.mat');
createfigure(dist_map)

%% Disparity to Distance Mapping (HYPERBOLIC 2)
load('F:\Rhys\MATLAB Workspace\Probe_20\A2_mat.mat');
load('F:\Rhys\MATLAB Workspace\Probe_20\C2_mat.mat');
load('F:\Rhys\MATLAB Workspace\Probe_20\MC_window.mat'); % same window and roi for this method as the MC method
load('F:\Rhys\MATLAB Workspace\Probe_20\MC_roi.mat');
im1_roi = [r_start, r_end, c_start, c_end];
for n = 1:size(imRange,2)
    disp_map = Disp_cells{n};

    if isequal(size(A_mat), size(disp_map)) && sum(MC_roi==im1_roi)==4
            dist_map = A_mat ./ (disp_map) + C_mat;
    elseif (size(A_mat,1) > size(disp_map,1)) && (size(A_mat,2) > size(disp_map,2))
        disp('Warning: Interpolating 2D disparity to displacement map');
        yy = linspace(MC_roi(1), MC_roi(2)+1, MC_roi(2)+1-MC_roi(1));
        xx = linspace(MC_roi(3), MC_roi(4)+1, MC_roi(4)+1-MC_roi(3));
        [X, Y] = meshgrid(xx, yy);
        points = [X(:), Y(:)];
        A_mat_points = A_mat(:);
        B_mat_points = B_mat(:);
        C_mat_points = C_mat(:);
        
        yy = linspace(im1_roi(1), im1_roi(2)+1, im1_roi(2)+1-im1_roi(1));
        xx = linspace(im1_roi(3), im1_roi(4)+1, im1_roi(4)+1-im1_roi(3));
        [X, Y] = meshgrid(xx, yy);
        
        A_mat_new = griddata(points(:,1), points(:,2), A_mat_points, X, Y, 'linear');
        C_mat_new = griddata(points(:,1), points(:,2), C_mat_points, X, Y, 'linear');
        
        dist_map = A_mat_new ./ (disp_map) + C_mat_new;
    else
        disp('Error in image '+string(imRange(n))+': Check image sizes and ROIs');
    end

    save(imageFolder+'dist_map_hyp_'+string(imRange(n))+'.mat', 'dist_map');

end

%% Visualise
n = 8;
load(imageFolder+'dist_map_hyp_'+string(n)+'.mat');
createfigure(dist_map)
disp(mean2(dist_map))
disp(std2(dist_map))

%%
figure;
histogram(dist_map)

