proc timeseries data=ts.ex2 plots=(series corr);
 id time interval=month;
 var sales;
run;

proc x12 data=ts.ex2 date=time;
 var sales;
 x11;
 output out=ex2Decomp A1 D10 D11 D12 D13;
run;

proc sgplot data=ex2Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D12;
 series x=time y=sales_D11; 
 series x=time y=sales_A1;
run;

proc sgplot data=ex2Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D10;
run;

proc sgplot data=ex2Decomp;
 styleattrs datacontrastcolors=(red blue green);
 series x=time y=sales_D13;
run;


proc sgplot data=ts.ex2;
 pbspline x=time y=sales / smooth=10000000;
run;

proc arima data=ts.ex2;
 identify var=sales;
 estimate p=1 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales;
 estimate p=2 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales;
 estimate p=2 q=1 method=ml;
run;/***All of these are a bad start because
 I have not made the series stationary***/

proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=2 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=1 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=1 q=1 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=2 q=1 method=ml;
run;

proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=1 q=2 method=ml; 
run;/***On the differenced series,
 the autoregressive component now
 appears weaker, and an MA component
 is required***/

proc timeseries data=ts.ex4 plots=(series corr) crossplots=(series ccf);
 id time interval=month;
 var sales;
 crossvar AdSpend;
run;

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate p=0 method=ml input=AdSpend;
 /**Direct correlation on same months for ads and sales,
   we want a 1 month lag***/
run;

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate p=0 method=ml input=(1 AdSpend);
 /***input=(lagBack variable) to get a correlation
  on a lagged predictor***/
run;

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate p=1 method=ml input=(1 AdSpend);
run;

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate q=1 method=ml input=(1 AdSpend);
run;
/*
proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate p=1 q=1 method=ml input=(1 AdSpend);
run;*/

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate q=2 method=ml input=(1 AdSpend);
run;

/***Forecasts...***/
proc arima data=ts.ex2;
 identify var=sales(1);
 estimate p=1 q=2 method=ml; 
 forecast id=time interval=month back=12 out=ex2Forecast;
run;

proc arima data=ts.ex4;
 identify var=sales crosscorr=AdSpend;
 estimate p=1 method=ml input=(1 AdSpend);
 forecast id=time interval=month back=12 lead=24 out=ex4Forecast;
run;


