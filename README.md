## Outline of the scripts in the study
### Presentation
	mySARTv11.1.py
### Behavioral analysis
	FlickeringSART_div_Beh_single.Rmd
### Pre-processing
	SSVEP_div_PC2_formal.m 
	-- Pre-processing of EEG: From original data to averaged mat in the folder of "PreCleanICApostAve"
### Average level:
	ERPs 
		erpsSSVEP.m
		-- Detecting averaged ERP
		Dependent on "erpPeaki" function
		-- save the individual peaks to files: "Ave_State_n1.csv","Ave_State_p1.csv", "Ave_State_p3.csv";
		    "Ave_Stick_n1.csv","Ave_Stick_p1.csv", "Ave_Stick_p3.csv"
		-- Save the waveform to folder "ERPsPeaks"
	
	Oscillation:
		computePower_Flicker_whole.m
		-- Computing power oscillations of post-stimulus interval and save it to folder "Pw900_whole". 
		Dependent functions: "electrodePower_whole.m","groupPower_whole.m","trialPower_whole.m";
		"filHil.m","splTrial.m","meanSpectrum.m"
		
		AlphaThetaSSVEP_solution2.m
		--Convert Single trial power oscillations from folder of "Pw900_whole" 
		Save average power oscillations to files:
		bandExport_wide_er900_whole.mat
		bandExport_wide_stickiness_er900_whole.mat
		strs_sub.mat
		-- Alternative way to compute single trial power oscillations and save it to folder "Pw"
	ITC:
		AmpPwSSVEP_TF.m
		-- compute ITC across frequencies, save to folder "SSVEPPeaks_Oz_-2001200_wind500900_freqwind1213alpha"
		Dependent on "ssvepPeak.m", "freqsPeak_ave" and "itcPeaks2D" function
### Single trial Level
	Single trial ERP
		Run_ST.m
		-- Single trial ERP, save to folder "ST"
		Dependent on the "computeSingleTrialERP_diy" and "compute_Wst" function
		
	Single trial oscillation
		computePower_Flicker
		--Computing power oscillations of pre-stimulus and post-stimulus interval separately
		dependent on "electrodePower.m","groupPower.m","trialPower.m";
	Single trial ERSP
		itcpwSSVEP_trial.m
		-- Compute Single trial ERSP, detect the peak ERSP, save to folder "ITC_ST_exact"
		Dependent on the "sumitcPeaks_exact" and "itcPeaks2D_exact" function for finding peak ERSP and their frequencies
### Classification
    ModelingFlickeringSART_ersp.Rmd
    ModelingFlickeringSART_cca.Rmd
