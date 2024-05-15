local Kp = -0.0025
local Ki = 0
local Kd = 0
local integral = 0
local lastError = 0
local START_RPS_THRESHOLD = 2.5
local CRUISING_AFR = 25
local MIN_TEMP_ADJUSTMENT = 1
local MIN_TEMP_DEFAULT = 10
local MIN_FUEL_OUT = 0.05
local fuelOut = 0.1

function calculateLinearSpoolUpAFR(temp)
    local base_temp = MIN_TEMP_DEFAULT -- The temperature at which the AFR starts at 14.7
    local max_temp = 115 -- The temperature at which the AFR reaches its maximum of 20
    local min_AFR = 14.7 -- The minimum AFR value
    local max_AFR = 18 -- The maximum AFR value
    
    -- If the temperature is below the base temp, return the minimum AFR
    if temp <= base_temp then
        return min_AFR
    -- If the temperature is above the max temp, return the maximum AFR
    elseif temp >= max_temp then
        return max_AFR
    else
        -- Calculate the slope of the line
        local slope = (max_AFR - min_AFR) / (max_temp - base_temp)
        -- Use the point-slope form of a linear equation to calculate the AFR at the given temperature
        return min_AFR + slope * (temp - base_temp)
    end
end


function onTick()
    local starter = false
    
    local airVol =  input.getNumber(1)
    local fuelVol = input.getNumber(2)
    local temp =    input.getNumber(3)
    local rps =     input.getNumber(4)
    local wsInput = input.getNumber(6)
    local maxRps =  input.getNumber(9)
    local idleRps = input.getNumber(10)
    local airMax =  input.getNumber(11)

	local battery = input.getNumber(13)

    local ignition = input.getBool(1)
	local ecoMode = input.getBool(2)
	
	local spacebar = input.getBool(31)
	
	local motorReading = battery
	motorOutput = 0
	alt = ((battery * -1) + 1 )*10
	
	if spacebar then
		maxRps = maxRps * 2
	end
	
	if ecoMode then
		SPOOL_UP_AFR_BASE = 15.7
	else
		SPOOL_UP_AFR_BASE = 14.7
	end

    local targetRps = wsInput > 0.1 and maxRps or idleRps
    local SPOOL_UP_AFR = calculateLinearSpoolUpAFR(temp)

    if rps > maxRps or not ignition then
        baseAFR = CRUISING_AFR
	elseif not ignition then
		baseAFR = 50
	elseif (rps < idleRps or (wsInput > 0.1 and battery > .2)) then
		motorOutput = (math.max(0, math.min(motorReading, 1)))
		baseAFR = SPOOL_UP_AFR
    else
        baseAFR = (rps < targetRps or wsInput > 0.1) and SPOOL_UP_AFR or CRUISING_AFR
    end

    local afr = fuelVol > 0 and ((airVol / fuelVol)) or 0
    local adjustedTemp = math.max(temp, MIN_TEMP_ADJUSTMENT)

    local PID_output = Kp * (baseAFR - afr)

    fuelOut = math.max(MIN_FUEL_OUT, math.min(fuelOut + PID_output, 1))

    starter = rps < START_RPS_THRESHOLD and ignition


	if (rps < idleRps and ignition) then
		motorOutput = (math.max(0, math.min(motorReading, 1)))/8
	end

    output.setBool(1, starter)
    output.setNumber(2, fuelOut)
    output.setNumber(3, temp)
    output.setNumber(4, afr)
	output.setNumber(5, maxRps)
	output.setNumber(6, motorOutput)
	output.setNumber(7, alt)
    output.setNumber(32, baseAFR)
end
