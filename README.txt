PROJECT DESCRIPTION: 
	Setup a modular reconstruction framework that allows for easy prototyping and has all the available resources.

	Init: T. Bruijnen @ 20180316
	Last edit: T. Bruijnen @ 20180320


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
	Radial phase corrections zero method
    	Openadapt and espirit matlab implementations work now
    	Option to load k-space data from directory if it was saved
	Iterative density estimation code works for 3D
	Respiratory motion estimation from multi-channel data (coil clustering)
	Respiratory phases binning and transformation of matrices
	Noise prewhitening included
	Radial phase correction model-based
	General TV operator as sparse matrix
	LSQR iterative L2 TV sense 2D
	FlatIron 2D/3D NUFFT added
	LSQR iterative L2 TV sense 3D
	NLCG iterative L1 TV sense 2D / 3D
	Generic view sharing function

TODO:
	BART radial trajectory add tiny golden angle
	Iterative DCF estimation for 2D trajectories
	Fessler 3D NUFFT shift bug
	Greengard 3D forward NUFFT operation seems to be bugged
	Method to process the GIRF
	Verbose arguments to all functions


