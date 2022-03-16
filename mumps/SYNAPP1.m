SYNAPP1 ; ; 3/16/22 9:48am
 ; APPOINTMENTS
 new host,user,pass,sql,xx,zznor,in,c,cmd,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT p.role_desc, app.* FROM appointment app join practitioner p on p.id = app.practitioner_id WHERE app.patient_id IN ();"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 S zznor="",zt=1
 
 K ^STATS("APP"),^STATS("APP-NOR")
 K ^STATS("APP-CANCEL")
 
 S in="",c=0
 F  S zznor=$O(^COHORT(zznor)) Q:zznor=""  DO
 .S c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",zznor
 ..S in=$E(in,1,$L(in)-1)
 ..S $P(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/apps.txt"
 ..ZSYSTEM cmd
 ..D SAVE1
 ..S in=""
 ..quit
 .S in=in_zznor_","
 .quit
 
 I in'="" D END(sql,in,xx)
 quit
 
END(sql,in,xx) ;
 new cmd
 S in=$E(in,1,$L(in)-1)
 S $P(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/apps.txt"
 ZSYSTEM cmd
 D SAVE1
 quit
 
SAVE1 ;
 n f,str,role,zzid,nor,age,sex,noncore,zcancelled
 new concept,planneddur,patdelay,actual,wait
 new cohortorg,orgid
 
 s f="/datagenerator/nel/apps.txt"
 close f
 
 O f:(readonly)
 u f r str
 I $zeof CLOSE f QUIT
 F  U f R str Q:$ZEOF  DO
 .S role=$P(str,$C(9),1)
 .S zzid=$P(str,$C(9),2)
 .S nor=$P(str,$C(9),4)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .set orgid=$piece(str,$C(9),3)
 .; current org for patient
 .set cohortorg=$P(^COHORT(nor),"~",1)
 .if orgid'=cohortorg quit ; *** continue ***
 .S concept=$P(str,$C(9),11)
 .S cancelled=$P(str,$C(9),17)
 .I cancelled="NULL" S cancelled=""
 .set zcancelled=0
 .if cancelled'="" set zcancelled=1
 .S planneddur=$piece(str,$c(9),9)
 .I planneddur="NULL" set planneddur=""
 .S patdelay=$piece(str,$c(9),13)
 .I patdelay="NULL" set patdelay=""
 .S wait=$p(str,$c(9),12)
 .I wait="NULL" set wait=""
 .S actual=$P(str,$c(9),10)
 .I actual="NULL" set actual=""
 .if zcancelled set ^STATS("APP-CANCEL",age,sex,nor)=$get(^STATS("APP-CANCEL",age,sex,nor))+1
 .; concepts
 .; pending, booked, arrived, fulfilled, cancelled, no show
 .set ^STATS("APP",role,age,sex,concept)=""
 .set ^STATS("APP-NOR",age,sex,nor,zzid,concept)=""
 .set:planneddur'="" ^STATS("APP",role,age,sex,concept,"plandur",planneddur)=""
 .set:patdelay'="" ^STATS("APP",role,age,sex,concept,"patdelay",patdelay)=""
 .set:wait'="" ^STATS("APP",role,age,sex,concept,"wait",wait)=""
 .set:actual'="" ^STATS("APP",role,age,sex,concept,"actual",actual)=""
 .quit
 CLOSE f
 quit
