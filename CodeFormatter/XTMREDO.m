XTMREDO	;JLI/FO-OAK-ROUTINE TO MAKE ROUTINES EASIER TO READ ;08/10/11  13:50
	;;7.3;TOOLKIT;**to be determined**;
	;
	;  The code in this routine is based on that in routine XINDX8,
	;  it has simply been modified to make the Structured Format listing
	;  into an actual routine.  Conversion should not alter the
	;  functioning of the routine.
	;
	;  The modified routine is saved with a long file name concatenating
	;    ZZ the first two characters
	;    YYMMDD (digits) as the next six characters
	;    FILENAME - the original filename of the file analyzed
	;      e.g., analysis of XTDEBUG on Sept. 15, 2009 would result in
	;      a new routine named  ZZ090915XTDEBUG
	;      This is longer than names allowed by the SAC, but insures
	;      it will not overwrite or collide with other routines.
	;
	; Convert an M routine to fully spelled out commands, functions, etc.
	;
	; Single commands on a line (FOR, IF, ELSE commands followed by necesary code)
	;
	; Creates new TAGs for argumentless DO commands and moves the code
	; to these locations (the tags are DODOT1, DODOT2, etc in the order
	; in which they are encountered).
	;
	; Note that this code does not necessarily keep naked globals, if
	; present, on the same line - it is recommended that a search for
	; ^( be made to locate any naked globals and either notate them
	; or move them back to the same line.
	;
	; 090917 - handling of Q:condition in FOR commands
	;             default conversion to IF condition QUIT causes the
	;             rest of the line to be ignored.
	;                1) Can use Q:condition if desired
	;                2) Can use IF $$DOFORn(index) QUIT and move all
	;                   code related to the QUIT and following to the
	;                   DOFORn tag - which must return values on QUITs
	;    ---->       3) move all code after FOR args to DOFORn and
	;                   replace with DO DOFORn, where any QUIT will cause
	;                   the FOR loop to be terminated.  Also makes
	;                   handling of nested FOR loops simple
	;
ENTRY(RTN,XTMLOG)	; entry without special handling for multiple commands following IF
	K ^UTILITY($J)
	S ^UTILITY($J,RTN)=""
	S XTMLOG=+$G(XTMLOG)
	I XTMLOG,$T(^XTMLOG)="" S XTMLOG=0
	D XC2
	Q
	;
LOGENTRY(RTN)	;
	D INITEASY^XTMLOG("C;G,LOGDATA","DEBUG")
	D ENTRY(RTN,1)
	D STOPLOG^XTMLOG("XTMLOG")
	Q
	;
