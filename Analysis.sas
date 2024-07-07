/* Import dataset */
FILENAME REFFILE '/folders/myshortcuts/SASUniversityEdition/myfolders/MT5763/Coursework 2/Baldy.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=MT5763.BALDYRAW;
	GETNAMES=YES;
RUN;

/* Transfrom data to make it easier to analyse */

/* Start by making a new table, with three columns for treatment, hair growth, and age */
/* Create temporary tables for each treatment */
DATA MT5763.LUXURIANT;
SET MT5763.BALDYRAW;
Treatment="Luxuriant";
Growth = Luxuriant;
Age = AgeLuxuriant;
KEEP Treatment Growth Age
RUN;

DATA MT5763.PLACEBO;
SET MT5763.BALDYRAW;
Treatment="Placebo";
Growth = Placebo;
Age = AgePlacebo;
KEEP Treatment Growth Age
RUN;

DATA MT5763.BALDBEGONE;
SET MT5763.BALDYRAW;
Treatment="BaldBeGone";
Growth = BaldBeGone;
Age = AgeBaldBeGone;
KEEP Treatment Growth Age
RUN;

DATA MT5763.SKINHEADNOMORE;
SET MT5763.BALDYRAW;
Treatment="Skinheadnomore";
Growth = Skinheadnomore;
Age = AgeSkinheadnomore;
KEEP Treatment Growth Age
RUN;

/* Now merge these temporary tables to create new table */
DATA MT5763.Baldy;
SET MT5763.LUXURIANT MT5763.PLACEBO MT5763.BALDBEGONE MT5763.SKINHEADNOMORE; 
RUN;

/* Transform growth from inches into mm */
DATA MT5763.Baldy;
SET MT5763.Baldy;
Growth = Growth * 25.4;
RUN;

/* Is there an effect of Luxuriant above and beyond the placebo? */

PROC BOXPLOT DATA=MT5763.BALDY;
PLOT Growth*Treatment; 
WHERE Treatment = "Placebo" | Treatment = "Luxuriant";
RUN;

/* Looks like there's a fairly big difference */
/* Can confirm this using a Two-Sample One-Sided T-test */

PROC TTEST SIDES=U DATA=MT5763.BALDY;
	WHERE Treatment = "Placebo" | Treatment = "Luxuriant";
	CLASS Treatment;
	VAR Growth;
	TITLE 'T-TEST OF EQUALITY OF MEANS'; 
	RUN;
	
/* Perhaps don't need to include this in the Report. Depends how the wordcount is looking */
/* Assumptions aren't being met either so a non-parametric version might be better */

/* Is Luxuriant more effective than the existing treatments on the market? */

PROC BOXPLOT DATA=MT5763.BALDY;
PLOT Growth*Treatment; 
WHERE Treatment NE "Placebo";
RUN;

/* Looks like Luxuriant is the worst at inciting hair growth, with BaldBeGone the best. */
/* Can quantify this using a linear model */

PROC GLM DATA = MT5763.BALDY;
  WHERE Treatment NE "Placebo";
  CLASS Treatment;
  MODEL Growth = Treatment/solution clparm;
  RUN;

/* This confirms it. Could display model in report using LaTeX */

/* Is age relevant to any effect? */

PROC SGPANEL data=MT5763.BALDY;
 panelby Treatment;
 SCATTER x=Age y=Growth;
 TITLE "Scatter...";
RUN;


PROC GLM DATA = MT5763.BALDY;
  CLASS Treatment;
  MODEL Growth = Treatment Age Treatment*Age/solution clparm;
  RUN;












