SYNDOWNLOAD ; ; 4/8/22 10:08am
 set ^%W(17.6001,"B","GET","api2/syndownload","D^SYNDOWNLOAD",54321)=""
 set ^%W(17.6001,54321,0)="GET"
 set ^%W(17.6001,54321,1)="api2/syndownload"
 set ^%W(17.6001,54321,2)="D^SYNDOWNLOAD"
 set ^%W(17.6001,54321,"AUTH")=2
 quit
 
D(result,arguments) 
 new file,i,str,c
 kill ^TMP($j)
 
 set file=$get(arguments("filename"))
 
 ;set file="/tmp/conmap.7z"
 
 open file:(readonly:fixed:nowrap:recordsize=255:chset="M"):0
 use file
 set c=1
 f i=1:1 r str:0  q:$zeof  do
 .set ^TMP($J,c)=str,c=$i(c)
 .quit
 close file
 set result=$NA(^TMP($J))
 set result("mime")="application/x-7z-compressed"
 quit
