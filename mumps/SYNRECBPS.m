SYNRECBPS ; ; 3/2/22 2:06pm
 N d,nor,rec,bp,age,nor,h,t,f,sd
 
 kill d
 
 S nor=""
 F  S nor=$O(^COHORT(nor)) Q:nor=""  DO
 .S rec=^(nor)
 .S age=$P(rec,"~",2)
 .S d(age)=$GET(d(age))+1
 .QUIT
  
 ;set zzsys="1047556",zzdia="1047557"
 set zzsys=^ICONFIG("BP","SYS"),zzdia=^ICONFIG("BP","DIA")
 
 kill bp
 
 S nor=""
 F  S nor=$O(^AXIN(zzsys,nor)) Q:nor=""  DO
 .S rec=$GET(^COHORT(NOR))
 .I rec="" QUIT
 .S age=$P(rec,"~",2)
 .S bp(age)=$G(bp(age))+1
 .quit
  
 K ^ZT
 S age=""
 F  S age=$O(D(age)) Q:age=""  DO
 .W !,"AGE: ",AGE," COHORT TOT: ",D(AGE)," NUMBER OF PATS WITH BP: ",$GET(BP(AGE))
 .S ^ZT(age)=$get(bp(age))
 .QUIT	
  
 S (nor,h)=""
 K ZBPAGE
 
 K ^STDBP ; standard deviation
 
 F  S nor=$O(^AXIN(zzsys,nor)) Q:nor=""  DO
 .S rec=$GET(^COHORT(nor))
 .I rec="" QUIT
 .S age=$P(rec,"~",2)
 .S t=0
 .F  S h=$O(^AXIN(zzsys,nor,h)) Q:h=""  DO
 ..S ZBPAGE(age)=$GET(ZBPAGE(age))+1
 ..S T=T+1
 ..QUIT
 .S ^STDBP(AGE,T)="" 	
  
 S (age,t)=""
 K ^MAXBP
 F  S age=$O(^STDBP(age)) Q:age=""  DO
 .S f="/datagenerator/nel/sample.dat"
 .CLOSE f
 .O f:(newversion)
 .S t=""
 .F  S t=$O(^STDBP(age,t)) Q:t=""  DO
 ..U f W t,!
 ..QUIT
 .CLOSE f
 .S sd=$$STT^SYNSD()
 .S ^MAXBP(age)=$J(sd,0,0)
 .QUIT
   
 ; 3 RECORDS:
 ; PARENT RECORD (1047546 = O/E - blood pressure reading)
 ; SYSTOLIC (1414664)
 ; DIASTOLIC (1414648)
 ; ^GARBLE("BP",AGE,C)=BP <- BP READINGS FOR AGE
 
 S age=""
 K ^T
 F  S age=$O(BP(age)) Q:age=""  DO
 .; NUMBER OF PATIENT FOR THIS AGE GROUP TO RECORD A BP
 .S no=BP(age)
 .S nor="",c=1
 .F  S nor=$O(^COHORT(nor)) Q:nor=""  DO
 ..S zage=$P(^COHORT(nor),"~",2)
 ..I zage=age W !,age," * ",nor S ^T(age,c)=nor,c=c+1
 ..QUIT
 .QUIT	
 
 s age=""
 kill ^DONE,^PATS
 
 F  S age=$O(BP(age)) Q:age=""  DO
 .S z=BP(age)
 .F i=1:1:z DO
 ..S c=$O(^T(age,""),-1)
LOOP ..S r=$random(c)
 ..I r=0 S r=1
 ..S nor=^T(age,r)
 ..I $D(^DONE(nor)),$GET(^DONE(nor))<10 S ^DONE(nor)=$G(^DONE(nor))+1 GOTO LOOP ; !!!
 ..S ^DONE(nor)=$GET(^DONE(nor))
 ..W !,age," ",nor
 ..S ^PATS(age,nor)=""
 .QUIT	
 
RUN ;
 S (age,nor)=""
 s d=$c(9)
 
 D IDXSYN
 
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
 S iprob="\N"
 S isreview="\N"
 S probenddate="\N"
 S parentobs="\N"
 S coreconcept="\N"
 
 S ageatevent="\N"
 S epsdconceptid="\N"
 S isprimary="\N"
 S daterecorded="\N"
 S zencid="\N"
 
 S ztot=0
 F  S age=$O(^PATS(age)) Q:age=""  DO
 .F  S nor=$O(^PATS(age,nor)) Q:nor=""  DO
 ..; FORGET AGE GROUPS THAT DON'T HAVE ANY BP'S
 ..I '$D(^GARBLE("BP",age)) QUIT
 ..S ztot=ztot+1
 ..S z=^MAXBP(age)
 ..I +z=0 QUIT
 ..S r=$R(z)
 ..I r=0 S r=1
 ..F zz=1:1:r DO
 ...S c=$O(^BPREC(age,nor,""),-1)+1
 ...; 3 RECORDS
 ...; PARENT RECORD (1047546 = O/E - blood pressure reading)
 ...S rec=$$BPREC(zzsys,"\N","")
 ...S ^BPREC(age,nor,c,1)=rec
 ...; GET A BP FOR AGE
 ...S r1=$O(^GARBLE("BP",age,""),-1)
 ...S r1=$R(r1)
 ...I r1=0 S r1=1
 ...S bp=^GARBLE("BP",age,r1)
 ...S sys=$P(bp,"/",1),dia=$P(bp,"/",2)
 ...;SYSTOLIC (1414664)
 ...S rec=$$BPREC(zzsys,sys,"mmHg")
 ...S ^BPREC(age,nor,c,2)=rec
 ...;DIASTOLIC (1414648)
 ...S rec=$$BPREC(zzdia,dia,"mmHg")
 ...S ^BPREC(age,nor,c,3)=rec
 ...QUIT
 ..QUIT
 .QUIT
 QUIT
 
