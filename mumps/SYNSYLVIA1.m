SYNSYLVIA1 ; ; 3/2/22 1:24pm
 new i,rec,d,id,zzc,orgid,dob,sex,age,gender,nhsno,zdob,ethite,title,firtname,lstnam,dod,regorgid,address,addid
 new regdate,usualgp,regtype,regstatus,dateregend
 new add1,add2,add3,add4,city,post
 
 K ^ID
 
 D TORG
 
 K ^T
 K ^PERSON,^PATIENT,^EOC,^ADDRESS
 
 S id=1,d=$C(9)
 S zzc=""
 F  S zzc=$O(^ZTDOB(zzc)) Q:zzc=""  DO
 .; get a random orgnization_id (GP PRACTICE)
 .S orgid=$$ORG()
 .S ^T("ORG",orgid)=$GET(^T("ORG",orgid))+1
 .S rec=$get(^ZTDOB(zzc))
 .S dob=$P(rec,"~",1),sex=$P(rec,"~",2),age=$P(rec,"~",3)
 .S gender=$S(sex="M":1335244,sex="F":1335245,1:"?")
 .I gender="?" QUIT
 .S nhsno=$$NHSNO^SYNMYSQLX()
 .S zdob=$P(dob,".",3)_"-"_$P(dob,".",2)_"-"_$P(dob,".",1)
 .S ethite=$$GETETH()
 .I ethite="" S ethite="\N"
 .S title=$S(sex="M":"Mr",1:"Mrs")
 .I sex="M",age<13 S title="Master"
 .I sex="F",age<21 S title="Ms"
 .S firstname=$$GETFNM(sex)
 .S lstnam=$$GETSNM()
 .W !,id,"~",orgid,"~",title,"~",firstname,"~",lstnam,"~",zdob,"~",age,"~",gender,"~",nhsno,"~",ethite
 .S dod="\N"
 .S regorgid=orgid
 .S address=$$GETADD()
 .S addid=$P(address,"~",1)
 .; CREATE AN ADDRESS RECORD FOR PERSON ID,ETHITE,REGORGID
 .; ID,ORGID,TITLE,FIRSTNAME,LSTNAM,GENDER,NHSNO,DOB,DOD,ADDID,ETHITE,REGORGID
 .S ^PERSON(id)=id_d_orgid_d_title_d_firstname_d_lstnam_d_gender_d_nhsno_d_zdob_d_dod_d_addid_d_ethite_d_regorgid
 .S ^PATIENT(id)=id_d_orgid_d_id_d_title_d_firstname_d_lstnam_d_gender_d_nhsno_d_zdob_d_dod_d_addid_d_ethite_d_regorgid
 .S regdate=$$REGDATE(dob)
 .S usualgp="\N" ; *** TO DO
 .S regtype="1335267"
 .S regstatus="1335286"
 .S dateregend="\N"
 .S ^EOC(id)=id_d_orgid_d_id_d_id_d_regtype_d_regstatus_d_regdate_d_dateregend_d_usualgp
 .S add1=$P(address,"~",2),add2=$P(address,"~",3)
 .S add3=$P(address,"~",4),add4=$P(address,"~",5)
 .S city=$P(address,"~",6),post=$P(address,"~",7)
 .S ^ADDRESS(addid)=addid_d_orgid_d_id_d_id_d_add1_d_add2_d_add3_d_add4_d_city_d_post
 .S id=id+1
 .quit
 quit
 
ETHNIC ;
 new nor,ethnic,c
 
 K ^ETHNIC
 K ^LISTS("ETHNIC")
 
 S nor=""
 F  S nor=$O(^ASUM(nor)) Q:nor=""  DO
 .S ethnic=^ASUM(nor,"ethnic")
 .I ethnic="NULL" quit
 .S ^ETHNIC(ethnic)=$get(^CONCEPT(ethnic))
 .QUIT
 
 S ethnic="",c=1
 F  S ethnic=$O(^ETHNIC(ethnic)) Q:ethnic=""  DO
 .I c#3=0 DO
 ..; SOME PEOPLE DON'T HAVE ETHNICITY RECORDED
 ..S ^LISTS("ETHNIC",c)="",c=c+1
 ..QUIT
 .S ^LISTS("ETHNIC",c)=ethnic_"~"_^ETHNIC(ethnic)
 .S c=c+1
 .QUIT
 QUIT
 
TORG ;
 new z,c,rec
 K ^TORG
 S z="",c=1
 F  S z=$O(^ORGS(z)) Q:z=""  DO
 .S rec=^ORGS(z)
 .W !,$piece(rec,$C(9),4)
 .I $P(rec,$C(9),4)'="PR",$piece(rec,$char(9),4)'="TR" quit
 .W !,z
 .S ^TORG(c)=z
 .S c=$I(c)
 .QUIT
 QUIT
 
HOSPSTAFF ;
 new d,lastname,r,firstname,rolecode,role,sex,c
 
 D TORG^SYNSYLVIA1
 kill ^P
 S d=$char(9)
 set sex(1)="M",sex(2)="F"
 F i=1:1:(400*3) do
 .set lastname=$$GETSNM^SYNSYLVIA1()
 .set r=$R(2)
 .I r=0 S r=1
 .S firstname=$$GETFNM(sex(r))
 .S orgid=$$ORG()
 .S rolecode="\N",role="\N"
 .S c=$O(^P(orgid,""),-1)+1
 .S ^P(orgid,c)=i_d_orgid_d_lastname_", "_firstname_d_rolecode_d_role
 .quit
 quit
 
