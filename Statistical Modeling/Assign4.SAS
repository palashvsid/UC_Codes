/* 12.9 with added stuff*/

/* Regression with Autocorrelated Errors */
data a; 
input Y X;time+1;
label Y = 'Value of Components Used' X= 'Industry Production Value';
cards; 
  102.9  2.052
  101.5  2.026
  100.8  2.002
   98.0  1.949
   97.3  1.942
   93.5  1.887
   97.5  1.986
  102.2  2.053
  105.0  2.102
  107.2  2.113
  105.1  2.058
  103.9  2.060
  103.0  2.035
  104.8  2.080
  105.0  2.102
  107.2  2.150
;

proc print data=a;run;
proc sgplot data=a noautolegend;
   series x=time y=y / markers; 
   reg x=time y=y/  lineattrs=(color=black);
title 'Initial plots with superimplosed Time Trend line';
run;

proc print data=a;run;
/*12.9a) OLS fit, 12.9b) The residual plot clearly shows nonrandom pattern
  indicative of AR error process.*/
proc reg data=a;
 var time;
 model  y=x;
 plot r.*time/vref=0;
 output out=new p=yhat r=res;
 title 'OLS regression with iid normal error structure';
 run;
proc print data=new;run;

title 'Simple model with no AR error: Durbin-Watson Test';
ods graphics on;
proc autoreg data=a plots = all;/*Plot of trend line and the data*/
   model y = x/DW=2 DWPROB;
   output out=new1 r=resid p=predict;
run;
/*12.9c)Try Durbin-Watson test with AR(1) and AR(2). Also, look at ACF plot.
DW test shows AR(2) is not significant, but AR(1)for positive autocorrelation
is significant (p=0.0025).So use AR(1) error model. 
Also, the ACF plot shows a pattern indicative of an AR error process, i.e.,it
does not look like a white noise error process (one spike and 
 no other significant spikes).  This agrees with the residual plot.*/
data new3; set new1;;
proc print data=new3;run;
proc gplot data=new3; plot resid*time/vref=0;run;
title 'Full model with stuctural part and AR(1) error ONLY';
proc autoreg data=a plots = all;
   model y = x / DW=1 DWPROB nlag=1 method=ml;
run;
/*Using AR(1) error model, ACF looks more like white noise.  DW test shows
there is no longer any AR behavior in the residuals (p=0.8856). The R-sq of 0.9132 is 
for the trend model only and the Total R-Square=0.9624 is for the full model 
with the AR(1) error model*/
data b;
input Y X time; 
cards;
. 2.210 17
;
data c;set a b;
proc print data=c;
title ' Add new data point to data';run;


proc autoreg data=c plots = all;
   model y = x / nlag=1 method=ml;
   output out=predictions p=yhat pm=trendhat r=resid alphacli=.05 lcl=lower95 ucl=upper95;;
title 'Full model fit with predictions & prediction intervals';run;
proc gplot data=predictions;
plot resid*time/vref=0;run;
proc print data=predictions;run;
/* At time 17 with X=2.210, the trend prediction is 110.918.  The prediction
for the full model with AR(1) error is 110.532 . The 95% prediction interval
for time 17 is (108.470, 112.595) */
proc sgplot data=predictions;
   scatter x=time y=y / markerattrs=(color=blue);  
   series x=time y=yhat / lineattrs=(color=blue);
   series x=time y=trendhat / lineattrs=(color=black);
title1 'Predictions for Autocorrelation Model';
title2 'Plots of predictions, trendline (of the mean w/o AR error)';run;

proc print data=predictions;
title 'Predictions with and without AR error for Autocorrelation Model';run;

/*Chapter 13*/

data A;
input Y X; obs+1;
label y = 'Proportion Purchasing'
      x = 'Price of Computer';
cards;
 0.65     200
 0.46     400
 0.34     800
 0.26    1200
 0.17    1600
 0.15    2000
 0.06    3000
 0.04    4000
 0.63     200
 0.50     400
 0.30     800
 0.24    1200
 0.19    1600
 0.12    2000
 0.08    3000
 0.05    4000
;
/*13.5a)*/data A;
  set A;
  yprime = log(y);
run;
proc reg data = A;/*Using OLS on log(y) to help get starting values*/
  model yprime = x;
title 'OLS regression to get starting values':
run;
quit;
data initial; 
b0= -0.50725; b1= -0.00069346;
g0=0;g1=-b1;g2=exp(b0);
proc print data=initial;
title 'transform OLS ests to get initial values'; run;
/*This method yields: g0(0)=0 g1(0)=0.60215 g2(0)=.00069346 */

/*13.5b)*/
proc nlin data=A method=gauss listder plots;
parms g0=0 g1= .00069346 g2=0.60215 ;
model y=g0+g2*exp(-g1*x);
output out=nlresult p=pred r=resid student=student u95=upperi l95=loweri l95m=lowerm u95m=upperm h=lever;
title "Nonlinear Regression with Gauss-Newton";run;
/*Here are LS estimates of gamma's, standard errors, and 95% confidence intervals
g0 0.0482  SE 0.0146   CI 0.0168 0.0797 
g1 0.00112 SE 0.000092 CI 0.000918 0.00132 
g2 0.7134  SE 0.0228   CI 0.6642 0.7626 
*/
proc print data=nlresult;run;
goptions reset=all; 
ods graphics on;
symbol1 i=none v=dot;
axis1 order= -0.05 to 0.05 by .01 minor=none;
axis2 order=0 to .7 by .1 minor=none;


