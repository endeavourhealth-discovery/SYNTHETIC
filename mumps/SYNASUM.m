SYNASUM ; ; 3/16/22 2:12pm
 quit
 
STT(GP) new HOST,USER,PASS,DB
 
 K ^ASUM
 
 set HOST=^ICONFIG("MYSQL","HOST")
 set USER=^ICONFIG("MYSQL","USER")
 set PASS=^ICONFIG("MYSQL","PASS")
 set DB=^ICONFIG("MYSQL","DB")
 
 S QF=0
 S SQL="select id, date_of_birth, organization_id, gender_concept_id,ethnic_code_concept_id, person_id from "_DB_".patient"
 
 I +$G(GP) DO
 .S SQL="SELECT p.id, p.date_of_birth, p.gender_concept_id, p.organization_id, pa.address_line_1, pa.address_line_2, pa.address_line_3, pa.address_line_4, pa.city, pa.postcode, e.date_registered, p.current_address_id, p.last_name, p.nhs_number, p.person_id, p.title, p.ethnic_code_concept_id FROM "_DB_".patient p join "_DB_".episode_of_care e on e.patient_id = p.id join "_DB_".concept c on c.dbid = e.registration_type_concept_id join "_DB_".patient_address pa on pa.id=p.current_address_id where c.code = 'R' and p.date_of_death IS NULL and e.date_registered <= now() and (e.date_registered_end > now() or e.date_registered_end IS NULL)"
 .QUIT
 
 F START=0:500000 DO  Q:QF
 .S ROWCOUNT=500000
 .S CMD="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute """_SQL_" limit "_START_", "_ROWCOUNT_";"" > /datagenerator/barts/patients.txt"
 .W !,CMD
 .ZSYSTEM CMD
 .S QF=$$READ("/datagenerator/barts/patients.txt")
 .QUIT
 QUIT
 
READ(f) ;
 new str,nor,dob,orgid,gender,ethnic,sex,personid
 close f
 o f:(readonly)
 u f r str
 if $zeof close f q 1
 f  u f r str q:$zeof  do
 .s nor=$p(str,$c(9),1)
 .s dob=$p(str,$c(9),2)
 .s orgid=$p(str,$c(9),3)
 .s gender=$p(str,$c(9),4)
 .s ethnic=$p(str,$c(9),5)
 .set personid=$piece(str,$c(9),6)
 .;if ethnic="NULL" s ethnic=""
 .set sex=$S(gender=1335244:"M",gender=1335245:"F",1:"?")
 .if sex="?" quit
 .set ^ASUM(nor)=orgid
 .set ^ASUM(nor,"dob")=dob
 .set ^ASUM(nor,"age")=$$AGE^SYNRANDOM(dob)
 .set ^ASUM(nor,"org")=orgid
 .set ^ASUM(nor,"gender")=gender
 .set ^ASUM(nor,"sex")=sex
 .set ^ASUM(nor,"ethnic")=ethnic
 .set ^ASUM(nor,"personid")=personid
 .quit
 close f
 quit 0
