/*Antton Wilbanks - 23 Feb 2021*/
/*Modified 5.3.1 Code*/
data merged;
	merge sasprg.courses sasprg.schedule;
	by course_code;
	call symput(cats('Title',course_number), strip(course_title));
	call symput(cats('Fee',course_number), Fee);
	call symput(cats('Location',course_number), strip(location));
	call symput(cats('Date',course_number), put(begin_date,worddate.));
	call symput(cats('Code',Course_Number),Course_Code);
run;

data _null_;
	set sasprg.register;
	by course_number;
	if first.course_number then do;
 	enrollment = 0;
  	feePaid = 0;
 	end;/***initialize your counters at the start of each course***/
 	enrollment+1;
 	if paid eq 'Y' then feePaid+1;
 	if last.course_number then do;
 		call symput(cats('Enroll',course_number),put(enrollment,best3.));
 		call symput(cats('Paid',course_number),put(feepaid,best3.));
 		check=symget(cats('code',course_number));
 		check2=symget(cats('Fee',course_number));
 		put check check2;
 		call symput(cats('Outstanding',course_number),
  						put((enrollment-feepaid)*symget(cats('Fee',course_number)),dollar8.));
  	end;
run;
%put _user_;

%macro CrsReport(crs);
Title "Enrollment List for &&Title&crs";
Title2 "&&Location&crs, Starting &&Date&crs";
proc report data=sasprg.register;
	where course_number eq &crs;
	column Student_Name Paid;
	define Student_Name/'Student';
	define Paid/'Fees Paid';
	
	compute after _page_;
	line "&&Enroll&crs students enrolled; &&Paid&crs paid";
	line "&&Outstanding&crs in Fees Due";
	endcomp;
run;
%mend;
%CrsReport(1);