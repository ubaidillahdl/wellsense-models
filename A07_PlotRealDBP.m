clear; clc; close all;

% all_actual = [86, 61, 64, 71, 70, 66, 66, 62, 64, 65, 70, 61, 60, 77, 63, 73, 80, 77, 62, 70, 99, 82];
% all_pred   = [63.3, 59.9, 61.0, 56.6, 58.6, 54.7, 54.9, 57.5, 62.0, 60.9, 60.7, 56.5, 55.6, 59.3, 57.1, 57.2, 57.8, 57.8, 56.6, 54.2, 55.3, 59.4];
all_actual = [86, 61, 64, 71, 70, 66, 66, 62, 64, 65, 70, 61, 60, 77, 63, 73, 80, 77, 62, 70, 82];
all_pred   = [63.3, 59.9, 61.0, 56.6, 58.6, 54.7, 54.9, 57.5, 62.0, 60.9, 60.7, 56.5, 55.6, 59.3, 57.1, 57.2, 57.8, 57.8, 56.6, 54.2, 59.4];

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
title(sprintf('DIASTOLIK (DBP): R = %.5f', R));
legend([h1, h2, h3], {'Data', 'Fit', 'Y = T'}, 'Location', 'northwest');
xlabel('Target DBP (mmHg)', 'FontWeight', 'bold');
ylabel(sprintf('Output~=%.3f*Target+%.3f', coef_sbp(1), coef_sbp(2)), 'FontWeight', 'bold');

% Batas sumbu
% xlim([min(all_actual), max(all_actual)]);
% ylim([min(all_pred), max(all_pred)]);
hold off;
