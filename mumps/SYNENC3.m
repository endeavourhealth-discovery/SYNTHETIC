SYNENC3 ; ; 3/14/22 4:14pm
 QUIT
 
EVENTS ;
 new sql,in,c,nor,cmd,xx,host,user,pass,db
 
 set db=^ICONFIG("MYSQL","DB")
 S sql="""use "_db_"; SELECT * FROM encounter_event ev "
 S sql=sql_" WHERE (organization_id = 2782572 or organization_id =1874749 or organization_id= 11953981) and ev.person_id IN ()"
 
 K ^STATS("ENC-EVENTS")
 K ^D
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 K ^AXPERSON
 S nor=""
 for  s nor=$o(^COHORT(nor)) q:nor=""  do
 .s personid=^ASUM(nor,"personid")
 .;
 .set age=^ASUM(nor,"age")
 .set sex=^ASUM(nor,"sex")
 .set ^AXPERSON(personid)=age_"~"_sex
 .quit
 
 ;quit
 
 S in="",c=0,nor=""
 ;for  set nor=$order(^COHORT(nor)) quit:nor=""  do
 for  set nor=$order(^AXPERSON(nor)) quit:nor=""  do
 .set c=c+1
 .if c#1000=0 do
 ..w !," NOR [",nor,"] c=",c
 ..set in=$extract(in,1,$length(in)-1)
 ..set $piece(sql,"(",3)=in
 ..set sql=sql_");"""
 ..set cmd=xx_sql_" > /datagenerator/barts/enc-events.txt"
 ..zsystem cmd
 ..D SAVE1
 ..set in=""
 ..quit
 .set in=in_nor_","
 .quit
 
 if in'="" D END(sql,in,xx)
 quit
 
END(sql,in,xx) ;
 new cmd
 S in=$extract(in,1,$length(in)-1)
 S $piece(sql,"(",3)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/barts/obs-enc.txt"
 ZSYSTEM cmd
 D SAVE1
 quit
 
SAVE1 ;
 new f,str,encid,noncore,nor,admethod
 
 S f="/datagenerator/barts/enc-events.txt"
 close f
 open f:(readonly)
 u f r str
 if $zeof close f quit
 f  u f r str q:$zeof  do
 .set nor=$p(str,$c(9),4) ; personid
 .set rec=^AXPERSON(nor)
 .S age=$p(rec,"~",1)
 .S sex=$p(rec,"~",2)
 .set encid=$piece(str,$c(9),5)
 .set noncore=$p(str,$c(9),13)
 .set admethod=$p(str,$c(9),17)
 .set ^STATS("ENC-EVENTS",age,sex,admethod,encid,noncore)=""
 .set ^STATS("ENC-EVENTS-X",age,sex,admethod,noncore)=""
 .;S:'$data(^D(admethod)) ^D(admethod)=""
 .;S ^D(age,sex,admethod,noncore)=$GET(^D(age,sex,admethod,noncore))+1
 .quit
 close f
 quit
