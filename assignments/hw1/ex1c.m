% Exercise 1C: Sketch Ix(Vx) with transition point

% Given parameters
VDD   = 1.1;         % V
VTN   = 0.25;        % V
R1    = 1e3;         % Ohm
R2    = 4e3;         % Ohm
beta  = 5e-3;        % A/V^2 (mu_n*Cox*W/L)
% Gate divider
VG    = @(Vx) (R2/(R1+R2))*VDD + (R1/(R1+R2))*Vx;   % = 0.88 + 0.2*Vx
VGS   = @(Vx) VG(Vx) - Vx;                          % = 0.88 - 0.8*Vx
VOV   = @(Vx) VGS(Vx) - VTN;                        % = 0.63 - 0.8*Vx

% Transition (VGS = VTN -> VOV=0)
Vx_star = 0.63/0.8;  % 0.7875 V

% Ix(Vx): saturation when VOV>0, else 0 (lambda = 0)
Ix = @(Vx) 0.5*beta*max(VOV(Vx),0).^2;

% Sweep Vx
Vx = linspace(0, VDD, 1000);
Ix_mA = 1e3 * Ix(Vx);    % plot in mA

% Plot
figure; plot(Vx, Ix_mA, 'LineWidth', 2); grid on; hold on;
xline(Vx_star, '--', 'LineWidth', 1.5, 'Label', 'V_x^*', 'LabelVerticalAlignment','bottom');
yline(0, ':');

% Shade/annotate regions (optional but clear)
yl = ylim;
patch([0 Vx_star Vx_star 0],[yl(1) yl(1) yl(2) yl(2)], [0.9 0.95 1], ...
      'EdgeColor','none','FaceAlpha',0.25);   % Saturation region
patch([Vx_star VDD VDD Vx_star],[yl(1) yl(1) yl(2) yl(2)], [1 0.95 0.95], ...
      'EdgeColor','none','FaceAlpha',0.25);   % Off region
uistack(findobj(gca,'Type','line','-and','LineWidth',2),'top'); % keep curve on top

% Labels & legend
title('I_X(V_X) with Region Transition');
xlabel('V_X (V)');
ylabel('I_X (mA)');
text(0.2*Vx_star, 0.9*yl(2), 'Saturation','FontWeight','bold');
text(0.85*(Vx_star+VDD)/2, 0.1*yl(2), 'Off','FontWeight','bold');
legend({'I_X(V_X)','Transition V_X^*'}, 'Location','northeast');

% Display numeric transition point
fprintf('Transition point Vx* = %.4f V\n', Vx_star);
