/* 10.10 */

options PageNo=1 Linesize=100;
options nodate ls=100;
Data A;
Input Y X1 X2 X3;
Label Y='Total Labor Hours' X1='Number of Cases Shipped' X2='Indirect Costs' X3='Holiday' ;
cards;
4264 305657 7.17 0
4496 328476 6.20 0
4317 317164 4.61 0
4292 366745 7.02 0
4945 265518 8.61 1
4325 301995 6.88 0
4110 269334 7.23 0
4111 267631 6.27 0
4161 296350 6.49 0
4560 277223 6.37 0
4401 269189 7.05 0
4251 277133 6.34 0
4222 282892 6.94 0
4063 306639 8.56 0
4343 328405 6.71 0
4833 321773 5.82 1
4453 272319 6.82 0
4195 293880 8.38 0
4394 300867 7.72 0
4099 296872 7.67 0
4816 245674 7.72 1
4867 211944 6.45 1
4114 227996 7.22 0
4314 248328 8.50 0
4289 249894 8.08 0
4269 302660 7.26 0
4347 273848 7.39 0
4178 245743 8.12 0
4333 267673 6.75 0
4226 256506 7.79 0
4121 271854 7.89 0
3998 293225 9.01 0
4475 269121 8.01 0
4545 322812 7.21 0
4016 252225 7.85 0
4207 261365 6.14 0
4148 287645 6.76 0
4562 289666 7.92 0
4146 270051 8.19 0
4555 265239 7.55 0
4365 352466 6.94 0
4471 426908 7.25 0
5045 369989 9.65 1
4469 472476 8.20 0
4408 414102 8.02 0
4219 302507 6.72 0
4211 382686 7.23 0
4993 442782 7.61 1
4309 322303 7.39 0
4499 290455 7.99 0
4186 411750 7.83 0
4342 292087 7.77 0
;

proc print data=grocery;
run;


/*10.10 a */

ods graphics on;
proc reg data=A plots(label)=( CooksD RStudentByLeverage DFFITS DFBETAS);
model Y=X1 X2 X3/all influence;
output out=B r=residual h=hat student=student rstudent=rstudent 
dffits=dffits cookd=cookd  p=plabor;/*rstudent is studentized deleted residual*/
title "residuals, studentized residuals,  studentized deleted residuals, dffits, 
   Cook's D & dfbetas";
run;
ods graphics off;

data B;
set B;
obs+1;
prob_t=1-probt(abs(rstudent),52-4-1); /*two tailed test*/
critt=tinv(1-(.05/2/52),52-4-1); /*two tailed test, family alpha of .05, 52 observations*/
proc print data=B;
var  residual rstudent prob_t critt;
title1 "residuals, and studentized deleted residuals and outlier criterion.";
title2 ' Since none of the absolute values of studentized deleted variables are greater than 3.523, there are no outliers ';run;


/* 10.10b */
proc print data=B;
  where hat> (2*4/52); /*flag leverage if hat > 2p/n according to book*/
  var hat Y X1 X2 X3;
title 'Influential cases as determained by leverage: hat > 2p/n ';
run;


/*10.10 c */
data C;
input y u v X3;
datalines;
. 300000 7.2 0
; 

data next; set A C;
proc gplot data=next;
plot X1*X2='O' U*V='X'/overlay;
title1 'O:Old Points X=new point';
title2 'The X is in the middle, so clearly, interpolation is not needed';
run;

data D;
input y X1 X2 X3;
datalines;
. 300000 7.2 0
; 
data next2; set A D;
proc reg data=next2;
model Y=X1 X2 X3/influence;
output out=E h=hat ;
title1 "From observation 53, we can observe no extrapolation is needed";
run;


/* 10.10 d */
data F;
set B;
DFFITSbar=2*sqrt(4/52);
COOKDbar=4/52;
if abs(dffits)>dffitsbar then flagFITS=1; 
	else flagFITS=0; 
if cookd>cookdbar then flagCOOK=1;
	else flagCOOK=0;

proc print data=F; 
  var dffits DFFITSbar flagFITS cookd COOKDbar flagCOOK;
title1 "Guidebar for DFFITS = 2*SQRT(p/n)=.5547 .";
title2 "Guidebar for Cook's D = 4/p=.0769";
 run;

proc print data=F;
	where (flagFITS=1 or flagCOOK=1);
title 'Influential cases by DFFITS and COOKD';
run;

/*Now consider DFBETAS*/
proc reg data=B;
  model Y=X1 X2 X3/influence;
  ods output OutputStatistics=G;
  id obs;
run;
quit;

proc print data=G;
run;
data H;
set G; 
dfBAR=2/sqrt(52);
if abs(DFB_intercept)> dfBAR then flagB0=1; 
	else flagB0=0;
