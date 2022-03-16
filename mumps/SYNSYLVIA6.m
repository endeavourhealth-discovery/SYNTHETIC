SYNSYLVIA6 ; ; 3/14/22 10:29am
 ;
 ; APPOINTMENTS
 
 new id,stop,rec,orgid,zzsex,zzage,gender
 new zztot,zzi,appdats,appdat,tdob,dob,zappid
 new tdob,rec,total,appdat,appdats
 new schedid,pdur,actual,concept,wait,delay,sentin,left,source,cancelled
 new data,appcounts,d,zt
 
 kill
 
 ;K ^PS
 
 K ^APP
 
 K ^APPIDX,^XAPP
 
 K ^TRACK("APPS")
 
 set id="",stop=0,d=$char(9)
 set zappid=1
 for  set id=$order(^PATIENT(id)) quit:id=""  do  q:stop>+^ICONFIG("STOP")
 .set stop=stop+1
 .set rec=^(id)
 .set orgid=$p(rec,d,2)
 .set dob=$piece(rec,d,9)
 .set gender=$p(rec,d,7)
 .S zzsex=$S(gender="1335245":"F",1:"M")
 .S zzage=$$AGE^SYNRANDOM(dob)
 .set appcounts(zzage,zzsex)=$get(appcounts(zzage,zzsex))+1
 .if appcounts(zzage,zzsex)>+$get(^ZCNT("APP",zzage,zzsex)) quit
 .set zztot=$$TOTAPP(zzage,zzsex,id)
 .set total=0
 .f zt=3,7,4,8 s total=total+$p(zztot,"~",zt)
 .set ^XAPP(id)=zztot
 .if total=0 quit
 .kill appdats
 .; format dob to dd.mm.yyyy
 .set tdob=$p(dob,"-",3)_"."_$p(dob,"-",2)_"."_$p(dob,"-",1)
 .do LIST^SYNRANDOM(tdob,total,.appdats)
 .set (schedid,pdur,actual,concept,wait,delay,sentin,left,source,cancelled)="\N"
 .set appdat=""
 .for  set appdat=$order(appdats(appdat)) q:appdat=""  do
 ..set time=$$RTIME^SYNRANDOM()
 ..; format appdat
 ..S tappdat=$$F(appdat)_" "_time
 ..kill data
 ..D PRACT^SYNSYLVIA2(orgid,.data)
 ..set practid=$get(data(1))
 ..set role=$get(data(2))
 ..set d=$char(9)
 ..set rec=zappid_d_orgid_d_id_d_id_d_practid_d_schedid_d_tappdat_d_pdur_d_actual_d_concept_d_wait_d_delay_d_sentin_d_left_d_source_d_cancelled
 ..set ^APP(zappid)=rec
 ..set ^APPIDX(id,zappid)=""
 ..S ^TRACK("APPS",id,zappid)=""
 ..set zappid=$increment(zappid)
 ..quit
 .quit
 
 do FIXUP
 
 quit
 
FIXUP ; add the status info the appointments that have just been created
 ; supports - booked, fulfilled, cancelled, no show
 new id,rec,appid,a,i,zz
 
 set (id,appid)=""
 for  set id=$o(^APPIDX(id)) quit:id=""  do
 .;W !,^XAPP(id)
 .set rec=^XAPP(id)
 .kill a,b
 .set a(1)=$p(rec,"~",3) ; total booked (1335322)
 .set b(1)="1335322"
 .set a(2)=$p(rec,"~",7) ; fulfilled (1335324)
 .s b(2)="1335324"
 .set a(3)=$p(rec,"~",4) ; cancelled (1335325)
 .s b(3)="1335325"
 .set a(4)=$p(rec,"~",8) ; noshow (1335326)
 .s b(4)="1335326"
 .W !,"booked=",a(1)," fulf=",a(2)," canc=",a(3)," noshow=",a(4)
 .D GATHER(id)
 .f i=1:1:4 do
 ..set tot=+a(i)
 ..for zz=1:1:tot do FIX(b(i),id)
 ..quit
 .quit
 quit
 
GATHER(id) K ^TAPP
 new c,appid
 set c=1,appid=""
 for  set appid=$order(^APPIDX(id,appid)) q:appid=""  do
 .set ^TAPP(c)=appid
 .s c=c+1
 .quit
 quit
 
 quit
 
