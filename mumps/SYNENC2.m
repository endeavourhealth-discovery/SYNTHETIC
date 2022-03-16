SYNENC2 ; ; 3/16/22 10:30am
 ; ENCOUNTER NUMBERS
 
ENC  ;
 new nor,host,user,pass,sql,xx,zt,in,c,cmd,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT e.id, patient_id, non_core_concept_id from encounter e WHERE e.patient_id IN ()"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 S nor="",zt=1
 
 K ^STATS("ENC-NOR")
 
 S in="",c=0
 F  S nor=$O(^COHORT(nor)) Q:nor=""  DO
 .S c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",nor
 ..S in=$extract(in,1,$length(in)-1)
 ..S $piece(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/encs.txt"
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
 S cmd=xx_sql_" > /datagenerator/nel/encs.txt"
 ZSYSTEM cmd
 D SAVE1
 QUIT
 
SAVE1 ;
 new nor,encid,age,sex,f
 
 S f="/datagenerator/nel/encs.txt"
 close f
 O f:(readonly)
 U f R str
 I $zeof close f quit
 F  U f R str Q:$zeof  DO
 .S encid=$P(str,$C(9),1)
 .S nor=$P(str,$C(9),2)
 .S noncore=$p(str,$c(9),3)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .S ^STATS("ENC-NOR",age,sex,nor,encid)=""
 .S ^STATS("ENC-ASSOC",age,sex,noncore)=$get(^STATS("ENC-ASSOC",age,sex,noncore))+1
 .quit
 close f
 quit

ASSOC ;
 K ^ZD
 N AGE,SEX,ITE
 F AGE=0:1:100 DO
 .F SEX="M","F" DO
 ..S ITE=""
 ..F  S ITE=$O(^STATS("ENC-ASSOC",AGE,SEX,ITE)) Q:ITE=""  DO
 ...W !,ITE
 ...S T=^(ITE)
 ...S ^ZD(ITE)=$P(^CONCEPT(ITE),"~",1)
 ...S ^ZD(ITE,"T")=$GET(^ZD(ITE,"T"))+T
 ...QUIT
 ..QUIT
 QUIT