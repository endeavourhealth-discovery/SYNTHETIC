SYNLOAD ; ; 4/7/22 1:24pm
 ; bcp's the global into MySQL
 NEW RET
 
 D STT("^RX","rx.txt")
 S RET=$$LOAD("medication_statement","rx.txt")
 Q:RET=1
 
 D STT("^PATIENT","patient.txt")
 S RET=$$LOAD("patient","patient.txt")
 Q:RET=1
 
 D STT("^OBS","observation.txt")
 S RET=$$LOAD("observation","observation.txt")
 Q:RET
 
 D STT("^ORGS","organization.txt")
 S RET=$$LOAD("organization","organization.txt")
 Q:RET
 
 D STT("^ENC","encounter.txt")
 S RET=$$LOAD("encounter","encounter.txt")
 Q:RET
 
 D STT("^P","practitioner.txt")
 S RET=$$LOAD("practitioner","practitioner.txt")
 Q:RET
 
 D STT("^ADDRESS","address.txt")
 S RET=$$LOAD("patient_address","address.txt")
 Q:RET
 
 D STT("^PERSON","person.txt")
 S RET=$$LOAD("person","person.txt")
 Q:RET
 
 D STT("^EOC","eoc.txt")
 S RET=$$LOAD("episode_of_care","eoc.txt")
 quit:RET
 
 ;D STT("^RX","rx.txt")
 ;quit:$$LOAD("medication_statement","rx.txt")
 
 D STT("^ALLERGY","allergy.txt")
 quit:$$LOAD("allergy_intolerance","allergy.txt")
 
 D STT("^APP","appointments.txt")
 quit:$$LOAD("appointment","appointments.txt")
 
 D STT("^RXORDER","rxorder.txt")
 quit:$$LOAD("medication_order","rxorder.txt")
 
 D STT("^CONTACT","contact.txt")
 quit:$$LOAD("patient_contact","contact.txt")
 
 quit
 
 new HOST,USER,PASS,DB,SQL,X
 
 S HOST=^ICONFIG("MYSQL","HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","DB")
 
 S X="/usr/bin/mysql --local_infile=1 -h "_HOST_" --user="_USER_" --password="_PASS
 
 D STT("^RX","/datagenerator/test/rx.txt")
 D STT("^PATIENT","/datagenerator/test/patient.txt")
 D STT("^OBS","/datagenerator/test/observation.txt")
 D STT("^ORGS","/datagenerator/test/organization.txt")
 D STT("^ENC","/datagenerator/test/encounter.txt")
 D STT("^P","/datagenerator/test/practitioner.txt")
 D STT("^ADDRESS","/datagenerator/test/address.txt")
 D STT("^PERSON","/datagenerator/test/person.txt")
 D STT("^EOC","/datagenerator/test/eoc.txt")
 D STT("^RX","/datagenerator/test/rx.txt")
 D STT("^ALLERGY","/datagenerator/test/allergy.txt")
 D STT("^APP","/datagenerator/test/appointments.txt")
 D STT("^RXORDER","/datagenerator/test/rxorder.txt")
 D STT("^CONTACT","/datagenerator/test/contact.txt")
 
 K SQL
 set SQL(1)="truncate table synthetic.medication_statement;"
 set SQL(2)="truncate table synthetic.patient;"
 set SQL(3)="truncate table synthetic.observation;"
 set SQL(4)="truncate table synthetic.encounter;"
 set SQL(5)="truncate table synthetic.practitioner;"
 set SQL(6)="truncate table synthetic.patient_address;"
 set SQL(7)="truncate table synthetic.person;"
 set SQL(8)="truncate table synthetic.episode_of_care;"
 set SQL(9)="truncate table synthetic.medication_statement;"
 set SQL(10)="truncate table synthetic.allergy_intolerance;"
 set SQL(11)="truncate table synthetic.appointment;"
 set SQL(12)="truncate table synthetic.medication_order;"
 set SQL(14)="truncate table synthetic.patient_contact;"
 
 ;S SQL(19)=$$DEBUG("medication_statement")
 set SQL(20)="load data local infile '/datagenerator/test/rx.txt' into table synthetic.medication_statement FIELDS TERMINATED BY '\t';"
 set SQL(22)="load data local infile '/datagenerator/test/patient.txt' into table synthetic.patient FIELDS TERMINATED BY '\t';"
 set SQL(24)="load data local infile '/datagenerator/test/observation.txt' into table synthetic.observation FIELDS TERMINATED BY '\t';"
 set SQL(26)="load data local infile '/datagenerator/test/encounter.txt' into table synthetic.encounter FIELDS TERMINATED BY '\t';"
 set SQL(28)="load data local infile '/datagenerator/test/practitioner.txt' into table synthetic.practitioner FIELDS TERMINATED BY '\t';"
 set SQL(30)="load data local infile '/datagenerator/test/address.txt' into table synthetic.patient_address FIELDS TERMINATED BY '\t';"
 set SQL(32)=$$INFILE("person.txt","person")
 set SQL(34)=$$INFILE("eoc.txt","episode_of_care")
 set SQL(36)=$$INFILE("rx.txt","medication_statement")
 set SQL(38)=$$INFILE("allergy.txt","allergy_intolerance")
 set SQL(40)=$$INFILE("appointments.txt","appointment")
 set SQL(42)=$$INFILE("rxorder.txt","medication_order")
 set SQL(44)=$$INFILE("contact.txt","patient_contact")
 
 S F="/datagenerator/test/load-stuff.sql"
 C F
 O F:(newversion)
 F I=1:1:$O(SQL(""),-1) DO
 .if $get(SQL(I))="" quit
 .U F W SQL(I),!
 .QUIT
 CLOSE F
 
 S CMD=X_" < /datagenerator/test/load-stuff.sql"
 ZSYSTEM CMD
 QUIT
 
