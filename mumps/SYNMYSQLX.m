SYNMYSQLX ; ; 3/16/22 10:28am
 quit
 
BP ;
 new zznor,host,user,pass,zzsys,zzdia,in,c,sql,cmd,db
 
 kill ^BP,^BPOBS
 ; simpler implemetation
 kill ^ZCOUNTS("BP")
 K ^STATS("BP-NOR")
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 ;set zzsys="1047556",zzdia="1047557"
 set zzsys=^ICONFIG("BP","SYS"),zzdia=^ICONFIG("BP","DIA")
 
 set (in,zznor)="",c=0
 
 for  set zznor=$order(^AXIN(zzsys,zznor)) quit:zznor=""  do
 .set c=c+1
 .if c#1000=0 do
 ..write !,c," NOR=",zznor
 ..set in=$extract(in,1,$length(in)-1)
 ..set sql="""use "_db_"; SELECT id, clinical_effective_date, non_core_concept_id, result_value, parent_observation_id, patient_id FROM observation where patient_id IN ("_in_") and (non_core_concept_id = '"_zzsys_"' or non_core_concept_id = '"_zzdia_"') order by clinical_effective_date, id ASC;"""
 ..set x="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 ..set cmd=x_sql_" > /datagenerator/nel/bp_obs.txt"
 ..ZSYSTEM cmd
 ..do READBP(zzsys,zzdia)
 ..set in=""
 ..quit
 .set in=in_zznor_","
 .quit
 
 if in'="" do END(x,in,zzsys,zzdia)
 
 quit

END(x,in,zzsys,zzdia) ;
 new sql
 
 set in=$extract(in,1,$length(in)-1)
 
 set sql="""use internal_nel_secondary_pid; SELECT id, clinical_effective_date, non_core_concept_id, result_value, parent_observation_id, patient_id FROM observation where patient_id IN ("_in_") and (non_core_concept_id = '"_zzsys_"' or non_core_concept_id = '"_zzdia_"') order by clinical_effective_date, id ASC;"""
 ;W !,sql
 ;S SQL=sql
 ;W !,"PRESS A KEY: " R *y
 set cmd=x_sql_" > /datagenerator/barts/bp_obs.txt"
 ZSYSTEM cmd
 do READBP(zzsys,zzdia)
 quit
 
READBP(zzsys,zzdia) ;
 ; 1414664 - O/E - Systolic BP reading~2469.
 ; 1414648 - O/E - Diastolic BP reading~246A.
 ;
 ; * ALSO *
 ; 1047556 - O/E - Systolic BP reading~2469.
 ; 1047557 - O/E - Diastolic BP reading~246A.
 ;
 new f,str,id,date,ite,nor,d,h,value,cnt,id,sys,dia,did,c
 
 kill ^T
 set f="/datagenerator/nel/bp_obs.txt"
 close f
 open f:(readonly)
 use f read str
 if $zeof close f quit
 
 for  use f read str quit:$zeof  do
 .set id=$piece(str,$char(9),1)
 .set date=$piece(str,$char(9),2)
 .set ite=$piece(str,$char(9),3)
 .set value=$piece(str,$char(9),4)
 .set date=$piece(date," ",1)
 .set nor=$piece(str,$char(9),6)
 .set d=$piece(date,"-",3)_"."_$piece(date,"-",2)_"."_$piece(date,".",1)
 .set h=$$DH^STDDATE(d)
 .set ^T(nor,h,ite,id)=value
 .quit
 close f
 
 ; PAIR UP THE SYSTOLIC AND DIASTOLIC READINGS
 set (nor,h,ite,id)=""
 for  set nor=$order(^T(nor)) quit:nor=""  do
 .for  set h=$order(^T(nor,h)) quit:h=""  do
 ..set cnt=1
 ..for  set id=$order(^T(nor,h,zzsys,id)) quit:id=""  do
 ...set sys=^(id)
 ...kill dia
 ...do DIA(nor,h,cnt,.dia)
 ...set did=$get(dia(1),"?")
 ...set dia=$get(dia(2),"?")
 ...set cnt=cnt+1
 ...set ^BP(sys,dia,nor)=""
 ...set zc=$order(^BPOBS(nor,""),-1)+1
 ...set ^BPOBS(nor,zc)=id_"~"_did ; SYSTOLIC & DIASTOLIC OBS IDS
 ...; simpler implementation
 ...set age=$get(^ASUM(nor,"age"))
 ...set sex=$get(^ASUM(nor,"sex"))
 ...set c=$order(^ZCOUNTS("BP",age,sex,""),-1)+1
 ...set ^ZCOUNTS("BP",age,sex,c)=sys_"/"_dia
 ...set ^STATS("BP-NOR",age,sex,nor)=$get(^STATS("BP-NOR",age,sex,nor))+1
 ...quit
 ..quit
 .quit
 
 quit
 
