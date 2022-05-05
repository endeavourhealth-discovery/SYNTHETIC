SYNRANDOM ; ; 3/14/22 10:23am
 quit
 
PHONE() ;
 new num1,num2,num3,phone
 new set2,set3
 
 set num1=$r(600)+100
 set num2=$r(641)+100
 set num3=$r(8999)+1000
 
 set string1=$$FUNC^%DO(num1,4)
 
 set phone=string1_"-"_num2_"-"_num3
 quit phone
 
EMAIL() ;
 new saltchars,domain,i,z,a
 
 set domain(1)="gmail.com"
 set domain(2)="supanet.com"
 set domain(3)="yahoo.com"
 
 set saltchars="abcdefghijklmnopqrstuvwxyz1234567890"
 set a=""
 f i=1:1:9 do
 .s z=$r($l(saltchars))+1
 .s a=a_$e(saltchars,z,z)
 .quit
 
 s r=$r(3)+1
 set email=a_"@"_domain(r)
 quit email
 
LIST(dob,t,ret) ; random set of dates from patients dob -> system date
 N A,T,i,h,t1991,c,r,z1,d,TDONE
 
 set t1991=$$DH^STDDATE("1.1.1991")
 
 if '$data(^TAPPLST) DO
 .set c=1
 .; create appointments from 1991
 .for i=t1991:1:+$h do
 ..S ^TAPPLST(c)=i
 ..S c=c+1
 ..quit
 .quit
 
 K TDONE
 
 f i=1:1:t do
 .S r=$ORDER(^TAPPLST(""),-1)
LOOP .S z1=$R(r)+1
 .S d=^TAPPLST(z1)
 .i $d(TDONE(d)),$g(TDONE(d))<10 s TDONE(d)=$get(TDONE(d))+1 goto LOOP
 .S TDONE(d)=""
 .set ret(d)=$$HD^STDDATE(d)
 .quit
 
 ;S A="",T=0 F  S A=$O(ret(A)) Q:A=""  S T=T+1
 ;I T'=t w !,"bug? " R *Y
 quit
 
RTIME() ; random time between 8 am and 6 pm
 NEW C,I,R
 K ^TIM
 I '$D(^TIM) DO
 .set C=1
 .F I=28800:60:64800 DO
 ..S ^TM(C)=I_"~"_$$HT^STDDATE(I)
 ..S C=$I(C)
 ..Q
 .QUIT
 S C=$O(^TM(""),-1)
 S R=$RANDOM(C)+1
 quit $PIECE(^TM(R),"~",2)_":00"
 
DOB(age) ;
 new zi,c,qf,d,a,r,z1
 K ^T($J)
 S c=1,qf=0
 F zi=(365*age):1 DO  Q:qf
 .S d=(+$H-zi)
 .S d=$$HD^STDDATE(d)
 .S a=$$AGE(d)
 .I a=age S ^T($J,c)=d,c=c+1
 .I a>age S qf=1 QUIT
 .QUIT
 S r=$ORDER(^T($J,""),-1)
  S z1=$R(r)
  I +z1=0 S z1=1
  S d=^T($J,z1)
  QUIT d
  
DOB4(age) ;
 new d,z1
 do DOBFAST
 S r=$ORDER(^ZTDOB(age,""),-1)
 S z1=$R(r)+1
 S d=$piece(^ZTDOB(age,z1),"~",1)
 quit d
 
DOBFAST ;
 n age,dummy
 
 if $data(^DSYSTEM("DOBFAST",+$H)) quit
 
 w !,"running dob fast"
 
 kill ^ZTDOB
 for age=0:1:120 do
 .set dummy=$$DOB2(age)
 .quit
 
 set ^DSYSTEM("DOBFAST",+$H)=""
 quit
 
DOB2(age) ; performance improvement ?
 new today,year,back,h,qf,a,start,end,c,i,a,z,r,z1,d,T2
 
 S today=$$HD^STDDATE(+$H)
 S year=$P(today,".",3)
 S year=year-(age+1)
 S back=$P(today,".",1)_"."_$P(today,".",2)_"."_year
 S h=$$DH^STDDATE(back)
 S qf=0
 for i=h:-1 Q:qf  do
 .S a=$$AGE($$HD^STDDATE(i))
 .I a>age S qf=1
 .quit
 
 S start=$$HD^STDDATE(i+2)
 S end=(i+2)+363
 
 set c=1
 K T2
 F z=(i+2):1:end do
 .S T2(c)=$$HD^STDDATE(z)_"~"_$$AGE($$HD^STDDATE(z))
 .set c=$i(c)
 .quit
 
 merge ^ZTDOB(age)=T2
 
 S r=$ORDER(T2(""),-1)
 S z1=$R(r)+1
 ;I +z1=0 S z1=1
 S d=$piece(T2(z1),"~",1)
 quit d
 
TIME() ;
 N I,C,R
 K ^TIME
 SET C=1
 F I=60:60:(((60*60)-1)*24) S ^TIME(C)=$$HT^STDDATE(I),C=C+1
 S C=$O(^TIME(""),-1)
 S R=$R(C)+1
 QUIT ^TIME(R)_":00"
 
AGE(dob) ;
 new TDAY,TDOB,JN,DA2,MO2,YEC2,DA1,MO1,YEC1,YEARS
 U 0
 S TDAY=$$DA^STDDATE($$HD^STDDATE(+$H))
 S TDOB=dob
 I dob["-" S TDOB=$P(dob,"-",3)_"."_$P(dob,"-",2)_"."_$P(dob,"-")
 S JN=$$DA^STDDATE(TDOB)
 S DA2=$A($E(TDAY,5)),MO2=$A($E(TDAY,4)),YEC2=($A($E(TDAY,1))-33)_($A($E(TDAY,2))-33)_($A($E(TDAY,3))-33)
 S DA1=$A($E(JN,5)),MO1=$A($E(JN,4)),YEC1=($A($E(JN,1))-33)_($A($E(JN,2))-33)_($A($E(JN,3))-33)
 S YEARS=YEC2-YEC1
 I MO2>MO1 Q YEARS
 I MO2<MO1 S YEARS=YEARS-1 Q YEARS
 I DA2>DA1 Q YEARS
 I DA2<DA1 S YEARS=YEARS-1 Q YEARS
 Q YEARS
