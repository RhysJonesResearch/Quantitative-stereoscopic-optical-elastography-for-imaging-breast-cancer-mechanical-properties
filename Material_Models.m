%% Load csv's
Materials = {'SO_31_113_MinStableNve','Layer2_MinStableNve','Layer3_2nd0','Layer3_MinStableNve', ...
            'Layer3_0p035','Layer7_0p035','SmoothOn31_113','SmoothOn31_122',...
            'SmoothOn31_121','SmoothOn31_112','SmoothOn31_111','SmoothOn31_11', ...
            'SmoothOn31_21','Layer7','SmoothOn20_111','SmoothOn20_21',...
            'SmoothOn45_11','RT601_5to1','RT601_10to1to10','SmoothOn31_121_MinStableNve',...
            'Layer2_MinStableNve2'};
data = {};
for nM = 1:size(Materials,2)
    data{end+1} = table2array(readtable(['F:\Rhys\MATLAB Workspace\CompressionTestData\',Materials{nM},'\Sample1_Test1.csv']));
end
%% Make Paper 3 Figures
Materials = {'Layer3_2nd0','SmoothOn31_113','SmoothOn31_121','SmoothOn20_21'};
%M_Names = {'Wacker P7676 1:1','SmoothOn 31 1:1:3','SmoothOn 31 1:2:1','SmoothOn 20 2:1'};
M_Names = {'P7676 1:1','00-31 1:1:3','00-31 1:2:1','00-20 2:1'};
M_Names = {'Layer','Phantom 1','Phantom 2','Phantom 3'};
Colors = {[0.9 0 0],[0 0.9 0],[0 0 0.9],[0.9 0.0 0.9]};
LS = {'-','--',':','-.'};
data = {};
for nM = 1:size(Materials,2)
    data{end+1} = table2array(readtable(['F:\Rhys\MATLAB Workspace\CompressionTestData\',Materials{nM},'\Sample1_Test1.csv']));
end
pos =   [5.0, 5.0, 7.5, 7.5]; % left, bot, width, height
axpos = [1.5, 1.5, 5.5, 5.5];
fig = figure;
fig.Units = 'centimeters';
fig.Position = pos;
fig.GraphicsSmoothing = 'off';
hold on
for nM = 1:4
    temp = data{nM};
    Mat_e_strain = -temp(:,1)/100;
    Mat_e_stress = temp(:,2)*1000;
    
    %Mat_e_stress = Mat_e_stress - max(Mat_e_stress); % Sets 0 stress = 0 strain
    
    Mat_e_strain = movmean(Mat_e_strain, 10, 'Endpoints', 'discard');
    Mat_e_stress = movmean(Mat_e_stress, 10, 'Endpoints', 'discard');
    
    Mat_t_strain = log(1+Mat_e_strain);
    Mat_t_stress = Mat_e_stress.*(1+Mat_e_strain);

    true_linear_func = @(p, t_strain) p(1) .* t_strain;
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    [TE, resnorm, res, exitflag, output, lambda, J] = lsqcurvefit(true_linear_func, 12000, Mat_t_strain,Mat_t_stress, [], [], options);
    disp(TE)

    N = length(Mat_t_stress);
    p = 1;
    dof = N - p;
    sd_fit_error = sqrt(sum(res.^2) / dof);
    var_TE = (resnorm / dof) / (J' * J); 
    sd_TE = sqrt(var_TE);
    disp(sd_fit_error)
    disp(sd_TE)

    xf = (-0.8:0.01:-0.01);
    xf_t = log(1 + xf);
    y_fit1 = true_linear_func(TE, xf_t);
    plot(-Mat_e_strain, -Mat_e_stress/1000,'Color', Colors{nM}, 'LineStyle', LS{nM}, 'LineWidth', 2, 'DisplayName', M_Names{nM});
    %plot(xf, y_fit1 ./ (1 + xf) / 1000, 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.0,'HandleVisibility','off');
end
xlabel('Engineering Strain');
ylabel('Engineering Stress (kPa)');
%title(Materials{nM});
lgd=legend('Location','none','Position', [0.35,0.76,0.1,0.1]);
lgd.ItemTokenSize = [19, 18];
xlim([0,0.5]);
xticks([0.0,0.1,0.2,0.3,0.4,0.5]);
%ylim([-60, 0]);
grid off;
hold off;
fontsize(gcf, 10, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = axpos;
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig2a.pdf', 'ContentType', 'vector');

fig = figure;
fig.Units = 'centimeters';
fig.Position = pos;
fig.GraphicsSmoothing = 'off';
hold on
for nM = 1:4
    temp = data{nM};
    Mat_e_strain = -temp(:,1)/100;
    Mat_e_stress = temp(:,2)*1000;
    
    %Mat_e_stress = Mat_e_stress - max(Mat_e_stress); % Sets 0 stress = 0 strain
    
    Mat_e_strain = movmean(Mat_e_strain, 10, 'Endpoints', 'discard');
    Mat_e_stress = movmean(Mat_e_stress, 10, 'Endpoints', 'discard');
    
    Mat_t_strain = log(1+Mat_e_strain);
    Mat_t_stress = Mat_e_stress.*(1+Mat_e_strain);

    true_linear_func = @(p, t_strain) p(1) .* t_strain;
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    TE = lsqcurvefit(true_linear_func, 12000, Mat_t_strain,Mat_t_stress, [], [], options);
    xf = (-0.8:0.01:-0.01);
    xf_t = log(1 + xf);
    y_fit1 = true_linear_func(TE, xf_t);
    plot(-Mat_t_strain, -Mat_t_stress/1000,'Color', Colors{nM}, 'LineStyle', LS{nM}, 'LineWidth', 2, 'DisplayName', M_Names{nM});
    plot(-xf_t, -y_fit1 / 1000, 'Color', 'black', 'LineStyle', '-', 'LineWidth', 0.8,'HandleVisibility','off');
end
xlabel('True (Hencky) Strain');
ylabel('True (Cauchy) Stress (kPa)');
%title(Materials{nM});
lgd=legend('Location','none','Position', [0.35,0.76,0.1,0.1]);
lgd.ItemTokenSize = [19, 18];
xlim([0,0.7]);
xticks([0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7]);
yticks([0.0,5,10,15,20,25,30]);
set(gca, 'XTickLabelRotation', 0);
ylim([0,30]);
fontsize(gcf, 10, "points")
fontname(gcf, "Arial")
grid off;
hold off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = axpos;
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig2b.pdf', 'ContentType', 'vector');
%% Make Paper 3 Figures
Materials = {'Layer3_2nd0','SmoothOn31_113','SmoothOn31_121','SmoothOn20_21'};
M_Names = {'Wacker P7676 1:1','SmoothOn 31 1:1:3','SmoothOn 31 1:2:1','SmoothOn 20 2:1'};
Colors = {[0.9 0 0],[0 0.9 0],[0 0 0.9],[0.9 0.0 0.9]};
data = {};
for nM = 1:size(Materials,2)
    data{end+1} = table2array(readtable(['F:\Rhys\MATLAB Workspace\CompressionTestData\',Materials{nM},'\Sample1_Test1.csv']));
end
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 8.0, 8.0]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
for nM = 1:4
    temp = data{nM};
    Mat_e_strain = -temp(:,1)/100;
    Mat_e_stress = temp(:,2)*1000;
    
    %Mat_e_stress = Mat_e_stress - max(Mat_e_stress); % Sets 0 stress = 0 strain
    
    Mat_e_strain = movmean(Mat_e_strain, 10, 'Endpoints', 'discard');
    Mat_e_stress = movmean(Mat_e_stress, 10, 'Endpoints', 'discard');
    
    Mat_t_strain = log(1+Mat_e_strain);
    Mat_t_stress = Mat_e_stress.*(1+Mat_e_strain);

    true_linear_func = @(p, t_strain) p(1) .* t_strain;
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    TE = lsqcurvefit(true_linear_func, 12000, Mat_t_strain,Mat_t_stress, [], [], options);
    disp(TE)
    xf = (-0.8:0.01:-0.01);
    xf_t = log(1 + xf);
    y_fit1 = true_linear_func(TE, xf_t);
    plot(-Mat_e_strain, -Mat_e_stress/1000,'Color', Colors{nM}, 'LineWidth', 2, 'DisplayName', M_Names{nM});
    %plot(xf, y_fit1 ./ (1 + xf) / 1000, 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5,'HandleVisibility','off');
end
xlabel('Engineering Strain');
ylabel('Engineering Stress (kPa)');
%title(Materials{nM});
legend('Location', 'best');
xlim([0,0.5]);
xticks([0.0,0.1,0.2,0.3,0.4,0.5]);
%ylim([-12, 0]);
grid off;
hold off;
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 6, 6];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig2a.pdf', 'ContentType', 'vector');
%%
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 8.0, 8.0]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
for nM = 1:4
    temp = data{nM};
    Mat_e_strain = -temp(:,1)/100;
    Mat_e_stress = temp(:,2)*1000;
    
    %Mat_e_stress = Mat_e_stress - max(Mat_e_stress); % Sets 0 stress = 0 strain
    
    Mat_e_strain = movmean(Mat_e_strain, 10, 'Endpoints', 'discard');
    Mat_e_stress = movmean(Mat_e_stress, 10, 'Endpoints', 'discard');
    
    Mat_t_strain = log(1+Mat_e_strain);
    Mat_t_stress = Mat_e_stress.*(1+Mat_e_strain);

    true_linear_func = @(p, t_strain) p(1) .* t_strain;
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    TE = lsqcurvefit(true_linear_func, 12000, Mat_t_strain,Mat_t_stress, [], [], options);
    xf = (-0.8:0.01:-0.01);
    xf_t = log(1 + xf);
    y_fit1 = true_linear_func(TE, xf_t);
    plot(Mat_t_strain, Mat_t_stress/1000,'Color', Colors{nM}, 'LineWidth', 2, 'DisplayName', M_Names{nM});
    plot(xf_t, y_fit1 / 1000, 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5,'HandleVisibility','off');
end
xlabel('True (Hencky) Strain');
ylabel('True (Cauchy) Stress (kPa)');
%title(Materials{nM});
legend('Location', 'best');
xlim([-0.7, 0]);
yticks([-40, -30, -20, -10, 0.0]);
xticks([-0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0.0]);
set(gca, 'XTickLabelRotation', 0);
%ylim([-12, 0]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
grid off;
hold off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 6, 6];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig2b.pdf', 'ContentType', 'vector');

%% Homogeneous paper 3 figure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5, 5, 8.5, 8.5]; % left, bot, width, height
fig.GraphicsSmoothing = 'off';
hold on
EE  = [7.9,28,54];
ME1 = [8.9,8.5,8.8];
ME2 = [28.0,32.8,26.8];
ME3 = [47.9,46.7,47.6];
sME1 = [0.2,0.3,0.4];
sME2 = [1.2,1.2,0.5];
sME3 = [1.0,1.8,1.1];
n = [3,3,3];
% Calculation
x_total = sum(n .* ME1) / sum(n);
within_var  = sum((n - 1) .* sME1.^2);
between_var = sum(n .* (ME1 - x_total).^2);
sd_1 = sqrt((within_var + between_var) / (sum(n) - 1));
% Calculation
x_total = sum(n .* ME2) / sum(n);
within_var  = sum((n - 1) .* sME2.^2);
between_var = sum(n .* (ME2 - x_total).^2);
sd_2 = sqrt((within_var + between_var) / (sum(n) - 1));
% Calculation
x_total = sum(n .* ME3) / sum(n);
within_var  = sum((n - 1) .* sME3.^2);
between_var = sum(n .* (ME3 - x_total).^2);
sd_3 = sqrt((within_var + between_var) / (sum(n) - 1));

scatter(EE(1),mean(ME1),'s','blue','DisplayName','Phantom 1'); %'00-31 1:1:3');
eb=errorbar(EE(1),mean(ME1), sd_1, sd_1,'HandleVisibility','off','color','black');
scatter(EE(2),mean(ME2),'d','green','DisplayName','Phantom 2'); %'00-31 1:2:1');
eb=errorbar(EE(2),mean(ME2), sd_2, sd_2,'HandleVisibility','off','color','black');
scatter(EE(3),mean(ME3),'o','MarkerEdgeColor',[0.8 0.8 0.0],'DisplayName','Phantom 3'); %'00-20 2:1');
eb=errorbar(EE(3),mean(ME3), sd_3, sd_3,'HandleVisibility','off','color','black');


%scatter(EE(1)*ones(1,3),ME1,'s','blue','DisplayName','00-31 1:1:3');
%eb=errorbar(EE(1)*ones(1,3),ME1, [0.2,0.3,0.4], [0.2,0.3,0.4],'HandleVisibility','off','color','black');
%eb.LineStyle = 'none';
%scatter(EE(2)*ones(1,3),ME2,'d','green','DisplayName','00-31 1:2:1');
%eb=errorbar(EE(2)*ones(1,3),ME2, [1.2,1.2,0.5], [1.2,1.2,0.5],'HandleVisibility','off','color','black');
%eb.LineStyle = 'none';
%scatter(EE(3)*ones(1,3),ME3,'o','MarkerEdgeColor',[0.8 0.8 0.0],'DisplayName','00-20 2:1'); % 'yellow'
%eb=errorbar(EE(3)*ones(1,3),ME3, [1.0,1.8,1.1], [1.0,1.8,1.1],'HandleVisibility','off','color','black');
%eb.LineStyle = 'none';
plot([0,60],[0,60],'Color', 'black', 'LineStyle', '--','HandleVisibility', 'off');
xlabel('Expected Elasticity (kPa)');
ylabel('Measured Elasticity (kPa)');
%title(Materials{nM});
legend('Location', 'northwest');
xlim([0, 60]);
xticks(0:10:60);
set(gca, 'XTickLabelRotation', 0);
ylim([0, 60]);
fontsize(gcf, 12, "points")
fontname(gcf, "Arial")
grid off;
hold off;
ax = gca();
ax.Units = 'centimeters';
ax.Position = [1.5, 1.5, 6.5, 6.5];
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, 'Fig3j.pdf', 'ContentType', 'vector');

%% Generate engineerning and true stress-strain curves
nM = 1;
temp = data{nM};
Mat_e_strain = -temp(:,1)/100;
Mat_e_stress = temp(:,2)*1000;

%Mat_e_stress = Mat_e_stress - max(Mat_e_stress); % Sets 0 stress = 0 strain

Mat_e_strain = movmean(Mat_e_strain, 10, 'Endpoints', 'discard');
Mat_e_stress = movmean(Mat_e_stress, 10, 'Endpoints', 'discard');

Mat_t_strain = log(1+Mat_e_strain);
Mat_t_stress = Mat_e_stress.*(1+Mat_e_strain);
%%
figure;
plot(Mat_e_strain, Mat_e_stress);
title(['Eng ',Materials(nM)])
xlabel('Eng Strain');
ylabel('Eng Stress');
grid on;

figure;
plot(Mat_t_strain, Mat_t_stress);
title(['True ',Materials(nM)])
xlabel('Tru Strain');
ylabel('Tru Stress');
grid on;

%% Define Models
eng_linear_func = @(p, x) p(1) .* x;

true_linear_func = @(p, t_strain) p(1) .* t_strain;

neo_hook_func = @(p, e) 2.0 .* p(1) .* ((1.0 + e) - 1.0 ./ ((1.0 + e).^2.0));

mooney_rivlin_func = @(p, e) 2.0 .* (p(1) + p(2) ./ (1.0 + e)) .* ...
    ((1.0 + e) - 1.0 ./ ((1.0 + e).^2.0));

ogden_func = @(p, e) (2 .* p(1) ./ p(2)) .* ...
    ((1.0 + e).^(p(2) - 1) - (1.0 + e).^(-p(2) ./ 2 - 1));
%% Fit Models

start = 100;
stop = 1000;
%Mat_e_strain = Mat_e_strain(start:stop); Mat_e_stress = Mat_e_stress(start:stop); Mat_t_strain = Mat_t_strain(start:stop); Mat_t_stress = Mat_t_stress(start:stop);

options = optimoptions('lsqcurvefit', 'Display', 'off'); % Optimization options to silence output
EE = lsqcurvefit(eng_linear_func, 12000, Mat_e_strain, Mat_e_stress, [], [], options);
TE = lsqcurvefit(true_linear_func, 12000, Mat_t_strain,Mat_t_stress, [], [], options);
NH = lsqcurvefit(neo_hook_func, 600, Mat_e_strain,Mat_e_stress, [], [], options);
p_mr = lsqcurvefit(mooney_rivlin_func, [200, 800], Mat_e_strain, Mat_e_stress, [], [], options);
C1 = p_mr(1); C2 = p_mr(2);
p_ogden = lsqcurvefit(ogden_func, [1000, 8], Mat_e_strain, Mat_e_stress, [], [], options);
mu = p_ogden(1); alpha = p_ogden(2);

xf = (-0.8:0.01:-0.01);
xf_t = log(1 + xf);

y_fit0 = eng_linear_func(EE, xf);
y_fit1 = true_linear_func(TE, xf_t);
y_fit2 = mooney_rivlin_func([C1, C2], xf);
y_fit3 = ogden_func([mu, alpha], xf);
y_fit4 = neo_hook_func(NH,xf);

disp(' ');
disp(Materials{nM});
fprintf('EE: %.2f\n', EE);
fprintf('TE: %.2f\n', TE);
fprintf('NH: %.2f\n', NH);
fprintf('C1: %.2f, C2: %.2f\n', C1, C2);
fprintf('mu: %.2f, alpha: %.2f\n', mu, alpha);

%% Visualise models in Engineering Stress Strain

figure;
hold on;
plot(Mat_e_strain, Mat_e_stress/1000, 'LineWidth', 3, 'DisplayName', 'Uniaxial Compression Test');
plot(xf, y_fit0/1000, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Eng Linear Model');
plot(xf, y_fit1 ./ (1 + xf) / 1000, 'Color', [0 0.5 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'True Linear Model');
%plot(xf, y_fit3 / 1000, 'Color', [0.9 0.9 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Ogden Model');
plot(xf, y_fit4 / 1000, 'Color', [0.9 0.9 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'NeoHookean Model');
plot(xf, y_fit2 / 1000, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'MooneyRivlin Model');
xlabel('Engineering Strain');
ylabel('Engineering Stress (kPa)');
%title(Materials{nM});
legend('Location', 'best');
%xlim([-0.4, 0]);
%ylim([-11, 0]);
xlim([-0.5, 0]);
ylim([-12, 0]);
grid on;
% Add SOP data (comment / uncomment depending on what layer model)
%plot(Eng_Sample_Strain, Eng_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'From SOP using Moo-Riv');
%plot(Eng_Sample_Strain, Eng_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'From SOP using Tru Lin');
%plot(Eng_Sample_Strain, Eng_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'From SOP using Eng Lin');
hold off;

%% Visualise True Stress-Strain Model

figure;
hold on;
plot(Mat_t_strain, Mat_t_stress/1000, 'LineWidth', 3, 'DisplayName', 'Uniaxial Compression Test');
plot(xf_t, y_fit1 / 1000, 'Color', [0 0.5 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'True Linear Model');

plot(xf_t, y_fit0 .* (1 + xf) / 1000, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Eng Linear Model');
plot(xf_t, y_fit4 .* (1 + xf) / 1000, 'Color', [0.9 0.9 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'NeoHookean Model');
plot(xf_t, y_fit2 .* (1 + xf) / 1000, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'MooneyRivlin Model');

xlabel('True Strain');
ylabel('True Stress (kPa)');
%title(Materials{nM});
legend('Location', 'best');
xlim([-0.5, 0]);
ylim([-4, 0]);
%xlim([-0.8, 0]);
%ylim([-60, 0]);
grid on;
% Add SOP data (comment / uncomment depending on what layer model)
%plot(Tru_Sample_Strain, Tru_Layer_Stress, '-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'From SOP using Tru Lin');
hold off;

%% find expected true elasticity measurement for neohookean constant at specific strains
neo_hook_func = @(p, e) 2.0 .* p(1) .* ((1.0 + e) - 1.0 ./ ((1.0 + e).^2.0));
C1 = 0.00154 * 1000;

xf = (-0.60:0.01:-0.01);
xf_t = log(1 + xf);

y_fit4 = neo_hook_func(C1,xf);
y_fit4_t = y_fit4 .* (1 + xf);

figure;
hold on;
plot(xf_t, y_fit4_t, 'LineWidth', 1, 'DisplayName', 'NeoHookean Model');
plot([xf_t(1),0], [y_fit4_t(1) 0], 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', ('Secant Modulus '+string(y_fit4_t(1)/xf_t(1))));
xlabel('True Strain');
ylabel('True Stress (kPa)');
legend('Location', 'best');
grid on;
hold off;