DIA(nor,h,cnt,dia) ;
 new id,i
 set id=""
 for i=1:1:cnt set id=$order(^T(nor,h,zzdia,id)) Q:id=""
 set dia="?"
 if id'="" set dia(1)=id,dia(2)=^T(nor,h,zzdia,id)
 quit
 
POSTCDE() ;
 N pcde,num,firstchar,secondchar
 s pcde=$order(^GARBLE("PCPREFIX",""),-1)
 s pcde=$random(pcde)+1
 s pcde=^GARBLE("PCPREFIX",pcde)
 S num=$random(9)
 S firstchar=$random(26)
 s secondchar=$random(26)
 S pcde=pcde_" "_num_$char(firstchar+65)_$char(secondchar+65)
 QUIT pcde
 
PC new f,c,str
 K ^GARBLE("PCPREFIX")
 S f="/tmp/post_code_prefixes.txt"
 CLOSE f
 O f:(readonly)
 S c=1
 F  U f R str Q:$zeof  DO
 .S str=$translate(str,$C(13),"")
 .U 0 W !,str," * ",$L(str),! ; R *Y
 .S ^GARBLE("PCPREFIX",c)=str
 .S c=c+1
 .QUIT
 CLOSE f
 QUIT
 
SURNAMES ;
 new f,c,str
 
 K ^GARBLE("SNM")
 S f="/tmp/SURNAMES.txt"
 CLOSE f
 S c=1
 O f:(readonly)
 F  U f R str Q:$zeof  DO
 .I str="" QUIT
 .S str=$P(str,"@",1)
 .S ^GARBLE("SNM",c)=str
 .S c=$I(c)
 .QUIT
 CLOSE f
 QUIT
 
FIRSTNAMES ;
 N f,c,str,sex,first
 
 K ^GARBLE("FNM")
 S f="/datagenerator/nel/FIRSTNAMES.txt"
 CLOSE f
 S c=1
 O f:(readonly)
 U f R str
 F  U f R str Q:$ZEOF  DO
 .U 0 W str,!
 .S sex=$P(str,",",2)
 .S first=$P(str,",",3)
 .S c=$order(^GARBLE("FNM",sex,""),-1)+1
 .S ^GARBLE("FNM",sex,c)=first
 .QUIT
 CLOSE f
 QUIT
 
NHSNO() ;
 new nhs,i,valnhs
 S nhs=""
 f i=1:1:10 s nhs=nhs_$r(10)
 S valnhs=0
 f i=0:1:9 q:valnhs=1  d
 .s $e(nhs,10)=i
 .i $$NHSVAL(nhs)=1 s valnhs=1 q
 .quit
 QUIT nhs
 
NHSVAL(nhs) 
 N i,tot,chk
 I nhs'?10N Q 0         ;invalid: must be 10 digits
 I nhs<3200000000 Q 0
 S tot=0 F i=1:1:9 S tot=tot+((11-i)*$E(nhs,i))
 S chk=(11-(tot#11))#11
 I chk=10 Q 0           ;invalid if 10
 Q ($E(nhs,10)=chk)     ;check digit matches?
