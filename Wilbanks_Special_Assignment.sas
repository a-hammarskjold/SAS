%let return=%sysfunc(dlgcdir('C:\Users\acw9163\Desktop\SAS Map'));

/*Creating sorting variables*/
data us;
 set mapsgfk.us;
 ident=catx('-',statecode,segment);
run;

data us;
	set us;
	ord=_n_;
run;

/*Computing values*/
proc means data=sasprg.projects mean;
	class stname;
	var jobtotal;
	ods output summary=means;
run;

/*Pre-processing data and creating macro variables*/
proc sql;
	create table mapping as
	select *
	from us full join means
		on statecode eq stname
	where statecode not in ('DC')
	order by ord
	;
	create table state_names as
	select statecode as code, statename
	from mapssas.us2
	where statename not in ('Puerto Rico','District of Columbia')
	;
	create table mapping_2 as
	select *
	from mapping full join state_names
		on statecode eq code
	order by ord
	;
	select distinct statecode, statename
	into :state separated by '~', :names separated by '~'
	from mapping_2
	;
quit;
%put &names;
/*Creating map with links to reports*/
ods listing image_dpi=300;
ods graphics / reset imagemap imagefmt=jpeg drilltarget="_self";

ods html body='Wilbanks_Special_Assignment_Map.htm';	

title 'Average Total Cost for all Pollutants';
proc sgplot data=mapping_2 aspect=.625;
	polygon x=x y=y id=ident / colorresponse=jobtotal_mean fill outline
		    colormodel=(cxfcf9ae cx5dc2b1 cx274a96) url=stname;
	xaxis display=none;
	yaxis display=none;
	format jobtotal_mean dollar10.;
	label ident='ISO States Code';
	gradlegend / position=bottom title='Average Job Cost';
run;
ods html close;

/*Creating reports*/
%macro report();
	%let i = 1;
	%let code = %scan(&state,&i,~);
	%let name = %scan(&names,&i,~);
	%do %while (&name ne );
		ods html body="&code";
		title;
		proc report data=sasprg.projects;
			where stname eq "&code";
			column pol_type n personel equipmnt jobtotal;
			define pol_type / group 'Pollutant';
			define n / 'Number of Jobs';
			define personel / sum 'Personnel Costs' format=dollar10.;
			define equipmnt / sum 'Equipment Costs' format=dollar10.;
			define jobtotal / sum 'Total Costs' format=dollar10.;
			rbreak after / summarize;
			compute before _page_;
				line "Totals for &name";
			endcomp;
			compute after _page_; 
				line "<a href='Wilbanks_Special_Assignment_Map.htm'>Back to Map</a>";
			endcomp;
		run;
		ods html close;
		%let i = %eval(&i + 1);
		%let code = %scan(&state,&i,~);
		%let name = %scan(&names,&i,~);
	%end;
%mend;
%report();