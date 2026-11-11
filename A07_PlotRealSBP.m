clear; clc; close all;

% all_actual = [130, 124, 129, 136, 120, 118, 118, 108, 117, 123, 121, 100, 110, 127, 116, 117, 146, 122, 123, 123, 139, 136];
% all_pred   = [117.8, 116.6, 112.4, 113.1, 113.3, 113.1, 113.5, 111.4, 118.5, 113.9, 115.4, 101.6, 101.6, 103.5, 101.5, 102.0, 101.9, 102.0, 101.3, 102.5, 101.1, 100.3];
all_actual = [130, 124, 129, 136, 120, 118, 118, 108, 117, 123, 121, 100, 110, 127, 116, 117, 122, 123, 123];
all_pred   = [117.8, 116.6, 112.4, 113.1, 113.3, 113.1, 113.5, 111.4, 118.5, 113.9, 115.4, 101.6, 101.6, 103.5, 101.5, 102.0, 102.0, 101.3, 102.5];

err = all_pred - all_actual;

RMSE = sqrt(mean(err.^2));
MAE = mean(abs(err));
MAPE = mean(abs(err ./ all_actual)) * 100;
R = corrcoef(all_actual, all_pred);
R = R(1,2);

mean_diff = mean(err);
sd_diff = std(err);

fprintf('SISTOLIK (SBP):\n');
fprintf('\tR\t\t\t: %.4f\t\n', R);
fprintf('\tRMSE\t\t: %.2f\tmmHg\n', RMSE);
fprintf('\tMAE\t\t\t: %.2f\tmmHg\n', MAE);
fprintf('\tMAPE\t\t: %.2f\t%%\n', MAPE);
fprintf('\tMean Diff\t: %.2f mmHg\n', mean_diff);
fprintf('\tSD Diff\t\t: %.2f mmHg\n', sd_diff);

figure();
% h1 = scatter(all_actual, all_pred);
h1 = scatter(all_actual, all_pred, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;

% Garis fit linear
coef_sbp = polyfit(all_actual, all_pred, 1);
x_fit = [min(all_actual), max(all_actual)];
y_fit = polyval(coef_sbp, x_fit);
h2 = plot(x_fit, y_fit, 'r-', 'LineWidth', 1.5);

% Garis Y = T (ideal)
h3 = plot(x_fit, x_fit, 'k:', 'LineWidth', 1.5);

% Judul, legend, label
title(sprintf('SISTOLIK (SBP): R = %.5f', R));
legend([h1, h2, h3], {'Data', 'Fit', 'Y = T'}, 'Location', 'northwest');
xlabel('Target SBP (mmHg)', 'FontWeight', 'bold');
ylabel(sprintf('Output~=%.3f*Target+%.3f', coef_sbp(1), coef_sbp(2)), 'FontWeight', 'bold');

% Batas sumbu
% xlim([min(all_actual), max(all_actual)]);
% ylim([min(all_pred), max(all_pred)]);
hold off;