P ; PRACTITIONERS
 N sex,d,i,lastname,r,firstname,orgid,t,rolecode,role
 
 K ^P
 DO PRACT
 S d=$C(9)
 S sex(1)="M"
 S sex(2)="F"
 F i=1:1:5000 DO
 .S lastname=$$GETSNM^SYLVIA1()
 .S r=$R(2)
 .I r=0 S r=1
 .S firstname=$$GETFNM(sex(r))
 .S orgid=$$ORG()
 .S r=$$RPRACT()
 .S t=^T(r)
 .S rolecode=$P(t,"~",1),role=$P(t,"~",2)
 .W !,lastname," ",firstname
 .S c=$O(^P(orgid,""),-1)+1
 .S ^P(orgid,c)=i_d_orgid_d_lastname_", "_firstname_d_rolecode_d_role
 .QUIT
 QUIT
 
PRACT ; PRACTITIONERS
 ; 1 Consultant, R0050 *
 ; 30 General Medical Practitioner, R0260 *
 ; 4 Salaried General Practitioner, R0270 *
 ; 3 Community Practitioner, R0690 *
 ; 1 Community Nurse, R0700 *
 ; 6 Health Care Support Worker, R1450 *
 ; 10 Clerical Worker, R1720 *
 ; 12 Receptionist, R1730 *
 ; 4 Manager, R1780 *
 ; 2 Sessional GP, R6300 *
 new i
 K ^T
 F i=1:1:30 S ^T(i)="R0260~General Medical Practitioner"
 F i=1:1:10 S ^T($O(^T(""),-1)+1)="R1720~Clerical Worker"
 F i=1:1:12 S ^T($O(^T(""),-1)+1)="R1730~Receptionist"
 F i=1:1:1 S ^T($O(^T(""),-1)+1)="R0050~Consultant"
 F i=1:1:4 S ^T($O(^T(""),-1)+1)="R0270~Salaried General Practitioner"
 F i=1:1:2 S ^T($O(^T(""),-1)+1)="R6300~Sessional GP"
 F i=1:1:4 S ^T($O(^T(""),-1)+1)="R1780~Manager"
 F i=1:1:3 S ^T($O(^T(""),-1)+1)="R0690~Community Practitioner"
 F i=1:1:1 S ^T($O(^T(""),-1)+1)="R0700~Community Nurse"
 F i=1:1:6 S ^T($O(^T(""),-1)+1)="R1450~Health Care Support Worker"
 QUIT
 
GETSNM() ;
 new c,snm
 S c=$O(^GARBLE("SNM",""),-1)
 S c=$R(c)+1
 S snm=^GARBLE("SNM",c)
 QUIT snm
 
GETFNM(sex) ;
 new fnm,c
 S fnm=""
 I sex="M" DO
 .S c=$O(^GARBLE("FNM","B",""),-1)
 .S c=$R(c)+1
 .S fnm=^GARBLE("FNM","B",c)
 .QUIT
 I sex="F" DO
 .S c=$O(^GARBLE("FNM","G",""),-1)
 .S c=$R(c)+1
 .S fnm=^GARBLE("FNM","G",c)
 .QUIT
 QUIT fnm
 
ORG() ; RANDOM GP SURGERY ORGANIZATION_ID
 new x,r
 S x=$O(^TORG(""),-1)
 S r=$R(x)
 if r=0 set r=1
 S r=^TORG(r)
 QUIT r
 
RPRACT() ;
 new r,c
 S c=$O(^T(""),-1)
 S r=$R(c)
 I r=0 S r=1
 QUIT r
 
DOB2  ; loop down ^COHORT insead of ^B
 new nor,rec,zage,sex,dob,c
 ;K ^ZTDOB,^T
 K ^T
 S nor="",c=1
 F  S nor=$O(^COHORT(nor)) Q:nor=""  DO
 .S rec=^(nor)
 .S zage=$P(rec,"~",2)
 .S sex=$P(rec,"~",3)
 .S ^T(zage)=$GET(^T(zage))+1
 .S dob=$$DOB4^SYNRANDOM(zage)
 .S ^ZTDOB(c)=dob_"~"_sex_"~"_zage
 .S c=c+1
 .QUIT
  QUIT
  
GETETH() ;
 new c,rec,ite
 S c=$O(^LISTS("ETHNIC",""),-1)
 S c=$R(c) I c=0 S c=1
 S rec=^LISTS("ETHNIC",c)
 S ite=$P(rec,"~",1)
 QUIT ite
 
GETADD() ;
 new c,rec,add1,add2,add3,add4,city,post,add
 
 ;S c=$O(^HULL(""),-1)
 set c=$order(^WALES(""),-1)
 S c=$R(c)+1 ; I c=0 S c=1
 ;S rec=^HULL(c)
 S rec=^WALES(c)
 S add1=$P(rec,"~",1)
 I $P(rec,"~",1)="" S add1=$P(rec,"~",3)
 I add1="" S add1=$P(rec,"~",2)
 I add1="" S add1=$P(rec,"~",10) ; ORG !
 S add2=$P(rec,"~",4)
 I add1["FLAT" S add2=$P(rec,"~",3)
 S add3=$P(rec,"~",5)
 S add4=$P(rec,"~",6)
 S city=$P(rec,"~",8)
 S post=$P(rec,"~",9)
 S add=c_"~"_add1_"~"_add2_"~"_add3_"~"_add4_"~"_city_"~"_post
 QUIT add
  
REGDATE(dob) ;
 new z,x
 I dob["-" S dob=$P(dob,"-",3)_"."_$P(dob,"-",2)_"."_$P(dob,"-",1)
 S z=$$DH^STDDATE(dob)
 S x=+$H-z
 I x=0 S x=1
 S z=z+$R(x)
 I z>+$H S z=+$H
 S z=$$HD^STDDATE(z)
 S z=$P(z,".",3)_"-"_$P(z,".",2)_"-"_$P(z,".",1)
 QUIT z
