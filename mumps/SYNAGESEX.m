SYNAGESEX ; ; 3/16/22 9:37am
 kill ^T
 
 new nor,t,org,age,sex,totage,pop,p,y,c,zqf,i,tot
 
 set pop=$get(^ICONFIG("POP"))
 if pop="" write !,"no population total defined" quit
 
 set nor="",t=0
 for  set nor=$order(^ASUM(nor)) Q:nor=""  do
 .set org=$get(^ASUM(nor))
  .set age=$get(^ASUM(nor,"age"))
  .set sex=$get(^ASUM(nor,"gender"))
  .if age="" quit
  .if age>100 quit
  .set sex=$select(sex=1335244:"M",sex=1335245:"F",1:"?")
  .if sex="?" quit
  .set ^T("AGE",sex,age,org)=$get(^T("AGE",sex,age,org))+1
  .set ^T("ORG",org)=$get(^T("ORG",org))+1
  .set ^T("X",sex,age)=$GET(^T("X",sex,age))+1
  .set t=t+1
  .quit
  
  set age=""
  for sex="M","F" DO
  .for  set age=$order(^T("X",sex,age)) Q:age=""  DO
  ..set totage=^(age)
  ..set ^T("%",sex,age)=$J((totage/t*100),0,4)
  ..QUIT
  .QUIT
  
  set age=""
  set t=0
  kill ^B
   
  for sex="M","F" do
  .for  set age=$order(^T("%",sex,age)) Q:age=""  do
  ..set p=^(age)
  ..set p=p/100
  ..set y=p*pop
  ..set ^B(sex,age)=$J(y,0,0)
  ..set t=t+$justify(y,0,0)
  ..quit
  
GEN ; GET NEXT ORG
  set c=1
  set org=""
  kill ^R
  for  set org=$order(^T("ORG",org)) Q:org=""  do
  .set ^R(c)=org
 .set c=c+1
 .quit
 
 ; AXIN ASUM
 kill ^AX,^AX2
 set nor=""
 for  set nor=$order(^ASUM(nor)) quit:nor=""  do
 .set org=^ASUM(nor)
 .set sex=^ASUM(nor,"gender")
 .set sex=$S(sex=1335244:"M",sex=1335245:"F",1:"?")
 .if sex="?" quit
 .set a=^ASUM(nor,"age")
 .set ^AX2(a,sex,org,nor)=""
 .set ^AX(org,sex,nor)=a
 .quit
 
 ; CREATE A COHORT
 kill ^COHORT
 
 for sex="M","F" do
 .for i=0:1:$order(^B(sex,""),-1) do
 ..set tot=+$get(^B(sex,i))
 ..if tot=0 quit
 ..set org="",t=0,zqf=0
 ..for  set org=$order(^T("ORG",org)) do  quit:zqf
 ...; FIND ME A PATIENT FOR THIS AGE/ORG WHO IS NOT IN THE COHORT?
 ...set nor=$$FIND2(i,org,sex)
 ...if nor'="" set ^COHORT(nor)=org_"~"_i_"~"_sex,t=t+1
 ...if t>tot set zqf=1
 ...quit
 ..quit
 .quit	
 quit
 
FIND2(age,org,sex) 
 new nor,qf
 set nor="",qf=0
 for  set nor=$order(^AX2(age,sex,org,nor)) q:nor=""  do  q:qf
 .if $data(^COHORT(nor)) quit
 .s qf=1
 .quit
 quit nor
