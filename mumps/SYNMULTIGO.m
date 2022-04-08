SYNMULTIGO ; ; 3/31/22 3:05pm
 ; yotta compatible %GO (ZWR format)
STT(dir) ; /datagenerator/nel/
 new file
 
 set file=dir_"synthetic.go"
 close file
 open file:(newversion)
 use file W "%GO Global Output Utility",!
 W "GT.M ",$zd($h,"DD-MON-YEAR 24:60:SS")," ZWR",!
 
 D GO("^CONCEPT","",file)
 D GO("^CONMAP","",file)
 D GO("^COHORT","",file)
 D GO("^GARBLE","",file)
 D GO("^ORGS","",file)
 D GO("^P","",file)
 D GO("^HULL","",file)
 D GO("^ZCOUNTS","",file)
 D GO("^OELIST","",file)
 D GO("^STATS","RX",file)
 D GO("^STATS","ENC-CODES",file)
 D GO("^RXLIST","",file)
 D GO("^LISTS","",file)
 D GO("^ZCNT","",file)
 D GO("^ZCNTALL","",file)
 D GO("^ALLRGYLST","",file)
 D GO("^CONLIST","",file)
 
 write !!!!
 close file
 quit
 
GO(glob,node,file) ;
 new qf,znode,n,data
 
 set qf=0
 set n=glob
 
 set:node'="" glob=glob_"("""_node_""")"
 i node'="",$data(@glob)=1,node?1n.n s glob=n_"("""_(node-1)_""")"
 
 S T=0
 
 u 0 w !,glob
 
 for  set glob=$query(@glob) Q:glob=""!(qf)  DO
 .set znode=$$TR^LIB(glob,n,"")
 .set znode=$$TR^LIB(znode,"(","")
 .set znode=$$TR^LIB(znode,")","")
 .set znode=$P($$TR^LIB(znode,"""",""),",",1)
 .I node'="",znode'=node set qf=1 quit
 .I T#100000=0 U 0 W T," * ",glob,"=",@glob,! ; R *Y
 .set data=@glob
 .set data=$$TR^LIB(data,"""","""""")
 .use file write glob,"=""",data,"""",!
 .S T=T+1
 .quit
 
 quit