BPREC(ite,value,units) ;
 new rec
 
 S coreconcept="\N"
 S map=$P($GET(^CONMAP(ite)),"~",1)
 S:map'="" coreconcept=map
 
 S rec=obsid_d_orgid_d_xnor_d_xnor_d_zencid_d_practid_d_obsdate_d
 S rec=rec_datprecsiion_d_value_d_units_d_resdate_d_restext_d_resconid_d
 S rec=rec_isprob_d_isreview_d_probenddate_d_parentobs_d_coreconcept_d_ite_d_ageatevent_d_epsdconceptid_d_isprimary_d_daterecorded
 Q rec
 
IDXSYN ;
 N id,age,rec,dob
 
 K ^TIDX
 S id=""
 F  S id=$O(^PATIENT(id)) Q:id=""  DO
 .S rec=^(ID)
 .S dob=$P(rec,$C(9),9)
 .S age=$$AGE^SYNRANDOM(dob)
 .S ^TIDX("AGE",age,id)=""
 .QUIT
 QUIT
 
FILE ;
 new id,zzzid,age,i,z,patid,nor,c,data,orgid,practid
 
 S id=""
 
 K ^OBSBP
 S zzzid=$O(^OBS(""),-1)+1
 
 F age=0:1:100 DO
 .S z=+$GET(^ZT(age))
 .S PATID=""
 .F i=1:1:z DO  Q:patid=""
 ..S patid=$O(^TIDX("AGE",age,patid))
 ..Q:patid=""
 ..S orgid=$P(^PATIENT(patid),$C(9),2)
 ..S dob=$P(^PATIENT(patid),$C(9),9)
 ..; GET A BUNCH OF BLOOD PRESSURES FOR THIS PATIENT!
 ..S (nor,c)=""
 ..S nor=$O(^BPREC(age,""))
 ..I nor="" Q
 ..K data
 ..D PRACT^SYNSYLVIA2(orgid,.data)
 ..S practid=$GET(data(1))
 ..F  S c=$O(^BPREC(age,nor,c)) Q:c=""  DO
 ...S parentrec=^BPREC(age,nor,c,1)
 ...S sysrec=^BPREC(age,nor,c,2)
 ...S diarec=^BPREC(age,nor,c,3)
 ...S cdate=$$REGDATE^SYNSYLVIA1(DOB)
 ...S parentid=""
 ...S parentrec=$$REREC(parentrec,orgid,patid,practid,cdate,parentid)
 ...S parentid=$order(^OBSBP(""),-1)
 ...S sysrec=$$REREC(sysrec,orgid,patid,practid,cdate,parentid)
 ...S DIAREC=$$REREC(diarec,orgid,patid,practid,cdate,parentid)
 ...; GO FOR A DIFFERENT PRACTITIONER FOR NEXT BP
 ...K data
 ...DO PRACT^SYLVIA2(orgid,.data)
 ...S practid=$GET(data(1))
 ...QUIT
 ..kill ^BPREC(age,nor)
 ..QUIT
 .QUIT
 QUIT
 
REREC(zrec,orgid,patid,practid,cdate,parentid) ;
 n d
 S d=$C(9)
 S $P(zrec,d,1)=zzzid ; global var
 S $P(zrec,d,2)=orgid
 S $P(zrec,d,3)=patid
 S $P(zrec,d,4)=patid
 S $P(zrec,d,6)=practid
 S $P(xrec,d,7)=cdate
 I parentid'="" S $P(zrec,d,17)=parentid
 S ^OBSBP(zzzid)=zrec
 S zzzid=$I(zzzid)
 QUIT zrec
 
TEST ; where there is an observation in a patients record, file the bp
 new d,id,rec,patid,t
 
 K ^T
 K ^TRACK("BP")
 
 S d=$C(9)
 S id=""
 F  S id=$O(^OBS(id)) Q:id=""  DO
 .S rec=^(id)
 .S patid=$P(rec,d,3)
 .S ^T("OBS",patid)=""
 .QUIT
 
 S t=0
 F  S id=$O(^OBSBP(id)) Q:id=""  DO
 .S rec=^(id)
 .S patid=$P(rec,d,3)
 .I $D(^T("OBS",patid)) S ^T("OBSBP",patid,id)="" S t=t+1
 .QUIT
 
 write !,"MERGING OBSBP INTO OBS"
 
 S (patid,id)=""
 S d=$C(9)
 F  S patid=$O(^T("OBSBP",patid)) Q:patid=""  DO
 .F  S id=$O(^T("OBSBP",patid,id)) Q:id=""  DO
 ..S rec=^OBSBP(id)
 ..S ^OBS(id)=rec
 ..S ^TRACK("BP",patid,id)=""
 ..QUIT
 QUIT
