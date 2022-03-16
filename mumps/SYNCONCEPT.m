SYNCONCEPT ; ; 3/16/22 1:36pm
 NEW HOST,USER,PASS,QF,ROWCOUNT,CMD,DB
 
 K ^CONCEPT,^CLALL
 S HOST=^ICONFIG("MYSQL","CONCEPT-HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","CONCEPT-DB")
 
 S QF=0
 F START=0:500000 DO  Q:QF
 .S ROWCOUNT=500000
 .S CMD="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute ""select dbid, name, code, scheme, id from "_DB_".concept limit "_START_", "_ROWCOUNT_";"" > /datagenerator/barts/concept.txt"
 .W !,CMD
 .ZSYSTEM CMD
 .S QF=$$READ("/datagenerator/barts/concept.txt")
 .QUIT
 QUIT
 
MAP ;
 K ^CONMAP
 S HOST=^ICONFIG("MYSQL","CONCEPT-HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","CONCEPT-DB")
 
 S QF=0
 F START=0:100000 DO  Q:QF
 .S ROWCOUNT=100000
 .S CMD="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute ""select * from "_DB_".concept_map limit "_START_", "_ROWCOUNT_";"" > /datagenerator/barts/concept_map.txt"
 .U 0 w !,CMD
 .ZSYSTEM CMD
 .S QF=$$READMAP("/datagenerator/barts/concept_map.txt")
 .QUIT
 QUIT
 
READMAP(F) ;
 O F:(readonly)
 S C=0
 U F R STR ; HEADER
 
 I $ZEOF CLOSE F Q 1
 F  U F R STR Q:$ZEOF  DO
 .S LEGACY=$P(STR,$C(9),1)
 .S CORE=$P(STR,$C(9),2)
 .S UPDATED=$P(STR,$C(9),3)
 .S ^CONMAP(LEGACY)=CORE_"~"_UPDATED
 .QUIT
 CLOSE F
 QUIT 0
 
READ(F) ;
 O F:(readonly)
 S C=0
 U F R STR ; HEADER
 I $ZEOF CLOSE F Q 1
 F  U F R STR Q:$ZEOF  DO
 .S DBID=$P(STR,$C(9),1)
 .S NAME=$P(STR,$C(9),2)
 .S CODE=$P(STR,$C(9),3)
 .S SCHEME=$P(STR,$C(9),4)
 .S ID=$P(STR,$C(9),5)
 .S ^CONCEPT(DBID)=NAME_"~"_CODE
 .S ^CONCEPT(DBID,"S")=SCHEME
 .S ^CLALL(CODE)=NAME_"~"_SCHEME_"~"_DBID_"~"_ID
 .S C=C+1
 .QUIT
 C F
 U 0 W !,C ; R *Y
 I C=0 Q 1
 QUIT 0
 
EXPORT ;
 S F="/tmp/clall.txt"
 CLOSE F
 O F:(newversion)
 S ITE=""
 F  S ITE=$O(^CLALL(ITE)) Q:ITE=""  DO
 .U F W ITE,"~",^CLALL(ITE),!
 .QUIT
 CLOSE F
 QUIT
