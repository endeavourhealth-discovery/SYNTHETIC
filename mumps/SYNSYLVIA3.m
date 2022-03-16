SYNSYLVIA3 ; ; 3/10/22 3:40pm
 ; MEDICATION_STATEMENT
 ;
 
 new zztot,id,zrxid,stop,g1,g2,rec,d,gender
 
 K ^RX,^RXIDX
 kill ^XRX
 
 kill ^RXORDER
 
 K ^TRACK("RX")
 K ^TRACK("RX-ORDER")
 
 S id="",zrxid=1
 S stop=0
 S d=$C(9),g1=0,g2=0
 F  S id=$O(^PATIENT(id)) Q:id=""  DO  Q:stop>+^ICONFIG("STOP")
 .S stop=stop+1
 .S rec=^(id)
 .S orgid=$P(rec,d,2)
 .S dob=$P(rec,d,9)
 .S gender=$P(rec,d,7)
 .S zzsex=$S(gender="1335245":"F",1:"M")
 .S zzage=$$AGE^REG(dob)
 .set zztot=$$TOTRX(zzage,zzsex,id)
 .S ^XRX(id)=$piece(zztot,"~",2) ; how many to cancel for this patient
 .K ^TDRUG
 .F zzi=1:1:+zztot DO
 ..kill data
 ..D PRACT^SYNSYLVIA2(orgid,.data)
 ..S practid=$get(data(1))
 ..S zzrole=$get(data(2))
 ..S cdate=$$REGDATE^SYNSYLVIA1(dob) ; clinicaleffectivedate
 ..S noncore=$$GETNONCORE(zzrole,zzage,zzsex)
 ..I noncore="" QUIT
 ..S rec=$$GETDOSETC(zzrole,zzage,zzsex,noncore)
 ..S units=$P(rec,"~",1),dose=$P(rec,"~",2),bnf=$P(rec,"~",3)
 ..S core=$P(rec,"~",4),qvalue=$P(rec,"~",5)
 ..; medication_order
 ..set duration=+$piece(rec,"~",6),cost=+$piece(rec,"~",7)
 ..S authtypeconceptid="\N"
 ..S ageatevent="\N"
 ..S issuemethod="\N"
 ..S encid="\N"
 ..S datprecision="\N"
 ..S cancdate="\N"
 ..S ^RX(zrxid)=zrxid_d_orgid_d_id_d_id_d_encid_d_practid_d_cdate_d_datprecision_d_cancdate_d_dose_d_qvalue_d_units_d_authtypeconceptid_d_core_d_noncore_d_bnf_d_ageatevent_d_issuemethod
 ..S ^RXORDER(zrxid)=zrxid_d_orgid_d_id_d_id_d_encid_d_practid_d_cdate_d_datprecision_d_dose_d_qvalue_d_units_d_duration_d_cost_d_zrxid_d_core_d_noncore_d_bnf_d_ageatevent_d_issuemethod
 ..S ^TRACK("RX",id,zrxid)=""
 ..;S ^TRACK("RX-ORDER",id,zrxid)=""
 ..S ^RXIDX(id,zrxid)=""
 ..S zrxid=$I(zrxid)
 ..S g1=g1+zztot
 ..QUIT
 .QUIT
 QUIT
 
GETNONCORE(zzrole,zzage,zzsex) 
 new ite,attempts,zztot,q,r
 
 set zztot=$order(^RXLIST(zzrole,zzage,zzsex,""),-1)
 I zztot="" QUIT ""
 set q=0
LOOP set r=$random(zztot)+1
  S ite=^RXLIST(zzrole,zzage,zzsex,r)
  I $data(^TDRUG(ite)),q<10 S q=q+1 G LOOP
  I $data(^TDRUG(ite)) Q ""
  set q=0
  S ^TDRUG(ite)=""
  QUIT ite
 
