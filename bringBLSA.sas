PROC IMPORT OUT= WORK.blsa 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\BLSA_ACR_20210109.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
