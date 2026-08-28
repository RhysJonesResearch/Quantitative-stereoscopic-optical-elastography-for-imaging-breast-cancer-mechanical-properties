function masd = calculateMASD(BW_seg, BW_gt)
    % Convert binary masks to their outer boundaries
    boundary_seg = bwperim(BW_seg);
    boundary_gt  = bwperim(BW_gt);
    
    % 1. Compute distance transform for both ground truth and segmentation
    D_gt  = bwdist(boundary_gt);  % Distance to nearest true boundary pixel
    D_seg = bwdist(boundary_seg); % Distance to nearest segmented boundary pixel
    
    % 2. Find distances from segmented boundary points to the true boundary
    dist_seg_to_gt = D_gt(boundary_seg);
    
    % 3. Find distances from true boundary points to the segmented boundary
    dist_gt_to_seg = D_seg(boundary_gt);
    
    % 4. Calculate the symmetric mean absolute surface distance
    masd = (mean(dist_seg_to_gt) + mean(dist_gt_to_seg)) / 2;
    % or 4. Calculate the asymmetric mean absolute surface distance
    masd = mean(dist_seg_to_gt);
end