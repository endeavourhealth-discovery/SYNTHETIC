SYNSYLVIA8 ; ; 3/15/22 1:05pm
 ; ENCOUNTER EVENTS
 new id,encid,age,sex,rec,dob,gender,ztotevt,zi
 new zencevtid,orgid,practid,zrec,d
 new coreconcept,map,noncore,ageatevt
 new type,subtype,enddate,instlocid,daterecorded
 new finished
 
 K ^ENCEVT
 
 set zencevtid=1
 
 set (id,encid)=""
 for  s id=$order(^PATIENT(id)) q:id=""  do
 .set rec=^(id)
 .s dob=$piece(rec,$c(9),9)
 .s gender=$p(rec,$c(9),7)
 .S sex=$S(gender="1335245":"F",1:"M")
 .set age=$$AGE^SYNRANDOM(dob)
 .for  s encid=$o(^ENCIDX(id,encid)) quit:encid=""  do
 ..S rec=^ENC(encid)
 ..set admethod=$piece(rec,$c(9),16)
 ..set orgid=$p(rec,$c(9),2)
 ..set practid=$p(rec,$c(9),5)
 ..set cdate=$piece(rec,$c(9),7)
 ..set dateprecision="\N" ; set to 58 in live
 ..set aptid="\N"
 ..set epofcareid="\N" ; needs sorting
 ..set servprvorgid="\N"
 ..set ageatevt="\N"
 ..set type="\N"
 ..set subtype="\N"
 ..set enddate="\N"
 ..set instlocid="\N"
 ..set daterecorded="\N"
 ..set finished=0 ; needs sorting
 ..set ztotevt=$$TOTEVT(admethod,age,sex)
 ..K ^TADM
 ..for zi=1:1:+ztotevt do
 ...set tcdate=cdate_" "_$$TIME^SYNRANDOM()
 ...set noncore=$$GETNONCORE(admethod,age,sex)
 ...set coreconcept="\N"
 ...S map=$P($GET(^CONMAP(noncore)),"~",1)
 ...set:map'="" coreconcept=map
 ...set d=$char(9)
 ...set zrec=zencevtid_d_orgid_d_id_d_id_d_encid_d_practid_d_aptid_d_tcdate_d_dateprecision_d_epofcareid_d
 ...set zrec=zrec_servprvorgid_d_coreconcept_d_noncore_d_ageatevt_d
 ...set zrec=zrec_type_d_subtype_d_admethod_d_enddate_d_instlocid_d_daterecorded_d_finished
 ...set ^ENCEVT(zencevtid)=zrec
 ...set zencevtid=$increment(zencevtid)
 ...quit
 ..quit
 .quit
 quit
 
GETNONCORE(admethod,age,sex) ;
 new c,r,ite,q
 set c=$order(^ENCEVTLST(admethod,age,sex,""),-1)
 set q=0
LOOP set r=$r(c)+1
 set ite=^ENCEVTLST(admethod,age,sex,r)
 if $data(^TADM(ite)),q<10 set q=$i(q) goto LOOP
 if $data(^TADM(ite)) quit ""
 set q=0
 set ^TADM(ite)=""
 quit ite
 
BUILDLIST ; $r list of non_core_coded concepts
 new age,sex,admethod,c,node,ite
 s (age,sex,admethod,ite)=""
 set c=1
 
 K ^ENCEVTLST
 
 set node="ENC-EVENTS-X"
 f  s age=$o(^STATS(node,age)) q:age=""  do
 .f  s sex=$o(^STATS(node,age,sex)) q:sex=""  do
 ..;S c=1
 ..f  s admethod=$o(^STATS(node,age,sex,admethod)) q:admethod=""  do
 ...set c=1
 ...f  s ite=$o(^STATS(node,age,sex,admethod,ite)) q:ite=""  do
 ....;w !,ite
 ....set ^ENCEVTLST(admethod,age,sex,c)=ite,c=$i(c)
 QUIT
 
TOTEVT(admethod,age,sex) 
 new c,r,totevt
 set c=$o(^ZCOUNTS("ENC-EVENTS",admethod,age,sex,""),-1)
 set r=$r(c)+1
 s totevt=^ZCOUNTS("ENC-EVENTS",admethod,age,sex,r)
 quit totevt
 
LIST ; how many encounter events should we record?
 new age,sex,admethod,encid,noncore,node
 
 K ^ZCOUNTS("ENC-EVENTS")
 set (age,sex,admethod,encid,code)=""
 set node="ENC-EVENTS"
 for  S age=$o(^STATS(node,age)) quit:age=""  do
 .for  set sex=$o(^STATS(node,age,sex)) q:sex=""  do
 ..for  s admethod=$o(^STATS(node,age,sex,admethod)) q:admethod=""  do
 ...for  s encid=$o(^STATS(node,age,sex,admethod,encid)) q:encid=""  do
 ....set tc=0
 ....for  s code=$o(^STATS(node,age,sex,admethod,encid,code)) q:code=""  do
 .....s tc=$i(tc)
 .....quit
 ....set c=$o(^ZCOUNTS(node,admethod,age,sex,""),-1)+1
 ....set ^ZCOUNTS(node,admethod,age,sex,c)=tc
 ....quit
 ...quit
 .quit
 QUIT