ENTRY1(RTN)	;
	N DDOT,LO,PG,LC
	N ARG,CURDOT,DIE,DIF,DODOTCNT,DODOTTOT,DOFORTOT,DOIFGLOB
	N DOTGLOB,EOC,FORCNT,FORFLAG,FORGLOB,I,IFFLAG,J,JJ,LIN
	N ML,NEWRTN,OLD,OUTCNT,OUTGLOB,OUTLIN,SAV,TY,X,XCN
	N DOIFTOT,DOIFCNT,DOIFTOT,QUOTECHR,XTMLIN
	; set and initialize global storage for generated code
	S OUTGLOB=$NA(^UTILITY("OUT",$J,RTN,0)) K @OUTGLOB
	S DOTGLOB=$NA(^UTILITY("DOT",$J,RTN,0)) K @DOTGLOB
	S FORGLOB=$NA(^UTILITY("FOR",$J,RTN,0)) K @FORGLOB
	S DOIFGLOB=$NA(^UTILITY("IF",$J,RTN,0)) K @DOIFGLOB
	;
	S QUOTECHR="""",(DDOT,LO)=0,PG=+$G(PG)
	S OUTCNT=0,CURDOT=0,DODOTTOT=0,DODOTCNT=0
	S IFFLAG=0
	S FORFLAG=0,OUTLIN="",DOFORTOT=0,FORCNT=0
	;
	F LC=1:1 Q:'$D(^UTILITY($J,1,RTN,0,LC))  S LIN=^(LC,0),XTMLIN=LIN,ML=0 D CD0(LIN,.OUTCNT,OUTGLOB,OUTLIN,1)
	;
	I $G(@DOIFGLOB@(0))>0 F I=0:0 S I=$O(@DOIFGLOB@(I)) Q:I'>0  D
	. F J=0:0 S J=$O(@DOIFGLOB@(I,J)) Q:J'>0  D
	. . S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=@DOIFGLOB@(I,J,0)
	. . Q
	. S J=@OUTGLOB@(OUTCNT,0) I J'=" QUIT 0",J'=" QUIT 1" S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=" QUIT 0"
	. Q
	I $G(@DOTGLOB@(0))>0 F I=0:0 S I=$O(@DOTGLOB@(I)) Q:I'>0  D
	. F J=0:0 S J=$O(@DOTGLOB@(I,J)) Q:J'>0  D
	. . S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=@DOTGLOB@(I,J,0)
	. . Q
	. I @OUTGLOB@(OUTCNT,0)'=" DO XTGETTES QUIT" S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=" DO XTGETTES QUIT"
	. Q
	I $G(@FORGLOB@(0))>0 F I=0:0 S I=$O(@FORGLOB@(I)) Q:I'>0  D
	. F J=0:0 S J=$O(@FORGLOB@(I,J)) Q:J'>0  D
	. . S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=@FORGLOB@(I,J,0)
	. . Q
	. I @OUTGLOB@(OUTCNT,0)'=" QUIT 0" S OUTCNT=OUTCNT+1,@OUTGLOB@(OUTCNT,0)=" QUIT 0"
	. Q
	I $GET(@DOTGLOB@(0))>0 DO
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" ;"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)="XTSETTES ;"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" SET XTDLRTES=$TEST"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" QUIT"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" ;"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)="XTGETTES ;"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" IF XTDLRTES"
	. SET OUTCNT=OUTCNT+1 SET @OUTGLOB@(OUTCNT,0)=" QUIT"
	. QUIT
	; check for lines too long
	F I=0:0 S I=$O(@OUTGLOB@(I)) Q:I'>0  I $L(^(I,0))>245 W !,"ROUTINE=",RTN,"  LINE=",I,"  LENGTH=",$L(^(0)),!,"   ",^(0)
	S NEWRTN="ZZ"_$E($$NOW^XLFDT(),2,7)_RTN
	S (DIF,DIE)="^UTILITY(""OUT"",$J,RTN,0,",XCN=0,X=NEWRTN N ROUNAME S ROUNAME=NEWRTN
	X ^%ZOSF("SAVE")
	Q
	;
CD0(LIN,OUTCNT,OUTGLOB,OUTLIN,NEWLIN)	;
	N IFFLAG
	;W !,"LC=",LC,"   IFFLAG=",$G(IFFLAG)
	S IFFLAG=0 ; make sure it is cleared for new line
	D CD
	Q
	;
CD1(LIN,DODOTTOT,OUTGLOB,DDOT,OUTLIN,NEWLIN)	;
CD	;
	N ARG,ARG2,CM,COM,CONIFSTR
	S DDOT=+$G(DDOT)
	S DODOTTOT=+$G(DODOTTOT)
	; identify label as first thing on line before space, otherwise increment offset
	S LLABEL=$P(LIN," ",1),LIN=$P(LIN," ",2,999),LOFFSET=$S(LLABEL="":$G(LOFFSET)+1,1:0)
	I $G(NEWLIN),OUTLIN'="",OUTLIN'=" " S OUTLIN=$$OUTPUT(OUTLIN,DOIFTOT+DODOTTOT+DOFORTOT,DDOT),IFFLAG=0,OLDIFFLG=0,OLDFORFL=0,OUTLIN=""
	I $G(NEWLIN),FORFLAG S OUTLIN=$$OUTPUT(" QUIT 0",DOIFTOT+DOFORTOT+DODOTTOT,DDOT),FORFLAG=0,OUTLIN=""
	S NEWLIN=0,IFSTR="",LSTDODOT=0
	I OUTLIN="" S OUTLIN=$S('LOFFSET:LLABEL,1:"")_" "
	; EXTRACT AND OUTPUT COMMENT (IF ANY), RETURN ACTIVE LINE
	I LIN[";" S LIN=$$WCOMMNT(LIN,.OUTCNT,OUTGLOB)
	;
EE	; falls through from above or by direct call
	D:XTMLOG DEBUG^XTMLOG("ENTERED EE","IFFLAG,LIN,OUTLIN,CONDIFX")
	I LIN="",OUTLIN'="",OUTLIN'=" ",('FORFLAG!'$D(LINA)!(OUTLIN[" GOTO ")!(OUTLIN[" GOTO:")) S OUTLIN=$$OUTPUT(OUTLIN,DODOTTOT+DOFORTOT,DDOT),IFFLAG=0,OLDIFFLG=0,OUTLIN=""
	I LIN="",FORFLAG,'$D(LINA) S OUTLIN=$$OUTPUT(" QUIT 0",DODOTTOT+DOFORTOT,DDOT),FORFLAG=0
	I LIN="" Q
	S CONIFSTR="",CONDIFX=""
	I $E(LIN)=" " S LIN=$E(LIN,2,9999) G EE ;Skip blanks
	D:XTMLOG DEBUG^XTMLOG("LINE IN EE","LIN")
	;D SEP1(.LIN,.ARG) S EOC=0,COM=$$UC($P(ARG,":")),CM=$P($G(IND("CMD",COM)),"^") I CM="" G ERR
	D SEP1(.LIN,.ARG)
	S EOC=0,COM=$$UC($P(ARG,":")),CM=$S($P($G(IND("CMD",COM)),"^")'="":$P($G(IND("CMD",COM)),"^"),1:COM) I CM="" D  G ERR
	. ; debug statement if CM is a null value to identify problems so they can be addressed
	. W !,"CM=NULL  ROU=",RTN,"  LC=",LC,"   LINE=",XTMLIN,"   COM=",COM
	. Q
	D:XTMLOG DEBUG^XTMLOG("CM=","CM,ARG")
	S ARG2=""
	; JLI 110809 I ARG[":",CM'="LOCK",'IFFLAG D:XTMLOG DEBUG^XTMLOG("ARG=","ARG,LIN") S CONIFSTR=$$CONDIF($P(ARG,":",2,99)) D:XTMLOG DEBUG^XTMLOG("ARG1A=","ARG,LIN")
	;I ARG[":",CM'="LOCK",IFFLAG D:XTMLOG DEBUG^XTMLOG("ARG2=","ARG,LIN") S ARG2=$P($$CONDIF($P(ARG,":",2)),"IF ",2)
	; JLI 110809 S COM=CM I ARG[":",IFFLAG S COM=COM_":"_$P(ARG,":",2,99)
	S COM=CM I ARG[":" S COM=COM_":"_$P(ARG,":",2,99),ARG="",CONIFSTR="" ; JLI 110809
	D:XTMLOG DEBUG^XTMLOG("ARG2A=","ARG,LIN")
	D:XTMLOG DEBUG^XTMLOG("BEFORE D SEP","COM,ARG,IFFLAG")
	D SEP
	D:XTMLOG DEBUG^XTMLOG("ARG3A=","ARG,LIN")
	D:XTMLOG DEBUG^XTMLOG("AFTER D SEP","ARG,COM,LIN")
	S POSTCOND=""
	I COM[":",ARG=":"_$P(ARG,":",2,99) D:XTMLOG DEBUG^XTMLOG("ARG4A=","ARG,LIN,COM")
	I ARG[":",$E(COM)'="F",$E(COM)'="R",$E(COM)'="V",'IFFLAG D
	. S POSTCOND=$$CONDIF2(.ARG,.COM,.LIN) D:XTMLOG DEBUG^XTMLOG("POSTCOND","POSTCOND,ARG,LIN")
	. ;I IFFLAG,POSTCOND'="" S ARG=ARG_":"_$P(POSTCOND,"IF ",2),POSTCOND=""
	. Q
	S:$E(COM)="H"&(ARG'="") COM="HANG"
	S X=$E(COM,1)
	I ARG2'="" D:XTMLOG DEBUG^XTMLOG("ARG2","ARG2")
	D:XTMLOG DEBUG^XTMLOG("ARG5A=","ARG,LIN,COM")
	I ARG2'="" S COM=COM_":"_ARG2 S:$E(COM,$L(COM))=" " COM=$E(COM,1,$L(COM)-1)
	D:XTMLOG DEBUG^XTMLOG("ARG6A=","ARG,LIN,COM")
	D:XTMLOG DEBUG^XTMLOG("GOING TO DO @$S(COMMANDS","X,CONIFSTR,ARG2,POSTCOND")
	D @$S("BCHKLMNOPQRUWZ"[X:"GRB",X="S":"SET","DGX"[X:"DGX","IE"[X:"IFE",X="F":"FOR",X="V":"VIEW",1:"GRB")
	D:XTMLOG DEBUG^XTMLOG("FROM DO @$S(COMMANDS GOTO EE")
	G EE
	;
GRB	;
	D:XTMLOG DEBUG^XTMLOG("ENTERED GRB","ARG,COM,CONIFSTR,LIN")
	I ARG["$" F I=1:1 S CH=$E(ARG,I) Q:CH=""  D QUOTE:CH=QUOTECHR I CH="$" D FUN
	I FORFLAG,COM="QUIT",ARG="" S ARG=1
	D:XTMLOG DEBUG^XTMLOG("GRB1","CONIFSTR,OUTLIN")
	; 110807 I CONIFSTR'="" S OUTLIN=OUTLIN_CONIFSTR
	; 110807 I POSTCOND'="" S OUTLIN=OUTLIN_POSTCOND
	D:XTMLOG DEBUG^XTMLOG("GRB2","CONIFSTR,POSTCOND,OUTLIN")
	S OUTLIN=OUTLIN_COM_$S(CONIFSTR'="":CONIFSTR,1:"")_" "_ARG_$S(POSTCOND'="":POSTCOND,1:"")_" "
	D:XTMLOG DEBUG^XTMLOG("GRB3","CONIFSTR,OUTLIN")
	I FORFLAG,'IFFLAG S OUTLIN=$$OUTPUT(OUTLIN,DODOTTOT+DOFORTOT,DDOT)
	I 'FORFLAG,'IFFLAG S OUTLIN=$$OUTPUT(OUTLIN,DODOTTOT+DOFORTOT,DDOT)
	D:XTMLOG DEBUG^XTMLOG("QUITTING GRB")
	Q
	;
CONDIF(ARG)	;
	S CONDIFX=""
	I ARG["$" F I=1:1 S CH=$E(ARG,I) Q:CH=""  D QUOTE:CH=QUOTECHR I CH="$" D FUN
	D:XTMLOG DEBUG^XTMLOG("CONDIF","ARG")
	;Q "IF "_ARG_" "
	;S CONDIFX=":"_ARG
	Q ":"_ARG
	;
CONDIF2(ARG,COM,LIN)	;
	N VALUE
	I ARG["$" F I=1:1 S CH=$E(ARG,I) Q:CH=""  D QUOTE:CH=QUOTECHR I CH="$" D FUN
	D:XTMLOG DEBUG^XTMLOG("CONDIF2","ARG,COM,LIN,CONDIFX")
	S STR=1,L=":," D LOOP I CH="" Q ""
	I CH="," S SAV=ARG,ARG=$E(ARG,1,I-1),IP=I+1 S LIN=COM_" "_$E(SAV,IP,999)_" "_LIN Q ""
	;
	S SAV=ARG,STR=I+1,L="," D LOOP S IP=I+1
	;S OLD=COM,ARG=$E(ARG,STR,I-1),COM="IF" D GRB
	;110807 S VALUE="IF "_$E(ARG,STR,I-1)_" ",ARG=$E(SAV,1,STR-2)
	S VALUE=":"_$E(ARG,STR,I-1),ARG=$E(SAV,1,STR-2)
	I $E(SAV,IP,999)'="" S LIN=COM_$G(CONDIFX)_" "_$E(SAV,IP,999)_" "_LIN
	D:XTMLOG DEBUG^XTMLOG("CONDIF2","VALUE,ARG,LIN,COM,CONDIFX")
	Q VALUE
	;
FUN	;
	I " $$ $& $% "[(" "_$E(ARG,I,I+1)_" ") D  S I=J-1 Q  ;Handle Extrinsics
	. F J=I+2:1 Q:"(,"[$E(ARG,J)
	. Q
	F J=I+1:1 Q:$E(ARG,J)'?1A
	S X=$E(ARG,I+1,J-1),L=$L(X),CH=$E(ARG,I+1),TY=$S($E(ARG,J)="(":"FNC",1:"SVN")
	Q:CH="Z"  S XTMX=X,XTMTY=TY,X=$S($P($G(IND(TY,X)),"^")'="":$P($G(IND(TY,X)),"^"),1:X)
	; debug statement if $L(X) is false to identify problems so they can be addressed
	I '$L(X) W !,"$L(X) is zero  RTN=",RTN,"   LC=",LC,"   LINE=",XTMLIN,"   X=",XTMX,"   TY=",XTMTY G ERR
	Q:L=$L(X)
	;D:$L(ARG)>245 LEN S ARG=$E(ARG,1,I)_X_$E(ARG,J,999),I=I+$L(X)-L
	S ARG=$E(ARG,1,I)_X_$E(ARG,J,999),I=I+$L(X)-L
	Q
	;
WCOMMNT(LIN,OUTCNT,OUTGLOB)	;
	S STR=1 S I=$$LOOP1(LIN,.STR,.CH,";")
	I CH=";" S OUTLIN=$$OUTPUT(OUTLIN_$E(LIN,I,999),DODOTTOT+DOFORTOT,DDOT),LIN=$E(LIN,1,I-2)
	Q LIN
	;
ERR	W !,"*** ERROR ***",! Q
	;
IFE	;
	S IFSTR=""
IFE1	;
	D:XTMLOG DEBUG^XTMLOG("ENTERED IFE","ARG,LIN")
	S OUTPUT=1
	; handles argumentless IF and ELSE by checking $TEST
	; for an ELSE, convert to IF '$TEST, change COM and X to fit
	I ARG=""!(X="E") S:X="E" ARG="'",COM="IF",X="I" S ARG=ARG_"$TEST"
	I ARG["$" F I=1:1 S CH=$E(ARG,I) Q:CH=""  D QUOTE:CH=QUOTECHR I CH="$" D FUN
	S STR=1,L="," S I=$$LOOP1(.ARG,.STR,.CH,",") S SAV=ARG,ARG=$E(ARG,1,I-1),IP=I+1
	S IFSTR=IFSTR_$S(IFSTR'="":" ",1:"")_"IF "_ARG
	S ARG=$E(SAV,IP,999)
	I ARG'="" G IFE1
	D:XTMLOG DEBUG^XTMLOG("IFE","IFSTR")
	S OUTLIN=OUTLIN_IFSTR_" ",IFSTR=""
	S IFFLAG=1
	D:XTMLOG DEBUG^XTMLOG("LEAVING IFE","OUTLIN")
	Q
	;
SET	;
	S STR=1,L="," S I=$$LOOP1(.ARG,.STR,.CH,",") S SAV=ARG,ARG=$E(ARG,1,I-1),IP=I+1
	D GRB S ARG=$E(SAV,IP,999)
	Q:ARG=""
	I IFSTR'="" S OUTLIN=OUTLIN_IFSTR
	G SET
	;
VIEW	;
	S OUTLIN=OUTLIN_"VIEW "_ARG_" "
	Q
	;
FOR	;
	D:XTMLOG DEBUG^XTMLOG("ENTERED FOR")
	I (LIN[" G ")!(LIN[" GOTO ")!(LIN[" G:")!(LIN[" GOTO:") D  Q
	. N IFFLAGA,OUTLINA,LINA,FORFLAG
	. S IFFLAGA=IFFLAG
	. S OUTLINA=OUTLIN
	. S LINA=LIN
	. S IFFLAG=1,FORFLAG=1
	. S OUTLIN=OUTLIN_COM_" "_ARG_" "
	. D EE
	. S XXLIN=">"_OUTLIN_"<"
	. D:XTMLOG DEBUG^XTMLOG("BACK FROM EE","OUTLIN,XXLIN")
	. I (OUTLIN="")!(OUTLIN=" ") K FORFLAG Q  ; 110809
	. Q
	D:XTMLOG DEBUG^XTMLOG("CONTINUED ON") ; 110809
	N FORTOT1
	S FORTOT1=$G(@FORGLOB@(0))+1,^(0)=FORTOT1
	D:XTMLOG DEBUG^XTMLOG("FORTOT","FORTOT1")
	S OUTLIN=OUTLIN_COM_" "_ARG_" QUIT:$$DOFOR"_FORTOT1_"()"
	D:XTMLOG DEBUG^XTMLOG("FORTOT2","FORTOT1,OUTLIN")
	S OUTLIN=$$OUTPUT(OUTLIN,DOFORTOT+DODOTTOT,$G(DDOT))
	N DOFORTOT,DODOTTOT
	S DOFORTOT=FORTOT1,DODOTTOT=0
	N FORFLAG,IFFLAG S FORFLAG=1,IFFLAG=0
	S @FORGLOB@(DOFORTOT,1,0)=" ;"
	S @FORGLOB@(DOFORTOT,2,0)="DOFOR"_DOFORTOT_"() ;"
	S @FORGLOB@(DOFORTOT,0)=2
	N OLDLIN S OLDLIN=OUTLIN
	N I,COM,EOC,Y
	N OUTLIN,IFSTR,OUTGLOB,OUTCNT
	S OUTLIN=" ",IFSTR="",OUTGLOB=FORGLOB
	D EE
	S FORCNT=@FORGLOB@(DOFORTOT,0) I @FORGLOB@(DOFORTOT,FORCNT,0)']" QUIT" S OUTLIN=$$OUTPUT(" QUIT 0",DODOTTOT+DOFORTOT,DDOT)
	D:XTMLOG DEBUG^XTMLOG("EXITING FOR")
	Q
	;
OUTPUT(OUTLIN,TOT,DDOT)	; output a line
	N I
	; remove any trailing spaces
	D:XTMLOG DEBUG^XTMLOG("ENTERED OUTPUT","OUTLIN,TOT,DDOT")
	F  Q:$E(OUTLIN,$L(OUTLIN))'=" "  S OUTLIN=$E(OUTLIN,1,$L(OUTLIN)-1)
	IF OUTLIN="" Q " "
	; find and expand any function names in conditionals
	F I=1:1 Q:$E(OUTLIN,I)=""  D
	. I $E(OUTLIN,I,I+1)=":$",$E(OUTLIN,I+3)="(" S OUTLIN=$E(OUTLIN,1,I+1)_$P($G(IND("FNC",$E(OUTLIN,I+2))),"^")_$E(OUTLIN,I+3,$L(OUTLIN)) Q
	. I $E(OUTLIN,I,I+2)=":'$",$E(OUTLIN,I+4)="(" S OUTLIN=$E(OUTLIN,1,I+2)_$P($G(IND("FNC",$E(OUTLIN,I+3))),"^")_$E(OUTLIN,I+4,$L(OUTLIN))
	. Q
	IF FORFLAG,$E(OUTLIN,$L(OUTLIN)-4,$L(OUTLIN))=" QUIT" S OUTLIN=OUTLIN_" 1"
	IF FORFLAG,OUTLIN["QUIT:",OUTLIN'["FOR " S OUTLIN=OUTLIN_" 1"
	IF FORFLAG D:XTMLOG DEBUG^XTMLOG("FORFLAG OUTPUT","OUTLIN,TOT")
	IF FORFLAG,'$D(OUTLINA) S FORCNT=$G(@FORGLOB@(TOT,0))+1,^(0)=FORCNT,^(FORCNT,0)=OUTLIN Q " "
	IF DDOT'>0 S OUTCNT=$G(@OUTGLOB@(0))+1,^(0)=OUTCNT,^(OUTCNT,0)=OUTLIN Q " "
	; handling DODOT output
	; if quitting reset $TEST value
	IF $E(OUTLIN,$L(OUTLIN)-4,$L(OUTLIN))=" QUIT",OUTLIN'["DO XTGETTES" S OUTLIN=$E(OUTLIN,1,$L(OUTLIN)-5)_" DO XTGETTES QUIT"
	; conditional quits may be anywhere in line and may be multiple
	S HH=" QUIT:"
	S QQ=" XUIT:"
	IF OUTLIN'["QUIT:$$DOFOR" FOR  Q:OUTLIN'[HH  D
	. N PART1,PART2,COND
	. S PART1=$P(OUTLIN,HH)
	. S PART2=$P(OUTLIN,HH,2,99)
	. D SEP1(.PART2,.COND)
	. S OUTLIN=PART1_" DO:"_COND_" XTGETTES XUIT:"_COND_$S(PART2'="":" "_PART2,1:"")
	. Q
	FOR  Q:OUTLIN'[QQ  S OUTLIN=$P(OUTLIN,QQ)_HH_$P(OUTLIN,QQ,2,99)
	; and output
	S OUTCNT=$G(@DOTGLOB@(TOT,0))+1,^(0)=OUTCNT,^(OUTCNT,0)=OUTLIN
	Q " "
	;
DGX	; DO, GO, eXecute
	; identify and handle argumentless DO commands
	I ARG="",$E(COM)="D" D DDOT Q
	;
	D:XTMLOG DEBUG^XTMLOG("DGX1","COM,LIN,CONIFSTR,ARG,OUTLIN")
	;S STR=1,L=":," D LOOP I CH="" G GRB
	;JLI 110809 S STR=1,L=":," D:XTMLOG DEBUG^XTMLOG("DGX1-1","COM,LIN,CONIFSTR,ARG,OUTLIN")
	S STR=1,L="," D:XTMLOG DEBUG^XTMLOG("DGX1-1","COM,LIN,CONIFSTR,ARG,OUTLIN")
	D LOOP
	I CH="" D:XTMLOG DEBUG^XTMLOG("DGX1-2","COM,LIN,CONIFSTR,ARG,OUTLIN") G GRB
	D:XTMLOG DEBUG^XTMLOG("DGX2","CH,CONIFSTR,ARG,OUTLIN")
	I CH="," S SAV=ARG,ARG=$E(ARG,1,I-1),IP=I+1 D GRB G D1
	;
	D:XTMLOG DEBUG^XTMLOG("DGX3","CONIFSTR,OUTLIN")
	S SAV=ARG,STR=I+1,L="," D LOOP S IP=I+1
	D:XTMLOG DEBUG^XTMLOG("DGX4","CONIFSTR,OUTLIN")
	;110807 I 'IFFLAG S OUTLIN=" IF "_$E(ARG,STR,I-1)_" "_COM_" "_$E(SAV,1,STR-2)
	;110807 I IFFLAG S OUTLIN=OUTLIN_COM_":"_$E(ARG,STR,I-1)_" "_$E(SAV,1,STR-2)_" "
	S OUTLIN=OUTLIN_COM_":"_$E(ARG,STR,I-1)_" "_$E(SAV,1,STR-2)_" "
	D:XTMLOG DEBUG^XTMLOG("DGX5","CONIFSTR,OUTLIN")
	;S ARG=$E(SAV,1,STR-2),COM=OLD D GRB
	I 'IFFLAG S OUTLIN=$$OUTPUT(OUTLIN,DOIFTOT+DODOTTOT+DOFORTOT,$G(DDOT))
D1	;
	S ARG=$E(SAV,IP,999) Q:ARG=""  G DGX
	;
DDOT	;
	D:XTMLOG DEBUG^XTMLOG("ENTERED DODOT","OUTLIN")
	N DODOTTO1
	S DODOTTO1=$G(@DOTGLOB@(0))+1,^(0)=DODOTTO1
	D:XTMLOG DEBUG^XTMLOG("IN DODOT","COM,CONIFSTR,OUTLIN,IFFLAG")
	I CONIFSTR'="",'IFFLAG S OUTLIN=OUTLIN_"DO"_CONIFSTR_" DODOT"_DODOTTO1
	I CONIFSTR="" S OUTLIN=OUTLIN_COM_" DODOT"_DODOTTO1 ;I IFFLAG,COM[":" S OUTLIN=OUTLIN_":"_$P(COM,":",2,99)
	I IFFLAG S OUTLIN=OUTLIN_" "
	I 'IFFLAG S OUTLIN=$$OUTPUT(OUTLIN,DODOTTOT+DOFORTOT,$G(DDOT))
	N OUTLIN S OUTLIN=" "
	N DODOTTOT,DOFORTOT
	S DODOTTOT=DODOTTO1,DOFORTOT=0
	N IFFLAG,FORFLAG,DOTFLAG S IFFLAG=0,FORFLAG=0,DOTFLAG=1
	S @DOTGLOB@(DODOTTOT,1,0)=" ;"
	S @DOTGLOB@(DODOTTOT,2,0)="DODOT"_DODOTTOT_" NEW XTDLRTES DO XTSETTES"
	S @DOTGLOB@(DODOTTOT,0)=2
	S DDOT=DDOT+1
	N LIN,I,COM,EOC,Y
	N IFSTR,FORFLAG,OUTGLOB,OUTCNT
	S OUTLIN="",IFSTR="",FORFLAG=0,OUTGLOB=DOTGLOB,OUTCNT=DODOTCNT
	; process subsequent lines until no longer a dot structure
	N NUMDOTS
	F LC=LC+1:1 S LIN=$G(^UTILITY($J,1,RTN,0,LC,0)) Q:LIN=""  D  Q:NUMDOTS<DDOT  D CD1(LIN,DODOTTOT,DOTGLOB,DDOT,OUTLIN,1)
	. N LABEL,I
	. S LABEL=$P(LIN," "),LIN=$P(LIN," ",2,999)
	. F I=1:1:254 Q:". "'[$E(LIN,I)
	. S NUMDOTS=$L($E(LIN,1,I),".")-1,LIN=LABEL_" "_$E(LIN,I,999)
	. D:XTMLOG DEBUG^XTMLOG("DODOT1","X,LIN")
	. Q
	S DODOTCNT=@OUTGLOB@(DODOTTOT,0) I @OUTGLOB@(DODOTTOT,DODOTCNT,0)'=" DO XTGETTES QUIT" S OUTLIN=$$OUTPUT(" DO XTGETTES QUIT",DODOTTOT+DOFORTOT,DDOT)
	S LC=LC-1,DDOT=DDOT-1
	D:XTMLOG DEBUG^XTMLOG("EXITING DODOT","IFFLAG")
	Q
	;
LOOP1(ARG,STR,CH,L)	;
	D LOOP
	Q I
	;
LOOP	;
	F I=STR:1 S CH=$E(ARG,I) D QUOTE:CH=QUOTECHR,PAREN:CH="(" Q:L[CH
	Q
	;
PAREN	;
	S PC=1
	F I=I+1:1 S CH=$E(ARG,I) Q:PC=0!(CH="")  I "()"""[CH D QUOTE:CH=QUOTECHR S:"()"[CH PC=PC+$S(CH="(":1,1:-1)
	Q
	;
QUOTE	;
	F I=I+1:1 S CH=$E(ARG,I) Q:CH=""!(CH=QUOTECHR)
	Q
	;
SEP1(LIN,ARG)	;
SEP	;
	D:XTMLOG DEBUG^XTMLOG("ENTERED SEP","LIN,ARG")
	F I=1:1 S CH=$E(LIN,I) D SEPQ1(.LIN,.I,.CH):CH=QUOTECHR Q:"; "[CH
	S ARG=$E(LIN,1,I-1) S:CH=" " I=I+1 S LIN=$E(LIN,I,999)
	D:XTMLOG DEBUG^XTMLOG("EXITING SEP","LIN,ARG")
	Q
	;
SEPQ1(LIN,I,CH)	;
SEPQ	;
	S I=I+1,CH=$E(LIN,I)
	; debug statement to identify problems
	I CH="" W !,"CH=NULL  ROUTINE=",RTN,"  LC=",LC,"   LIN=",LIN,"  LINE=",XTMLIN
	I CH="" G ERR
	G SEPQ:CH'=QUOTECHR S I=I+1,CH=$E(LIN,I) G:CH=QUOTECHR SEPQ
	Q
	;
LEN	;
	S AGR=$E(ARG,1,I-1) S OUTLIN=$$OUTPUT(OUTLIN_COM_" "_AGR_"...",DODOTTOT+DOFORTOT,$G(DDOT)) S ARG=$E(ARG,I)_$E(ARG,J-1,999),I=1,J=3,ML=1 K AGR
	Q
	;
HDR	;
	S PG=PG+1
	W @IOF,RTN,"   ",+^UTILITY($J,1,RTN,0),"     printed  ",INDXDT,?(IOM-10)," Page ",PG,!!
	Q
	;
UC(%)	;
	Q $TR(%,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
XC2	;
	D BUILD
	S RTN="" F  S RTN=$O(^UTILITY($J,RTN)) Q:RTN=""  D  D ENTRY1(RTN)
	. S X=RTN,XCNP=0,DIF="^UTILITY("_$J_",1,RTN,0," X ^%ZOSF("TEST") Q:'$T  X ^%ZOSF("LOAD") S ^UTILITY($J,1,RTN,0,0)=XCNP-1
	. S CCN=0 F I=1:1:+^UTILITY($J,1,RTN,0,0) S CCN=CCN+$L(^UTILITY($J,1,RTN,0,I,0))+2
	. S ^UTILITY($J,1,RTN,0)=CCN
	. Q
	; falls through
EXIT	;
	;D ^%ZISC K ^UTILITY($J),^UTILITY("OUT",$J),^UTILITY("DOT",$J),RTN,T,CCN,I,PG,INDXDT
	K ^UTILITY($J),^UTILITY("OUT",$J),^UTILITY("DOT",$J),RTN,T,CCN,I,PG,INDXDT
	Q
	;
	;
	;  The following code was copied from XINDX7 to make this routine
	;  independent of other routines.
	;
BUILD	N IX,X,TAG,TG,TX,S,L,V K IND
	F TAG=1:1 S X=$T(TABLE+TAG) Q:X=""  D
	. S TG=$P(X,";;",2),TX=$P(X,";;",3) Q:TG=""
	. F IX=1:1 S X=$P(TX,":",IX) Q:X=""  D
	. . S S=$P(X,","),L=$P(X,",",2),V=$P(X,",",3)
	. . S IND(TG,S)=L_"^"_V,IND(TG,L)=L_"^"_V
	. Q
	Q
TABLE	;;Short name, Full name, parameters (CMD default - add to GRB)
CMD	;;CMD;;B,BREAK,B:C,CLOSE,C:D,DO,DG1^XINDX4:E,ELSE,E:ESTA,ESTART,:ESTO,ESTOP,:ETR,ETRIGER,:F,FOR,F:G,GOTO,G:H,HALT,H:H,HANG,H:I,IF,:J,JOB,J:K,KILL,K:L,LOCK,L
	;;CMD;;M,MERGE,M:N,NEW,N:O,OPEN,O:Q,QUIT,Q:R,READ,R:S,SET,S:TC,TCOMMIT,2:TRE,TRESTART,2:TRO,TROLLBACK,2:TS,TSTART,2:U,USE,U:V,VIEW,V:W,WRITE,W:X,XECUTE,X:
	;;
FNC	;;FNC;;A,ASCII,1;2:C,CHAR,1;999:D,DATA,1;1:E,EXTRACT,1;3:F,FIND,2;3:G,GET,1;2:J,JUSTIFY,2;3:L,LENGTH,1;2:O,ORDER,1;2:P,PIECE,2;4:Q,QUERY,1;2:R,RANDOM,1;1:S,SELECT,1;999:T,TEXT,1;1:V,VIEW,1;999,
	;;FNC;;FN,FNUMBER,2;3:NA,NAME,1;2:QL,QLENGTH,1;1:QS,QSUBSCRIPT,1;3:RE,REVERSE,1;1:ST,STACK,1;2:TR,TRANSLATE,1;3:WFONT,WFONT,4;4:WTFIT,WTFIT,6;6:WTWIDTH,WTWIDTH,5;5:
	;;
SVN	;;SVN;;D,DEVICE:EC,ECODE:ES,ESTACK:ET,ETRAP:H,HOROLOG:I,IO:J,JOB:K,KEY:PD,PDISPLAY:P,PRINCIPAL:Q,QUIT:S,STORAGE:ST,STACK:SY,SYSTEM:T,TEST:X,X:Y,Y
	;;
SSVN	;;SSVN;;C,CHARACTER:D,DEVICE:DI,DISPLAY:E,EVENT:G,GLOBAL:J,JOB:L,LOCK:R,ROUTINE:S,SYSTEM:W,WINDOW:Z,Z
