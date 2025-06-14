% MCTA 4354: System Modelling and Identification - Mini Project
% Project: System Identification of an RC Electrical Circuit
% Group Members: [Your Names Here]
% Date: June 4, 2025

%% 1. Data Collection: Load and Process Your MultiSim Data
% Your provided raw data with non-uniform time steps (t and Vo)
time_data_original = [
    0; 0.001; 0.002; 0.004; 0.008; 0.016; 0.032; 0.064; 0.128; 0.228;
    0.328; 0.42800000000000005; 0.528; 0.628; 0.728; 0.828; 0.9279999999999999;
    1.028; 1.1280000000000001; 1.2280000000000002; 1.3280000000000003; 1.4280000000000004;
    1.5280000000000005; 1.6280000000000006; 1.7280000000000006; 1.8280000000000007;
    1.9280000000000008; 2.02800000000001; 2.12800000000001; 2.22800000000001;
    2.32800000000001; 2.42800000000013; 2.52800000000014; 2.62800000000014;
    2.72800000000015; 2.82800000000016; 2.92800000000017; 3.0280000000002;
    3.1280000000002; 3.2280000000002; 3.3280000000002; 3.4280000000002;
    3.52800000000022; 3.62800000000023; 3.72800000000024; 3.82800000000025;
    3.92800000000026; 4.0280000000002; 4.1280000000002; 4.22800000000015;
    4.3280000000001; 4.4280000000001; 4.52800000000005; 4.628; 4.728;
    4.827999999999999; 4.927999999999999; 5
]; % Your recorded time points from MultiSim
output_voltage_original = [
    0; 0.004995004994955094; 0.009985019974880363; 0.019955079874731347;
    0.03983549871635336; 0.0793587218294026; 0.15746413892442618;
    0.30998495337287746; 0.6008385993929086; 1.0198063510599435;
    1.3988724117120066; 1.7418369424343347; 2.0521381842053623;
    2.332886926478649; 2.5868976930426895; 2.816716957798807;
    3.02464867332208; 3.2127773681307263; 3.38298904421553;
    3.536990084328346; 3.676324358576449; 3.8023887018173994;
    3.916446917016297; 4.019642444949942; 4.113009827272495;
    4.197485077860592; 4.2739150664112975; 4.343066008364041;
    4.405631146258564; 4.462237699534955; 4.513453152447965;
    4.559790943132328; 4.601715610852342; 4.639647453037185;
    4.673966738789066; 4.705017521104879; 4.733111086029117;
    4.758529073316041; 4.7815262998859165; 4.802333314380659;
    4.8211587084284595; 4.838191207787965; 4.853601564335877;
    4.86754426786525; 4.88015909485537; 4.891572509739748;
    4.901898932720024; 4.91124188683567; 4.919695035788971;
    4.9273431229295275; 4.934262820811666; 4.94052349984161;
    4.946187923720167; 4.95131287865277; 4.955949742634761;
    4.960145000519025; 4.963940710029553; 4.966446757619258
]; % Your recorded output voltage from MultiSim

% --- Resampling Data to a Uniform Sampling Time ---
Ts_uniform = 0.001; % seconds
time_resampled = (0 : Ts_uniform : time_data_original(end))';
output_voltage_resampled = interp1(time_data_original, output_voltage_original, time_resampled, 'linear', 'extrap');
input_voltage_resampled = 5 * ones(size(time_resampled)); % Assuming a 5V step input
data = iddata(output_voltage_resampled, input_voltage_resampled, Ts_uniform);

%% 2. Plot Input-Output Data (Resampled)
figure;
subplot(2,1,1); plot(data.samplinginstants, data.u); title('Resampled Input Signal (DC 5V)'); ylabel('Voltage (V)'); grid on;
subplot(2,1,2); plot(data.samplinginstants, data.y); title('Resampled Output Signal (from MultiSim)'); ylabel('Voltage (V)'); grid on;
xlabel('Time (s)');

%% 3. Model Selection and Estimation (ARMAX Model)
% ARMAX Model Order Selection
% na: Order of the A polynomial (denominator of the AR part)
% nb: Order of the B polynomial (numerator of the input part)
% nc: Order of the C polynomial (numerator of the noise part)
% nk: Input delay in number of samples (1 for a causal system where y(t) depends on u(t-1))
na = 2;
nb = 1;
nc = 1;
nk = 2; % For a first-order RC circuit, an input delay of 1 or 2 samples often works well
        % depending on the exact implementation and sampling rate.

