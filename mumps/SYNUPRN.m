SYNUPRN ; ; 4/7/22 1:15pm
 new id,rec,zd
 new add1,add2,add3,add4,postcode,adrec
 new a,r,c,stop,tmp,i,pmid,d1,ralf,status,m,matchdate
 new algversion
 
 set id="",zd=$char(9),c=1,stop=0,pmid=1
 set m=$$HD^STDDATE(+$H)
 set matchdate=$p(m,".",3)_"-"_$p(m,".",2)_"-"_$p(m,".",1)
 
 kill ^U
 
 for  set id=$order(^ADDRESS(id)) quit:id=""  do  Q:stop>+^ICONFIG("STOPU")
 .set stop=$i(stop)
 .set rec=^ADDRESS(id)
 .set add1=$piece(rec,zd,5)
 .set add2=$piece(rec,zd,6)
 .set add3=$piece(rec,zd,7)
 .set add4=$p(rec,zd,8)
 .set city=$p(rec,zd,9)
 .set postcode=$p(rec,zd,10)
 .set adrec=add1_","_add2_","_add3_","_add4_","_city_","_postcode
 .;U 0 W !,adrec
 .kill a,r
 .set a("adrec")=adrec
 .d GETCSV^UPRNTEST(.r,.a)
 .if c#100=0 u 0 write !,^TMP($J,1)
 .s c=c+1
 .;U 0 W !,^TMP($J,1)
 .set tmp=^TMP($job,1)
 .
 .kill t
 .for i=1:1:$length(tmp,",") set data=$$LT^LIB($piece(tmp,",",i)) do
 ..if data="" set data="\N"
 ..set t(i)=data
 ..quit
 .; NULL UPRN?
 .if t(21)="\N" quit
 .set ralf="\N"
 .set epoch="\N"
 .set algversion="4.2.1e"
 .set status=1
 .set r=pmid_zd_id_zd_t(21)_zd_ralf_zd_status_zd_t(20)_zd_t(15)_zd
 .s r=r_t(16)_zd_t(18)_zd_t(19)_zd_t(8)_zd_t(7)_zd_matchdate_zd
 .s r=r_t(2)_zd_t(5)_zd_t(1)_zd_t(6)_zd_t(4)_zd_t(3)_zd_t(12)_zd
 .s r=r_t(13)_zd_t(11)_zd_t(9)_zd_t(10)_zd_algversion_zd_epoch
 .set ^U(pmid)=r
 .set pmid=$i(pmid)
 .quit
 
 D STT^PS("^U","uprn_match.txt")
 S RET=$$LOAD^PS("patient_address_match","uprn_match.txt")
 
 QUIT
 
FIXCLASS ;
 N UPRN,C
 ;K ^TFIXCLASS
 S UPRN="",C=1
 F  S UPRN=$O(^UPRN("CLASS",UPRN)) Q:UPRN=""  DO
 .;W !,UPRN
 .S ZUPRN=$$TR^LIB(UPRN,"""","")
 .;W !,ZUPRN
 .S ^TFIXCLASS("CLASS",ZUPRN)=^UPRN("CLASS",UPRN)
 .I C#10000=0 W !,ZUPRN
 .S C=C+1
 .QUIT
 QUIT
 
MERGE ;
 K ^UPRN("CLASS")
 M ^UPRN("CLASS")=^TFIXCLASS("CLASS")
 QUIT
