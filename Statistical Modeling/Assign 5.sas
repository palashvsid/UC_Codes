/*Problem 14.20*/
data flushot;
infile '/home/siddampy0/sasuser.v94/CH14PR14.txt';
input Y X1 X2 X3 ;
x1x2 = x1*x2;
x1x3 = x1*x3;
x2x3 = x2*x3;
x1sq = x1**2;
x2sq = x2**2;
;

data newcase;
input y x1 x2 x3 ;
cards;
 . 55 60 1
;

data flushot1;/*Adds new data point to the dataset*/
set flushot newcase;
run;
proc print data=flushot1;
run;

/* 14.20 (a)*/
data flushot2;
set flushot1;
if x3=1;
/*Males only to do 14.20 (a)*/
proc logistic data=flushot2 descending  ;/*14.20 (a,b,c)*/
   model y  = x1 x2 x3/expb clparm=wald covb alpha=.05 ; 
  output out=first predicted=phat;
   title "Multiple Logistic Regression of Flu Shot";
   title2 "Against Age, Health Awareness, and Gender";
;run;

data odds; alpha=.10;bon=1-alpha/4;z=quantile('normal',bon);b1= 0.0758; sb1=0.0412; 
lowb1=b1-z*sb1;
hib1=b1+z*sb1;
lowodd30=exp(30*lowb1);hiodds30=exp(30*hib1);
b2=  -0.1006; sb2=0.0508; 
lowb2=b2-z*sb2;hib2=b2+z*sb2;
lowodd25=exp(25*lowb2);hiodds25=exp(25*hib2);
proc print data=odds;run;


/* 14.20 (b)*/
proc logistic data=flushot1 descending  ;/*14.20 (a,b,c)*/
   model y  = x1 x2 x3/expb clparm=wald covb alpha=.05 ; 
  output out=first predicted=phat;
   title "Multiple Logistic Regression of Flu Shot";
   title2 "Against Age, Health Awareness, and Gender";
;run;

data testgender;/*14.20 (b) To test if gender is significant, look at the Wald ChiSq in output
  of the model with both genders above using data=flushot*/
 chisq=0.6917;
 pval=0.4056; /* Can drop gender*/
 /*Note SQRT(Wald ChiSQ)=Z. Then do a Z-test as in text instead to get same result*/
 z=sqrt(chisq);
 pvalZ=2*(1-probnorm(abs(z)));
 proc print data=testgender;
 run;
 

/*14.20 (c)*/
proc logistic data=flushot1 descending  ;
   model y  = x1 x2 x3; /*Full model*/
   title "Full Multiple Logistic Regression of Flu Shot";
   title2 "Against Age, Health Awareness, and Gender";
;run;

proc logistic data=flushot descending  ;
   model y  = x1 x2 ; /*Reduced model*/
   title "Reduced Multiple Logistic Regression of Flu Shot";
   title2 "Against Age, Health Awareness only";
;run;

data devdif;
/*note: devfull = -2logL(full) and devred=-2logL(reduced): Obtained from -2*log(L) in SAS output*/
devfull=105.093;devred= 105.795; dfful=3;dfred=2;Gsq=(devred-devfull);dfdif=dfful-dfred;
pval=1-probchi(Gsq,dfdif); 
proc print data=devdif;;run;


/*14.20 (d)*/
proc logistic data=flushot1 descending;
/*My interpretation is that X3 is not included*/
	model y  = x1 x2 x1x2 x1sq x2sq;
	bigtest: test x1x2= x1sq =x2sq=0;
	title "Multiple Logistic Regression of Flu Shot";
	title2 "Against Age and Health Awareness";
	title3 "With Interaction & Quadratic Terms Included";run;
/*If you are using Gsq, you will need reduced model as well*/
proc logistic data=flushot descending;
   model y  = x1 x2 ;run;

data devdif2;
/*note: devfull = -2logL(full) and devred=-2logL(reduced)*/
devfull=104.261;
devred= 105.795; 
dfful=5;
dfred=2;
Gsq=(devred-devfull);
dfdif=dfful-dfred;
pval=1-probchi(Gsq,dfdif); 
proc print data=devdif2;
title 'Do you need 2nd order terms given X1 and X2 are already in model?';
run;