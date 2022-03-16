SYNTHETICVITT ; ; 3/7/22 4:18pm
 ;
GO ;
 ;#1
 D STT("3170667904",1)
 D STT("3170667904",0)
 
 ;#2
 D STT("3175080830",1)
 D STT("3175080830",0)
 
 ;#3
 D STT("3160856818",1)
 D STT("3160856818",0)
 
 ;#4
 D STT("3025117248",1)
 D STT("3025117248",0)
 
 ;#5
 D STT("3026565334",1)
 D STT("3026565334",0)
 
 ;#6
 D STT("3014858197",1)
 D STT("3014858197",0)
 
 ;#7
 D STT("3078997319",1)
 D STT("3078997319",0)
 
 ;#8
 D STT("3153621242",1)
 D STT("3153621242",0)
 
 ;#9
 D STT("3225847755",1)
 D STT("3225847755",0)
 
 D STT("3048449072",1)
 D STT("3048449072",0)
 
 QUIT
 
ENCEVENTS ;
 S SQL="select e.person_id, e.clinical_effective_date, c.nhs_number "
 S SQL=SQL_"from encounter_event e "
 S SQL=SQL_"join data_extracts.vitt_cohort_v2 c on c.person_id = e.person_id "
 S SQL=SQL_"where e.admission_method = 'emergency';"
 S F="/datagenerator/barts/encounter_events.txt"
 D RUN(SQL,F)
 QUIT
 
RUN(SQL,F) ;
 S HOST=^ICONFIG("MYSQL","HOST")
 S USER=^ICONFIG("MYSQL","USER")
 S PASS=^ICONFIG("MYSQL","PASS")
 S DB=^ICONFIG("MYSQL","DB")
 S X="/usr/bin/mysql -h "_HOST_" --user="_USER_" --password="_PASS_" --execute "
 S SQL1="""use "_DB_"; "_SQL_""""
 S CMD=X_SQL1_" > "_F
 W !,CMD
 ZSYSTEM CMD
 QUIT
 
