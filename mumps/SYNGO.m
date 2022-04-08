SYNGO ; ; 4/8/22 3:17pm
 ;
 ; download the global saves
 quit
 
CURL(file) ; include the full path
 new username,password,endpoint,cmd
 
 set username=^ICONFIG("CURL","username")
 set password=^ICONFIG("CURL","password")
 set endpoint=^ICONFIG("CURL","endpoint")
 
 set cmd="curl -u "_username_":"_password_" """_endpoint_"syndownload?filename="_file_""" --output /tmp/temp.7z"
 
 zsystem cmd
 
 if $zsystem=1 w !,"Something went wrong?"
 
 quit $zsystem
 
UNZIP(file) 
 new cmd
 
 set cmd="7z e "_file_" -o/tmp/ -aoa"
 zsystem cmd
 
 q $zsystem
 
STT ;
 
 new file,username,password,endpoint,cmd
 
 ;set username=^ICONFIG("CURL","username")
 ;set password=^ICONFIG("CURL","password")
 ;set endpoint=^ICONFIG("CURL","endpoint")
 
 set file="/tmp/synthetic.go.7z"
 
 ;set cmd="curl -u "_username_":"_password_" """_endpoint_"syndownload?filename="_file_""" --output /tmp/test.zip"
 ;zsystem cmd
 ;W !,cmd
 ;zsystem cmd
 ;W !,"$ZSYSTEM=",$ZSYSTEM
 
 Q:$$CURL(file)
 Q:$$UNZIP("/tmp/test.zip")
 quit
