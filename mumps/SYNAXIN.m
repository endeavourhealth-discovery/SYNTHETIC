SYNAXIN ; ; 3/16/22 10:29am
 new nor,host,user,pass,c,sql,in,x,cmd,db
 
 set nor=""
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 kill ^AXIN
 
 set c=0
 set sql="""use "_db_"; SELECT patient_id, clinical_effective_date, core_concept_id, non_core_concept_id from observation where patient_id IN ()"
 
 set in=""
 for  set nor=$order(^COHORT(nor)) Q:nor=""  do
 .set c=c+1
 .; RUN THE SQL
 .if c#2000=0 do
 ..use 0 write !,c," NOR=",nor
 ..set in=$extract(in,1,$length(in)-1)
 ..set $piece(sql,"(",2)=in
 ..set sql=sql_");"""
 ..set x="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 ..set cmd=x_sql_" > /datagenerator/nel/observations.txt"
 ..ZSYSTEM cmd
 ..set in=""
 ..do AXIN1
 ..quit
 .set in=in_nor_","
 .quit	
 quit
 
AXIN1 ;
 new f,str,patid,noncore,dat,h
 set f="/datagenerator/nel/observations.txt"
 close f
 open f:(readonly)
 use f read str ; HEADER
 if $zeof quit
 for  use f read str quit:$zeof  do
 .set patid=$P(str,$char(9),1)
 .set noncore=$piece(str,$char(9),4)
 .if noncore="NULL" quit
 .set dat=$piece($piece(str,$char(9),2)," ")
 .set dat=$P(dat,"-",3)_"."_$P(dat,"-",2)_"."_$P(dat,"-",1)
 .set h=$$DH^STDDATE(dat)
 .set ^AXIN(noncore,patid,h)=""
 .quit
 CLOSE f	
 QUIT
