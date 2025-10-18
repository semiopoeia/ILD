*sqi
*person mean
egen mSQI=mean(sqi), by(si_idx)
*daily deviations
gen dSQI=sqi-mSQI

*sAHI 3%
*person mean
egen mSAHI3=mean(sahi_3), by(si_idx)
*daily deviations
gen dSAHI3=sahi_3-mSAHI3

*sAHI 4%
*person mean
egen mSAHI4=mean(sahi_4), by(si_idx)
*daily deviations
gen dSAHI4=sahi_4-mSAHI4

foreach y of varlist mood_smiley stress_smiley sleepiness_slidernegpos fatigue_slidernegpos{
	mixed `y'||si_idx:
	estimates store l2
	estat icc
	mixed `y'||si_idx: ||elapseday:
	estimates store l3
	estat icc
	lrtest l3 l2
	mixed `y' mSQI dSQI||si_idx: 
	mixed `y' mSAHI3 dSAHI3||si_idx: 
	mixed `y' mSAHI4 dSAHI4||si_idx: 
	mixed `y' mSQI dSQI mSAHI3 dSAHI3||si_idx: 
	mixed `y' mSQI dSQI mSAHI4 dSAHI4||si_idx: 
	*direct for each momentary measure
	bysort questionlistname: mixed `y' sqi ||si_idx:
	bysort questionlistname: mixed `y' sahi_3||si_idx:
	bysort questionlistname: mixed `y' sahi_4||si_idx:
}

foreach y of varlist mood_smiley stress_smiley{
	mixed `y' mSQI dSQI||si_idx: ||elapseday: 
	mixed `y' mSAHI3 dSAHI3||si_idx: ||elapseday:
	mixed `y' mSAHI4 dSAHI4||si_idx: ||elapseday:
	mixed `y' mSQI dSQI mSAHI3 dSAHI3||si_idx: ||elapseday:
	mixed `y' mSQI dSQI mSAHI4 dSAHI4||si_idx:  ||elapseday:
}

foreach y of varlist mood_smiley stress_smiley{
	mixed `y' c.mSQI##birthsex c.dSQI##birthsex c.mSAHI4##birthsex c.dSAHI4##birthsex||si_idx: ||elapseday:
	*direct for each momentary measure
	bysort questionlistname: mixed `y' c.sqi##birthsex ||si_idx:
	bysort questionlistname: mixed `y' c.sahi_3##birthsex||si_idx:
	bysort questionlistname: mixed `y' c.sahi_4##birthsex||si_idx:
}

foreach y of varlist sleepiness_slidernegpos fatigue_slidernegpos{
	mixed `y' c.mSQI##birthsex c.dSQI##birthsex c.mSAHI4##birthsex c.dSAHI4##birthsex||si_idx: 
	*direct for each momentary measure
	bysort questionlistname: mixed `y' c.sqi##birthsex ||si_idx:
	bysort questionlistname: mixed `y' c.sahi_3##birthsex||si_idx:
	bysort questionlistname: mixed `y' c.sahi_4##birthsex||si_idx:
}

mixed fatigue_slidernegpos c.mSQI##birthsex c.dSQI##birthsex||si_idx:

*stratified.
foreach y of varlist mood_smiley stress_smiley sleepiness_slidernegpos fatigue_slidernegpos{
bysort birthsex: mixed `y' c.mSQI c.dSQI||si_idx:
bysort birthsex: mixed `y' c.mSAHI3 c.dSAHI3||si_idx:
bysort birthsex: mixed `y' c.mSAHI4 c.dSAHI4||si_idx:
bysort questionlistname birthsex: mixed `y' c.sqi ||si_idx:
bysort questionlistname birthsex: mixed `y' c.sahi_3||si_idx:
bysort questionlistname birthsex: mixed `y' c.sahi_4||si_idx:
}

foreach y of varlist mood_smiley stress_smiley sleepiness_slidernegpos fatigue_slidernegpos sqi sahi_3 sahi_4{
mixed `y' i.birthsex||si_idx:
bysort questionlistname:mixed `y' i.birthsex||si_idx:
}

foreach y of varlist mood_smiley stress_smiley sleepiness_slidernegpos fatigue_slidernegpos sqi sahi_3 sahi_4{
	ttest `y', by(birthsex) unequal welch
	bysort questionlistname:ttest `y', by(birthsex) unequal welch
}