if abs(DFB_X1)> dfBAR then flagX1=1; 
	else flagX1=0;
if abs(DFB_X2)> dfBAR then flagX2=1; 
	else flagX2=0;
if abs(DFB_X2)> dfBAR then flagX3=1; else flagX3=0;

proc print data=H;
var dfbar DFB_intercept flagB0 DFB_X1 flagX1 DFB_X2 flagX2 DFB_X3 flagX3; 
title 'Guidebars for DFBETAS is at 2/SQRT(n) = .277';
run;

proc print data=H; 
where (flagB0=1 or flagX1=1 or flagX2=1 or flagX3=1);
title 'Influential cases by DFBETAS';
run;


/* 10.10 e */
proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=10;
model Y=X1 X2 X3;
output out=labor2 p=predy10;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy10-predy)/predy))*100;
obs+1;
proc means ;var abspdiff;output out=case10a;
title "Average Absolute percent difference in predicted Y scores with OBS 10 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy10 predy ;
title " Absolute percent differences in descending order";run;
data case10;set case10a;if _n_=4;omit=10;keep _STAT_ abspdiff omit;proc print data=case10;run;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=16;
model Y=X1 X2 X3;
output out=labor2 p=predy16;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy16-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case16a;
title "Average Absolute percent difference in predicted Y scores with OBS 16 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy16 predy ;
title " Absolute percent differences in descending order";run;
data case16;set case16a;if _n_=4;omit=16;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=22;
model Y=X1 X2 X3;
output out=labor2 p=predy22;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy22-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case22a;
title "Average Absolute percent difference in predicted Y scores with OBS 22 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy22 predy ;
title " Absolute percent differences in descending order";run;
data case22;set case22a;if _n_=4;omit=22;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=32;
model Y=X1 X2 X3;
output out=labor2 p=predy32;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy32-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case32a;
title "Average Absolute percent difference in predicted Y scores with OBS 32 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy32 predy ;
title " Absolute percent differences in descending order";run;
data case32;set case32a;if _n_=4;omit=32;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=38;
model Y=X1 X2 X3;
output out=labor2 p=predy38;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy38-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case38a;
title "Average Absolute percent difference in predicted Y scores with OBS 38 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy38 predy ;
title " Absolute percent differences in descending order";run;
data case38;set case38a;if _n_=4;omit=38;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=40;
model Y=X1 X2 X3;
output out=labor2 p=predy40;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy40-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case40a;
title "Average Absolute percent difference in predicted Y scores with OBS 40 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy40 predy ;
title " Absolute percent differences in descending order";run;
data case40;set case40a;if _n_=4;omit=40;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=43;
model Y=X1 X2 X3;
output out=labor2 p=predy43;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy43-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case43a;
title "Average Absolute percent difference in predicted Y scores with OBS 43 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy43 predy ;
title " Absolute percent differences in descending order";run;
data case43;set case43a;if _n_=4;omit=43;keep _STAT_ abspdiff omit;

proc reg data=A;
model Y=X1 X2 X3;
output out=Labor1 p=predy;
reweight obs.=48;
model Y=X1 X2 X3;
output out=labor2 p=predy48;run;quit;
proc print data=labor1;run; proc print data=labor2;run;
data I;merge labor1 labor2;
abspdiff=(abs((predy48-predy)/predy))*100;
obs+1;
proc means;var abspdiff;output out=case48a;
title "Average Absolute percent difference in predicted Y scores with OBS 48 deleted";run;
proc sort data=I out=I;by descending abspdiff;
proc print;var obs abspdiff predy48 predy ;
title " Absolute percent differences in descending order";run;
data case48;set case48a;if _n_=4;omit=48;keep _STAT_ abspdiff omit;

data J;set case10 case16 case22 case32 case38 case40 case43 case48;
rename _stat_ = AVG_ABS_PER_DIFF;
proc print data=J;
title1 'Average Absolute Percent Differences of Fitted Values';
title2 '32nd observation has worst difference at .22%';
run;


/* 10.10f */
data B;
set B; 
obs+1;
cook_cutoff=0.0769;

proc print data=B;
var cookd cook_cutoff;
run;

symbol1 i=join;
axis1 order=0 to .5 by .1;
axis2 order=0 to 55 by 5;

proc gplot data=B;
plot cookd*obs/vaxis=axis1 haxis=axis2 vref=0.0769 ;
title1 "Index Influence Plot of Cook's D.";
title2 "Guidebar is at 4/n = .0769";run;

ods graphics on;
proc reg data=A 
	   plots(label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	   model Y=X1 X2 X3;
title 'Influence plots';
   run;   
   ods graphics off;
