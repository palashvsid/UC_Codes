DATA CASE;
	DO YEAR=1955 TO 1979;

		DO QUARTER=1 TO 4;
			DATE=YYQ(YEAR, QUARTER);
			INPUT SAVING @@;
			ONE=1;
			OUTPUT;
		END;
	END;
	KEEP DATE SAVING ONE;
	FORMAT DATE YYQ4.;
	*LABEL SAVING=(PERSONAL SAVING/DISPOSABLE INCOME)*100;
	CARDS;
4.9 5.2 5.7 5.7 6.2 6.7 6.9 7.1 6.6 7 6.9 6.4 6.6 6.4 7 7.3 6 6.3 4.8
5.3 5.4 4.7 4.9 4.4 5.1 5.3 6 5.9 5.9 5.6 5.3 4.5 4.7 4.6 4.3 5 5.2
6.2 5.8 6.7 5.7 6.1 7.2 6.5 6.1 6.3 6.4 7 7.6 7.2 7.5
7.8 7.2 7.5 5.6 5.7 4.9 5.1 6.2 6 6.1 7.5 7.8 8 8 8.1 7.6 7.1
6.6 5.6 5.9 6.6 6.8 7.8 7.9 8.7 7.7 7.3 6.7 7.5 6.4 9.7 7.5 7.1 6.4
6 5.7 5 4.2 5.1 5.4 5.1 5.3 5 4.8 4.7 5 5.4 4.3 3.5
;

PROC PRINT ;
RUN;

proc gplot data=CASE;
	symbol1 color=blue interpol=join value=dot height=1;
	plot SAVING*DATE/href=0;
	run;

data case1;
	set case;
	saving1=dif(saving);
run;

PROC PRINT ;
RUN;

proc gplot data=CASE1;
	symbol1 color=blue interpol=join value=dot height=1;
	plot SAVING1*DATE/href=0;
	run;
	
	
proc autoreg data=case;
      model saving = date / nlag=1 archtest dwprob;
      output out=r r=yresid;
run;

proc autoreg data=case1;
      model saving1 = date / nlag=1 archtest dwprob;
      output out=r r=yresid;
run;

proc arima data=case;
	identify var=saving stationarity=(adf=(0,1,2,3,4,5));
run;

proc arima data=case1;
	identify var=saving1 stationarity=(adf=(0,1,2,3,4,5));
run;


proc arima data=case1;
	identify var=saving1(1) minic esacf scan;
run;

proc arima data=case1;
	identify var=saving1(1);
	estimate p=1 q=0;
run;

/*Mean of the series is not significant so include option noconstant*/
proc arima data=case1;
	identify var=saving1(1);
	estimate p=1 q=0 noconstant;
run;

proc arima data=case1;
	identify var=saving1(1);
	estimate p=0 q=1 noconstant;
run;

proc arima data=case1;
	identify var=saving1(1);
	estimate p=1 q=0 noconstant;
	forecast lead=8 out=a;
run;
