/* Question 14.39 */

data ger;
infile '/home/siddampy0/sasuser.v94/CH14PR39.txt';
input Y X1 X2 X3 X4;
run;
proc print data=ger;
run;

/* 14.39 a*/
proc genmod data=ger;
model Y=X1 X2 X3 X4/dist=poisson link=log;
output out=model p=predcnt resdev=resdev;
title "Poisson regression on the Geriatric data";run;

/* 14.39 b*/
data model;set model;
i+1;
proc print;var Y predcnt resdev;
title "Responses, fitted values, and deviance residuals";run;
symbol1 c=black v=none i=join;

proc gplot data=model;
plot resdev*i;
title "Index plot of deviance residuals";run;

/* 14.39 c and d*/
proc genmod data=ger;
model Y=X1 X2 X3 X4/dist=poisson link=log;
title "Full model";run;

proc genmod data=ger;
model Y=X1 X3 X4/dist=poisson link=log;
title "Reduced model";run;

data devdif;
/*note: devfull = -2logL(full) and devred=-2logL(reduced): Obtained from -2*log(L) in SAS output*/
devfull=108.7899;devred= 108.9409; dfful=4;dfred=3;Gsq=(devred-devfull);dfdif=dfful-dfred;
pval=1-probchi(Gsq,dfdif); 
proc print data=devdif;;run;
