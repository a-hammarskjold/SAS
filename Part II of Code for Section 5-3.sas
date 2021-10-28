libname sasdat 'G:\SeaShare\SAS Programming Data\Monthly data SAS';
/**The library does need to be established***/

data try;
 length month $8;
 set sasdat.january(in=jan) sasdat.february(in=feb) sasdat.march(in=mar)
     sasdat.april(in=apr) sasdat.may(in=may) sasdat.june(in=june);
 if jan then month='January';
 if feb then month='February';
 if mar then month='March';
 if apr then month='April';
 if may then month='May';
 if june then month='June';
run;

%macro concatSAS(inLib=,dSets=,outLib=work,outDat=concat);
 %if(&outLib eq ) %then %do;
  %put WARNING: Library not specified;
 %end;
 %else %do;
 data &outlib..&outDat;
  length month $8;
  set
   %let i=1;
   %let file=%scan(&dSets,&i);
   %let Mon&i=&file;
   %do %while(&file ne );
    &inLib..&file(in=in&i)
    %let i=%eval(&i+1);
    %let file=%scan(&dSets,&i);
    %let Mon&i=&file;
   %end;
  ;
  %do j=1 %to &i-1;
    if in&j then Month=Propcase("&&Mon&j");
  %end;
run;
%end;
%mend;
options mprint;
%concatSAS(inLib=SASDat,dSets=January March May,outlib=);

ods trace on;
proc contents data=SASDat._all_ nods;
 ods output Members=dataSets;
run;

%macro GetDataSets(lib=);
 ods exclude all;/**turn off output...***/
 proc contents data=&lib.._all_ nods;
  ods output members=dsets;
 run;
 data _null_;
  set dsets end=last;
  call symputx(cats('DataSet',_n_),name,'G');
  if last then do;
    call symputx('n',_n_,'G');
  end;
 run;
 ods select all;/***...turn it back on before
   exiting the macro***/
%mend;
%GetDataSets(lib=SASDat);
%put _user_;


%macro concatSAS2(inLib=,dSets=,outLib=work,outDat=concat);
 %if(&dsets eq ) %then %do;
  %GetDataSets(lib=&inLib);
  %let setList=;
  %do j=1 %to &n;
   %let setList=&setList &inLib..&&DataSet&j(in=in&j);
  %end;
 %end;
 
 data &outlib..&outDat;
  length month $8;
  set
   %if(&dsets eq ) %then &setList;
 
   %else %do;
    %let i=1;
    %let file=%scan(&dSets,&i);
    %let Mon&i=&file;
    %do %while(&file ne );
      &inLib..&file(in=in&i)
      %let i=%eval(&i+1);
      %let file=%scan(&dSets,&i);
      %let Mon&i=&file;
    %end;
   %end;
  ;

  %if(&dsets eq ) %then %let stop=&n;
   %else %let stop=&i-1;
   
  %do j=1 %to &stop;
   %if(&dsets eq ) %then %do;
    if in&j then Month=Propcase("&&DataSet&j");
   %end;
   %else %do;
    if in&j then Month=Propcase("&&Mon&j");
   %end;
  %end;
run;
%mend;
options nomlogic nosymbolgen;
%concatSAS2(inLib=SASDat,dSets=January February March, outDat=FirstThree);
%concatSAS2(inLib=SASDat,outDat=All);

