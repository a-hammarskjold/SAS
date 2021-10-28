/*
Antton Wilbanks
Exercise 3 - Macro Part II
3/11/2021
*/

/*
Parameters:
'first_obs' - changes which line to begin reading data
'folder_name' - name of folder used to alter the file directory
'files' - list of file names (must use ~ separator)
'ext' - extension on file names (only input if list of files given)
'sep' - changes delimiter for read-in of various file types
'out' - name of output data
'outlib' - name of output library


Inside the code: 
I decided to have the file directory change be incorporated
into the macro variable so the user need only make changes to one line of code.

I also added a section to check if the file list was empty. If it is, then the
first DO WHILE loop iterates. The process I used also grabs
each file's extension. This is why the extension parameter is set IFF 
a list of file names are passed.

If the first DO WHILE loop executes, the macro variable named EXISTS 
resolves to 1 meaning the macro variable NEW_FILE was created. If 
NEW_FILE was created, the macro will exit. Without this, the second 
DO WHILE loops triggers and exits after the first iteration as the
condition is only true once because FILE in the second DO WHILE is
controlled by the FILES parameter in the macro.

Since some of the file names have special characters (blanks), I changed
the %scan function to %qscan, and I changed the %qscan delimiter to ~ so
the blanks could be read as part of the file name.
*/

%macro ConcatRaw(first_obs=2,folder_name=,files=,ext=,sep=,out=concat,outlib=work);
	/*Checking to ensure required parameters are set*/
	%if (&folder_name eq ) %then %do;
		%put ERROR: folder_name must be specified;
		%goto leave;
	%end;
	%if (&sep eq ) %then %do;
		%put ERROR: sep (delimiter) must be specified;
		%goto leave;
	%end;	
	%if (&first_obs eq ) %then %do;
		%put ERROR: first_obs must be specified;
		%goto leave;
	%end;
	
	%let folder=%sysfunc(dequote(&folder_name));
	%let return=%sysfunc(dlgcdir("C:\Users\acw9163\Desktop\SAS Monthly\&folder"));
 	
 	%let i=1;
 	%let file=%qscan(&files,&i,~);
 	
 	%if ((&file ne ) and (&ext eq )) %then %do;
 		%put ERROR: User must set ext= parameter if files= not empty;
 		%goto leave;
 	%end;
 	
 	/*Resolves if a file list is NOT passed*/
  	%if (&file eq ) %then %do;
  		/*Step one: Grabbing file names from folder*/
  		filename myDir "C:\Users\acw9163\Desktop\SAS Monthly\&folder" ;
 		data dummy (keep=filename);
			did=dopen("myDir");
			filecount=dnum(did);
			do j=1 to filecount;
				filename=dread(did,j);
				put filename=;
				output;
			end;
			rc=dclose(did);
		run;
 	
 		proc sql noprint;
  			select filename 
    		into :filename separated by '~'
    		from dummy;
		quit;
		
		%let new_files = &filename;
		%let new_file = %qscan(&new_files,&i,~);
		
		/*Step two: Reading in and concatenating the files*/
		%let z = 1;
		%do %while(&new_file ne );
			data nextData;
				infile "&new_file" dlm=&sep firstobs=&first_obs;
		   		input City:$10. Department:$25. Personnel Equipment Material Incidental;
		  	run;
		  
		  	%if(&z eq 1) %then %do;
		   		data &outlib..&out;
		    		set nextData;
		    		Month="&file";
		   		run;
		  	%end;
		
		  	%else %do;
		   		data &outlib..&out;
		    		set &outlib..&out nextData(in=current);
		    		if current then Month="&file";
		   		run;
		  	%end;
			  
			%let z=%eval(&z+1);
			%let new_file=%qscan(&new_files,&z,~);
		%end;
		/*Step three: setting loop exit conditions*/
		%let file = %qscan(&new_files,&i,~);
	%end;
	
	/*If first DO WHILE loop initiates, this will
	terminate the macro*/
	%let exists = %symexist(new_file);
	%if (&exists eq 1) %then %do;
		%goto leave;
	%end;
	
	/*Resolves if a file list is passed*/
	%do %while(&file ne );
		data nextData;
			infile "&file..&ext" dlm=&sep firstobs=&first_obs;
	   		input City:$10. Department:$25. Personnel Equipment Material Incidental;
	  	run;
	  
	  	%if(&i eq 1) %then %do;
	   		data &outlib..&out;
	    		set nextData;
	    		Month="&file";
	   		run;
	  	%end;
	
	  	%else %do;
	   		data &outlib..&out;
	    		set &outlib..&out nextData(in=current);
	    		if current then Month="&file";
	   		run;
	  	%end;
	  
	%let i=%eval(&i+1);
	%let file=%qscan(&files,&i,~);
	%end;
%leave: %mend;
options mlogic symbolgen;

/*Runs as examples do in book*/
%ConcatRaw(folder_name='monthly data 1', files= month1~month2~month6,ext=txt,sep='09'x,outLib=months,out=monthly1concat);

/*Given list of files without setting ext*/
%ConcatRaw(first_obs=1,folder_name='monthly data 2', files= month 3~month 4~month 5, sep='09'x,outLib=months,out=monthly2concat);

/*Given no delimiter and no file list*/
%ConcatRaw(first_obs=1,folder_name='monthly data 3',outLib=months,out=monthly3concat);

/*Given no file list*/
%ConcatRaw(folder_name='Monthly Data 4',sep=',',outLib=months,out=monthly4concat);