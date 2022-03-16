SYNSYLVIA7 ; ; 3/10/22 3:41pm
 ;
 ; PATIENT CONTACT INFORMATION
 ;
 
 new id,zcontactid,d,dob,gender,zzsex,zzage,zztot,zzi
 new practid,data,zzrole,use,type,stop
 
 set id="",d=$char(9)
 
 kill ^XCONT,^CONTIDX
 kill ^CONTACT
 
 set zcontactid=1,stop=0
 
 K ^TRACK("CONT")
 
 F  S id=$o(^PATIENT(id)) q:id=""  do  q:stop>+^ICONFIG("STOP")
 .s stop=$i(stop)
 .s rec=^(id)
 .S orgid=$P(rec,d,2)
 .S dob=$P(rec,d,9)
 .S gender=$P(rec,d,7)
 .S zzsex=$S(gender="1335245":"F",1:"M")
 .S zzage=$$AGE^SYNRANDOM(dob)
 .set zztot=$$TOTCON(zzage,zzsex,id)
 .set ^XCONT(id)=+$piece(zztot,"~",2) ; how many to end
 .for zzi=1:1:+zztot do
 ..kill data
 ..set startdate="\N"
 ..set enddate="\N"
 ..D GET(.use,.type,.value)
 ..S ^CONTACT(zcontactid)=zcontactid_d_orgid_d_id_d_id_d_use_d_type_d_startdate_d_enddate_d_value
 ..S ^CONTIDX(id,zcontactid)=""
 ..S ^TRACK("CONT",id,zcontactid)=""
 ..set zcontactid=$i(zcontactid)
 ..quit
 .quit
 quit
 
END ;
 new id,x,contid,c,i,rec,d,enddate,dob,r
 
 set id="",d=$char(9)
 for  set id=$order(^XCONT(id)) q:id=""  do
 .; number of contacts to end
 .set x=^XCONT(id)
 .set dob=$piece(^PATIENT(id),d,9)
 .set contid="",c=1
 .kill ^T
 .f  s contid=$order(^CONTIDX(id,contid)) q:contid=""  do
 ..set ^T(c)=contid,c=c+1
 ..quit
 .if '$data(^T) quit
 .for i=1:1:x do
 ..set c=$order(^T(""),-1)
 ..set r=$r(c)+1
 ..set contid=^T(r)
 ..set enddate=$$REGDATE^SYNSYLVIA1(dob)
 ..w !,contid," * ",enddate
 ..set $p(^CONTACT(contid),d,8)=enddate
 ..quit
 .quit
 quit
 
TOTCON(age,sex,nor) 
 new c,r,totcont
 set c=$order(^ZCOUNTS("CONTACTS-AX-2",age,sex,""),-1)
 set r=$r(c)+1
 set totcont=^ZCOUNTS("CONTACTS-AX-2",age,sex,r)
 quit totcont
 
GET(use,type,value) 
 new c,r,rec,usecode,typecode,useterm,typeterm
 set c=$order(^CONLIST(""),-1)
 set r=$r(c)+1
 set rec=^CONLIST(r)
 set use=$piece(rec,"~",1),type=$p(rec,"~",2) ; codes
 set useterm=$p(rec,"~",3),typeterm=$p(rec,"~",4)
 if use="NULL" set use="\N"
 if type="NULL" set type="\N"
 set value="\N"
 if $$LC^LIB(typeterm)["phone" do
 .S value=$$PHONE^SYNRANDOM()
 .quit
 if $$LC^LIB(typeterm)["email" do
 .set value=$$EMAIL^SYNRANDOM()
 .quit
 quit
 
TYPEUSE ;
 new age,sex,c,use,type,useterm,typeterm,c
 kill ^T
 set (age,sex,c)=""
 for  set age=$order(^ZCOUNTS("CONTACTS-AX",age)) quit:age=""  do
 .f  s sex=$o(^ZCOUNTS("CONTACTS-AX",age,sex)) q:sex=""  do
 ..f  s c=$o(^ZCOUNTS("CONTACTS-AX",age,sex,c)) q:c=""  do
 ...S rec=^(c)
 ...S use=$p(rec,"~",3),type=$p(rec,"~",4)
 ...S ^T(use,type)=$P($get(^CONCEPT(use)),"~")_"~"_$P($get(^CONCEPT(type)),"~",2)
 set (use,type)="",c=1
 kill ^CONLIST
 f  s use=$o(^T(use)) q:use=""  do
 .f  s type=$o(^T(use,type)) q:type=""  do
 ..set useterm=$piece($g(^CONCEPT(use)),"~")
 ..set typeterm=$p($get(^CONCEPT(type)),"~")
 ..S ^CONLIST(c)=use_"~"_type_"~"_useterm_"~"_typeterm
 ..s c=$i(c)
 quit
 
LIST ;
 new age,sex,nor,id,t,use,type
 
 K ^ZCOUNTS("CONTACTS-AX")
 K ^ZCOUNTS("CONTACTS-AX-2")
 
 set (age,sex,nor,id,use,type)=""
 s node="CONTACT-NOR"
 F  S age=$O(^STATS(node,age)) Q:age=""  DO
 .F  S sex=$O(^STATS(node,age,sex)) Q:sex=""  DO
 ..F  S nor=$O(^STATS(node,age,sex,nor)) Q:nor=""  DO
 ...kill t
 ...set t=0
 ...F  S id=$O(^STATS(node,age,sex,nor,id)) Q:id=""  DO
 ....S t=t+1
 ....F  S use=$o(^STATS(node,age,sex,nor,id,use)) q:use=""  do
 .....F  S type=$o(^STATS(node,age,sex,nor,id,use,type)) q:type=""  do
 ......S t(use,type)=$get(t(use,type))+1
 ...set tc=$GET(^STATS("CONTACT-X",age,sex,nor))
 ...set c=$order(^ZCOUNTS("CONTACTS-AX-2",age,sex,""),-1)+1
 ...set ^ZCOUNTS("CONTACTS-AX-2",age,sex,c)=t_"~"_tc
 ...set ^ZCOUNTS("CONTACTS-AX-2",age,sex,c,nor)=""
 ...set (use,type)=""
 ...f  s use=$o(t(use)) q:use=""  do
 ....f  s type=$o(t(use,type)) q:type=""  do
 .....set c=$order(^ZCOUNTS("CONTACTS-AX",age,sex,""),-1)+1
 .....set t=t(use,type)
 .....set tc=$GET(^STATS("CONTACT-X",age,sex,nor,use,type))
 .....set ^ZCOUNTS("CONTACTS-AX",age,sex,c)=+t_"~"_+tc_"~"_use_"~"_type
 quit