% Estimate the ARMAX model
identified_model = armax(data, [na nb nc nk]);

disp(' ');
disp('--- Identified ARMAX Model Parameters ---');
present(identified_model); % Displays the estimated model in a user-friendly format
disp(' ');

% Extract coefficients to relate to theoretical time constant (for 1st order ARMAX)
% For an ARMAX model: A(q^-1)y(t) = B(q^-1)u(t-nk) + C(q^-1)e(t)
% Where A(q^-1) = 1 + a1*q^-1 + a2*q^-2 + ...
% For a first-order system, we are interested in a1 from the A polynomial.
if na >= 1
    a1_identified = identified_model.A(2); % The second coefficient of the A polynomial (a1)

    % The time constant (tau) for a first-order discrete system with a pole 'p'
    % (where p = -a1_identified for A(q^-1) = 1 + a1*q^-1) is:
    % tau = -Ts_uniform / log(abs(p))
    % So, tau = -Ts_uniform / log(abs(-a1_identified)) = -Ts_uniform / log(abs(a1_identified))

    % Check for valid range: For a stable discrete pole, abs(pole) < 1.
    % Also, for a typical RC circuit step response, the pole is real and between 0 and 1,
    % meaning a1 will be between -1 and 0.
    if a1_identified < 0 && a1_identified > -1
        tau_estimated = -Ts_uniform / log(abs(a1_identified));
        disp(['Estimated Time Constant (tau) from ARMAX A-polynomial: ', num2str(tau_estimated, '%.4f'), ' seconds']);
    else
        disp('Cannot reliably estimate tau directly from ARMAX A-polynomial''s a1 coefficient.');
        disp('The estimated a1 (pole) is outside the stable range (-1, 0) or is not negative.');
    end
    disp(['Estimated Difference Equation Denominator: A(q^-1) = 1 + (', num2str(a1_identified, '%.4f'), ')q^-1']);
else
    disp('ARMAX A polynomial order (na) is 0, so no a1 coefficient for tau estimation.');
end

% Display B and C polynomial coefficients if desired
if nb >= 1
    b_coeffs = identified_model.B;
    disp(['Estimated Transfer Function Numerator (B polynomial): ', mat2str(b_coeffs)]);
end
if nc >= 1
    c_coeffs = identified_model.C;
    disp(['Estimated Noise Model Numerator (C polynomial): ', mat2str(c_coeffs)]);
end

%% 4. Model Validation
% First call compare with output arguments to get the fit percentage
[~, Fit_Percentage] = compare(data, identified_model);

% Then, call compare without output arguments to generate the plot
figure;
compare(data, identified_model); % This call generates the plot
title('Model Comparison: Identified Model vs. MultiSim Data'); % Title will be applied to the plot generated by compare
grid on;

% Display the accuracy value
disp(['Model Fit Accuracy: ', num2str(Fit_Percentage(1), '%.2f'), '%']);

figure;
resid(data, identified_model); % Perform residual analysis to check model fit and noise characteristics
sgtitle('Residual Analysis'); % Set a main title for the residual plots

%% 5. Calculate Theoretical Time Constant (for comparison)
% --- IMPORTANT: REPLACE THESE VALUES WITH YOUR ACTUAL R AND C VALUES FROM YOUR MultiSim CIRCUIT ---
R_val = 1000; % Your Resistor value from MultiSim (in Ohms, e.g., 1kOhm = 1000)
C_val = 0.000001; % Your Capacitor value from MultiSim (in Farads, e.g., 1uF = 0.000001)
% --- END OF REPLACE SECTION ---

Theoretical_Tau = R_val * C_val; % Calculate the theoretical time constant
disp(['Theoretical Time Constant (R*C) from MultiSim values: ', num2str(Theoretical_Tau, '%.4f'), ' seconds']);

% This comparison is meaningful if 'tau_estimated' was calculated for the chosen model.
if exist('tau_estimated', 'var') && ~isempty(tau_estimated) && ~isnan(tau_estimated)
    disp(['Difference (Estimated - Theoretical): ', num2str(tau_estimated - Theoretical_Tau, '%.4f'), ' seconds']);
    disp(['Percentage Difference: ', num2str(abs((tau_estimated - Theoretical_Tau)/Theoretical_Tau * 100), '%.2f'), '%']);
else
    disp('Tau estimation was not performed or was unreliable for this model type/parameters, so direct comparison is not available.');
end