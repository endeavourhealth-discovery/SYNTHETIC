SYNSYLVIA2 ; ; 3/10/22 4:11pm
 ; ENCOUNTERS AND OBSERVATIONS COMBINED
 ;
 N rec,id,zencid,stop
 
 S id="",d=$C(9)
 S zencid=1
 
 K ^OBS,^ENC
 K ^ENCIDX
 
 S d=$char(9)
 
 S stop=0
 
 K ^TRACK("ENC")
 K ^TRACK("ENC-OBS")
 
 F  S id=$O(^PATIENT(id)) Q:id=""  DO  Q:stop>+^ICONFIG("STOP")
 .S stop=stop+1
 .W !,"[",id,"]"
 .S rec=^(id)
 .S orgid=$P(rec,d,2)
 .S dob=$P(rec,d,9)
 .S gender=$P(rec,d,7)
 .S zzsex=$S(gender="1335245":"F",1:"M")
 .S zzage=$$AGE^SYNRANDOM(dob)
 .set tot=$$TOTENCS(zzage,zzsex,id)
 .I +tot=0 QUIT
 .F zg=1:1:tot DO
 ..kill data
 ..D PRACT(orgid,.data)
 ..S practid=$get(data(1))
 ..S zzrole=$get(data(2))
 ..S rolecode=$get(data(3))
 ..S cdate=$$REGDATE^SYNSYLVIA1(dob)
 ..S zrec=$$ASSOC(zzrole)
 ..set noncore=$p(zrec,"~",1),adminmethod=$p(zrec,"~",2)
 ..; ID,ORGID,PATID,PERID,PRACTID,APPID,CDATE,DATEPRECISION,EOCID,
 ..; SPORGID,CORECONCEPTID,NONCORECONCEPTID,AGEATEVENT,TYPE,SUBTYPE,
 ..; ADMINMETHOD,ENDDATE,INSTLOCID,DATERECORDED
 ..S appid="\N",datpconid="\N",eocid="\N",servprovordid="\N"
 ..S coreconcept="\N",ageatevent="\N",type="\N",subtype="\N" ; ,adminmethod="\N"
 ..S enddate="\N",instlocaid="\N",daterecorded="\N"
 ..S map=$P($GET(^CONMAP(noncore)),"~",1)
 ..S:map'="" coreconcept=map
 ..S ^ENC(zencid)=zencid_d_orgid_d_id_d_id_d_practid_d_appid_d_cdate_d_datpconid_d_eocid_d_servprovordid_d_coreconcept_d_noncore_d_ageatevent_d_type_d_subtype_d_adminmethod_d_enddate_d_instlocaid_d_daterecorded
 ..S ^TRACK("ENC",id,zencid)=""
 ..S ^ENCIDX(id,zencid)=""
 ..set zmaxobs=$$TOTOBS(zzrole,zzage,zzsex,id)
 ..D CREATEOBS(zzrole,zzage,zzsex,zmaxobs,zencid,id,orgid,practid,cdate)
 ..S zencid=zencid+1
 ..QUIT
 .QUIT
 quit
 
