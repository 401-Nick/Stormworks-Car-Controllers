### ECM (Engine Control Module):

#### Variables:
- `fuelAdjustVol` (float): Adjustment volume for the fuel, initialized to 0.
- `integralError` (float): Integral part of the PID control error, initialized to 0.
- `prevError` (float): Previous error value, initialized to 0.
- `targetAFR` (float): Target Air-Fuel Ratio (AFR), initialized to 13.7.
- `clutchOutput` (float): Clutch output value, initialized to 0.
- `startAFR` (float): Starting AFR, initialized to 13.7.
- `endAFR` (float): Ending AFR, initialized to 25.
- `scalingTemp` (int): Scaling temperature, initialized to 115.

#### Functions:
- `onTick()`: Main function called on each tick; handles ignition, steering position, throttle position, shifting position, engine power, etc.
- `ignitionAndLowRPM()`: Returns true if ignition is on and engineRps is less than 3.
- `throttleAndRPMConditions()`: Returns true based on throttle position and engineRps conditions.
- `updateTargetAFR()`: Updates the target AFR based on engine temperature.
- `clutch()`: Calculates and returns the clutch output.
- `setAFR()`: Calculates and returns the adjusted fuel volume using PID control.

### Control:

#### Functions:
- `onTick()`: Main function called on each tick; responsible for steering, braking, and front/rear brake logic.

##### Output:
- `output.setNumber(1, fLB)`: Front Left Brake
- `output.setNumber(2, fRB)`: Front Right Brake
- `output.setNumber(3, bLB)`: Back Left Brake
- `output.setNumber(4, bRB)`: Back Right Brake
- `output.setNumber(5, fLS)`: Front Left Steering
- `output.setNumber(6, fRS)`: Front Right Steering

In the Control section, steering and braking inputs are processed, and corresponding outputs are set. The steering is inverted for the front left side, and the brake values are multiplied by -1 before being used for all the brakes.