STT(NOR,FILTER) ;
 W !,"getting demographics"
 S SQL="SELECT * FROM patient WHERE ID = "_NOR
 S F="/datagenerator/barts/test-syn.txt"
 D RUN(SQL,F)
 CLOSE F
 O F:(readonly)
 U F R STR,STR
 CLOSE F
 
 W !,STR
 S ADDID=$P(STR,$C(9),11)
 S PATORGID=$P(STR,$C(9),2)
 S TITLE=$P(STR,$C(9),4)
 I TITLE="NULL" set TITLE=""
 S FIRSTNAME=$P(STR,$C(9),5)
 S LASTNAME=$P(STR,$C(9),6)
 S GENDER=$P(STR,$C(9),7)
 S NHSNO=$P(STR,$C(9),8)
 S DOB=$P(STR,$C(9),9)
 S ETHNIC=$P(STR,$C(9),12)
 S PERSONID=$P(STR,$C(9),3)
 S ETHTERM=""
 I ETHNIC'="" S ETHTERM=$GET(^CONCEPT(ETHTERM))
 S SEX=$GET(^CONCEPT(GENDER))
 S AGE=$$AGE(DOB)
 
 W !,"getting demographics (address) ",ADDID
 S SQL="SELECT * FROM patient_address where id = "_ADDID
 S F="/datagenerator/barts/test-syn.txt"
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
 S F="/datagenerator/barts/test-syn.txt"
 D RUN(SQL,F)
 
 CLOSE F
 O F:(readonly)
 U F R STR,STR
 CLOSE F
 
 W !,STR
 S REGDATE=$P(STR,$C(9),7)
 S REGTYPE=$P(STR,$C(9),5)
 S REGSTATUS=$P(STR,$C(9),6)
 
 S F="/datagenerator/barts/test-syn.txt"
 
 S SQL="SELECT * FROM data_extracts.vitt_covid_jabs where nhs_number="_NHSNO
 
 w !,"running start"
 D RUN(SQL,F)
 w !,"running end"
 CLOSE F
 K ^ZJABS
 O F:(readonly)
 U F R STR
 I '$ZEOF D
 .F  U F R STR Q:$ZEOF  DO
 ..S CDATE=$P(STR,$C(9),5)
 ..S DRUGNAME=$P(STR,$C(9),3)
 ..S ID=$P(STR,$C(9),1)
 ..S DAT=$P(CDATE,"-",3)_"."_$P(CDATE,"-",2)_"."_$P(CDATE,"-",1)
 ..S DAT=$$DH^STDDATE(DAT)
 ..S ^ZJABS(DAT,ID)=CDATE_"~"_DRUGNAME
 ..QUIT
 CLOSE F
 
 S F="/datagenerator/barts/test-syn.txt"
 S SQL="select p.id, p.name, e.* from encounter e "
 S SQL=SQL_"join practitioner p on p.id = e.practitioner_id "
 S SQL=SQL_"where e.organization_id = 2782572 and person_id ="_PERSONID
 D RUN(SQL,F)
 
 K ^ZENC
 S F="/datagenerator/barts/test-syn.txt"
 CLOSE F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S PRACTID=$P(STR,$C(9),1)
 .S PRACTNAME=$P(STR,$C(9),2)
 .S EID=$P(STR,$C(9),3)
 .S ORGID=$P(STR,$C(9),4)
 .S ZNOR=$P(STR,$C(9),5)
 .S CDATE=$P(STR,$C(9),9)
 .S DAT=$P(CDATE,"-",3)_"."_$P(CDATE,"-",2)_"."_$P(CDATE,"-",1)
 .S DAT=$$DH^STDDATE(DAT)
 .S NONCORE=$P(STR,$C(9),14)
 .S ADMETHOD=$P(STR,$C(9),18)
 .U 0 W !,EID
 .S ^ZENC(DAT,EID)=ORGID_"~"_ZNOR_"~"_PRACTID_"~"_PRACTNAME_"~"_CDATE_"~"_NONCORE_"~"_$P($GET(^CONCEPT(NONCORE)),"~")_"~"_ADMETHOD
 .QUIT
 CLOSE F
 
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
 
 S F="/datagenerator/barts/test-syn.txt"
 S SQL="SELECT * FROM observation where person_id = "_PERSONID_" and encounter_id is not null;"
 S F="/datagenerator/barts/test-syn.txt"
 CLOSE F
 D RUN(SQL,F)
 
 K TOTOBS
 S F="/datagenerator/barts/test-syn.txt"
 CLOSE F
 O F:(readonly)
 U F R STR
 I '$ZEOF DO
 .F  U F R STR Q:$ZEOF  DO
 ..S ID=$P(STR,$C(9),1)
 ..S ITE=$P(STR,$C(9),19)
 ..S VALUE=$P(STR,$C(9),9)
 ..I VALUE="NULL" S VALUE=""
 ..S UNITS=$P(STR,$C(9),10)
 ..I UNITS="NULL" S UNITS=""
 ..S EID=$P(STR,$C(9),5)
 ..S PROBLEM=$P(STR,$C(9),14)
 ..S REVIEW=$P(STR,$C(9),15)
 ..S ^ZOBSENC(EID,ID)=ITE_"~"_$P($GET(^CONCEPT(ITE)),"~",1)_"~"_VALUE_"~"_UNITS_"~"_PROBLEM_"~"_REVIEW
 ..S TOTOBS(EID)=$GET(TOTOBS(EID))+1
 ..QUIT
 .QUIT
 CLOSE F
 
 K ^T
 D H("<HTML>")
 S A=""
 
 I ADD1="NULL" S ADD1=""
 I ADD2="NULL" S ADD2=""
 I ADD3="NULL" S ADD3=""
 I ADD4="NULL" S ADD4=""
 
 I ADD1'="" S A=A_ADD1_", "
 I ADD2'="" S A=A_ADD2_", "
 I ADD3'="" S A=A_ADD3_", "
 I ADD4'="" S A=A_ADD4_", "
 
 D H("PSEUDO ID: "_$GET(^PSEUDO(NHSNO))_"<BR><BR>")
 
 D H("<a href=""#jabs"">Jump to JABS</a><br>")
 D H("<a href=""#encounter"">Jump to ENCOUNTER</a><br>")
 D H("<a href=""#encounter-events"">Jump to ENCOUNTER EVENTS</a><br>")
 D H("<a href=""#observations"">Jump to OBSERVATIONS</a><br>")
 
 D H("<h2 id=""jabs"">JABS</h2><br>")
 D H("<TABLE BORDER=1>")
 S (DAT,ID)=""
 F  S DAT=$O(^ZJABS(DAT)) Q:DAT=""  DO
 .F  S ID=$O(^ZJABS(DAT,ID)) Q:ID=""  DO
 ..S REC=^(ID)
 ..S CDATE=$P(REC,"~",1)
 ..S TERM=$P(REC,"~",2)
 ..D H("<TD>"_CDATE_"</TD><TD>"_TERM_"</TD><TR>")
 ..QUIT
 D H("</TABLE>")
 
 D H("<h2 id=""encounter"">ENCOUNTER</h2><br>")
 
 D:$d(^ZENC) H("<TABLE BORDER=1>")
 
 S (DAT,EID)=""
 F  S DAT=$O(^ZENC(DAT),-1) Q:DAT=""  DO
 .F  S EID=$O(^ZENC(DAT,EID),-1) Q:EID=""  DO
 ..S REC=^(EID)
 ..S ADMETHOD=$P(REC,"~",8)
 ..I ADMETHOD'="emergency" QUIT
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
 
 D:$D(^ZENC) H("</TABLE>")
 
 ; CONSULTATION EVENTS (VITT TESTING)
 S F="/datagenerator/barts/test-syn.txt"
 S SQL="select * from encounter_event e "
 S SQL=SQL_"where e.organization_id = 2782572 and person_id = "_PERSONID
 D RUN(SQL,F)
 CLOSE F
 K ^ENCEVENTS
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S ID=$P(STR,$C(9),1)
 .S CDATE=$P($P(STR,$C(9),8)," ")
 .S date=$p(CDATE,"-",3)_"."_$p(CDATE,"-",2)_"."_$p(CDATE,"-",1)
 .S HDAT=$$DH^STDDATE(date)
 .S ADMMETHOD=$P(STR,$C(9),17)
 .I ADMMETHOD'="emergency" quit
 .S ^ENCEVENTS(HDAT,ID)=CDATE_"~"_ADMMETHOD
 .U 0 W !,">>>> ",ID," * ",CDATE," * ",ADMMETHOD," * ",HDAT
 .QUIT
 CLOSE F
 
 D H("<h2 id=""encounter-events"">ENCOUNTER EVENTS</h2><br>")
 D H("<TABLE BORDER=1>")
 S (HDAT,ID)=""
 F  S HDAT=$O(^ENCEVENTS(HDAT)) Q:HDAT=""  DO
 .F  S ID=$O(^ENCEVENTS(HDAT,ID)) Q:ID=""  DO
 ..S REC=^(ID)
 ..S CDATE=$P(REC,"~",1),ADMETHOD=$P(REC,"~",2)
 ..D H("<TD>"_CDATE_"</TD><TD>"_ADMETHOD_"</TD><TR>")
 .QUIT
 D H("</TABLE>")
 
 ; ALL THE OBSERVATIONS FOR PATIENT (VITT TESTING)
 S F="/datagenerator/barts/test-syn.txt"
 S SQL="SELECT * from observation where person_id="_PERSONID
 D RUN(SQL,F)
 CLOSE F
 K ^ZZOBS
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S ID=$P(STR,$C(9),1)
 .S ORGID=$P(STR,$C(9),2)
 .S CDATE=$P(STR,$C(9),7)
 .S DAT=$P(CDATE,"-",3)_"."_$P(CDATE,"-",2)_"."_$P(CDATE,"-",1)
 .S HDAT=$$DH^STDDATE(DAT)
 .S NONCORE=$P(STR,$C(9),19)
 .S VALUE=$P(STR,$C(9),9)
 .S UNITS=$P(STR,$C(9),10)
 .S STAR=""
 .I $D(^VITTV(NONCORE))!($D(^THROMBOSIS(NONCORE))) S STAR="*"
 .I FILTER=1,STAR="" QUIT
 .S ^ZZOBS(HDAT,ID)=ORGID_"~"_CDATE_"~"_NONCORE_"~"_VALUE_"~"_UNITS_"~"_$P($GET(^CONCEPT(NONCORE)),"~")_"~"_STAR
 .QUIT
 CLOSE F
 
 D H("<h2 id=""observations"">OBSERVATIONS</h2><br><br>")
 
 D H("<TABLE BORDER=1>")
 S (HDAT,ID)=""
 D H("<TD>STAR</TD><TD>ORG</TD><TD>DATE</TD><TD>TERM</TD><TD>VALUE</TD><TD>UNITS</TD><TR>")
 F  S HDAT=$O(^ZZOBS(HDAT)) Q:HDAT=""  DO
 .F  S ID=$O(^ZZOBS(HDAT,ID)) Q:ID=""  DO
 ..S REC=^(ID)
 ..S ORGID=$P(REC,"~",1),CDATE=$P(REC,"~",2),ITE=$P(REC,"~",3),VALUE=$P(REC,"~",4),UNITS=$P(REC,"~",5)
 ..S TERM=$P($G(^CONCEPT(ITE)),"~")
 ..S STAR=$P(REC,"~",7)
 ..S (B1,B2)=""
 ..I STAR'="" S B1="<B>",B2="</B>"
 ..D H("<TD>"_STAR_"</TD><TD>"_ORGID_"</TD><TD>"_CDATE_"</TD><TD>"_ITE_"</TD><TD>"_B1_TERM_B2_"</TD><TD>"_VALUE_"</TD><TD>"_UNITS_"</TD><TR>")
 ..QUIT
 D H("</TABLE>")
 
 D H("</HTML>")
 
 W !,">>>>> ",NOR
 
 S F="/datagenerator/barts/sophie/SYNTHETIC_"_NOR_"_"_FILTER_".html"
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
