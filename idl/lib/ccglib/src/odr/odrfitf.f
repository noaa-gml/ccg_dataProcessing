      SUBROUTINE ODRFITF(infile,outfile,npts,ord)

ccccc  This program was converted to a subroutine at CSIRO
ccccc  so that it could be compiled and run with odrfit.c.
ccccc  This was required because the fortran compiler on
ccccc  MODON does not handle arguments passed to a main fortran
ccccc  program.  May 1996 - kam

c
c  Modeled after d_drive1.f provided with ODRPACK
c

C  Compile using make.odrfit

C  ODRPACK ARGUMENT DEFINITIONS
C      ==> FCN      NAME OF THE USER SUPPLIED FUNCTION SUBROUTINE
C      ==> N        NUMBER OF OBSERVATIONS 
C      ==> M        COLUMNS OF DATA IN THE EXPLANATORY VARIABLE
C      ==> NP       NUMBER OF PARAMETERS
C      ==> NQ       NUMBER OF RESPONSES PER OBSERVATION
C     <==> BETA     FUNCTION PARAMETERS
C      ==> Y        RESPONSE VARIABLE
C      ==> LDY      LEADING DIMENSION OF ARRAY Y
C      ==> X        EXPLANATORY VARIABLE
C      ==> LDX      LEADING DIMENSION OF ARRAY X
C      ==> WE       "EPSILON" WEIGHTS
C      ==> LDWE     LEADING DIMENSION OF ARRAY WE
C      ==> LD2WE    SECOND DIMENSION OF ARRAY WE
C      ==> WD       "DELTA" WEIGHTS
C      ==> LDWD     LEADING DIMENSION OF ARRAY WD
C      ==> LD2WD    SECOND DIMENSION OF ARRAY WD
C      ==> IFIXB    INDICATORS FOR "FIXING" PARAMETERS (BETA)
C      ==> IFIXX    INDICATORS FOR "FIXING" EXPLANATORY VARIABLE (X)
C      ==> LDIFX    LEADING DIMENSION OF ARRAY IFIXX
C      ==> JOB      TASK TO BE PERFORMED 
C      ==> NDIGIT   GOOD DIGITS IN SUBROUTINE FUNCTION RESULTS
C      ==> TAUFAC   TRUST REGION INITIALIZATION FACTOR
C      ==> SSTOL    SUM OF SQUARES CONVERGENCE CRITERION
C      ==> PARTOL   PARAMETER CONVERGENCE CRITERION
C      ==> MAXIT    MAXIMUM NUMBER OF ITERATIONS
C      ==> IPRINT   PRINT CONTROL 
C      ==> LUNERR   LOGICAL UNIT FOR ERROR REPORTS 
C      ==> LUNRPT   LOGICAL UNIT FOR COMPUTATION REPORTS 
C      ==> STPB     STEP SIZES FOR FINITE DIFFERENCE DERIVATIVES WRT BETA
C      ==> STPD     STEP SIZES FOR FINITE DIFFERENCE DERIVATIVES WRT DELTA
C      ==> LDSTPD   LEADING DIMENSION OF ARRAY STPD
C      ==> SCLB     SCALE VALUES FOR PARAMETERS BETA
C      ==> SCLD     SCALE VALUES FOR ERRORS DELTA IN EXPLANATORY VARIABLE 
C      ==> LDSCLD   LEADING DIMENSION OF ARRAY SCLD
C     <==> WORK     DOUBLE PRECISION WORK VECTOR
C      ==> LWORK    DIMENSION OF VECTOR WORK
C     <==  IWORK    INTEGER WORK VECTOR
C      ==> LIWORK   DIMENSION OF VECTOR IWORK
C     <==  INFO     STOPPING CONDITION 
 
C  PARAMETERS SPECIFYING MAXIMUM PROBLEM SIZES HANDLED BY THIS DRIVER
C     MAXN          MAXIMUM NUMBER OF OBSERVATIONS 
C     MAXM          MAXIMUM NUMBER OF COLUMNS IN EXPLANATORY VARIABLE
C     MAXNP         MAXIMUM NUMBER OF FUNCTION PARAMETERS
C     MAXNQ         MAXIMUM NUMBER OF RESPONSES PER OBSERVATION

C  PARAMETER DECLARATIONS AND SPECIFICATIONS
      INTEGER    LDIFX,LDSCLD,LDSTPD,LDWD,LDWE,LDX,LDY,LD2WD,LD2WE,
     +           LIWORK,LWORK,MAXM,MAXN,MAXNP,MAXNQ
      PARAMETER (MAXM=5,MAXN=5000,MAXNP=10,MAXNQ=1,
     +           LDY=MAXN,LDX=MAXN,
     +           LDWE=MAXN,LD2WE=1,LDWD=MAXN,LD2WD=1,
     +           LDIFX=MAXN,LDSTPD=1,LDSCLD=1,
     +           LWORK=18 + 11*MAXNP + MAXNP**2 + MAXM + MAXM**2 + 
     +                 4*MAXN*MAXNQ + 6*MAXN*MAXM + 2*MAXN*MAXNQ*MAXNP +  
     +                 2*MAXN*MAXNQ*MAXM + MAXNQ**2 + 
     +                 5*MAXNQ + MAXNQ*(MAXNP+MAXM) + LDWE*LD2WE*MAXNQ,
     +           LIWORK=20+MAXNP+MAXNQ*(MAXNP+MAXM))

