SYNCONTACT1 ; ; 3/16/22 10:29am
 new host,user,pass,sql,xx,zznor,in,c,cmd,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT c.* FROM patient_contact c WHERE c.patient_id IN ()"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 set zznor=""
 
 K ^STATS("CONTACT-NOR")
 K ^STATS("CONTACT-X")
 
 K ^STATS("CONTACT-NOR-USE")
 K ^STATS("CONTACT-NOR-TYPE")
 
 set in="",c=0
 F  S zznor=$O(^COHORT(zznor)) Q:zznor=""  DO
 .s c=c+1
 .if c#1000=0 do
 ..u 0 w !,c," NOR=",zznor
 ..s in=$E(in,1,$L(in)-1)
 ..set $P(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/contact.txt"
 ..zsystem cmd
 ..do SAVE1
 ..set in=""
 ..quit
 .set in=in_zznor_","
 .quit
 if in'="" D END(sql,in,xx)
 quit
 
END(sql,in,xx) 
 new cmd
 S in=$E(in,1,$L(in)-1)
 S $P(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/contact.txt"
 zsystem cmd
 D SAVE1
 quit
 
SAVE1 ;
 n f,str
 S f="/datagenerator/nel/contact.txt"
 close f
 o f:(readonly)
 u f r str
 if $zeof close f quit
 F  U f R str Q:$ZEOF  DO
 .set nor=$p(str,$c(9),3)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .;set nor=$p(str,$c(9),3)
 .set useconcept=$p(str,$c(9),5)
 .set typeconcept=$p(str,$c(9),6)
 .set enddate=$p(str,$c(9),8)
 .set id=$p(str,$c(9),1)
 .U 0 W !,"[",enddate,"]"
 .if enddate="NULL" s enddate=""
 .U 0 W !,"[",enddate,"]"
 .set ^STATS("CONTACT-NOR",age,sex,nor,id,useconcept,typeconcept)=""
 .if enddate'="" S ^STATS("CONTACT-X",age,sex,nor,useconcept,typeconcept)=$get(^STATS("CONTACT-X",age,sex,nor,useconcept,typeconcept))+1
 .if enddate'="" set ^STATS("CONTACT-X",age,sex,nor)=$get(^STATS("CONTACT-X",age,sex,nor))+1
 .quit
 close f
 quit
