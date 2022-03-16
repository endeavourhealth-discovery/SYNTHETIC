SYNENC1 ; ; 3/16/22 10:30am
 ; A GO FASTER VERSION OF OBSENC^ENCOUNTER
 quit
 
OBSENC  ;
 new nor,host,user,pass,sql,xx,zt,in,c,cmd,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT p.role_desc, e.clinical_effective_date as condate, e.id as eid, o.clinical_effective_date as obsdate, o.id, o.non_core_concept_id, o.result_value, o.result_value_units, o.parent_observation_id, o.patient_id, p.id, p.organization_id  FROM observation o join encounter e on o.encounter_id = e.id join practitioner p on p.id = e.practitioner_id WHERE o.patient_id IN ()"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 S nor="",zt=1
 
 K ^STATS("OBS-ENC")
 K ^STATS("OBS-ENC-COUNT")
 K ^STATS("ENC-NOR-ROLE")
 
 K ^SCRATCH
 
 S in="",c=0
 F  S nor=$O(^COHORT(nor)) Q:nor=""  DO
 .S c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",nor
 ..S in=$extract(in,1,$length(in)-1)
 ..S $piece(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/obs-enc.txt"
 ..ZSYSTEM cmd
 ..D SAVE1
 ..S in=""
 ..QUIT
 .S in=in_nor_","
 .QUIT
 
 D:in'="" END(sql,in,xx)
 
 quit
 
END(sql,in,xx) ;
 new cmd
 S in=$extract(in,1,$length(in)-1)
 S $piece(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/obs-enc.txt"
 ZSYSTEM cmd
 D SAVE1
 QUIT
 
SAVE1 ;
 new nor,f,str,role,code,value,valueunits,parentobs,value,age,sex,encid,parentobs,practid,orgid
 
 S f="/datagenerator/nel/obs-enc.txt"
 close f
 O f:(readonly)
 U f R str
 I $zeof close f quit
 F  U f R str Q:$zeof  DO
 .S role=$P(str,$C(9),1)
 .S encid=$P(str,$C(9),3)
 .S code=$P(str,$C(9),6)
 .S value=$P(str,$C(9),7)
 .S valueunits=$P(str,$C(9),8)
 .S parentobs=$P(str,$C(9),9)
 .I value="NULL" S value=""
 .I parentobs="NULL" S parentobs=""
 .S practid=$p(str,$C(9),11)
 .S orgid=$p(str,$c(9),12)
 .S nor=$P(str,$C(9),10)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .S ^STATS("ENC-NOR-ROLE",role,age,sex,nor,encid,code)=""
 .I value'="" S ^STATS("ENC-NOR-ROLE",role,age,sex,nor,encid,code,"V",value)=valueunits
 .S:value'="" ^STATS("OBS-ENC",role,age,sex,encid,code,"V",value)=valueunits
 .S:value="" ^STATS("OBS-ENC",role,age,sex,encid,code)=""
 .if parentobs'="" S ^STATS("OBS-ENC",role,age,sex,encid,code,"P",parentobs)=""
 .S ^STATS("OBS-ENC-COUNT",role,age,sex,encid,code)=$get(^STATS("OBS-ENC-COUNT",role,age,sex,encid,code))+1
 .S:'$data(^SCRATCH(orgid,practid)) ^SCRATCH(orgid,practid)=""
 .quit
 close f
 quit

SCRATCH ;
 N O,P,T
 S (O,P)=""
 S T=0
 F  S O=$O(^SCRATCH(O)) Q:O=""  DO
 .F  S P=$O(^SCRATCH(O,P)) Q:P=""  DO
 ..S O(O)=$GET(O(O))+1
 ..Q
 W !
 ZWR O
 QUIT