C  VARIABLE DECLARATIONS 
      INTEGER          I,INFO,IPRINT,J,JOB,L,LUNERR,LUNRPT,M,MAXIT,N,
     +                 NDIGIT,NP,NQ
      INTEGER          IFIXB(MAXNP),IFIXX(LDIFX,MAXM),IWORK(LIWORK)
      DOUBLE PRECISION PARTOL,SSTOL,TAUFAC
      DOUBLE PRECISION BETA(MAXNP),SCLB(MAXNP),SCLD(LDSCLD,MAXM),
     +                 STPB(MAXNP),STPD(LDSTPD,MAXM),
     +                 WD(MAXN,LD2WD,MAXM),WE(MAXN,LD2WE,MAXNQ),
     +                 WORK(LWORK),X(LDX,MAXM),Y(LDY,MAXNQ)
      EXTERNAL         FCN
C
C  Passed variables
C
      CHARACTER    infile*80,outfile*80
      INTEGER      npts,ord
C
      N=npts
      NP=ord

c     WRITE(6,*) N,NP,npts,ord
c     WRITE(6,*) infile,outfile

C  SPECIFY DEFAULT VALUES FOR DODRC ARGUMENTS
      WE(1,1,1)  = -1.0D0
      WD(1,1,1)  = -1.0D0
      IFIXB(1)   = -1
      IFIXX(1,1) = -1
      JOB        = -1
      NDIGIT     = -1
      TAUFAC     = -1.0D0
      SSTOL      = -1.0D0
      PARTOL     = -1.0D0
      MAXIT      = -1
      IPRINT     = -1
      LUNERR     = -1
      LUNRPT     = -1
      STPB(1)    = -1.0D0
      STPD(1,1)  = -1.0D0
      SCLB(1)    = -1.0D0
      SCLD(1,1)  = -1.0D0
C     N          = 4
      NQ         = 1
      M          = 1
C     NP         = 3

C  SET UP ODRPACK REPORT FILES
      LUNERR  =   9
      LUNRPT  =   9
      OPEN (UNIT=9,FILE=outfile)
c
c  READ PROBLEM DATA
c
      OPEN (UNIT=5,FILE=infile)
      DO 10 I=1,NP
         READ (5,FMT=*)  BETA(I)
c        WRITE (6,FMT=*)  BETA(I)
   10 CONTINUE
      DO 20 I=1,N
         READ (5,FMT=*) (X(I,J),WD(I,J,J),J=1,M),
     1                  (Y(I,L),WE(I,L,L),L=1,NQ)

c        WRITE (6,FMT=*)  (X(I,J),WD(I,J,J),J=1,M),
c    1                    (Y(I,L),WE(I,L,L),L=1,NQ)
   20 CONTINUE
      CLOSE(UNIT=5)
    
C  SPECIFY TASK: EXPLICIT ORTHOGONAL DISTANCE REGRESSION
C                WITH USER SUPPLIED DERIVATIVES (CHECKED)
C                COVARIANCE MATRIX CONSTRUCTED WITH RECOMPUTED DERIVATIVES
C                DELTA INITIALIZED TO ZERO
C                NOT A RESTART
C  AND INDICATE SHORT INITIAL REPORT
C               SHORT ITERATION REPORTS EVERY ITERATION, AND
C               LONG FINAL REPORT

c
c Use central finite differences to determine derivative,
c i.e, job=00010.  According to ODRPACK manual, this automatic
c derivative calculation is more accurate at the cost of some
c additional computations.  November 1996 - kam.
c
      JOB     = 00010
c     IPRINT  = 0001
      IPRINT  = 1112

C  COMPUTE SOLUTION
      CALL DODRC(FCN,
     +          N,M,NP,NQ,
     +          BETA,
     +          Y,LDY,X,LDX,
     +          WE,LDWE,LD2WE,WD,LDWD,LD2WD,
     +          IFIXB,IFIXX,LDIFX,
     +          JOB,NDIGIT,TAUFAC,
     +          SSTOL,PARTOL,MAXIT,
     +          IPRINT,LUNERR,LUNRPT,
     +          STPB,STPD,LDSTPD,
     +          SCLB,SCLD,LDSCLD,
     +          WORK,LWORK,IWORK,LIWORK,
     +          INFO)
      CLOSE(UNIT=9)
      END


      SUBROUTINE FCN(N,M,NP,NQ,
     +               LDN,LDM,LDNP,
     +               BETA,XPLUSD,
     +               IFIXB,IFIXX,LDIFX,
     +               IDEVAL,F,FJACB,FJACD,
     +               ISTOP)

