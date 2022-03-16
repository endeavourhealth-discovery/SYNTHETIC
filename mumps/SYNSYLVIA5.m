SYNSYLVIA5 ; ; 3/10/22 3:41pm
 ; ALLERGY_INTOLERANCE
 ;
 new zztot,id,zalrgyid,stop,g1,g2,rec,d,gender
 
 new allcnts,stop
 
 K ^ALLERGY
 
 K ^TRACK("ALLERGY")
 
 set id="",zalrgyid=1,d=$char(9),stop=0
 kill allcnts
 for  set id=$order(^PATIENT(id)) quit:id=""  do  q:stop>+^ICONFIG("STOP")
 .s stop=stop+1
 .set rec=^PATIENT(id)
 .S orgid=$P(rec,d,2)
 .S dob=$P(rec,d,9)
 .S gender=$P(rec,d,7)
 .S zzsex=$S(gender="1335245":"F",1:"M")
 .S zzage=$$AGE^REG(dob)
 .;S allcnts(age,sex)=$get(allcnts(age,sex))+1
 .if +$get(allcnts(zzage,zzsex))>+$get(^ZCNTALL(zzage,zzsex)) quit
 .S allcnts(zzage,zzsex)=$get(allcnts(zzage,zzsex))+1
 .set zztot=$$TOTALLRGY(zzage,zzsex)
 .kill ^TALLERGY
 .F zzi=1:1:+zztot do
 ..kill data
 ..D PRACT^SYLVIA2(orgid,.data)
 ..S practid=$get(data(1))
 ..S zzrole=$get(data(2))
 ..S cdate=$$REGDATE^SYNSYLVIA1(dob) ; clinicaleffectivedate
 ..S noncore=$$GETNONCORE(zzrole,zzage,zzsex)
 ..if noncore="" quit
 ..w !,id," ",cdate," ",noncore," ",$get(^CONCEPT(noncore))
 ..set encid="\N"
 ..set datprecision="\N"
 ..set coreconcept="\N"
 ..set isreview="\N"
 ..set ageatevnt="\N"
 ..set daterecorded="\N"
 ..set map=$P($GET(^CONMAP(noncore)),"~",1)
 ..S:map'="" coreconcept=map
 ..S ^ALLERGY(zalrgyid)=zalrgyid_d_orgid_d_id_d_id_d_encid_d_practid_d_cdate_d_datprecision_d_isreview_d_coreconcept_d_noncore_d_ageatevnt_d_daterecorded
 ..set ^TRACK("ALLERGY",id,zalrgyid)=""
 ..set zalrgyid=$i(zalrgyid)
 ..quit
 .quit
 quit
 
GETNONCORE(zzrole,zzage,zzsex) 
 new ite,attempts,zztot,q,r
 
 set zztot=$order(^ALLRGYLST(zzrole,zzage,zzsex,""),-1)
 I zztot="" QUIT ""
 
 set q=0
LOOP set r=$random(zztot)
 I r=0 set r=1
 S ite=^ALLRGYLST(zzrole,zzage,zzsex,r)
 I $data(^TALLERGY(ite)),q<10 S q=q+1 G LOOP
 if $data(^TALLERGY(ite)) quit ""
 set ^TALLERGY(ite)=""
 quit ite
 
TOTALLRGY(age,sex) ;
 new c,r,totallergy
 set c=$order(^ZCOUNTS("ALLERGY-AX",age,sex,""),-1)
 ;W !,c
 set r=$random(c)
 if r=0 set r=1
 set totallergy=^ZCOUNTS("ALLERGY-AX",age,sex,r)
 quit totallergy
 
ALLCNT ; #3
 new age,sex,nor
 K ^ZCNTALL
 S (age,sex,nor)=""
 f  s age=$order(^STATS("ALLERGY-NOR",age)) q:age=""  do
 .f  s sex=$order(^STATS("ALLERGY-NOR",age,sex)) q:sex=""  do
 ..s t=0
 ..f  s nor=$o(^STATS("ALLERGY-NOR",age,sex,nor)) q:nor=""  do
 ...set t=t+1
 ...quit
 ..S ^ZCNTALL(age,sex)=t
 quit
 
BUILDLIST ; #2
 new zzrole,zzage,zzsex,ite,c
 
 K ^ALLRGYLST
 set c=1
 
 S (zzrole,zzage,zzsex,ite)=""
 F  S zzrole=$O(^STATS("ALLERGY",zzrole)) Q:zzrole=""  DO
 .F  S zzage=$O(^STATS("ALLERGY",zzrole,zzage)) Q:zzage=""  DO
 ..F  S zzsex=$O(^STATS("ALLERGY",zzrole,zzage,zzsex)) Q:zzsex=""  DO
 ...S c=1
 ...F  S ite=$O(^STATS("ALLERGY",zzrole,zzage,zzsex,ite)) Q:ite=""  DO
 ....S ^ALLRGYLST(zzrole,zzage,zzsex,c)=ite,c=$I(c)
 
 quit
 
LIST ; #1
 new age,sex,nor,id,node,c,t,tc
 
 K ^ZCOUNTS("ALLERGY-AX")
 
 S (age,sex,nor,id)=""
 S node="ALLERGY-NOR"
 F  S age=$O(^STATS(node,age)) Q:age=""  DO
 .F  S sex=$O(^STATS(node,age,sex)) Q:sex=""  DO
 ..F  S nor=$O(^STATS(node,age,sex,nor)) Q:nor=""  DO
 ...S t=0
 ...F  S id=$O(^STATS(node,age,sex,nor,id)) Q:id=""  DO
 ....S t=t+1
 ....quit
 ...set c=$order(^ZCOUNTS("ALLERGY-AX",age,sex,""),-1)+1
 ...W !,age," * ",sex," ",c
 ...set ^ZCOUNTS("ALLERGY-AX",age,sex,c)=t
 ...set ^ZCOUNTS("ALLERGY-AX",age,sex,c,nor)=""
 quit