CREATEOBS(role,age,sex,zmaxobs,zencid,nor,orgid,practid,encdate) ;
 ; ID,ORGID,PATID,PERSONID,ENCID,PRACTID,CDATE,DATEPRECISION
 ; RESULT_VALUE,VALUEUNITS,RESULTDATE,RESULTTEXT,RESULTCONID
 ; ISPROB,ISREVIEW,PROBENDDATE,PROB_ENDDATE,PARENT_OBS_ID
 ; CORE_CONCEPT,NON_CORE,AGE_AT_EV,EPOSID_CONCEPT_ID,IS_PRIMARY,DATE_RECORDED
 new ite,totobs,qf,zc,zite,zcodes,ite,zcnt,z1,r,d,values,value,units,zvalue
 new obsid,dateprecision
 new datprecision,resdate,restext,resconid,isprob
 new isreview,probenddate,parentobs,coreconcept,ageatevent,epsdconceptid,isprimary,daterecorded,key
 
 S totobs=0
 S ite="",qf=0
 
 ; CREATE A LIST SO THAT WE CAN RANDOMIZE
 S zcnt=1
 K zite
 
 I '$D(^OELIST(age,sex,role)) quit
 
 K zcodes
 F z1=1:1:zmaxobs DO
 .s r=$r($O(^OELIST(age,sex,role,""),-1))+1
 .set zcodes(^OELIST(age,sex,role,r))=""
 .QUIT
 
 S ite=""
 S d=$C(9)
 F  S ite=$O(zcodes(ite)) Q:ite=""  DO
 .K values
 .D GETVALUES(role,age,sex,ite,.values)
 .S value="\N",units="\N"
 .I $D(values) DO
 ..S r=$O(values(""),-1)
 ..S r=$R(r)+1
 ..S zvalue=values(r)
 ..S value=$P(zvalue,"~",1),units=$P(zvalue,"~",2)
 ..QUIT
 .S obsid=$O(^OBS(""),-1)+1
 .S datprecision="\N"
 .S resdate="\N"
 .S restext="\N"
 .S resconid="\N"
 .S isprob="\N"
 .S isreview="\N"
 .S probenddate="\N"
 .S parentobs="\N"
 .S coreconcept="\N"
 .S map=$P($GET(^CONMAP(ite)),"~",1)
 .S:map'="" coreconcept=map
 .; NON_CORE_CONCEPT_ID <= ITE
 .S ageatevent="\N"
 .S epsdconceptid="\N"
 .S isprimary="\N"
 .S daterecorded="\N"
 .S ^OBS(obsid)=obsid_d_orgid_d_nor_d_nor_d_zencid_d_practid_d_encdate_d_datprecision_d_value_d_units_d_resdate_d_restext_d_resconid_d
 .S ^OBS(obsid)=^OBS(obsid)_isprob_d_isreview_d_probenddate_d_parentobs_d_coreconcept_d_ite_d_ageatevent_d_epsdconceptid_d_isprimary_d_daterecorded
 .S ^TRACK("ENC-OBS",id,obsid)=""
 .;set key="ENC-X:"_obsid_","_ite_","_value_","_units
 .;set key=$$TR^LIB(key,"\N","")
 .;D AUDIT(id,key)
 .QUIT
 QUIT
 
GETVALUES(ROLE,AGE,SEX,CODE,VALUES) ; RETURN AN AVERAGE VALUE
 ; BRANCH OFF WHEN DOING BLOOD PRESSURES
 N VALUE,ZC
 S VALUE="",ZC=1
 F  S VALUE=$O(^STATS("ENC-CODES",AGE,SEX,ROLE,CODE,"V",VALUE)) Q:VALUE=""  DO
 .S UNITS=^STATS("ENC-CODES",AGE,SEX,ROLE,CODE,"V",VALUE)
 .S VALUES(ZC)=VALUE_"~"_UNITS
 .S ZC=$I(ZC)
 .QUIT
 QUIT
 
ASSOC(ROLE) ; non_core_concept_id used in encounter records
 N ZA
 ;W !,"[",ROLE,"]"
 S C=$O(^A(ROLE,""),-1)
 S R=$R(C)+1
 S ZA=^A(ROLE,R)
 I $P(ZA,"~",1)="" S $P(ZA,"~",1)="\N"
 I $P(ZA,"~",2)="" S $P(ZA,"~",2)="\N"
 QUIT ZA
 
PRACT(ORG,DATA) ; RANDOM PRACTITIONER (FOR ORGANIZATION)
 N REC,D,ID,C
 S D=$C(9)
 S C=$O(^P(ORG,""),-1)
 S R=$R(C)
 I R=0 S R=1
 S REC=^P(ORG,R)
 S ID=$P(REC,D,1)
 S ROLECODE=$P(REC,D,4)
 if ROLECODE="\N" S ROLECODE="NULL"
 S ROLE=$P(REC,D,5)
 if ROLE="\N" S ROLE="NULL"
 
 S DATA(1)=ID
 S DATA(2)=ROLE
 S DATA(3)=ROLECODE
 QUIT
 
MAXLST ;
 K ^MAXLST
 F I=1:1:100 S ^MAXLST(I)=1
 F I=1:1:4 S R=$$R100() S ^MAXLST(R)=2
 F I=1:1:3 S R=$$R100() S ^MAXLST(R)=3 
 QUIT
 
R100() ;
 S R=$R(100)
 I R=0 S R=1
 QUIT R
 
HOSPASSOCS ;
 new r
 K ^A
 S r="NULL"
 S ^A(r,1)="1483429~inpatient"
 S ^A(r,2)="1485118~outpatient"
 S ^A(r,3)="1479938~emergency"
 quit
 
