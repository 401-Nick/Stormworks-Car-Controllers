function onTick()
	steering = input.getNumber(1)
	brake = input.getNumber(2)
	brake = brake * -1

	fLB = brake
	fRB = brake
	bLB = brake
	bRB = brake
	fLS = -steering
	fRS = steering
	
	output.setNumber(1, fLB)
	output.setNumber(2, fRB)
	output.setNumber(3, bLB)
	output.setNumber(4, bRB)
	output.setNumber(5, fLS)
	output.setNumber(6, fRS)
end
