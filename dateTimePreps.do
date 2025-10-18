*YYYY-MM-DD string format, covert to days since Jan 1st 1960
gen datestart1=date(datestart,"YMD")
*converst string HH:MM:SS format to numberic minutes since midnight
gen hour = real(substr(timestart, 1, 2))
gen minute = real(substr(timestart, 4, 2))
gen second = real(substr(timestart, 7, 2))
gen DayMinute=round((hour*60^2+minute*60+second)/60)

*make ild dataset example
keep matchid si_idx age start_date average_signal_quality-wake_transitions spo2_below90_duration_sec-spo2_below86_percent date questionlistname elapseday elapsehr mood_smiley-fatigue_slider ematime mSQI-dSAHI4 day DayMinute datestart1
gen studyhrs=elapseday*24+elapsehr
destring min_apnea_duration_sec mean_apnea_duration_sec cvhr_rem_percent-apnea_rem_index cvhr_stable_percent,replace force

save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SleepHUB\JonnaMorris\ILDexamp.dta", replace

*to MPLUS
foreach x of varlist average_signal_quality-mean_heart_rate_bpm ///
apnea_total_count_3-spo2_below86_percent elapseday-DayMinute{
	replace `x'=-9999 if missing(`x')
}
replace questionlistname=subinstr(questionlistname," ","",.)

export delimited using "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SleepHUB\JonnaMorris\ILDexam.dat", delimiter(tab) novarnames replace