C  SUBROUTINE ARGUMENTS
C      ==> N        NUMBER OF OBSERVATIONS
C      ==> M        NUMBER OF COLUMNS IN EXPLANATORY VARIABLE
C      ==> NP       NUMBER OF PARAMETERS
C      ==> NQ       NUMBER OF RESPONSES PER OBSERVATION
C      ==> LDN      LEADING DIMENSION DECLARATOR EQUAL OR EXCEEDING N
C      ==> LDM      LEADING DIMENSION DECLARATOR EQUAL OR EXCEEDING M
C      ==> LDNP     LEADING DIMENSION DECLARATOR EQUAL OR EXCEEDING NP
C      ==> BETA     CURRENT VALUES OF PARAMETERS
C      ==> XPLUSD   CURRENT VALUE OF EXPLANATORY VARIABLE, I.E., X + DELTA
C      ==> IFIXB    INDICATORS FOR "FIXING" PARAMETERS (BETA)
C      ==> IFIXX    INDICATORS FOR "FIXING" EXPLANATORY VARIABLE (X)
C      ==> LDIFX    LEADING DIMENSION OF ARRAY IFIXX
C      ==> IDEVAL   INDICATOR FOR SELECTING COMPUTATION TO BE PERFORMED
C     <==  F        PREDICTED FUNCTION VALUES
C     <==  FJACB    JACOBIAN WITH RESPECT TO BETA
C     <==  FJACD    JACOBIAN WITH RESPECT TO ERRORS DELTA
C     <==  ISTOP    STOPPING CONDITION, WHERE
C                     0 MEANS CURRENT BETA AND X+DELTA WERE
C                       ACCEPTABLE AND VALUES WERE COMPUTED SUCCESSFULLY
C                     1 MEANS CURRENT BETA AND X+DELTA ARE
C                       NOT ACCEPTABLE;  ODRPACK SHOULD SELECT VALUES 
C                       CLOSER TO MOST RECENTLY USED VALUES IF POSSIBLE
C                    -1 MEANS CURRENT BETA AND X+DELTA ARE
C                       NOT ACCEPTABLE;  ODRPACK SHOULD STOP

C  INPUT ARGUMENTS, NOT TO BE CHANGED BY THIS ROUTINE:
      INTEGER          I,IDEVAL,ISTOP,L,LDIFX,LDM,LDN,LDNP,M,N,NP,NQ
      DOUBLE PRECISION BETA(NP),XPLUSD(LDN,M)
      INTEGER          IFIXB(NP),IFIXX(LDIFX,M)
C  OUTPUT ARGUMENTS:
      DOUBLE PRECISION F(LDN,NQ),FJACB(LDN,LDNP,NQ),FJACD(LDN,LDM,NQ)
C  LOCAL VARIABLES
      INTRINSIC        EXP
      DOUBLE PRECISION XX

C  COMPUTE PREDICTED VALUES
      IF (MOD(IDEVAL,10).GE.1) THEN
         DO 110 L = 1,NQ
            DO 100 I = 1,N
                  F(I,L)=0.0D0
               DO 90 J = 1,NP
                  F(I,L) = F(I,L)+BETA(J)*(XPLUSD(I,1)**(J-1))
  90           CONTINUE
  100       CONTINUE
  110    CONTINUE
      END IF

C  COMPUTE derivatives with respect to beta
c
c Code not used unless activated by JOB=00020
c November 1996 - kam
c
      IF (MOD(IDEVAL/10,10).GE.1) THEN
         DO 210 L = 1,NQ
            DO 205 I = 1,N
               DO 200 J = 1,NP
                  IF (J.EQ.1) THEN 
                     FJACB(I,J,L) = 1.0D0
                  ELSE 
                     FJACB(I,J,L) = XPLUSD(I,1)**(J-1)
                  END IF

  200          CONTINUE
  205       CONTINUE
  210    CONTINUE
      END IF

C  COMPUTE derivatives with respect to delta
c
c Code not used unless activated by JOB=00020
c November 1996 - kam
c
      IF (MOD(IDEVAL/100,10).GE.1) THEN
         DO 310 L = 1,NQ
            DO 305 I = 1,N
               DO 300 J = 1,NP
                  IF (J.EQ.1) THEN 
                     FJACD(I,1,L) = 0.0D0
                  ELSE
                     XX=(J-1)*BETA(J)*(XPLUSD(I,1)**(J-2))
                     FJACD(I,1,L) = FJACD(I,1,L)+XX
                  END IF
  300          CONTINUE
  305       CONTINUE
  310    CONTINUE
      END IF
      RETURN
      END
