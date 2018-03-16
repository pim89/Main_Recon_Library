PROJECT DESCRIPTION: 
	Setup a modular reconstruction framework that allows for easy prototyping and has all the available resources.

	Init: T. Bruijnen @ 20180316
	Last edit: T. Bruijnen 20180316


Data format:
	Default dataformat is the 12D one employed by reconframe.
	Image space: [X,Y,Z,COIL,DYN,PH,ECH,MIX,LOC,EX1,EX2,AVE]
	K-space: [KX,KY,KZ,COIL,DYN,PH,ECH,MIX,LOC,EX1,EX2,AVE]
	K-space coords: [3 KX,KY,KZ,DYN,PH,ECH,MIX,LOC,EX1,EX2,AVE]


Tested and supported features:
	Read lab/raw data from reconframe
	Read par/rec data from reconframe
	Extract PPE parameters from reconframe --> Template?
	Radial trajectory and density functions work now
TODO:
	Integrate NUFFT code from FlatIron https://github.com/dfm/finufft/tree/master/matlab
	BART radial trajectory and tiny golden angle

