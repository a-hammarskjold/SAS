/*Exercise 3*/
proc logistic data=sashelp.heart;
	class sex ;
	model bp_status = AgeAtStart Weight Sex / link=alogit;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

/*Exercise 5*/
data real_estate;
	set sasprg.real_estate;
	price = price/1000;
run;

proc logistic data=real_estate;
	model qual = price sq_ft pool / link=alogit;
	ods select ResponseProfile ParameterEstimates OddsRatios;
run;

/*The model to predict home quality is:
Price - is significant with a p-value <0.0001. For a $1000 
		increase in price (sq_ft and pool fixed), the odds 
		of having quality status 1 increases by 2.5%.
Square Footage - is significant with a p-value of <0.0001.
		For a 1 sqft. increase in home size (price and pool fixed), 
		the odds of	having quality status 1 increases by 0.1%.
Pool - is not significant with a p-value of 0.6624. Therefore,
		it will be dropped from the model.