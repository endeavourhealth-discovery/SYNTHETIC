SYNRX2 ; ; 3/16/22 10:36am
 ;
 ; MEDICATION_ORDER
 ; collects:
 ; duration_days, estimated_cost and medication_statement_id
 ; so that we can create an extract for medication_order
 new host,user,pass,sql,xx,zznor,in,c,cmd,zt,db
 
 set host=^ICONFIG("MYSQL","HOST")
 set user=^ICONFIG("MYSQL","USER")
 set pass=^ICONFIG("MYSQL","PASS")
 set db=^ICONFIG("MYSQL","DB")
 
 set sql="""use "_db_"; SELECT p.role_desc, mo.* FROM medication_order mo join practitioner p on p.id = mo.practitioner_id WHERE mo.patient_id IN ();"
 
 S xx="/usr/bin/mysql -h "_host_" --user="_user_" --password="_pass_" --execute "
 
 S zznor="",zt=1
 
 K ^STATS("RX-ORDER")
 
 set in="",c=0
 F  S zznor=$O(^COHORT(zznor)) Q:zznor=""  DO
 .s c=c+1
 .I c#1000=0 DO
 ..U 0 W !,c," NOR=",zznor
 ..S in=$E(in,1,$L(in)-1)
 ..S $P(sql,"(",2)=in
 ..S sql=sql_");"""
 ..S cmd=xx_sql_" > /datagenerator/nel/rx_order.txt"
 ..ZSYSTEM cmd
 ..D SAVE1
 ..S in=""
 ..quit
 .S in=in_zznor_","
 .quit
 
 if in'="" D END(sql,in,xx)
 quit
 
END(sql,in,xx) ;
 new cmd
 S in=$E(in,1,$L(in)-1)
 S $P(sql,"(",2)=in
 S sql=sql_");"""
 S cmd=xx_sql_" > /datagenerator/nel/rx_order.txt"
 ZSYSTEM cmd
 D SAVE1
 quit
 
SAVE1 ;
 n f,str,role,zzid,nor,age,sex,noncore
 new medstateid,durdays,estcost
 
 set f="/datagenerator/nel/rx_order.txt"
 close f
 o f:(readonly)
 u f r str
 i $zeof close f quit
 F  U f R str Q:$ZEOF  DO
 .S role=$P(str,$C(9),1)
 .s noncore=$p(str,$c(9),17)
 .S medstateid=$piece(str,$c(9),15)
 .S durdays=$p(str,$c(9),13)
 .S estcost=$p(str,$char(9),14)
 .;u 0 w !,"role: ",role
 .;u 0 w !,"noncore: ",noncore
 .;u 0 w !,"rx medstateid: ",medstateid
 .;u 0 w !,"dur:",durdays
 .;u 0 w !,"cost: ",estcost
 .;u 0 r *y
 .S nor=$P(str,$C(9),4)
 .S age=^ASUM(nor,"age")
 .S sex=^ASUM(nor,"sex")
 .S:+durdays>0 ^STATS("RX-ORDER",role,age,sex,noncore,"durdays",durdays)=""
 .S:+estcost>0 ^STATS("RX-ORDER",role,age,sex,noncore,"estcost",estcost)=""
 .quit
 close f
 quit
