SYNORGS ; ; 2/14/22 8:19am
 
 new sql,d,zi,postcode,odscode,type,typedesc,parent,name
 
 ; COUNT HOW MANY UNIQUE ORGS IN PERSON TABLE 
 S sql="SELECT count(distinct o.id) FROM person p join nwl_subscriber_pid.organization o on o.id=p.organization_id;"
 ; 352
 ;
 ; COUNT HOW MANY UNIQUE PARENT IDS
 S sql="SELECT count(distinct o.parent_organization_id) FROM person p join nwl_subscriber_pid.organization o on o.id=p.organization_id;"
 ; 8 CCG's
 ;
 
 K ^ORGS
 
 S d=$char(9)
 F zi=1:1:8 do
 .S name="CCG "_zi
 .S postcode=$$POSTCDE^SYNMYSQLX()
 .; NNA
 .S odscode=$$ODSCODE(99,0)
 .S type="CC"
 .S typedesc="CLINICAL COMMISSIONING GROUP"
 .S ^ORGS(zi)=zi_d_odscode_d_name_d_type_d_typedesc_d_postcode_d_d_d_d
 .QUIT
 
 S parent=1
 F zi=9:1:(9+352) DO
 .S name="PRACTICE "_zi
 .S postcode=$$POSTCDE^SYNMYSQLX()
 .; ANNN
 .S odscode=$$ODSCODE(9999,1)
 .S type="PR"
 .S typedesc="GP PRACTICE"
 .S ^ORGS(zi)=zi_d_odscode_d_name_d_type_d_typedesc_d_postcode_d_parent_d_d_d
 .S parent=parent+1
 .I parent>8 S parent=1
 .QUIT
 QUIT

HOSP ;
 new d,postcode,name,type,typedesc
 kill ^ORGS
 set d=$char(9)
 set postcode=$$POSTCDE^SYNMYSQLX()
 set type="TR"
 set typedesc="NHS Trust"
 set name="ST HIERONYMUS NHS TRUST"
 set ^ORGS(1)=1_d_"AA1"_d_name_d_type_d_typedesc_d_postcode_d_d_d_d
 set name="ST CYRIL NHS TRUST"
 set postcode=$$POSTCDE^SYNMYSQLX()
 set ^ORGS(2)=2_d_"AA2"_d_name_d_type_d_typedesc_d_postcode_d_d_d_d
 set name="ST AMBROSE NHS TRUST"
 set postcode=$$POSTCDE^SYNMYSQLX()
 set ^ORGS(3)=3_d_"AA3"_d_name_d_type_d_typedesc_d_postcode_d_d_d_d
 QUIT
 
ODSCODE(n,z) ;
 N c,i,odscode
 
 K ^T($J)
 S c=1
 F i=65:1:(65+25) S ^T($J,c)=$C(i),c=c+1
 S c=$random(26)
 I c=0 S c=1
 S c=^T($J,c)
 ; N = 99
 S c=$translate($justify($random(n),$length(n))," ",0)
 S odscode=n_c
 I z=1 S odscode=c_n
 QUIT n_c