ASSOCS ;
 new i,r
 
 K ^A
 S r="Consultant"
 ; codes that we don't really want to randomly select that often!
 S ^A(r,1)="1488081~telephone consultation"
 S ^A(r,2)="1484913~other"
 S ^A(r,3)="1487065~seen in gps surgery"
 S ^A(r,4)="1487581~surgery consultation"
 ; most often randomly selected
 F i=5:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 ;
 S r="General Medical Practitioner"
 S ^A(r,1)="1488081~telephone consultation"
 S ^A(r,2)="1483989~main surgery"
 S ^A(r,3)="1486421~results recording"
 F i=4:1:14 S ^A(r,i)="1480467~g.p.surgery"
 F i=15:1:20 S ^A(r,i)=""
 
 S r="Salaried General Practitioner"
 S ^A(r,1)="1487581~surgery consultation"
 S ^A(r,2)="1483989~main surgery"
 S ^A(r,3)="1483236~inbound document"
 S ^A(r,4)="1488081~telephone consultation"
 F i=5:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Community Practitioner"
 S ^A(r,1)="1483989~main surgery"
 S ^A(r,2)="1484913~other"
 S ^A(r,3)="1478729~clinic"
 S ^A(r,4)="1487581~surgery consultation"
 F i=5:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Community Nurse"
 S ^A(r,1)="1484913~other"
 S ^A(r,2)="1488081~telephone consultation"
 S ^A(r,3)="1477949~awaiting clinical code migration to emis web"
 S ^A(r,4)="1478729~clinic"
 F i=5:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Health Care Support Worker"
 S ^A(r,1)="1488007~telephone"
 S ^A(r,2)="1487581~surgery consultation"
 F i=3:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Clerical Worker"
 S ^A(r,1)="1484913~other"
 S ^A(r,2)="1484568~non-consultation data"
 F i=3:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Receptionist"
 S ^A(r,1)="1484913~other"
 S ^A(r,2)="1477594~administration"
 S ^A(r,3)="1486711~scanned"
 F i=4:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Manager"
 S ^A(r,1)="1477594~administration"
 S ^A(r,2)="1488609~third party consultation"
 F i=3:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 S r="Sessional GP"
 S ^A(r,1)="1488081~telephone consultation"
 S ^A(r,2)="1483989~main surgery"
 F i=3:1:15 S ^A(r,i)="1480467~g.p.surgery"
 F i=16:1:20 S ^A(r,i)=""
 
 QUIT
 
 ; how many encounters shall we record for this patient?
TOTENCS(age,sex,nor) 
 new c,r,totenc
 ;W !,"[",age," - ",sex,"]"
 set c=$order(^ZCOUNTS("ENC-AX",age,sex,"ENC",""),-1)
 
 ;set key="ENC-AX:"_age_","_sex_","_c
 ;D AUDIT(nor,key)
 
 if c="" q 1
 
 set r=$random(c)
 if r=0 set r=1
 set totenc=^ZCOUNTS("ENC-AX",age,sex,"ENC",r)
 
 set key="ENC-AX:"_age_","_sex_","_c_","_r_","_totenc
 D AUDIT(nor,key)
 quit totenc
 
 ; how many observation shall record against this encounter?
TOTOBS(role,age,sex,nor) 
 new c,r,totobs,key
 ;W !,"[",role," - ",age," - ",sex,"]"
 set c=$order(^ZCOUNTS("ENC",role,age,sex,"OBS",""),-1)
 
 ;set key="ENC:"_age_","_sex_","_c
 ;D AUDIT(nor,key)
 
 if c="" q 1
 set r=$random(c)+1
 set totobs=^ZCOUNTS("ENC",role,age,sex,"OBS",r)
 
 ;set key="ENC:"_role_","_age_","_sex_","_c_","_r_","_totobs
 ;D AUDIT(nor,key)
 
 quit totobs
 
AUDIT(nor,key) ;
 new idx
 S idx=$O(^AUDIT(nor,""),-1)+1
 S ^AUDIT(nor,idx)=key
 quit
 
LIST ;
 new role,age,sex,nor,encid,code,t,tc,c
 
 K ^ZCOUNTS("ENC")
 K ^ZCOUNTS("ENC-AX")
 
 S (role,age,sex,nor,encid,code)=""
 S node="ENC-NOR-ROLE"
 F  S role=$O(^STATS(node,role)) Q:role=""  DO
 .F  S age=$O(^STATS(node,role,age)) Q:age=""  DO
 ..F  S sex=$O(^STATS(node,role,age,sex)) Q:sex=""  DO
 ...F  S nor=$O(^STATS(node,role,age,sex,nor)) Q:nor=""  DO
 ....S t=0
 ....F  S encid=$O(^STATS(node,role,age,sex,nor,encid)) Q:encid=""  DO
 .....S t=t+1
 .....S tc=0
 .....F  S code=$O(^STATS(node,role,age,sex,nor,encid,code)) Q:code=""  DO
 ......S tc=tc+1
 ......Q
 .....S c=$O(^ZCOUNTS("ENC",role,age,sex,"OBS",""),-1)+1
 .....S ^ZCOUNTS("ENC",role,age,sex,"OBS",c)=tc
 .....S ^ZCOUNTS("ENC",role,age,sex,"OBS",c,nor,encid)="" ; patient where we got the stat from
 .....Q
 ...QUIT
 
 S node="ENC-NOR"
 F  S age=$o(^STATS(node,age)) q:age=""  do
 .F  S sex=$o(^STATS(node,age,sex)) q:sex=""  do
 ..F  s nor=$o(^STATS(node,age,sex,nor)) q:nor=""  do
 ...S t=0
 ...F  S encid=$o(^STATS(node,age,sex,nor,encid)) q:encid=""  do
 ....s t=t+1
 ....quit
 ...S c=$O(^ZCOUNTS("ENC-AX",age,sex,"ENC",""),-1)+1
 ...S ^ZCOUNTS("ENC-AX",age,sex,"ENC",c)=t
 ...S ^ZCOUNTS("ENC-AX",age,sex,"ENC",c,nor)="" ; patient where we got the stat from
 QUIT
 