FIX(ite,id) ;
 new r,c,appid
 quit:'$data(^TAPP)
 
 s c=$o(^TAPP(""),-1)
 
 s r=$r(c)+1
 
 s appid=^TAPP(c)
 set $piece(^APP(appid),$c(9),10)=ite
 kill ^APPIDX(id,appid)
 D GATHER(id)
 quit
 
F(dat) ;
 s dat=$$HD^STDDATE(dat)
 s dat=$p(dat,".",3)_"-"_$p(dat,".",2)_"-"_$p(dat,".",1)
 quit dat
 
TOTAPP(age,sex,nor) 
 new c,r,totapp
 set c=$order(^ZCOUNTS("APP-AX",age,sex,""),-1)
 if c="" q 0
 set r=$random(c)+1
 set totapp=^ZCOUNTS("APP-AX",age,sex,r)
 quit totapp
 
DISTINCT ;
 K ^T
 new role,age,sex,concept
 s (role,age,sex,concept)=""
 f  s role=$o(^STATS("APP",role)) q:role=""  do
 .f  s age=$o(^STATS("APP",role,age)) q:age=""  do
 ..f  s sex=$o(^STATS("APP",role,age,sex)) q:sex=""  do
 ...f  s concept=$o(^STATS("APP",role,age,sex,concept)) q:concept=""  do
 ....w !,concept
 ....S ^T(concept)=$get(^CONCEPT(concept))
 ....S ^T(concept,"T")=$get(^T(concept,"T"))+1
 quit
 
APPCNT ;
 new age,sex,nor
 set (age,sex,nor)=""
 
 K ^ZCNT("APP")
 
 f  s age=$order(^STATS("APP-NOR",age)) q:age=""  do
 .f  s sex=$order(^STATS("APP-NOR",age,sex)) q:sex=""  do
 ..s t=0
 ..f  s nor=$o(^STATS("APP-NOR",age,sex,nor)) q:nor=""  do
 ...set t=t+1
 ...quit
 ..S ^ZCNT("APP",age,sex)=t
 quit
 
LIST ;
 new age,sex,nor,id,node,c,t,tc
 
 K ^ZCOUNTS("APP-AX")
 
 K ^TMAP
 S ^TMAP(1335321)="pending"
 S ^TMAP(1335322)="booked"
 S ^TMAP(1335323)="arrived"
 S ^TMAP(1335324)="fulfilled"
 S ^TMAP(1335325)="cancelled"
 S ^TMAP(1335326)="noshow"
 
 S (age,sex,nor,id,concept)=""
 S node="APP-NOR"
 F  S age=$O(^STATS(node,age)) Q:age=""  DO
 .F  S sex=$O(^STATS(node,age,sex)) Q:sex=""  DO
 ..F  S nor=$O(^STATS(node,age,sex,nor)) Q:nor=""  DO
 ...S t=0
 ...set t("booked")=0
 ...set t("cancelled")=0
 ...set t("arrived")=0
 ...set t("pending")=0
 ...set t("fulfilled")=0
 ...set t("noshow")=0
 ...set t("?")=0
 ...F  S id=$O(^STATS(node,age,sex,nor,id)) Q:id=""  DO
 ....S t=t+1
 ....F  S concept=$O(^STATS(node,age,sex,nor,id,concept)) q:concept=""  do
 .....S type=$get(^TMAP(concept),"?")
 .....if type="pending" quit
 .....if type="arrived" quit
 .....S t(type)=$get(t(type))+1
 .....quit
 ....QUIT
 ...set tc=$get(^STATS("APP-CANCEL",age,sex,nor))
 ...set c=$order(^ZCOUNTS("APP-AX",age,sex,""),-1)+1
 ...set ^ZCOUNTS("APP-AX",age,sex,c)=t_"~"_tc_"~"_t("booked")_"~"_t("cancelled")_"~"_t("arrived")_"~"_t("pending")_"~"_t("fulfilled")_"~"_t("noshow")_"~"_t("?")
 ...set ^ZCOUNTS("APP-AX",age,sex,c,nor)=""
 quit
