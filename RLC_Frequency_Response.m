%% Advanced RLC Circuit Frequency Response Analyzer
clc; clear; close all;

%% User Configurable Inputs
config = 'series';     % 'series' or 'parallel'
R = 50;                % Ohms
L = 100e-6;            % Henry
C = 1e-6;              % Farads

%% Frequency Vector (Log-Spaced)
f = logspace(1, 7, 5000);
w = 2 * pi * f;
s = 1j * w;

%% Calculate Transfer Function
[H, Z, title_str] = compute_transfer_function(config, R, L, C, s);

%% Calculate Frequency Characteristics
[f_res, BW, Q] = calculate_characteristics(R, L, C);

%% Plotting
plot_bode(f, H, f_res, title_str);
plot_phase(f, H, title_str);
plot_nyquist(H, title_str);
plot_pzmap(config, R, L, C, title_str);

%% Report Results
print_results(config, f_res, BW, Q);


%% ---- Functions ----
function [H, Z, title_str] = compute_transfer_function(config, R, L, C, s)
    switch lower(config)
        case 'series'
            Z = R + s*L + 1./(s*C);
            H = 1 ./ Z;
            title_str = 'Series RLC Circuit';
        case 'parallel'
            Y = 1/R + 1./(s*L) + s*C;
            Z = 1 ./ Y;
            H = Z ./ (Z + 0);  
            title_str = 'Parallel RLC Circuit';
        otherwise
            error('Invalid config: choose "series" or "parallel".');
    end
end

function [f_res, BW, Q] = calculate_characteristics(R, L, C)
    f_res = 1 / (2*pi*sqrt(L*C));
    BW = R / (2*pi*L);
    Q = f_res / BW;
end

function plot_bode(f, H, f_res, title_str)
    figure;
    semilogx(f, 20*log10(abs(H)), 'LineWidth', 1.8);
    hold on;
    xline(f_res, '--r', sprintf('f_{res} = %.2f Hz', f_res), 'LabelOrientation','horizontal');
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title([title_str ' - Bode Magnitude']);
    legend('Magnitude', 'Resonance Frequency', 'Location', 'best');
    set(gca, 'FontSize', 12);
end

function plot_phase(f, H, title_str)
    figure;
    semilogx(f, angle(H)*180/pi, 'LineWidth', 1.8);
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Phase (Degrees)');
    title([title_str ' - Bode Phase']);
    set(gca, 'FontSize', 12);
end

function plot_nyquist(H, title_str)
    figure;
    plot(real(H), imag(H), 'LineWidth', 1.8);
    grid on;
    xlabel('Real');
    ylabel('Imaginary');
    title([title_str ' - Nyquist Plot']);
    axis equal
    set(gca, 'FontSize', 12);
end

function plot_pzmap(config, R, L, C, title_str)
    s_syms = tf('s');
    if strcmpi(config, 'series')
        H_sys = 1 / (R + L*s_syms + 1/(C*s_syms));
    elseif strcmpi(config, 'parallel')
        H_sys = 1 / (1/R + 1/(L*s_syms) + C*s_syms);
    end
    figure;
    pzmap(H_sys);
    title([title_str ' - Pole Zero Map']);
    grid on;
end

function print_results(config, f_res, BW, Q)
    fprintf('\n--- %s RLC Circuit ---\n', upper(config));
    fprintf('Resonant Frequency (f_res) : %.2f Hz\n', f_res);
    fprintf('Bandwidth (BW)              : %.2f Hz\n', BW);
    fprintf('Quality Factor (Q)          : %.2f\n\n', Q);
end