BUILDLIST ;
 N AGE,SEX,ROLE,ITE,N,C
 K ^OELIST
 S (AGE,SEX,ROLE,ITE)=""
 S N="ENC-CODES"
 F  S AGE=$O(^STATS(N,AGE)) Q:AGE=""  DO
 .F  S SEX=$O(^STATS(N,AGE,SEX)) Q:SEX=""  DO
 ..F  S ROLE=$O(^STATS(N,AGE,SEX,ROLE)) Q:ROLE=""  DO
 ...F  S ITE=$O(^STATS(N,AGE,SEX,ROLE,ITE)) Q:ITE=""  DO
 ....S C=$O(^OELIST(AGE,SEX,ROLE,""),-1)+1
 ....S ^OELIST(AGE,SEX,ROLE,C)=ITE
 QUIT
 
AUDITREP ;
 new nor,c,z,rec,c1,ddsid,enccnt,pract,z,ite,value,units,randcnt
 s (nor,c)=""
 for  set nor=$order(^AUDIT(nor)) quit:nor=""  do
 .set enccnt=1
 .for  set c=$o(^AUDIT(nor,c)) quit:c=""  do
 ..s rec=^(c)
 ..if $p(rec,":")="RX-AX" do
 ...set z=$p(rec,":",2,99)
 ...set age=$p(z,",",1),sex=$p(z,",",2)
 ...set c1=$p(z,",",3),rxcnt=+$p(z,",",5),r=$p(z,",",4),cancrx=$p($p(z,",",5),"~",2)
 ...write "Patient:",nor," age: ",age," sex: ",sex,!
 ...s ddsid=$order(^ZCOUNTS("RX-AX",age,sex,r,""))
 ...write "c1= ",c1," c=",c," r=",r,!
 ...write rxcnt," prescriptions - count calculated from dds patient: ",ddsid,!
 ...write "will cancel ",cancrx," prescriptions",!
 ...R *Y
 ...quit
 ..if $p(rec,":")="ENC-AX" do
 ...set z=$p(rec,":",2,99)
 ...set age=$p(z,",",1),sex=$p(z,",",2)
 ...set c1=$p(z,",",3),enccount=$p(z,",",5),randcnt=$p(z,",",4)
 ...write "Patient: ",nor," age: ",age," sex: ",sex,!
 ...s ddsid=$order(^ZCOUNTS("ENC-AX",age,sex,"ENC",randcnt,""))
 ...write enccount," encounters, c1=",c1," r=",randcnt,!
 ...write "dds patient: ",ddsid,!
 ...W "randomized to: ",randcnt,!
 ...R *Y
 ...quit
 ..if $p(rec,":")="ENC" do
 ...set z=$p(rec,":",2,99),c1=$p(z,",",5),role=$p(z,",",1),obscnt=$p(z,",",6)
 ...write "encounter ",enccnt," (",role,") ",obscnt," observations",!
 ...;BREAK
 ...set ddsid=$order(^ZCOUNTS("ENC",role,age,sex,"OBS",c1,""))
 ...set zencid=$order(^ZCOUNTS("ENC",role,age,sex,"OBS",c1,ddsid,""))
 ...write "observation count calculated from dds patient: ",ddsid,"/encounter id: ",zencid,!
 ...set enccnt=$i(enccnt)
 ...;R *Y
 ...;quit
 ..if $p(rec,":")="ENC-X" do
 ...set z=$p(rec,":",2,99)
 ...set ite=$p(z,",",2),value=$p(z,",",3),units=$p(z,",",4)
 ...write "  ",ite," ",$p($get(^CONCEPT(ite)),"~")," ",value," ",units,!
 ...quit
 ..quit
 .;R *Y
 .quit
 quit
