fuelAdjustVol = 0
integralError = 0
prevError = 0
targetAFR = 13.7
clutchOutput = 0
startAFR = 13.7
endAFR = 25
scalingTemp = 115

function onTick()
    ignition    = input.getBool(1)
    
    steeringPos = input.getNumber(1)
    throttlePos = input.getNumber(2)
    shiftPos    = input.getNumber(3)
    enginePower = input.getNumber(4)
    airVol      = input.getNumber(5)
    fuelVol     = input.getNumber(6)
    engineTemp  = input.getNumber(7)
    idleRps     = input.getNumber(8)
    maxRps      = input.getNumber(9)
    engineRps   = input.getNumber(10)
    maxTemp = 100

    Kp = -0.002
    Ki = 0
    Kd = 0

    if engineRps < 1 then engineRps = 0.01 end

    if ignitionAndLowRPM() then
        output.setBool(1, true)
    else
        output.setBool(1, false)
    end

    if throttleAndRPMConditions() then
        updateTargetAFR()
    else
        targetAFR = endAFR
    end

    output.setNumber(1, setAFR())
    output.setNumber(2, clutch())
    output.setNumber(3, 1)
end

function ignitionAndLowRPM()
    return ignition == true and engineRps < 3
end

function throttleAndRPMConditions()
    return (throttlePos > 0.1 and engineRps < maxRps) or engineRps < idleRps
end

function updateTargetAFR()
    if engineTemp <= 100 then
        targetAFR = startAFR
    elseif engineTemp >= scalingTemp then
        targetAFR = endAFR
    else
        targetAFR = startAFR + (endAFR - startAFR) * ((engineTemp - 100) / (scalingTemp - 100)) -- Linear interpolation
    end
end

function clutch()
    clutchOutput = (engineRps-idleRps)/(maxRps-idleRps)
    return clutchOutput
end

function setAFR()
	if engineRps > maxRps then
		Kp = -0.001
	end
	
    local currentAFR = airVol / (fuelVol + 0.00001)
    local error = targetAFR - currentAFR
    integralError = integralError + error

    local derivativeError = error - prevError
    local PIDControl = Kp * error + Ki * integralError + Kd * derivativeError

    fuelAdjustVol = fuelAdjustVol + PIDControl
    prevError = error

    if fuelAdjustVol > 1 then
        fuelAdjustVol = 1
    end

	if fuelAdjustVol < 0 then
        fuelAdjustVol = 0
    end

    return fuelAdjustVol

end
