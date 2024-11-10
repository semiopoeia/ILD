PROC IMPORT OUT= WORK.actiheart 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\PAcog_SEM\Actiheart 2009 to 2014\PAcog_analytic_
actiheart.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAcog_analytic_actiheart$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
