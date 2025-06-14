# RC Circuit System Identification

## Project Overview

This repository contains the MATLAB code and resources for a **system identification project** focused on modeling the dynamic behavior of a simple **RC (Resistor-Capacitor) circuit**. The project utilizes simulated data from Multisim to identify a robust mathematical model using the **ARMAX (Autoregressive Moving Average with eXogenous input)** method. The goal is to demonstrate how system identification techniques can accurately capture the input-output relationship of a physical system.

## System Description: The RC Circuit

The subject of this study is a basic RC circuit, simulated in Multisim.

* **Input (**$u(t)$**):** Voltage applied across the series RC combination.

* **Output (**$y(t)$**):** Voltage measured across the capacitor.

This setup allows for the observation of the capacitor's charging and discharging response to input changes. The input and output data were recorded from this simulation to serve as the dataset for system identification.

## Model Selection: ARMAX

The **ARMAX model** was chosen due to its suitability for input-output systems and its ability to handle dynamic behavior and colored noise effectively.

### Justification for ARMAX:

* **Input-Output System:** An RC circuit is inherently an input-output system, and ARMAX explicitly captures this causal relationship between input and output.

* **Dynamic Nature:** The AR (Autoregressive) component models the circuit's inherent "memory" (dependence on past values).

* **Handling Noise:** The MA (Moving Average) component allows for modeling of **colored noise**, which is common in real-world measurements and provides more accurate parameter estimates than models assuming purely white noise (like ARX).

### Justification for Specific Orders:

The selected polynomial orders were $na=2, nb=1, nc=1$, and $nk=1$.

* $na=2$ **(Order of A polynomial):** While a theoretical ideal RC circuit is first-order, $na=2$ (a slight "over-ordering") provides **additional flexibility**. This helps capture any subtle higher-order dynamics from non-ideal components or effectively whiten complex residuals, ensuring a more robust model.

* $nb=1$ **(Order of B polynomial):** This represents a **direct and immediate influence** of the input on the output, consistent with how voltage directly drives an RC circuit.

* $nc=1$ **(Order of C polynomial):** This order is generally sufficient to model common types of **colored measurement noise** or low-frequency disturbances without unnecessary complexity.

* $nk=1$ **(Input Delay):** This signifies a **causal minimum delay** of one sample between when an input is applied and when it first affects the output, a standard assumption for discrete-time physical systems.

## Methodology and Results

1. **Data Preparation:** Input and output data from Multisim were **resampled** to ensure a constant time step, a requirement for MATLAB's System Identification Toolbox.

2. **Model Identification:** The ARMAX model was identified using the processed data in MATLAB.

3. **Model Validation:**

   * **Model Comparison:** The identified model's output was compared against the actual Multisim validation data. The results showed a **near-perfect overlap** with a **99.91% Model Fit Accuracy**, strongly validating the model's ability to predict the RC circuit's response.

   * **Residual Analysis:**

     * **Autocorrelation of Residuals:** Plots confirmed that residuals were **white noise** (uncorrelated at non-zero lags), indicating all dynamic information was captured.

     * **Cross-correlation between Input and Residuals:** Plots showed **no correlation** between the input and residuals, confirming the model fully accounted for the linear input-output relationship.

## Files in this Repository

* `RC_Circuit_Data.mat`: (Placeholder) - Simulated input and output data from Multisim.

* `identify_rc_circuit.m`: (Placeholder) - MATLAB script for data loading, preprocessing, ARMAX identification, and validation.

* `plots/`: (Placeholder) - Directory for generated plots (Model Comparison, Residual Analysis).

*(**Note:** Replace placeholders with actual file names once you upload them.)*

## How to Use

1. Clone this repository:


git clone https://github.com/your-username/RC-Circuit-System-ID.git
cd RC-Circuit-System-ID


2. Open MATLAB.

3. Navigate to the cloned repository directory.

4. Run the `identify_rc_circuit.m` script. This script will load the data, perform the system identification, and generate the validation plots.

## Conclusion

This project successfully demonstrates the application of system identification using the ARMAX model to accurately characterize an RC circuit. The high model fit accuracy and excellent residual analysis confirm the robustness and predictive power of the identified model.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
