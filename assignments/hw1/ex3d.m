% Exercise 3(d): |ID|(Vin) and Vd(Vin) with OFF region + Vin,on marker

clear; clc;

% Given constants
VDD   = 1.1;             % V
VTP   = 0.35;            % |V_TP|, V
RS    = 100;             % ohm
RD    = 1e3;             % ohm
betaP = 1.20e-3;         % A/V^2  (μpCox*W/L)
k     = betaP/2;         % A/V^2

% Turn-on input voltage (VSG = |VTP| at ID≈0)
Vin_on = 2*(VDD - VTP);  % 1.50 V

% Vin sweep
Vin = linspace(0, 1.8, 1001);     % V (wider than needed to show OFF region)

% Helper A = VDD - 0.5*Vin - |VTP|
A = VDD - 0.5*Vin - VTP;

% Closed-form solution in saturation for ID from: ID = k*(A - RS*ID)^2
% Only valid when A>0 (device ON). Otherwise ID = 0 (OFF region).
Id = zeros(size(Vin));            % A
on = A > 0;                       % logical mask for ON region
den = 2*sqrt(k)*RS;
Id(on) = ((-1 + sqrt(1 + 4*k*RS.*A(on))) ./ den).^2;

% Drain voltage
Vd = RD .* Id;                    % V

% ---- Plot ----
figure(1); clf; hold on; box on; grid on;

% Shade OFF region (Vin > Vin_on)
x_off = [Vin_on max(Vin) max(Vin) Vin_on];
y_off = [0 0 max([Vd, Id*1e3], [], 'all') max([Vd, Id*1e3], [], 'all')];
patch(x_off, y_off, [0.9 0.9 0.9], 'EdgeColor', 'none', 'DisplayName','OFF region');

% Plot |ID| on left axis (mA)
yyaxis left
plot(Vin, Id*1e3, 'LineWidth', 2, 'DisplayName','|I_D| (mA)');
ylabel('|I_D|  (mA)');

% Plot Vd on right axis (V)
yyaxis right
plot(Vin, Vd, 'LineWidth', 2, 'LineStyle','--', 'DisplayName','V_d (V)');
ylabel('V_d  (V)');

% Vertical line at Vin_on
xline(Vin_on, 'k-', 'LineWidth', 1.5, 'DisplayName','V_{in,on}');
text(Vin_on+0.02, 0.05*ylim(gca)*[0;1], 'V_{in,on}=1.50 V');

% Axes, legend, labels
xlabel('V_{in}  (V)');
title('|I_D|(V_{in}) and V_d(V_{in}) with OFF region & turn-on point');
legend('Location','northwest');
