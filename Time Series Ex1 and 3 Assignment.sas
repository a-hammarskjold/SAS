/*Exercise 1*/
proc timeseries data=ts.ex1 plots=(corr series);
	id time interval=month;
	var sales;
run;

ods select none;
proc x12 data=ts.ex1 date=time;
 var sales;
 x11;
 output out=ex1Decomp A1 D10 D11 D12 D13;
run;

ods select all;
proc sgplot data=ex1Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D12;
 series x=time y=sales_D11; 
 series x=time y=sales_A1;
run;

proc sgplot data=ex1Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D10;
run;

proc sgplot data=ex1Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D13;
run;

proc arima data=ts.ex1;
 identify var=sales(1);
 estimate q=2 method=ml;
 forecast id=time interval=month back=12 out=forecast1;
run;

/*The best model I found for this timeseries data is a 2nd order moving-average model. This
was determined using the auto-correlation function plot and partial auto-correlation
function plot. In the ACF, there was a quick drop following the 2nd lag (indicative 
of moving average) and the 2nd lag in the PACF was outside the bounding box. This 
ARIMA model also produced the lowest AIC and SBC scores, 2477 and 2486, respectively. 
The forecast for the data proved to be extremely poor; it only predicted the mean of 
the sales. If we look at the output of the X12 procedure, we can see the data exhibits
non-linearity, a possible shifting in seasonality, and errors which are quite large.*/

/*Exercise 3*/
proc timeseries data=ts.ex3 plots=(corr series);
	id time interval=month;
	var sales;
run;

ods select none;
proc x12 data=ts.ex3 date=time;
 var sales;
 x11;
 output out=ex3Decomp A1 D10 D11 D12 D13;
run;

ods select all;
proc sgplot data=ex3Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D12;
 series x=time y=sales_D11; 
 series x=time y=sales_A1;
run;

proc sgplot data=ex3Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D10;
run;

proc sgplot data=ex3Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D13;
run;

proc arima data=ts.ex3;
 identify var=sales(1);
 estimate p=2 q=4 method=ml;
 forecast id=time interval=month back=12 out=forecast1;
run;

/*The best model I found for this timeseries data is a 2nd order auto-regressive, followed
by a 4th order moving average model. Looking at the D10 plot, the primary/secondary peaks
appear every 4th month and each peak/valley appear 2 months apart. This suggests seasonality 
at the 2nd and 4th lags. Initially, the ACF strongly suggests auto-regression with the PACF
suggesting this occurs at the 2nd lag. Once that was accounted for, the residual ACF was highly
suggestive of moving average with the PACF suggesting this occurs at the 2nd and 4th lags and failing
the white noise test. Ultimately, the 4th lag was used for the residuals as it produced the 
lowest AIC/SBC scores and provided a forecast which modeled the trend best.*/