/*13.6 a and b) 
If you want your own residual plot, do this.  Or else use the PLOT command in PROC NLIN*/
proc gplot data=nlresult;
plot resid*pred/noframe vaxis=axis1 haxis=axis2 vref=0;
title "Residual plot against Y(pred). ";run;
ods graphics off;

proc sort data=nlresult;by pred;run;/*I had to sort the data to get the graph to work*/
proc print data=nlresult;run;

/*If you want your own fitted value plot. Or else use the PLOT command in PROC NLIN */
goptions reset=all;
symbol1 i=none v=dot c=red;
symbol2 i=join c=dot c=black;
Legend1 label=(color=blue height=2 )
value=(color=blue height=1 'Proportion Purchasing' 'Nonlinear Prediction' );
proc gplot data=nlresult;
plot (y pred)*x/overlay noframe legend=lengend1  ;
title "Plot of fitted values. ";run;
/*If you want a Q-Q plot to check for normality.Normality of residuals looks fine
  by the usual tests and the Q-Q plot.Or else use the PLOT 
  command in PROC NLIN to get plots*/
proc univariate data=nlresult plot normal;
var resid;
qqplot/noframe vref=0;
title "Normal Quantile-Quantile Plot for Residual";
run;
proc nlin data=A method=gauss listder;
parms g0=0 g1= .00069346 g2=0.60215 ;
model y=g0+g2*exp(-g1*x);
output out=nlresult p=pred r=resid student=student u95=upperi l95=loweri l95m=lowerm u95m=upperm h=lever;
title "Nonlinear Regression with Gauss-Newton";run;

/*13.7*/
data A;
input Y X; obs+1;
label y = 'Proportion Purchasing'
      x = 'Price of Computer';
cards;
 0.65     200
 0.46     400
 0.34     800
 0.26    1200
 0.17    1600
 0.15    2000
 0.06    3000
 0.04    4000
 0.63     200
 0.50     400
 0.30     800
 0.24    1200
 0.19    1600
 0.12    2000
 0.08    3000
 0.05    4000
;
run;

proc nlin data=a;
parms g0=0 g1= .00069346 g2=0.60215;
model y=g0+g2*exp(-g1*x);
run;

PROC reg data=a;
Model y=x / LACKFIT ;
run;

data a;
crit_f = finv(.99,5,8);
run;


/*13.8*/
proc nlin data=A method=gauss  outest=stuff; /*Bonferroni CI for 3 parameters with 1-alpha=.90*/
parms g0=0 g1= .00069346 g2=0.60215 ;
model y=g0+g2*exp(-g1*x);
 run;
 proc print data=stuff;run;
title "Nonlinear Regression with Gauss-Newton";run;
data bonferroni;
g0= 0.048227; g1=.001117359;g2= 0.71341;
sg0=sqrt( 0.000212);sg1=sqrt( .000000008); sg2=sqrt( 0.00052); 
z=probit(.983333);

lowg0=g0-z*sg0;hig0=g0+z*sg0;
lowg1=g1-z*sg1;hig1=g1+z*sg1;
lowg2=g2-z*sg2;hig2=g2+z*sg2;
proc print data=bonferroni;
title 'Bonferroni CIs for the 3 parameter with 90% confidence';run;

/*13.9 */
data B;set A; 
if obs le 8 then x2=0;else x2=1;
label x2='city';
proc print data=B;title 'Defining a new dummy variable';run;
/*13.9a) */
proc nlin data=B method=gauss  outest=stuff2; ;
parms g0=0 g1= .00069346 g2=0.60215 g3=0;
model y=g0+g3*x2+g2*exp(-g1*x);
title1 "Nonlinear Regression with Gauss-Newton including the dummy variable";
title2 'Dummy variable coefficient is NOT significant: 95% CI is (-0.0289 0.0239)  ';
title3 '0 is inside this CI: Citys A and B have equivalent effects. ' ;
/*This is consistent with the lack of fit test being non significant*/
run;
/*Least squares estimates are:
Estimate SE       Approximate 95% CI 
g0      0.0495    0.0163 0.0140 0.0850 
g1      0.00112   0.000096 0.000909 0.00133 
g2      0.7134    0.0237 0.6619 0.7649 
g3     -0.00250   0.0121 -0.0289 0.0239 

*/
/*13.9b) */
proc print data=stuff2;
title 'Another output of coefs and SEs';
 ;run;

data conf;
lo= -0.0289;hi=0.0239;/*from SAS output*/
g3= -0.00250;sg3= 0.0121;z=probit(.975);
low=g3-sg3*z; high=g3+sg3*z;
proc print data=conf;
title ' Another computation of the CI for dummy variable coefficient';run;

