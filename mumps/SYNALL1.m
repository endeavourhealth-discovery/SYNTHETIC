SYNALL1 ; ; 3/16/22 9:46am
 ; ALLERGIES
 quit
GO new host,user,pass,sql,xx,zznor,in,c,cmd,zt,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT p.role_desc, a.* FROM allergy_intolerance a join practitioner p on p.id = a.practitioner_id WHERE a.patient_id IN ()"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 S zznor="",zt=1
 
 K ^STATS("ALLERGY"),^STATS("ALLERGY-NOR")
 
 S in="",c=0
 F  S zznor=$O(^COHORT(zznor)) Q:zznor=""  DO
 .S c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",zznor
 ..S in=$E(in,1,$L(in)-1)
 ..S $P(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/allergies.txt"
 ..ZSYSTEM cmd
 ..D SAVE1
 ..S in=""
 ..QUIT
 .S in=in_zznor_","
 .QUIT
 
 I in'="" D END(sql,in,xx)
 QUIT
 
END(sql,in,xx) ;
 new cmd
 S in=$E(in,1,$L(in)-1)
 S $P(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/allergies.txt"
 ZSYSTEM cmd
 D SAVE1
 QUIT
 
SAVE1 ;
 n f,str,role,zzid,nor,noncore
 
 S f="/datagenerator/nel/allergies.txt"
 CLOSE f
 O f:(readonly)
 U f R str
 I $zeof CLOSE f QUIT
 F  U f R str Q:$ZEOF  DO
 .set role=$P(str,$C(9),1)
 .set zzid=$P(str,$C(9),2)
 .set nor=$P(str,$C(9),4)
 .set noncore=$piece(str,$C(9),12)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .S ^STATS("ALLERGY",role,age,sex,noncore)=""
 .S ^STATS("ALLERGY-NOR",age,sex,nor,zzid,noncore)=""
 .QUIT
 CLOSE f
 QUIT
