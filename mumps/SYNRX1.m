SYNRX1 ; ; 3/16/22 10:35am
 new host,user,pass,sql,xx,zznor,in,c,cmd,zt,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 S sql="""use "_db_"; SELECT p.role_desc, m.* FROM medication_statement m join practitioner p on p.id = m.practitioner_id WHERE m.patient_id IN ()"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 S zznor="",zt=1
 
 K ^STATS("RX"),^STATS("RX-NOR")
 K ^STATS("RX-CANCELLED")
 
 S in="",c=0
 F  S zznor=$O(^COHORT(zznor)) Q:zznor=""  DO
 .S c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",zznor
 ..S in=$E(in,1,$L(in)-1)
 ..S $P(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/rx.txt"
 ..ZSYSTEM cmd
 ..D SAVE1
 ..S in=""
 ..QUIT
 .S in=in_zznor_","
 .QUIT
 
 I in'="" D END(sql,in,xx)
 QUIT
 
END(sql,in,xx) ;
 new cmd
 S in=$E(in,1,$L(in)-1)
 S $P(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/rx.txt"
 ZSYSTEM cmd
 D SAVE1
 QUIT
 
SAVE1 ;
 n f,str,role,zzid,nor,age,sex,noncore,dose,qty,qtyunits,core,bnf,cancelled,zcancelled
 
 S f="/datagenerator/nel/rx.txt"
 CLOSE f
 O f:(readonly)
 U f R str
 I $zeof CLOSE f QUIT
 F  U f R str Q:$ZEOF  DO
 .S role=$P(str,$C(9),1)
 .S zzid=$P(str,$C(9),2)
 .S nor=$P(str,$C(9),4)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .S noncore=$P(str,$C(9),16)
 .S dose=$P(str,$C(9),11)
 .I dose="NULL" S dose=""
 .S qty=$P(str,$C(9),12)
 .I qty="NULL" S qty=""
 .S qtyunits=$P(str,$C(9),13)
 .I qtyunits="NULL" S qtyunits=""
 .S core=$P(str,$C(9),15)
 .I core="NULL" S core=""
 .S bnf=$P(str,$C(9),17)
 .S cancelled=$P(str,$C(9),10)
 .I cancelled="NULL" S cancelled=""
 .S zcancelled=0
 .I cancelled'="" S zcancelled=1
 .I bnf="NULL" S bnf=""
 .S ^STATS("RX",role,age,sex,noncore)=""
 .S ^STATS("RX-NOR",age,sex,nor,zzid,noncore)=""
 .I zcancelled S ^STATS("RX-CANCELLED",age,sex,nor)=$GET(^STATS("RX-CANCELLED",age,sex,nor))+1
 .I dose'="" S ^STATS("RX",role,age,sex,noncore,"dose",$E(dose,1,100))=""
 .I qtyunits'="" S ^STATS("RX",role,age,sex,noncore,"units",qtyunits)=""
 .I qty'="" S ^STATS("RX",role,age,sex,noncore,"qvalue",qty)=""
 .I core'="" S ^STATS("RX",role,age,sex,noncore,"core",core)=""
 .I bnf'="" S ^STATS("RX",role,age,sex,noncore,"bnf",bnf)=""
 .I zcancelled S ^STATS("RX",role,age,sex,noncore,"cancel",1)=""
 .QUIT
 CLOSE f
 QUIT
