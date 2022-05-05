SYNGO ; ; 5/5/22 12:59pm
 ;
 quit
 
ICONFIG ;
 set ^ICONFIG("CURL","endpoint")="https://"
 set ^ICONFIG("CURL","password")="?"
 set ^ICONFIG("CURL","username")="?"
 quit
 
PATCH(key) ; download stuff
 new err
 D ICONFIG
 ; download the routine restore code
 quit:$$CURL("/opt/syn/ZRI.m",0,key)
 ; copy ZRI to the routine directory
 ; ZRI restores mumps routines
 q:$$ZRI()
 ; download the routine editor code
 q:$$CURL("/opt/syn/VPE15P1.RSA",0,key)
 ; download the synthetic data routines
 q:$$CURL("/opt/syn/syn.ro",0,key)
 ; download the synthetic routines
 D STT^ZRI("/tmp/syn.ro")
 ; download the UPRN routines
 quit:$$CURL("/opt/syn/uprn.ro",0,key)
 D STT^ZRI("/tmp/uprn.ro")
 ; download a copy of the WELSH global
 ; used by the SYNTHETIC data generation routines
 q:$$CURL("/opt/syn/WALES.7z",1,key)
 q:$$UNZIP("/tmp/temp.7z")
 D STT^ZGI("/tmp/WALES.go")
 ; ^UPRN global save (welsh version)
 q:$$CURL("/opt/syn/uprn.go.7z",1,key)
 q:$$UNZIP("/tmp/temp.7z")
 D STT^ZGI("/tmp/uprn.go")
 ; Synthetic stats
 q:$$CURL("/opt/syn/synthetic.go.7z",1,key)
 quit
 
MISSING(key) ;
 q:$$CURL("/opt/syn/lists.go",0,key)
 D STT^ZGI("/tmp/lists.go")
 q:$$CURL("/opt/syn/zcnt.go",0,key)
 D STT^ZGI("/tmp/zcnt.go")
 q:$$CURL("/opt/syn/zcntall.go",0,key)
 D STT^ZGI("/tmp/zcntall.go")
 q:$$CURL("/opt/syn/allrgylst.go",0,key)
 D STT^ZGI("/tmp/allrgylst.go")
 quit
 
ZRI() new mrtns,cmd,username,password,endpoint
 
 ;
 ;
 ;
 
 set mrtns=$piece($piece($ZRO,"(",2)," ")
 set cmd="cp /tmp/ZRI.m "_mrtns_"/ZRI.m"
 zsystem cmd
 
 ;W !,"$ZSYSTEM=",$ZSYSTEM
 if $zsystem write !,"Something went wrong in ZRI"
 quit $zsystem
 
CURLFILE(file) ;
 quit
 
CURL(file,zip,key) ; include the full path
 new username,password,endpoint,cmd
 
 set username=$$DERCFOUR^EWEBRC4(^ICONFIG("CURL","username"),key)
 set password=$$DERCFOUR^EWEBRC4(^ICONFIG("CURL","password"),key)
 set endpoint=^ICONFIG("CURL","endpoint")
 
 set cmd="curl -u "_username_":"_password_" """_endpoint_"syndownload?filename="_file_""""
 
 if +$get(zip) do
 .set cmd=cmd_" --output /tmp/temp.7z"
 .quit
 
 if '+$get(zip) do
 .set cmd=cmd_" --output /tmp/"_$piece(file,"/",$length(file,"/"))
 .quit
 
 zsystem cmd
 
 if $zsystem>0 w !,"Something went wrong curling"
 
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
