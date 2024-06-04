/*read excel file*/
data heart;
proc import datafile='/home/u62152536/ProjectforSTAT366/heart.csv' 
  out= heart replace;
run;

/*This part is raw data read*/
data regression;
infile '/home/u62152536/ProjectforSTAT366/datapart2.0.dat';
input age
      platelets :11.4;
run;

/*This part is dlm file with overlength, reading character, numerical, data */
data special;
infile '/home/u62152536/ProjectforSTAT366/sepcialdata.dat' dlm=',';
input age
      creatine
      fraction
      platelets :11.6
      name :$12.
      date MMDDYY10.;
run;

/*This part is for misssing value*/
data special1;
infile '/home/u62152536/ProjectforSTAT366/datapart2.1 - copy1.dat';
input age  1-2
	  creatine 8-13;
	  
run;


/*merge the data*/
/*also include the ods part*/
/*we add the set drop function*/
data merge1;
	set special (keep=age name date);
run;
data merge2;
	set special1 (keep=age creatine);
run;
ODS CSV FILE = '/home/u62152536/ProjectforSTAT366/regression.csv'; ODS NOPROCTITLE;
proc sort data=merge1;
by age;
proc sort data=merge2;
by age;
data mergeit;
merge merge1 merge2; By age;
proc print data=mergeit;
run;
ODS CSV CLOSE;






