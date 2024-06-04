DATA heartfailure;
  INFILE '/home/u62262281/STAT S366F Group Project/heartfailure.dat';
  INPUT age anaemia $ cpk diabetes $
        ejecfrac hbp $ platelets 9.2
        creatinine 10. sodium sex $ smoking $
        time DEATH $;

*CONDITIONAL STATEMENTS + LOOPS;
LENGTH Remarks $30.;
LENGTH Caution $30.;

IF creatinine = . THEN Remarks = 'N/A';
  ELSE IF creatinine >= 0.6 or creatinine <= 1.3
  THEN Remarks = 'Normal';
  ELSE Remarks = 'Risk of heart failure!';

IF age = . or anaemia = . THEN Remarks = 'N/A';
  ELSE IF age >= 65 OR anaemia = '1' THEN DO
    Remarks = 'Risk of heart failure!';
    Caution = 'Conduct checkings!';
END; 
RUN;

PROC PRINT DATA = heartfailure LABEL;
  label anaemia = 'Anaemia (1=True/0=False)';
  label diabetes = 'Diabetes (1=True/0=False)';
  label hbp = 'High Blood Pressure (1=True/0=False)';
  label smoking = 'Smoking (1=True/0=False)';
  label sex = 'Sex (1=Male/0=Female)';
  label DEATH = 'Deceased (1=True/0=False)';
  label cpk = 'Creatinine Phosphokinase Level (mcg/L)';
  label ejecfrac = 'Ejection Fraction (%)';
  label hbp = 'High Blood Pressure (1=True/0=False)';
  label platelets = 'Number of Platelets in Blood Vessel (kiloplalets/mL)';
  label creatinine = 'Serum Creatinine Level (mEq/L)';
  label sodium = 'Serum Sodium Level (mEq/L)';

*UNIVARIATE ANALYSIS (4 extreme observations);
proc univariate data = heartfailure;
  var platelets;
run;

*BOX PLOT (serum creatinine, category: hbp);
PROC SGPLOT DATA = heartfailure;
  VBOX creatinine 
  / category = hbp;
  XAXIS LABEL = 'High Blood Pressure (1=True/0=False)'
  VALUEATTRS=(SIZE = 20);
  YAXIS LABEL = 'Serum Creatinine Level (mEq/L)'
  VALUEATTRS=(SIZE = 20);
RUN;

*Regression Plot (x=sodium, y=platelets);
ODS GRAPHICS ON;
proc reg data=heartfailure;
  MODEL platelets = sodium;
  ODS OUTPUT ParameterEstimates=PE;
run;
data _null_;
  SET PE;
  if _n_ = 1 then call symput('Int', put(estimate, BEST20.));    
  else call symput('Slope', put(estimate, BEST20.));  
run;
PROC SGPLOT DATA = heartfailure NOAUTOLEGEND;
  REG X=sodium Y=platelets
  / MARKERATTRS = (SYMBOL = HEART SIZE = 12);
  XAXIS LABEL = 'Serum Sodium Level (mEq/L)'
  VALUEATTRS=(SIZE = 15);
  YAXIS LABEL = 'Platelet Count in the Blood Vessel (kiloplatets/mL)'
  VALUEATTRS=(SIZE = 15);
  INSET 'Intercept = &Int' 'Slope = &Slope' / 
  BORDER TITLE='Parameter Estimates' POSITION=TOPRIGHT;
RUN;

*Hypothesis Testing;
*One-Sample T Test;
proc ttest data = heartfailure alpha = 0.05 h0 = 150;
  var sodium;
run;

*Test for Normality with PROV UNIVARIATE;
*Shapiro-Wilk Test;
*Kolmogorov-Smirnov Test;
*Cramer-von Mises Test;
*Anderson-Darling Test;
PROC UNIVARIATE DATA = heartfailure normal;
  var sodium;
RUN;

*Two-Sample Independent (Unpaired) T-Test;
proc ttest data=heartfailure sides=2
alpha=0.05 h0 = 150;
  class hbp; 
  var sodium;
run;

*Wilcoxon Rank Sum Test: Independent Samples;
proc npar1way data=heartfailure wilcoxon;
  class hbp;
  var sodium;
run;

*PROC SQL (COMP S320F), extension of conditionals/loops;
*serum sodium not in normal range
normal range is 135-145 mEq/L);
*subquery with IN;
proc sql;
  SELECT age, anaemia, diabetes, hbp, sodium, smoking
  FROM heartfailure
  WHERE sodium NOT IN /*exclude multiple values with NOT IN*/
        (SELECT sodium
        FROM heartfailure
        WHERE sodium BETWEEN 135 AND 145)
  ORDER BY age;

  SELECT age, sodium,
  CASE
    WHEN sodium IS NULL THEN 'N/A'
    WHEN sodium NOT BETWEEN 135 AND 145
    THEN 'Signs of heart failure!'
    ELSE 'Normal, healthy!'
  END AS Remarks
  FROM heartfailure
  ORDER BY age;
quit; *end PROC SQL;

*FOOTNOTES;
PROC PRINT DATA = heartfailure;
  FOOTNOTE1 'anaemia: Decrease of red blood cells or hemoglobin
  (character: 0=False, 1=True)';
  FOOTNOTE2 'cpk: Level of creatinine phosphokinase enzyme in the blood (mcg/L)';
  FOOTNOTE3 'diabetes: If the patient has diabetes (boolean: 0=False, 1=True)';
  FOOTNOTE4 'ejecfrac: Volume of blood leaving the heart at each contraction (%)';
  FOOTNOTE5 'hbp: If the patient has hypertension (boolean: 0=False, 1=True)';
  FOOTNOTE6 'platelets: Number of platelets in the blood (kiloplatelets/mL)';
  FOOTNOTE7 'smoking: If the patient smokes or not (boolean: 0=False, 1=True)';
  FOOTNOTE8 'sex: gender (boolean: 0=Female, 1=Male)';
  FOOTNOTE9 'time: Follow-up period (days)';
  FOOTNOTE10 'DEATH: Whether the patient deceased during the follow-up period
  (boolean: 0=False, 1=True)';
RUN;