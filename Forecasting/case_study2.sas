DATA CASE;
     DO YEAR=73 TO 78;
        DO MONTH=1 TO 12;
           DATE=MDY(MONTH,1,YEAR);
		   one=1;
           INPUT LOAN @@;
		   Output;
        END;
     END;
KEEP DATE LOAN one; 
FORMAT DATE MONYY5.;
Title 'COMMERCIAL BANK REAL-ESTATE LOANS';
CARDS;
46.5 47 47.5 48.3 49.1 50.1 51.1 52 53.2 53.9 54.5 55.2 55.6 55.7 56.1
56.8 57.5 58.3 58.9 59.4 59.8 60 60 60.3 60.1 59.7 59.5 59.4 59.3 59.2
59.1 59 59.3 59.5 59.5 59.5 59.7 59.7 60.5 60.7 61.3 61.4 61.8
62.4 62.4 62.9 63.2 63.4 63.9 64.5 65 65.4 66.3 67.7 69 70 71.4
72.5 73.4 74.6 75.2 75.9 76.8 77.9 79.2 80.5 82.6 84.4 85.9 87.6
;
PROC PRINT;RUN;


proc gplot data=CASE;
	symbol1 color=blue interpol=join value=dot height=1;
	plot LOAN*DATE/href=0;
	run;

/*First order differencing */
data case1;
	set case;
	LOAN1=dif(LOAN);
run;

PROC PRINT ;
RUN;

proc gplot data=CASE1;
	symbol1 color=blue interpol=join value=dot height=1;
	plot LOAN1*DATE/href=0;
	run;

/*Second order differencing */
data case2;
	set case1;
	LOAN2=dif(LOAN1);
run;

PROC PRINT ;
RUN;

proc gplot data=CASE2;
	symbol1 color=blue interpol=join value=dot height=1;
	plot LOAN2*DATE/href=0;
	run;


/*Base tests */
proc arima data=case;
	identify var=loan stationarity=(adf=(0,1,2,3,4,5));
run;

/*1st order tests */
proc arima data=case1;
	identify var=loan1 stationarity=(adf=(0,1,2,3,4,5));
run;


/*2nd order tests */
proc arima data=case2;
	identify var=loan2 stationarity=(adf=(0,1,2,3,4,5));
run;

proc autoreg data=case2;
      model loan2 = date / nlag=1 archtest dwprob;
      output out=r r=yresid;
run;


/* Model Selection- identify with 2nd order differencing*/
proc arima data=case;
	identify var=loan(1,1) minic esacf scan;
run;

proc arima data=case;
	identify var=loan(1,1);
	estimate p=0 q=1 noconstant;
run;

/* Forecasting */
proc arima data=case;
	identify var=loan(1,1);
	estimate p=0 q=1 noconstant;
	forecast lead=24 out=a;
run;