SYNSYLVIA4 ; ; 3/10/22 3:40pm
 ; BLOOD PRESSURES
 new id,zzsys,zzdia,age,sex,r,c,rec,bp,bpcounts
 new obsid,orgid,xnor,obsdate,practid,datprecision,resdate
 new restext,resconid,isprob,isreview,probenddate,parentobs,coreconcept
 new ageatevent,epsdconceptid,isprimary,daterecorded,zencid,zz,d
 
 set zzsys=^ICONFIG("BP","SYS"),zzdia=^ICONFIG("BP","DIA")
 
 K ^BPREC
 
 S obsid="?"
 S orgid="?"
 S xnor="?"
 S obsdate="?"
 S practid="?"
 
 S datprecision="\N"
 S resdate="\N"
 S restext="\N"
 S resconid="\N"
 S isprob="\N"
 S isreview="\N"
 S probenddate="\N"
 S parentobs="\N"
 S coreconcept="\N"
 
 S ageatevent="\N"
 S epsdconceptid="\N"
 S isprimary="\N"
 S daterecorded="\N"
 S zencid="\N"
 
 set id=""
 
 K bpcounts
 S stop=0,d=$char(9)
 
 for  s id=$order(^PATIENT(id)) q:id=""  do  q:stop>+^ICONFIG("STOP")
 .set stop=stop+1
 .set rec=^PATIENT(id)
 .S dob=$P(rec,d,9)
 .S gender=$P(rec,d,7)
 .S sex=$S(gender="1335245":"F",1:"M")
 .S age=$$AGE^SYNRANDOM(dob)
 .S bpcounts(age,sex)=$get(bpcounts(age,sex))+1
 .if bpcounts(age,sex)>+$get(^ZCNT("BP",age,sex)) quit
 .set r=$$TOTBP(age,sex)
 .W !,r
 .for zz=1:1:r do
 ..s bp=$$BPFORAS(age,sex)
 ..if bp="" quit
 ..set c=$order(^BPREC(age,id,""),-1)+1
 ..set rec=$$BPREC(zzsys,"\N","")
 ..set ^BPREC(age,id,c,1)=rec
 ..set sys=$P(bp,"/",1),dia=$P(bp,"/",2)
 ..set rec=$$BPREC(zzsys,sys,"mmHg")
 ..set ^BPREC(age,id,c,2)=rec
 ..set rec=$$BPREC(zzdia,dia,"mmHg")
 ..set ^BPREC(age,id,c,3)=rec
 ..quit
 .quit
 quit
 
FILE ;
 new age,id,c,rec,d,data,practid,orgid,dob,data
 new practid,parentrec,sysrec,diarec,cdate,parentid
 
 set d=$char(9)
 
 set (age,id,c)=""
 
 K ^OBSBP
 S ZZZID=$O(^OBS(""),-1)+1
 
 for  set age=$order(^BPREC(age)) quit:age=""  do
 .for  set id=$order(^BPREC(age,id)) quit:id=""  do
 ..for  set c=$order(^BPREC(age,id,c)) q:c=""  do
 ...set rec=$get(^PATIENT(id))
 ...set orgid=$P(rec,d,2)
 ...set dob=$P(rec,$C(9),9)
 ...kill data
 ...D PRACT^SYNSYLVIA2(orgid,.data)
 ...S practid=$GET(data(1))
 ...S parentrec=^BPREC(age,id,c,1)
 ...S sysrec=^BPREC(age,id,c,2)
 ...S diarec=^BPREC(age,id,c,3)
 ...S cdate=$$REGDATE^SYNSYLVIA1(dob)
 ...S parentid=""
 ...S parentrec=$$REREC(parentrec,orgid,id,practid,cdate,parentid)
 ...S parentid=$order(^OBSBP(""),-1)
 ...S sysrec=$$REREC(sysrec,orgid,id,practid,cdate,parentid)
 ...S diarec=$$REREC(diarec,orgid,id,practid,cdate,parentid)
 ...; GO FOR A DIFFERENT PRACTITIONER FOR NEXT BP
 ...K data
 ...DO PRACT^SYNSYLVIA2(orgid,.data)
 ...S practid=$GET(data(1))
 ...quit
 quit
 
REREC(zrec,orgid,patid,practid,cdate,parentid) ;
 new d
 S d=$C(9)
 S $P(zrec,d,1)=ZZZID
 S $P(zrec,d,2)=orgid
 S $P(zrec,d,3)=patid
 S $P(zrec,d,4)=patid
 S $P(zrec,d,6)=practid
 S $P(zrec,d,7)=cdate
 I parentid'="" S $P(zrec,d,17)=parentid
 S ^OBSBP(ZZZID)=zrec
 S ZZZID=$I(ZZZID)
 QUIT zrec
 
BPCNT ; count how many patients have at least 1 blood pressure reading in their record
 new age,sex,nor
 K ^ZCNT("BP")
 s (age,sex,nor)=""
 f  s age=$order(^STATS("BP-NOR",age)) q:age=""  do
 .f  s sex=$order(^STATS("BP-NOR",age,sex)) q:sex=""  do
 ..s t=0
 ..f  s nor=$o(^STATS("BP-NOR",age,sex,nor)) q:nor=""  do
 ...set t=t+1
 ...;set t=t+^(nor)
 ...quit
 ..S ^ZCNT("BP",age,sex)=t
 quit
 
BPFORAS(age,sex) ;
 new c,r
 set c=$order(^ZCOUNTS("BP",age,sex,""),-1)
 if c="" q ""
 S r=$random(c)+1
 ;if r=0 set r=1
 s rec=^ZCOUNTS("BP",age,sex,r)
 QUIT rec
 
BPREC(ite,value,units) ;
 new rec
 
 S coreconcept="\N"
 S map=$P($GET(^CONMAP(ite)),"~",1)
 S:map'="" coreconcept=map
 
 S rec=obsid_d_orgid_d_xnor_d_xnor_d_zencid_d_practid_d_obsdate_d
 S rec=rec_datprecision_d_value_d_units_d_resdate_d_restext_d_resconid_d
 S rec=rec_isprob_d_isreview_d_probenddate_d_parentobs_d_coreconcept_d_ite_d_ageatevent_d_epsdconceptid_d_isprimary_d_daterecorded
 Q rec
 
TOTBP(zzage,zzsex) 
 new c,r,totbp
 set c=$order(^ZCOUNTS("BP-AX",age,sex,""),-1)
 if c="" q 1
 W !,"zcounts ",c
 set r=$random(c)+1
 set totbp=^ZCOUNTS("BP-AX",age,sex,r)
 quit totbp
 
LIST ;
 new node,age,sex,nor,c
 K ^ZCOUNTS("BP-AX")
 S (age,sex,nor,id)=""
 S node="BP-NOR"
 F  S age=$O(^STATS(node,age)) Q:age=""  DO
 .F  S sex=$O(^STATS(node,age,sex)) Q:sex=""  DO
 ..F  S nor=$O(^STATS(node,age,sex,nor)) Q:nor=""  DO
 ...set t=^STATS(node,age,sex,nor)
 ...set c=$order(^ZCOUNTS("BP-AX",age,sex,""),-1)+1
 ...set ^ZCOUNTS("BP-AX",age,sex,c)=t
 ...QUIT
  QUIT
