SYNENCOUNTER ; ; 3/16/22 10:30am
 quit
 
LIST ;
 new role,age,sex,encid,code,value
 
 K ^STATS("ENC-CODES")
 K ^STATS("ROLES")
 
 S (role,age,sex,encid,code,value)=""
 F  S role=$O(^STATS("OBS-ENC",role)) Q:role=""  DO
 .F  S age=$O(^STATS("OBS-ENC",role,age)) Q:age=""  DO
 ..F  S sex=$O(^STATS("OBS-ENC",role,age,sex)) Q:sex=""  DO
 ...F  S encid=$O(^STATS("OBS-ENC",role,age,sex,encid)) Q:encid=""  DO
 ....F  S code=$O(^STATS("OBS-ENC",role,age,sex,encid,code)) Q:code=""  DO
 .....S ^STATS("ROLES",age,sex,role)=$get(^STATS("ROLES",age,sex,role))+1
 .....S ^STATS("ENC-CODES",age,sex,role,code)=$get(^STATS("ENC-CODES",age,sex,role,code))+1
 .....I $D(^STATS("OBS-ENC",role,age,sex,encid,code,"V")) DO
 ......S value=""
 ......F  S value=$O(^STATS("OBS-ENC",role,age,sex,encid,code,"V",value)) Q:value=""  DO
 .......I value'="NULL",value'="" S ^STATS("ENC-CODES",age,sex,role,code,"V",value)=""
 
 quit