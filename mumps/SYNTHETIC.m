SYNTHETIC ; ; 3/16/22 10:40am
 ;
RUN(SQL,F) ;
 S HOST=^ICONFIG("MYSQL","HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","DB")
 S X="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute "
 S SQL1="""use "_DB_"; "_SQL_""""
 S CMD=X_SQL1_" > "_F
 W !,CMD
 W !,"PRESS A KEY: "  R *Y
 ZSYSTEM CMD
 ;W !,$T
 ;W !,$ZSYSTEM
 QUIT
 
STT ;
 W !,"PATIENT ID: "
 R NOR
 W !,"getting demographics"
 S SQL="SELECT * FROM patient WHERE ID = "_NOR
 S F="/datagenerator/nel/test-syn.txt"
 D RUN(SQL,F)
 CLOSE F
 O F:(readonly)
 U F R STR,STR
 CLOSE F
 
 W !,STR
 S ADDID=$P(STR,$C(9),11)
 S PATORGID=$P(STR,$C(9),2)
 S TITLE=$P(STR,$C(9),4)
 S FIRSTNAME=$P(STR,$C(9),5)
 S LASTNAME=$P(STR,$C(9),6)
 S GENDER=$P(STR,$C(9),7)
 S NHSNO=$P(STR,$C(9),8)
 S DOB=$P(STR,$C(9),9)
 S ETHNIC=$P(STR,$C(9),12)
 S ETHTERM=""
 I ETHNIC'="" S ETHTERM=$GET(^CONCEPT(ETHTERM))
 S SEX=$GET(^CONCEPT(GENDER))
 S AGE=$$AGE(DOB)
 
 W !,"getting demographics (address) ",ADDID
 S SQL="SELECT * FROM patient_address where id = "_ADDID
 S F="/datagenerator/nel/test-syn.txt"
 D RUN(SQL,F)
 
 CLOSE F
 O F:(readonly)
 U F R STR,STR
 CLOSE F
 
 W !,STR
 S ADDORG=$P(STR,$C(9),2)
 S ADD1=$P(STR,$C(9),5)
 S ADD2=$P(STR,$C(9),6)
 S ADD3=$P(STR,$C(9),7)
 S ADD4=$P(STR,$C(9),8)
 S POSTCODE=$P(STR,$C(9),10)
 
 W !,"getting episode of care (registration dates)"
 S SQL="SELECT * FROM episode_of_care where patient_id = "_NOR
 S F="/datagenerator/nel/test-syn.txt"
 D RUN(SQL,F)
 
 CLOSE F
 O F:(readonly)
 U F R STR,STR
 CLOSE F
 
 W !,STR
 S REGDATE=$P(STR,$C(9),7)
 S REGTYPE=$P(STR,$C(9),5)
 S REGSTATUS=$P(STR,$C(9),6)
 
 S F="/datagenerator/nel/test-syn.txt"
 S SQL="select p.id, p.name, e.* from encounter e "
 S SQL=SQL_"join practitioner p on p.id = e.practitioner_id "
 S SQL=SQL_"where patient_id = "_NOR
 D RUN(SQL,F)
 
 K ^ZENC
 S F="/datagenerator/nel/test-syn.txt"
 CLOSE F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S PRACTID=$P(STR,$C(9),1)
 .S PRACTNAME=$P(STR,$C(9),2)
 .S EID=$P(STR,$C(9),3)
 .S ORGID=$P(STR,$C(9),4)
 .S NOR=$P(STR,$C(9),5)
 .S CDATE=$P(STR,$C(9),9)
 .S DAT=$P(CDATE,"-",3)_"."_$P(CDATE,"-",2)_"."_$P(CDATE,"-",1)
 .S DAT=$$DH^STDDATE(DAT)
 .S NONCORE=$P(STR,$C(9),14)
 .U 0 W !,EID
 .;
 .S ^ZENC(DAT,EID)=ORGID_"~"_NOR_"~"_PRACTID_"~"_PRACTNAME_"~"_CDATE_"~"_NONCORE_"~"_$GET(^CONCEPT(NONCORE))
 .QUIT
 CLOSE F
 
 W !,"CLOSED F = ",F R *Y
 
 S EID=""
 K ^ZOBSENC
 
 S IN="",DAT=""
 S TOTENC=0
 F  S DAT=$O(^ZENC(DAT)) Q:DAT=""  DO
 .F  S EID=$O(^ZENC(DAT,EID)) Q:EID=""  DO
 ..S IN=IN_EID_","
 ..S TOTENC=TOTENC+1
 ..QUIT
 .QUIT
 
 S F="/datagenerator/nel/test-syn.txt"
 S SQL="SELECT * FROM observation where patient_id = "_NOR_" and encounter_id is not null;"
 S F="/datagenerator/nel/test-syn.txt"
 CLOSE F
 D RUN(SQL,F)
 
 K TOTOBS
 S F="/datagenerator/nel/test-syn.txt"
 CLOSE F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S ID=$P(STR,$C(9),1)
 .S ITE=$P(STR,$C(9),19)
 .S VALUE=$P(STR,$C(9),9)
 .I VALUE="NULL" S VALUE=""
 .S UNITS=$P(STR,$C(9),10)
 .I UNITS="NULL" S UNITS=""
 .S EID=$P(STR,$C(9),5)
 .S PROBLEM=$P(STR,$C(9),14)
 .S REVIEW=$P(STR,$C(9),15)
 .S ^ZOBSENC(EID,ID)=ITE_"~"_$P($GET(^CONCEPT(ITE)),"~",1)_"~"_VALUE_"~"_UNITS_"~"_PROBLEM_"~"_REVIEW
 .S TOTOBS(EID)=$GET(TOTOBS(EID))+1
 .QUIT
 CLOSE F
 
 S F="/datagenerator/nel/test-syn.txt"
 S SQL="SELECT * FROM medication_statement where patient_id = "_NOR_";"
 D RUN(SQL,F)
 K ^RX2
 S F="/datagenerator/nel/test-syn.txt"
 CLOSE F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S ID=$P(STR,$C(9),1)
 .S CDATE=$P(STR,$C(9),7)
 .S DAT=$P(CDATE,"-",3)_"."_$P(CDATE,"-",2)_"."_$P(CDATE,"-",3)
 .S HDAT=$$DH^STDDATE(DAT)
 .S CANCDATE=$P(STR,$C(9),9)
 .I CANCDATE="NULL" S CANCDATE=""
 .S DOSE=$P(STR,$C(9),10)
 .S QTYVALUE=$P(STR,$C(9),11)
 .S QTYUNIT=$P(STR,$C(9),12)
 .S NONCORE=$P(STR,$C(9),15)
 .S TERM=$P($GET(^CONCEPT(NONCORE)),"~",1)
 .S NODE="A"
 .I CANCDATE'="" S NODE="X"
 .S ^RX2(NODE,HDAT,ID)=NONCORE_"~"_TERM_"~"_$P(CDATE," ",1)_"~"_CANCDATE_"~"_DOSE_"~"_QTYVALUE_"~"_QTYUNIT
 .QUIT
 CLOSE F
 
 K ^T
 D H("<HTML>")
 D H("Name: "_TITLE_" "_LASTNAME_" "_FIRSTNAME_"<BR>")
 D H("GENDER: "_SEX_" DOB: "_DOB_" NHS NO: "_NHSNO_" AGE: "_AGE_"<BR><BR>")
 I ETHTERM'="" D H("Ethnicity: "_ETHTERM_"<BR>")
 S A=""
 
 I ADD1="NULL" S ADD1=""
 I ADD2="NULL" S ADD2=""
 I ADD3="NULL" S ADD3=""
 I ADD4="NULL" S ADD4=""
 
 I ADD1'="" S A=A_ADD1_", "
 I ADD2'="" S A=A_ADD2_", "
 I ADD3'="" S A=A_ADD3_", "
 I ADD4'="" S A=A_ADD4_", "
 
 D H("Address: "_$E(A,1,$L(A)-2)_" "_POSTCODE_"<BR><BR>")
 
 D H("Total encounters: "_TOTENC_"<BR><BR>")
 
 D H("<TABLE BORDER=1>")
 
 S (DAT,EID)=""
 F  S DAT=$O(^ZENC(DAT),-1) Q:DAT=""  DO
 .F  S EID=$O(^ZENC(DAT,EID),-1) Q:EID=""  DO
 ..S REC=^(EID)
 ..S CDATE=$P($P(REC,"~",5)," "),DR=$P(REC,"~",4),PLACE=$P(REC,"~",7)
 ..D H("<TD><B>"_CDATE_"</B></TD><TD>"_DR_"</TD><TD>"_PLACE_"</TD><TD>total obs: "_+$G(TOTOBS(EID))_"</TD><TD>"_EID_"</TD><TR>")
 ..S ID=""
 ..F  S ID=$ORDER(^ZOBSENC(EID,ID)) Q:ID=""  DO
 ...S REC=^ZOBSENC(EID,ID)
 ...S ITE=$P(REC,"~",1),TERM=$P(REC,"~",2),VALUE=$P(REC,"~",3),UNITS=$P(REC,"~",4)
 ...S PROB=$P(REC,"~",5),REV=$P(REC,"~",6)
 ...S PROB=$S(PROB=1:"Y",1:"")
 ...S REV=$S(REV=1:"Y",1:"")
 ...D H("<TD>"_ITE_"</TD><TD>"_TERM_"</TD><TD>"_VALUE_"</TD><TD>"_UNITS_"</TD><TD>"_PROB_"</TD><TD>"_REV_"</TD><TR>")
 ...QUIT
 ..QUIT
 .QUIT
 
 D H("</TABLE>")
 
 F NODE="A","X" DO
 .I NODE="A",$D(^RX2(NODE)) D H("<BR>Active medications:<BR><BR>")
 .I NODE="X",$D(^RX2(NODE)) D H("<BR>Past medications:<BR><BR>")
 .D:$D(^RX2(NODE)) H("<TABLE BORDER=1>")
 .S (HDAT,ID)=""
 .F  S HDAT=$O(^RX2(NODE,HDAT)) Q:HDAT=""  DO
 ..F  S ID=$O(^RX2(NODE,HDAT,ID)) Q:ID=""  DO
 ...S REC=^(ID)
 ...S NONCORE=$P(REC,"~",1),TERM=$P(REC,"~",2),CDATE=$P(REC,"~",3),CANCDATE=$P(REC,"~",4)
 ...S DOSE=$P(REC,"~",5),QTYVALUE=$P(REC,"~",6),QTYUNIT=$P(REC,"~",7)
 ...D:NODE="A" H("<TD>"_TERM_"</TD><TD>"_CDATE_"</TD><TD>"_DOSE_"</TD><TD>"_QTYVALUE_"</TD><TD>"_QTYUNIT_"</TD><TR>")
 ...D:NODE="X" H("<TD>"_TERM_"</TD><TD>"_CDATE_"</TD><TD>"_CANCDATE_"</TD><TD>"_DOSE_"</TD><TD>"_QTYVALUE_"</TD><TD>"_QTYUNIT_"</TD><TR>")
 ...QUIT
 .D:$D(^RX2(NODE)) H("</TABLE>")
 .QUIT
 
 D H("</HTML>")
 
 S F="/datagenerator/nel/SYNTHETIC_"_NOR_".html"
 CLOSE F
 O F:(newversion)
 F I=1:1:$O(^T(""),-1) USE F W ^T(I),!
 CLOSE F
 
 QUIT
 
H(HTML) ;
 S C=$O(^T(""),-1)+1
 S ^T(C)=HTML
 QUIT
 
AGE(dob) ;
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
 QUIT YEARS
