libname datapath 'C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SleepHUB\JonnaMorris\SImPathILDexamp.v8xpt' ;
libname xptfile xport 'C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SleepHUB\JonnaMorris\SImPathILDexamp.v8xpt';


proc copy in = xptfile out = datapath ;

proc format library = work ;
	value SEXLAB
		1 = 'Female'
		2 = 'Male' ;

quit ;