GETDOSETC(role,age,sex,noncore) ;
 N units,dose,bnf,core,qvalue,rec,durdays,cost
 
 S units=$o(^STATS("RX",role,age,sex,noncore,"units",""))
 S dose=$O(^STATS("RX",role,age,sex,noncore,"dose",""))
 S bnf=$O(^STATS("RX",role,age,sex,noncore,"bnf",""))
 S core=$O(^STATS("RX",role,age,sex,noncore,"core",""))
 S qvalue=$O(^STATS("RX",role,age,sex,noncore,"qvalue",""))
 
 ; extra medication_order fields
 set durdays=$order(^STATS("RX-ORDER",role,age,sex,noncore,"durdays",""))
 set cost=$order(^STATS("RX-ORDER",role,age,sex,noncore,"estcost",""))
 
 S rec=units_"~"_dose_"~"_bnf_"~"_core_"~"_qvalue_"~"_durdays_"~"_cost
 quit rec
  
CANCEL ;
 new id,rec,x,rxid,c,x,r,cdate,d
 set d=$c(9)
 set id=""
 for  s id=$order(^XRX(id)) q:id=""  do
 .; number of prescriptions to delete
 .s x=^XRX(id)
 .set rxid="",c=1
 .K ^T
 .f  s rxid=$order(^RXIDX(id,rxid)) q:rxid=""  do
 ..set ^T(c)=rxid,c=c+1
 ..quit
 .if '$data(^T) quit
 .for i=1:1:x do
 ..;
 ..set c=$order(^T(""),-1)
 ..w !,x," > ",c
 ..set r=$random(c)+1
 ..set rxid=^T(r)
 ..set rec=^RX(rxid)
 ..set cdate=$p(rec,d,7)
 ..set cdate=$$REGDATE^SYNSYLVIA1(cdate)
 ..set $piece(^RX(rxid),d,9)=cdate
 ..W !,cdate
 ..quit
 .quit
 quit
 
TOTRX(age,sex,nor) 
 new c,r,totrx
 set c=$order(^ZCOUNTS("RX-AX",age,sex,""),-1)
 set r=$random(c)+1
 ;if r=0 set r=1
 set totrx=^ZCOUNTS("RX-AX",age,sex,r)
 
 ;s key="RX-AX:"_age_","_sex_","_c_","_r_","_totrx
 ;D AUDIT^SYNSYLVIA2(nor,key)
 
 quit totrx
 
BUILDLIST ;
 new zzrole,zzage,zzsex,ite,c
 
 K ^RXLIST
 S c=1
 
 S (zzrole,zzage,zzsex,ite)=""
 F  S zzrole=$O(^STATS("RX",zzrole)) Q:zzrole=""  DO
 .F  S zzage=$O(^STATS("RX",zzrole,zzage)) Q:zzage=""  DO
 ..F  S zzsex=$O(^STATS("RX",zzrole,zzage,zzsex)) Q:zzsex=""  DO
 ...S c=1
 ...F  S ite=$O(^STATS("RX",zzrole,zzage,zzsex,ite)) Q:ite=""  DO
 ....S ^RXLIST(zzrole,zzage,zzsex,c)=ite,c=$I(c)
 QUIT
    
LIST ;
 new age,sex,nor,id,node,c,t,tc
 
 K ^ZCOUNTS("RX-AX")
 
 S (age,sex,nor,id)=""
 S node="RX-NOR"
 F  S age=$O(^STATS(node,age)) Q:age=""  DO
 .F  S sex=$O(^STATS(node,age,sex)) Q:sex=""  DO
 ..F  S nor=$O(^STATS(node,age,sex,nor)) Q:nor=""  DO
 ...S t=0
 ...F  S id=$O(^STATS(node,age,sex,nor,id)) Q:id=""  DO
 ....S t=t+1
 ....QUIT
 ...W !,"TOT-DRUGS - NOR ",nor," AGE ",age," SEX ",sex," TOT=",t
 ...W !,"CANCELLED ",$GET(^STATS("RX-CANCELLED",age,sex,nor))
 ...set tc=$GET(^STATS("RX-CANCELLED",age,sex,nor))
 ...set c=$order(^ZCOUNTS("RX-AX",age,sex,""),-1)+1
 ...; how many rx~how many to cancel
 ...set ^ZCOUNTS("RX-AX",age,sex,c)=t_"~"_tc
 ...set ^ZCOUNTS("RX-AX",age,sex,c,nor)=""
  QUIT