LOAD(table,file) 
 new HOST,USER,PASS,DB,SQL,CMD,DIR,FILE
 
 w !,"bcp'in "_table_", data is in ",file
 
 S HOST=^ICONFIG("MYSQL","HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","DB")
 S DIR=^ICONFIG("MYSQL","DIR")
 
 S FILE=DIR_file
 
 S X="/usr/bin/mysql --local_infile=1 -h "_HOST_" --user="_USER_" --password="_PASS_" --execute="
 
 set SQL="""truncate table synthetic."_table_"; load data local infile '"_FILE_"' into table "_DB_"."_table_" FIELDS TERMINATED BY '\t';"""
 
 W !,SQL
 S CMD=X_SQL_" 2>/dev/null"
 ZSYSTEM CMD
 ;W !,"$T=",$T
 ;W !,"$ZSSYSTEM=",$ZSYSTEM
 I $ZSYSTEM=1 W !,"Something went wrong whilst loading the ",table," table?"
 quit $ZSYSTEM
 
 ;
ONEOFF ; test
 new HOST,USER,PASS,DB,SQL
 S HOST=^ICONFIG("MYSQL","HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","DB")
 
 S X="/usr/bin/mysql --local_infile=1 -h "_HOST_" --user="_USER_" --password="_PASS_" --execute="
 
 ;S X="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute="
 
 ;D STT("^RX","/datagenerator/test/rx.txt")
 
 set SQL="""truncate table synthetic.medication_statement; load data local infile '/datagenerator/test/rx.txt' into table synthetic.medication_statement FIELDS TERMINATED BY '\t';"""
 
 S CMD=X_SQL
 W !,CMD
 ZSYSTEM CMD
 quit
 
DEBUG(txt) ; 
 set txtout="select concat('** ', 'loading '"_txt_"') AS '** DEBUG:';"
 quit txtout
 
INFILE(file,table) ;
 new sql,dir
 set dir=^ICONFIG("MYSQL","DIR")
 set file=dir_file
 set sql="load data local infile '"_file_"' into table synthetic."_table_" FIELDS TERMINATED BY '\t';"
 quit sql
 
STT(GLOB,F) ;
 new dir
 set dir=^ICONFIG("MYSQL","DIR")
 set F=dir_F
 W !,"writing ",F," to disk"
 CLOSE F
 O F:(newversion)
 F  S GLOB=$Q(@GLOB) Q:GLOB=""  U F W @GLOB,!
 CLOSE F
 QUIT
