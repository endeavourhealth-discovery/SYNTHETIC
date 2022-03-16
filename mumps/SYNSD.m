SYNSD	;
STT()	;
	new r
	
	D MEAN(.am,.ct)
	set r=$$SD1(am,ct)
	
	QUIT r
	
MEAN(am,ct) ;
	new rt,str
	
	S rt=0,am=0,ct=0
	S f="/datagenerator/nel/sample.dat"
	C f
	O f:(readonly)
	F  U f R str Q:$ZEOF  DO
	.S rt=rt+str
	.S ct=ct+1
	.QUIT
	CLOSE f
	S am=$J(rt/ct,0,10)
	QUIT
	
SD1(AM,CT) ;
	new sum2,ang2,sdev
	new value,diff,dif2,sum2,avg2,f
	
	S sum2=0,ang2=0,sdev=0
	S f="/datagenerator/nel/sample.dat"
	CLOSE f
	O f:(readonly)
	F  U f R value Q:$ZEOF  DO
	.S diff=am-value
	.S dif2=diff*diff
	.S sum2=sum2+dif2
	.QUIT
	CLOSE f
 
	S avg2=sum2/ct
	
	ZSYSTEM "echo 'scale=30;sqrt("_avg2_")' | bc > /datagenerator/nel/sd.txt"
 
	S f="/datagenerator/nel/sd.txt"
	C f O f:(readonly) U f r str C f
 	QUIT str
 
