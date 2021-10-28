%let return=%sysfunc(dlgcdir('C:\Users\acw9163\Desktop\SAS Monthly\monthly data 1'));
/**the reference to the file is relative, so I need to make sure the 
 working directory points to the folder**/
data test;
 infile "Month1.txt" dlm='09'x firstobs=2;
 input City:$10. Department:$25. Personnel Equipment Material Incidental;
 /**Input types:
  List input and modified list input
  Column input and formatted input
  Any combination of any two (or more) is called mixed input***/
run;

%macro read(file=,ext=txt);
data &file;
 infile "&file..&ext" dlm='09'x firstobs=2;
 input City:$10. Department:$25. Personnel Equipment Material Incidental;
run;
%mend;
%read(file=Month3);

%macro readMultiple(files=,ext=txt);
 %let i=1;/**intializing a counter (for the list)**/
 %let file=%scan(&files,&i);/**grabs the "word" from the list**/
 %do %while(&file ne );/***If the value is non-empty (list non-empty) start the process***/
  data &file;
   infile "&file..&ext" dlm='09'x firstobs=2;
   input City:$10. Department:$25. Personnel Equipment Material Incidental;
  run;
  %let i=%eval(&i+1);/***Moves up the counter, by 1... ***/
  %let file=%scan(&files,&i);/**grabs the next "word" from the list**/
 %end;
%mend;
%readMultiple(files=month1 month2 month3);


%macro ConcatRaw(files=,ext=txt,out=concat,outlib=work);
 %let i=1;
 %let file=%scan(&files,&i);
 %do %while(&file ne );
  data nextData;
   infile "&file..&ext" dlm='09'x firstobs=2;
   input City:$10. Department:$25. Personnel Equipment Material Incidental;
  run;
  
  %if(&i eq 1) %then %do;/***Establishes the final data set
    correctly as a new data set containing information
     from the first read only***/
   data &outlib..&out;
    set nextData;
    Month="&file";
   run;
  %end;

  %else %do;
   data &outlib..&out;
    set &outlib..&out nextData(in=current);
    if current then Month="&file";/***Only need/want to
     update this for the new records read in on this iteration**/
   run;
  %end;
  
  %let i=%eval(&i+1);
  %let file=%scan(&files,&i);
 %end;/***WHILE ends here***/
%mend;
%ConcatRaw(files=month1 month2 month3);

%macro ConcatRaw2(files=,ext=txt,out=concat,outlib=work);
 %let i=1;
 %let file=%scan(&files,&i);
 %let Mon&i=&file;/**keeping those file names for later use***/
 %do %while(&file ne );
  data dSet&i;/***we're going to write one DATA step that uses all of
     the data sets read in, need different names**/
   infile "&file..&ext" dlm='09'x firstobs=2;
   input City:$10. Department:$25. Personnel Equipment Material Incidental;
  run;
  %let i=%eval(&i+1);
  %let file=%scan(&files,&i);
  %let Mon&i=&file;/**keeping those file names for later use***/
 %end;
  
 data &outlib..&out;
  set
   %do j=1 %to &i-1;/**i is one more than the number of words in the list***/
    dSet&j(in=in&j)
   %end;
  ;
  
  %do j=1 %to &i-1;
   if in&j then Month="&&Mon&j";
  %end;
 run;
%mend;
options mprint nonotes;
%ConcatRaw2(files=month1 month2 month3,out=concat2);
