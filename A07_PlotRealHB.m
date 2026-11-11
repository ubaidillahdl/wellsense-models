clear; clc; close all;

% all_actual = [156, 153, 174, 160, 140, 137, 127, 160, 129, 158, 148, 137, 89, 130, 132, 130, 138, 134, 121, 123, 142, 132];
% all_pred   = [155.3, 152.8, 156.3, 152.6, 154.4, 150.4, 149.6, 153.9, 153.9, 156.2, 153.5, 129.0, 129.2, 130.2, 129.6, 129.5, 129.8, 130.0, 129.3, 128.6, 128.9, 132.0];
all_actual = [156, 153, 174, 160, 140, 137, 127, 160, 158, 148, 137, 130, 132, 130, 138, 134, 121, 123, 142, 132];
all_pred   = [155.3, 152.8, 156.3, 152.6,  154.4, 150.4, 149.6, 153.9, 156.2, 153.5, 129.0, 130.2, 129.6, 129.5, 129.8, 130.0, 129.3, 128.6, 128.9, 132.0];

err = all_pred - all_actual;

RMSE = sqrt(mean(err.^2));
MAE = mean(abs(err));
MAPE = mean(abs(err ./ all_actual)) * 100;
R = corrcoef(all_actual, all_pred);
R = R(1,2);

mean_diff = mean(err);
sd_diff = std(err);

fprintf('HEMOGLOBIN (HB):\n');
fprintf('\tR\t\t\t: %.4f\t\n', R);
fprintf('\tRMSE\t\t: %.2f\tg/L\n', RMSE);
fprintf('\tMAE\t\t\t: %.2f\tg/L\n', MAE);
fprintf('\tMAPE\t\t: %.2f\t%%\n', MAPE);
fprintf('\tMean Diff\t: %.2f g/L\n', mean_diff);
fprintf('\tSD Diff\t\t: %.2f g/L\n', sd_diff);


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
title(sprintf('HEMOGLOBIN (HB): R = %.5f', R));
legend([h1, h2, h3], {'Data', 'Fit', 'Y = T'}, 'Location', 'northwest');
xlabel('Target HB (g/L)', 'FontWeight', 'bold');
ylabel(sprintf('Output~=%.3f*Target+%.3f', coef_sbp(1), coef_sbp(2)), 'FontWeight', 'bold');

% Batas sumbu
% xlim([min(all_actual), max(all_actual)]);
% ylim([min(all_pred), max(all_pred)]);
hold off;
