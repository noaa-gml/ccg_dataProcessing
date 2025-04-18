c ********************************************************************
      subroutine filter_data(X, Y, SIG, N0, CUTOFF1, CUTOFF2, INTERVAL, 
     .                       NUMPOLY, NUMHARM, PM, COVAR, NUMPM, 
     .                       MAXPAR, XFILT, SMOOTH, TREND, 
     .                       DERIV, NFILT, VARF1, VARF2, CHISQ, RSD1)

C Filter data using polynomial+harmonics+fft filter of residuals
C (long version).
C 
C INPUT PARAMETERS:
C  X         - ARRAY CONTAINING SAMPLE DATES
C  Y         - ARRAY CONTAINING CO2 VALUES
C  SIG       - ARRAY CONTAINING UNCERTAINTIES OF EACH CO2 VALUE
C  N0        - NUMBER OF POINTS IN X, Y, SIG
C  CUTOFF1   - SHORT TERM CUTOFF VALUE (SPECIFIED IN DAYS) 
C  CUTOFF2   - LONG TERM CUTOFF VALUE (SPECIFIED IN DAYS) 
C  INTERVAL  - NUMBER OF DAYS BETWEEN SAMPLES
C  NUMPOLY   - NUMBER OF POLYNOMIAL TERMS IN FUNCTION
C  NUMHARM   - NUMBER OF HARMONICS IN FUNCTION
C  MAXPAR    - DIMENSION OF ARRAYS PM, COVAR
C  
C OUTPUT PARAMETERS:
C  XFILT  - DATES OF FILTERED CURVE
C  SMOOTH - CONCENTRATIONS OF FILTERED CURVE
C  TREND  - FILTER RESULTS OF RESIDUALS USING LONG TERM CUTOFF
C  DERIV  - DERIVATIVE OF TREND + POLYNOMIAL, I.E. THE GROWTH RATE
C  NFILT  - NUMBER OF POINTS IN XFILT, SMOOTH, TREND, DERIV
C  PM     - ARRAY CONTAINING COEFFICIENTS OF FUNCTION FIT
C  COVAR  - ARRAY CONTAINING COVARIANCE MATRIX
C  NUMPM  - NUMBER OF PARAMETERS IN PM
C  VARF1  - VARIANCE OF FILTER WITH SHORT TERM CUTOFF
C  VARF2  - VARIANCE OF FILTER WITH LONG TERM CUTOFF
C  CHISQ  - CHI SQUARED VALUE OF FUNCTION FIT
C  RSD1   - RESIDUAL STANDARD DEVIATION OF POINTS ABOUT FUNCTION

C
C DEFINE AND DIMENSION PARAMETERS PASSED TO SUBROUTINE
C

      INTEGER NFILT
      INTEGER NUMPM
      INTEGER NUMPOLY
      INTEGER NUMHARM
      INTEGER MAXPAR
      real INTERVAL
      INTEGER CUTOFF1
      INTEGER CUTOFF2
      REAL    PM(*)
      REAL*8  X(*)
      REAL*8  Y(*)
      REAL*8  SIG(*)
      REAL*8  XFILT(*)
      REAL*8  SMOOTH(*)
      REAL*8  TREND(*)
      REAL*8  DERIV(*)
      REAL    VARF1
      REAL    VARF2
      REAL    CHISQ
      REAL    RSD1
      REAL*8  COVAR(MAXPAR,MAXPAR)


C 
C DEFINE AND DIMENSION PARAMETERS LOCAL TO THIS SUBROUTINE
C

      REAL    FILTVAR, RINTERVAL, CUTOFF, RMEAN
      REAL*8    USERFUNC, DP, P
      REAL    CA, CB
      INTEGER NUMPT, NUMHM, I, N0, MAXSIZE, J

      PARAMETER (MAXSIZE=8192*2+2)
      REAL*8 WORK1(MAXSIZE), WORK2(MAXSIZE)

      EXTERNAL PARTIAL

      COMMON /TERMS/ NUMPT, NUMHM
C
C 
C
      NUMPT = NUMPOLY
      NUMHM = NUMHARM
      NUMPM = NUMPOLY + 2*NUMHARM
D     print *,'Inside filter_data.  N0 = ',n0, ' Interval = ',interval
D     print *,'Cutoff 1 = ',cutoff1,' Cutoff 2 = ',cutoff2
D     print *,'Numpoly = ',numpoly,' Numharm = ',numharm
D     print *,'First point = ',x(1), y(1)
D     print *,'Last point = ',x(n0), y(n0)

C
C Fit the function to the data
C
      if (numpm .gt. 0) then
         call lfit (x,y,sig,n0,PM,covar,numpm,maxpar,chisq, PARTIAL)
D     	 print *,'Finished lfit'
D        do i=1, numpm
D           print *,'pm(',i,') = ',pm(i)
D        end do
      end if
C
C  CALCULATE RESIDUALS FROM FIT
C
      DO I=1,N0
         WORK1(I) = Y(I) -  USERFUNC (PM, X(I), NUMHM, NUMPT)
      END DO
      CALL MEANS (WORK1, RMEAN, RSD1, N0)
D     print *,'Finished residuals, rmean = ', rmean

C
C  REMOVE A LINEAR TREND BASED ON THE END POINTS OF THE RESIDUALS.
C  THIS IS TO REDUCE THE END EFFECTS OF THE FILTER
C
C
C  FILTER THE RESIDUALS, FIND VARIANCE DUE TO FILTER
C
      CALL ADJUSTEND (X, WORK1, N0, CUTOFF1, CA, CB)
D     print *,'Finished adjustend, ca = ',ca,' cb = ',cb
      CUTOFF = FLOAT(CUTOFF1)/365.
      RINTERVAL = INTERVAL/365.
      CALL FILTER (X,WORK1,N0,RINTERVAL,CUTOFF,XFILT,WORK2,NFILT)
      do i=1, nfilt
         smooth(i) = work2(i)
      end do
D     print *,'Finished short term filter'
      VARF1 = FILTVAR(CUTOFF,RINTERVAL,XFILT,SMOOTH,NFILT,X,WORK1,N0)
D     print *,'Finished short term filter variance = ',varf1
C
C Add back the linear fit to the ends of the data.
C Need to add to work1(*) before filtering again.
C
      do i=1, n0
         work1(i) = work1(i) + ca + cb*x(i)
      end do
      do i=1, nfilt
         smooth(i) = smooth(i) + ca + cb*xfilt(i)
      end do

      CALL ADJUSTEND (X, WORK1, N0, CUTOFF2, CA, CB)
D     print *,'Finished adjustend, ca = ',ca,' cb = ',cb, n0
      CUTOFF = FLOAT(CUTOFF2)/365.
      CALL FILTER (X,WORK1,N0,RINTERVAL,CUTOFF,XFILT,WORK2,NFILT)
      do i=1, nfilt
         trend(i) = work2(i)
      end do
D     print *,'Finished long term filter'
      VARF2 = FILTVAR(CUTOFF,RINTERVAL,XFILT,TREND,NFILT,X,WORK1,N0)
D     print *,'Finished long term filter variance = ',varf2
      do i=1, nfilt
         trend(i) = trend(i) + ca + cb*xfilt(i)
      end do
C
C  COMPUTE DERIVATIVE OF TREND
C
      CALL SPLINE_F (XFILT, TREND, NFILT, XFILT, WORK1, DERIV, NFILT)
D     print *,'Finished spline'
C
C Find derivative of polynomial at each filtered point
C
      DO I=1, NFILT
         DP=0.0
         P = PM(NUMPOLY)
         DO J=NUMPOLY-1, 1, -1
            DP = DP*XFILT(I)+P
            P = P*XFILT(I)+PM(J)
         END DO
         DERIV(I)=DERIV(I)+DP
      END DO
D     print *,'Finished derivative.  Returning ...'
c
      return
      end

**********************************************************************
      SUBROUTINE SPLINE_F (X, Y, N, DOMAIN, FUNC, DERIV, NARG)
C
C  GIVEN THE ARRAYS X(*) AND Y(*) OF N VALUES OF A FUNCTION,
C  I.E., Y(I)=F(X(I)) I=1..N, COMPUTE A SPLINE INTERPOLATION 
C  CONNECTING EACH OF THE POINTS.
C  GIVEN THE ARRAY DOMAIN(*) OF NARG POINTS, COMPUTE THE
C  INTERPOLATED VALUES FUNC(*) AND FIRST DERIVATIVE VALUES DERIV(*).
C
      REAL*8 X, Y, DOMAIN, FUNC, DERIV, D
      REAL*8  S1, R
      REAL*8 S, G, WORK, W, U, T, H, EPS, DSQRT
      INTEGER N, NARG, I, J, NMAX
      DIMENSION X(N), Y(N), DOMAIN(NARG), FUNC(NARG), DERIV(NARG)

      PARAMETER (NMAX=8192*2+2, EPS=1.D-3)
      DIMENSION S(NMAX), G(NMAX), WORK(NMAX)
C
      DO I=2, N-1
         D=X(I)-X(I-1)
         H=X(I+1)-X(I-1)
         WORK(I)=.5*D/H
         T=((Y(I+1)-Y(I))/(X(I+1)-X(I))-(Y(I)-Y(I-1))/D)/H
         S(I)=2.D0*T
         G(I)=3.D0*T
      END DO
      S(1)=0.D0
      S(N)=0.D0
      W=8.D0-4.D0*DSQRT(3.D0)

10    U=0.D0
      DO I=2, N-1
         T=W*(-S(I)-WORK(I)*S(I-1)-(.5D0-WORK(I))*S(I+1)+G(I))
         H=ABS(T)
         IF (H.GT.U) U=H
         S(I)=S(I)+T
      END DO
      IF (U.GE.EPS) then
        GOTO 10
      end if
      DO I=1, N-1
         G(I)=(S(I+1)-S(I))/(X(I+1)-X(I))
      END DO

      I=1
      DO J=1, NARG
         T=DOMAIN(J)
         DO WHILE (T.GE. X(I))
            I=I+1
            IF (I.GE.N) GOTO 20
         END DO
20       I=I-1
         H=T-X(I)
         R=T-X(I+1)
         D=H*R
         S1=S(I)+H*G(I)
         W=(Y(I+1)-Y(I))/(X(I+1)-X(I))
         U=(S(I)+S(I+1)+S1)/6.
         FUNC(J)=W*H+Y(I)+D*U
         DERIV(J) = W+(H+R)*U+(D*G(I))/6.
      END DO
      RETURN
      END

**********************************************************************
      REAL*8 FUNCTION VARNCE (COVAR, N, NCVM, X)
C
C  CALCULATE THE VARIANCE OF FIT TO USERS FUNCTION
C
C  COVAR  - ARRAY OF COVARIANCES OF PARMATERS FOUND BY ROUTINE 'LFIT'
C  N      - NUMBER OF PARAMETERS
C  NCVM   - PHYSICAL DIMENSION OF ARRAY 'COVAR'
C  X      - TIME VALUE AT WHICH TO CALCULATE VARIANCE (I.E. VARIANCE 
C           CHANGES WITH TIME)
C
C  CALLS FUNCTION 'PART(I,X)' WHICH RETURNS THE VALUE OF THE 
C  PARTIAL DERIVATIVE WITH RESPECT TO PARAMETER I AT TIME X.
C
      REAL*8  X
      REAL*8 PART, S, S2, COVAR
      INTEGER N, I, J, NCVM
      DIMENSION COVAR (NCVM, NCVM)

      VARNCE=0.0D0
      s = 0.0D0
      S2 = 0.0D0
      if (n .eq. 0) return
      do 10 i=1,n-1
C
C  FIND UNCERTAINTY DUE TO VARIANCES OF EACH PARAMETER
C
         S = s+dble(COVAR(I,I))*PART(I,X)**2
C
C  NOW ADD IN UNCERTAINTY DUE TO COVARIANCES BETWEEN PARAMETERS
C
         DO 30 J=I+1, N
            S2 = S2+dble(COVAR(I,J))*PART(I,X)*PART(J,X)
30       CONTINUE
10    continue
      S = s+dble(COVAR(N,N))*PART(N,X)**2
      VARNCE = S+2.0D0*S2
      RETURN 
      END
 
**********************************************************************
      REAL FUNCTION FILTVAR (CUTOFF, DINTERV, XFILT, FILT, NFILT,
     .      X, Y, N)
C
C  COMPUTE VARIANCE OF THE CURVE RESULTING FROM FFT FILTER
C
C  CUTOFF  - FILTER CUTOFF VALUE DEFINED IN SAME UNITS AS X(*)
C  DINTERV - SAMPLING INTERVAL SPECIFIED IN SAME UNITS AS X(*)
C  XFILT   - TIME VALUES OF FILTERED CURVE
C  FILT    - ARRAY OF FILTERED VALUES
C  NFILT   - NUMBER OF POINTS IN XFILT(*), FILT(*)
C  X       - ARRAY SPECIFYING TIME VALUES OF ORIGINAL DATA POINTS
C  Y       - ARRAY OF CONCENTRATIONS OF ORIGINAL DATA POINTS
C  N       - NUMBER OF POINTS IN X(*) AND Y(*)
C
      REAL*8 X, Y, XFILT, FILT
      REAL DINTERV, SSW, SM, RMEAN
      REAL*8 XTEMP, YTEMP, XTEMP2, WEIGHTS
      REAL RSD, COR, SUMR, R, CUTOFF
      REAL*8 DUMMY
      INTEGER NFILT, N, I, NW, J, IP, N0, NSIZE

      PARAMETER (NSIZE=2048)
      DIMENSION XFILT(NFILT), FILT(NFILT)
      DIMENSION X(N), Y(N)
      DIMENSION WEIGHTS(8*NSIZE+2), XTEMP(8*NSIZE), YTEMP(8*NSIZE+2)
      DIMENSION XTEMP2(8*NSIZE+2), DUMMY(8*NSIZE+2)
C
C  FIRST STEP: COMPUTE WEIGHTS OF FILTER BY FILTERING A SINGLE 
C  POINT IN THE MIDDLE OF ZERO VALUES (IMPULSE RESPONSE)
C
      N0=4*INT(CUTOFF/DINTERV)
D     print *,'N0 = ',n0
      IP=0
      DO WHILE ((2**IP) .LT. N0)
         IP=IP+1
      END DO
      N0=MIN(2**IP,NSIZE)
D     print *,'N0 = ',n0
      if (N0 .LE. 1) THEN
         FILTVAR =  0.0
	 RETURN
      END IF
      DO I=1, N0
         XTEMP(I)=I*DINTERV
         YTEMP(I)=0.
      END DO
      YTEMP(N0/2) = 1.
      CALL FILTER (XTEMP,YTEMP,N0,DINTERV,CUTOFF,XTEMP2,WEIGHTS,NW)
C
C  SECOND STEP: COMPUTE SUM OF SQUARES OF WEIGHTS
C
      SSW = 0.
      DO I=1, NW
         SSW = SSW + WEIGHTS(I)*WEIGHTS(I)
      END DO
D     print *,'SSW = ',ssw
C
C  THIRD STEP: COMPUTE RESIDUALS OF DATA ABOUT FILTERED CURVE.
C              INTERPOLATE FILTERED POINTS SINCE ORIGINAL RAW
C              DATA IS NOT NECESSARILY AT SAME LOCATION IN TIME
C
      CALL SPLINE_F(XFILT,FILT,NFILT,X,YTEMP,DUMMY,N)
      DO I=1,N
         XTEMP2(I) = Y(I)-YTEMP(I)
      END DO
C
C  FOURTH STEP: COMPUTE RESIDUAL STANDARD DEVIATION
C
      CALL MEANS (XTEMP2, RMEAN, RSD, N)
D     print *,'rsd = ',rsd
C
C  FIFTH STEP: COMPUTE LAG 1 AUTO COVARIANCE
C
      SM = 0.
      DO I=1, N-1
         SM = SM+(XTEMP2(I)-RMEAN)*(XTEMP2(I+1)-RMEAN)
      END DO
      COR = SM/FLOAT(N-1)/(RSD*RSD)
D     print *,'cor = ',cor
C
C  SIXTH STEP: COMPUTE AUTO COVARIANCES 
C
      SUMR = 0.
      DO 100 I=1, NW-1
         DO J=I+1, NW
            R = COR**(J-I)
            IF (R .LT. 1.E-3) GOTO 200
	    R = R*WEIGHTS(I)*WEIGHTS(J)
            SUMR = SUMR+R
         END DO
100   CONTINUE
C
C  LAST STEP: COMPUTE VARIANCE
C
200   FILTVAR = RSD*RSD*SSW+SUMR
      RETURN 
      END

C****************************************************************
      SUBROUTINE FILTER (X, Y, N, DINTERV, CUTOFF, X1, FILT, NP)
C
C  FILTER DATA USING FAST FOURIER TRANSFORM AND LOWPASS FILTER
C
C  X       - ARRAY SPECIFING TIME VALUES 
C  Y       - ARRAY CONTAINING DEPENDENT VARIABLE VALUES
C  N       - NUMBER OF POINTS IN X(*) AND Y(*)
C  DINTERV - EQUAL INTERVAL BETWEEN POINTS IN X(*) AND Y(*).  IN SAME 
C            UNITS AS X(*)
C  CUTOFF  - CUTOFF VALUE FOR LOWPASS FILTER (AMPLITUDE = 1/2).  IN SAME
C            UNITS AS X(*) AND DINTERV
C  X1      - ARRAY TO CONTAIN VALUES FOR FILTERED INDEPENDENT DATA
C  FILT    - ARRAY OF FILTERED VALUES FOR DEPENDENT VARIABLE
C  NP      - NUMBER OF POINTS IN X1(*) AND FILT(*)
C
C  THIS ROUTINE TAKES THE TWO ARRAYS X(*) AND Y(*) WITH N POINTS AND
C  APPLIES A LOWPASS FILTER IN THE FREQUENCY DOMAIN TO SMOOTH THE DATA.
C  THE FFT REQUIRES EQUALLY SPACED DATA.  TO GET THIS, DINTERV IS SPECIFIED
C  AND A LINEAR INTERPOLATION IS MADE BETWEEN POINTS IN X(*) TO GET A VALUE
C  IN X1(*) AT EACH DINTERV.  THE ARRAY FILT(*) IS PADDED WITH ZEROS TO 
C  MAKE SURE NP IS EQUAL TO AN INTEGER POWER OF 2.  
C  **** IMPORTANT ****  THE ARRAYS X1(*) AND FILT(*) MUST BE DIMENSIONED
C  IN THE CALLING PROGRAM LARGE ENOUGH TO HOLD NP POINTS, WHERE NP 
C  IS DEFINED AT THE BEGINNING OF THIS ROUTINE.
C  AFTER EQUALLY SPACED VALUES ARE DETERMINED, THE DATA IS TRANSFORMED 
C  TO THE FREQUENCY DOMAIN USING FFT.  THE TRANSFORMED DATA IS MULTIPLIED
C  BY A FILTER FUNCTION, SPECIFIED AS A VALUE FROM 0 TO 1 DEPENDING ON
C  FREEQUENCY.  THE FILTERED DATA IS TRANSFORMED BACK TO THE TIME DOMAIN,
C  AND THE ZERO PADDED DATA IS REMOVED.  
C
C  FOR BEST RESULTS, THE DATA Y(*) SHOULD BE CENTERED APPROXIMATELY ON ZERO,
C  USUALLY BY REMOVING A FUNCTION FIRST (THAT IS, FILTER THE RESIDUALS THEN
C  ADD THE RESULTS TO THE FUNCTION)
C
      REAL*8 X, Y, X1, FILT
      REAL  DINTERV, CUTOFF, CUTOFF2
      REAL H, W, B, DMAXFREQ, FREQ, RW, FNFILT
      INTEGER N, NP, IP, N2, NUMZER, INZHALF, N3, I, J, ND
      DIMENSION X(N), Y(N), X1(*), FILT(*)

D     print *, 'Inside filter'
D     print *,'DINTERV = ',dinterv, ' n = ',n
D     print *,' x(n) = ',x(n),' X(1) = ',x(1)
      NP = INT ((X(N)-X(1))/DINTERV) +1
D     print *,'NP = ',np
C
C  ZERO PAD TO GET 2**P POINTS
C  N3 - NUMBER OF ZEROS AT FRONT END OF DATA +1 
C       IN ORDER TO REMEMBER WHERE REAL DATA STARTS IN FILT(*)
C
      IP = 0
      DO WHILE (2**IP .LT. NP)
         IP = IP+1
      END DO
      N2 = 2**IP
      NUMZER = N2-NP
      INZHALF = INT(NUMZER/2)
      DO I=1, N2
         FILT(I)=0.
      END DO
      N3 = INZHALF+1
D     print *,'Finished zero pad.  Numzer = ',numzer
C
C  FILL GAPS IN DATA AND COMPUTE EQUALLY SPACED VALUES USING
C  LINEAR INTERPOLATION
C
      I = 1
      X1(1)=X(1)
      DO J=2, NP
         X1(J) = X1(1)+(J-1)*DINTERV
         DO WHILE (X1(J) .GE. X(I))
            I = I+1
            IF (I.GE.N) GOTO 10
         END DO
10       I = I-1
         IF (X1(J) .EQ. X(I+1)) THEN
            FILT(J+N3-1) = Y(I+1)
         ELSE
            H=X1(J)-X(I)
            W = (Y(I+1)-Y(I))/(X(I+1)-X(I))
            FILT(J+N3-1) = W*H+Y(I)
         END IF
      END DO
D     print *,'Finished interpolation'
C
C  TRANSFORM THE DATA (TIME >> FREQUENCY)
C
      ND = N2/2
      CALL REALFT (FILT, ND, 1)
D     print *,'Finished fft'
C
C  FILTER THE DATA
C  B - FREQUENCY STEP SIZE
C  DMAXFREQ - NYQUIST FREQUENCY
C
      B = 1./(ND*2.*DINTERV)
      DMAXFREQ = 1./(2.*DINTERV)
      CUTOFF2=1./CUTOFF
      DO I=3, N2+2, 2
         FREQ = FLOAT (I-1)/2.*B
         RW = FNFILT (FREQ, CUTOFF2, 6)
         FILT(I) = FILT(I)*RW
         FILT(I+1) = FILT(I+1)*RW
      END DO
      RW = FNFILT (DMAXFREQ, CUTOFF2, 6)
      FILT(2) = FILT(2)*RW
D     print *,'Finished filter'
C
C  INVERSE TRANSFORM (FREQUENCY >> TIME)
C
      CALL REALFT (FILT, ND, -1)
D     print *,'Finished inverse fft'
C
C  REMOVE ZERO PADDING
C
      DO I=1, NP
         FILT(I) = FILT(I+N3-1)
      END DO
D     print *,'Finished removing zero padding'
      RETURN
      END

C**********************************************************************
      REAL FUNCTION FNFILT (FREQ, SIGMA, POWER)
      REAL FREQ, SIGMA, Z
      INTEGER POWER
C
C Watch out for underflow
C
      Z = (FREQ/SIGMA)**POWER
      IF (Z .GT. 20) THEN
         FNFILT = 1.0E-10
      ELSE
         FNFILT = 1.0/(2.0**Z)
      END IF
      RETURN
      END
         
C**********************************************************************
      SUBROUTINE LFIT (X,Y,SIG,NDATA, A,COVAR,MA,NCVM, CHISQ, PARTIAL)
C
C  LEAST SQUARES FIT TO AN ARBITRARY FUNCTION THAT IS LINEAR
C  IN ITS PARAMETERS
C
C  GIVEN A SET OF NDATA POINTS IN X, Y WITH WEIGHTS SIG,
C  DETERMINE THE MA PARAMETERS A(*) BY MINIMIZING CHI SQUARE.
C  COVARIANCES OF PARAMETERS ARE STORED IN COVAR(*). FOR EXAMPLE,
C  VARIANCE OF A(I) IS STORED IN COVAR(I,I).  COVARIANCE BETWEEN 
C  A(I) AND A(J) IS STORED IN COVAR(I,J).
C  USER MUST SUPPLY THE ROUTINE 'PARTIAL' WHICH SPECIFIES THE PARTIAL
C  DERIVATIVE OF THE FITTING FUNCTION WITH RESPECT TO EACH PARAMETER.
C  NCVM IS PHYSICAL DIMENSION OF COVAR(*)
C
C  MODIFIED FROM ROUTINE 'LFIT' IN 'NUMERICAL RECIPES' BY PRESS ET AL.,
C  PG. 513
C  REMOVED OPTION FOR FITTING ONLY CERTAIN PARAMETERS
C

      EXTERNAL  PARTIAL
      REAL*8    AFUNC, BETA, WT , COVAR
      REAL*8    X, Y, SIG, SIG2I
      REAL      A, CHISQ, SUM
      INTEGER   NMAX, I, J, K, MA, NCVM, NDATA
      PARAMETER (NMAX = 50)
      DIMENSION X(NDATA), Y(NDATA), SIG(NDATA), A(MA)
      DIMENSION COVAR(NCVM,NCVM), BETA(NMAX)
      DIMENSION AFUNC(NMAX)
C
      DO J=1,MA
         DO K=1,MA
            covar(J,K)=0.D0
         END DO
         BETA(J)=0.D0
      END DO
C
      DO I=1, NDATA
C     print *,i, 'x(i) = ',x(i)
         CALL PARTIAL (X(I), AFUNC, MA)
         SIG2I = 1./SIG(I)**2
         DO J=1, MA
            WT = AFUNC(J)*SIG2I
            DO K=1,J
               covar(J,K) = covar(J,K)+WT*AFUNC(K)
            END DO
            BETA(J) = BETA(J)+Y(I)*WT
         END DO
      END DO

      IF (MA.GT.1) THEN 
         DO J=2, MA
            DO K=1, J-1
               covar(K,J) = covar(J,K)
            END DO
         END DO
      END IF
      CALL GAUSSJ (covar, MA, NCVM, BETA, 1, 1)
      DO J=1, MA
         A(J)=BETA(J)
         DO I=1, MA
            COVAR(J,I) = covar(J,I)
         END DO
      END DO
      CHISQ = 0.
      DO I=1, NDATA
         CALL PARTIAL (X(I), AFUNC, MA)
         SUM = 0.
         DO J=1, MA
            SUM = SUM+A(J)*AFUNC(J)
         END DO
         CHISQ = CHISQ+((Y(I)-SUM)/SIG(I))**2
      END DO
      CALL COVSRT (COVAR, NCVM, MA)
      RETURN
      END

C*********************************************************************
      SUBROUTINE COVSRT (COVAR, NCVM, MA)
C
C  GIVEN THE COVARIANCE MATRIX COVAR OF A FIT FOR MA PARAMETERS,
C  REPACK THE COVARIANCE MATRIX TO THE TRUE ORDER OF THE PARAMETERS.
C  NCVM IS THE PHYSICAL DIMENSION OF COVAR
C
C  FROM 'NUMERICAL RECIPES', PG 515, PRESS ET AL., 1986
C
      REAL*8 COVAR, SWAP
      INTEGER NCVM, MA, J, I
      DIMENSION COVAR(NCVM, NCVM)
      DO J=1,MA-1
         DO I=J+1, MA
            COVAR(I,J)=0.0D0
         END DO
      END DO
      DO I=1, MA-1
         DO J=I+1, MA
            COVAR(J,I) = COVAR(I,J)
         END DO
      END DO
      SWAP = COVAR(1,1)
      DO J=1,MA
         COVAR(1,J)=COVAR(J,J)
         COVAR(J,J)=0.0D0
      END DO
      COVAR(1,1)=SWAP
      DO J=2,MA
         COVAR(J,J)=COVAR(1,J)
      END DO
      DO J=2,MA
         DO I=1,J-1
            COVAR(I,J)=COVAR(J,I)
         END DO
      END DO
      RETURN
      END

C****************************************************************
      REAL*8 FUNCTION USERFUNC (P, X, NH, NT)
C
C  USER SUPPLIED FUNCTION DEFINING CURVE FIT
C 
C  FUNCTION IS A COMBINATION OF POLYNOMIAL TERMS AND 
C  SINE, COSINE HARMONIC TERMS:
C    F = A1*X + A2*X**2 + A3*X**3 +... for A = 1 to NT +
C         P(2*i-1)*SIN(2PI*X)+P(2*i)*COS(2PI*X)+... for i = 1 to NH 
C
C  P  - ARRAY OF PARAMETERS 
C  X  - VALUE AT WHICH TO CALCULATE THE VALUE OF THE FUNCTION
C  NH - NUMBER OF HARMONIC TERMS
C  NT - NUMBER OF POLYNOMIAL TERMS
C
C  CALLS FUNCTION POLYV(P,X,NT) WHICH CALCULATES THE VALUE OF A
C  POLYNOMIAL WITH NT COEFFICIENTS IN P(*) AT X
C
      REAL 	P
      REAL*8 	X, POLYV, Y, YEARHARMONIC
      INTEGER   NH, NT
      DIMENSION P(*)
C
C COMPUTE THE VALUE OF THE YEARLY HARMONIC PART OF THE FUNCTION
C
      Y = YEARHARMONIC(P, X, NT, NH)
C
C ADD THE POLYNOMIAL PART OF THE FUNCTION 
C
      USERFUNC = POLYV(P,X,NT)+Y
      RETURN
      END


C****************************************************************
      REAL*8 FUNCTION POLYV (PM, X, NUMPT)
      DIMENSION PM(*)
C
C  EVALUATE A POLYNOMIAL
C
C  PM  - POLYNOMIAL COEFFICIENTS
C  X   - DOMAIN VALUE AT WHICH TO EVALUATE POLYNOMIAL
C  NUMPT - NUMBER OF COEFFICIENTS IN PM
C
      REAL    PM
      REAL*8  X
      INTEGER NUMPT, J

      IF (NUMPT .EQ. 0) THEN
         POLYV = 0.0
         RETURN
      END IF
      POLYV = PM(NUMPT)
      DO 10 J=NUMPT-1, 1, -1
         POLYV = POLYV*X+PM(J)
10    CONTINUE
      RETURN 
      END

C***************************************************************
      REAL*8 FUNCTION YEARHARMONIC(PM, X, NT, NH)
      REAL    PM, PI, TWOPI
      REAL*8  X, S
      INTEGER NH, NT, I, IX
      DIMENSION PM(*)
      DATA PI /3.14159265/
      TWOPI = (PI+PI)*X
C
C COMPUTE THE VALUE OF THE YEARLY HARMONIC PART OF THE FUNCTION
C
      S=0.0
      DO 10 I=1, NH
         IX=2*I+(NT-1)
         S=S+PM(IX)*SIN(TWOPI*I)+PM(IX+1)*COS(TWOPI*I)
10    CONTINUE

      YEARHARMONIC = S
      RETURN
      END


**********************************************************************
      SUBROUTINE PARTIAL (X, DER, NUMPM)
C
C  CALCULATE THE PARTIAL DERIVATIVES OF USERS FUNCTION
C  WITH RESPECT TO EACH PARAMETER
C
C  P  - ARRAY OF PARAMETERS
C  X  - VALUE AT WHICH TO FIND PARTIAL DERIVATIVES
C  DER - ARRAY OF PARTIAL DERIVATIVES
C  NH  - NUMBER OF HARMONIC TERMS IN USER FUNCTION
C  NT  - NUMBER OF POLYNOMIAL TERMS IN USER FUNCTION
C
C  CALLS FUNCTION 'PART(I,X,NT)' WHICH RETURNS THE VALUE OF THE 
C  PARTIAL DERIVATIVE WITH RESPECT TO PARAMETER I AT TIME X.
C  WRITTEN THIS WAY SINCE THE FUNCTION VARNCE NEEDS TO USE 'PART' ALSO.
C
      REAL*8 DER, PART
      REAL*8 X
      INTEGER I, NUMPM
      DIMENSION DER(NUMPM)
      DO I=1, NUMPM
         DER(I) = PART(I, X)
      END DO
      RETURN
      END

*********************************************************************
      REAL*8 FUNCTION PART (N, X)
C
C  FIND PARTIAL DERIVATIVE OF USER FUNCTION FOR PARAMTER N AT X
C
C  N - NUMBER OF THE PARAMETER
C  X - VALUE AT WHICH TO CALCULATE PARTIAL DERIVATIVE
C  NUMPT - NUMBER OF POLYNOMIAL TERMS IN USER FUNCTION
C
      REAL*8 XX, PI, DFLOAT, DSIN, DCOS
      REAL*8 X
      INTEGER N, IX, NUMPT, NUMHM, MOD
      COMMON /TERMS/ NUMPT, NUMHM
      DATA PI /3.141592654D0/
      IF (N .LE. NUMPT) THEN
	 IF (N .EQ. 1) THEN
	    PART = 1.0
         ELSE
            PART = X**(N-1)
         END IF
      ELSE
         IX = ((N-NUMPT-1) / 2 + 1)
         XX = DFLOAT(IX)*(PI+PI)*X
         IF (MOD((N-NUMPT),2) .EQ. 1 ) THEN
            PART = DSIN(XX)
         ELSE
            PART = DCOS(XX)
         END IF
      END IF
      RETURN 
      END

C**********************************************************************
      SUBROUTINE REALFT (DATA,N,ISIGN)
C
C  CALCULATES THE FOURIER TRANSFORM OF A SET OF 2N REAL-VALUED DATA POINTS.
C  REPLACES THIS DATA (WHICH IS STORED IN ARRAY DATA) BY THE POSITIVE 
C  FREQUENCY HALF OF ITS COMPLEX FOURIER TRANSFORM.  THE REAL-VALUED FIRST AND
C  LAST COMPONENTS OF THE COMPLEX TRANSFORM ARE RETURNED AS ELEMENTS DATA(1)
C  AND DATA(2) RESPECTIVELY.  N MUST BE A POWER OF 2.  THIS ROUTINE ALSO 
C  CALCULATES THE INVERSE TRANSFORM OF A COMPLEX DATA ARRAY IF IT IS THE 
C  TRANSFORM OF REAL DATA.  THE RESULT IS DIVIDED BY N SO THIS WORKS PROPERLY.
C
C  FROM 'NUMERICAL RECIPES', PRESS ET AL., 1986, PG. 400
C
      REAL*8 WR, WI, WPR, WPI, WTEMP, THETA
      REAL*8 DATA
      REAL C1, C2, WRS, WIS, H1R, H1I, H2R, H2I
      INTEGER N, ISIGN, N2P3, I, I1, I2, I3,I4
      DIMENSION DATA(2*N+2)
      THETA=6.28318530717959D0/2.0D0/DFLOAT(N)
      WR=1.0D0
      WI = 0.0D0
      C1=0.5
      IF (ISIGN .EQ. 1) THEN
         C2=-0.5
         CALL FOUR1(DATA,N,+1)
         DATA(2*N+1)=DATA(1)
         DATA(2*N+2)=DATA(2)
      ELSE
         C2=0.5
         THETA=-THETA
         DATA(2*N+1)=DATA(2)
         DATA(2*N+2)=0.0
         DATA(2)=0.0
      END IF
      WPR=-2.0D0*DSIN(0.5D0*THETA)**2
      WPI=DSIN(THETA)
      N2P3=2*N+3
      DO I=1,  N/2+1
         I1=2*I-1
         I2=I1+1
         I3=N2P3-I2
         I4=I3+1
         WRS=SNGL(WR)
         WIS=SNGL(WI)
         H1R=C1*(DATA(I1)+DATA(I3))
         H1I=C1*(DATA(I2)-DATA(I4))
         H2R=-C2*(DATA(I2)+DATA(I4))
         H2I=C2*(DATA(I1)-DATA(I3))
         DATA(I1)=H1R+WRS*H2R-WIS*H2I
         DATA(I2)=H1I+WRS*H2I+WIS*H2R
         DATA(I3)=H1R-WRS*H2R+WIS*H2I
         DATA(I4)=-H1I+WRS*H2I+WIS*H2R
         WTEMP=WR
         WR=WR*WPR-WI*WPI+WR
         WI=WI*WPR+WTEMP*WPI+WI
      END DO
      IF (ISIGN.EQ.1) THEN
         DATA(2)=DATA(2*N+1)
         DO I=1, N*2+1
            DATA(I)=DATA(I)/FLOAT(N)
         END DO
      ELSE
         CALL FOUR1(DATA,N,-1)
      ENDIF
      RETURN
      END

C************************************************************************
      SUBROUTINE FOUR1(DATA,NN,ISIGN)
C
C  RELACES DATA BY ITS DISCRETE FOURIER TRANSFORM, IF ISIGN IS INPUT AS 1;
C  OR RELACES DATA BY NN TIMES ITS INVERSE DISCRETE FOURIER TRANSFORM IF
C  ISIGN IS INPUT AS -1.  DATA IS A COMPLEX ARRAY OF LENGTH NN OR, 
C  EQUIVALENTLY, A REAL ARRAY OF LENGTH 2*NN.  NN MUST BE AN INTEGER POWER
C  OF 2 (THIS IS NOT CHECKED FOR).
C
C  FROM 'NUMERICAL RECIPES' BY PRESS ET AL., 1986, PG 394
C
      REAL*8 WR,WI,WPR,WPI,WTEMP,THETA
      REAL*8 DATA
      REAL TEMPR, TEMPI
      INTEGER NN, ISIGN, N, J, I, M, ISTEP, MMAX
      DIMENSION DATA(2*NN)
      N=2*NN
      J=1
      DO I=1,N,2
         IF (J.GT.I) THEN
            TEMPR=DATA(J)
            TEMPI=DATA(J+1)
            DATA(J)=DATA(I)
            DATA(J+1)=DATA(I+1)
            DATA(I)=TEMPR
            DATA(I+1)=TEMPI
         END IF
         M=N/2
10       IF ((M.GE.2) .AND. (J.GT.M)) THEN
            J=J-M
            M=M/2
            GOTO 10
         END IF
         J=J+M
      END DO
      MMAX=2
20    IF (N.GT.MMAX) THEN
         ISTEP=2*MMAX
         THETA=6.28318530717959D0/(ISIGN*MMAX)
         WPR=-2.0D0*DSIN(0.5D0*THETA)**2
         WPI=DSIN(THETA)
         WR=1.D0
         WI=0.D0
         DO M=1,MMAX,2
            DO I=M,N,ISTEP
               J=I+MMAX
               TEMPR=SNGL(WR)*DATA(J)-SNGL(WI)*DATA(J+1)
               TEMPI=SNGL(WR)*DATA(J+1)+SNGL(WI)*DATA(J)
               DATA(J)=DATA(I)-TEMPR
               DATA(J+1)=DATA(I+1)-TEMPI
               DATA(I)=DATA(I)+TEMPR
               DATA(I+1)=DATA(I+1)+TEMPI
            END DO
            WTEMP=WR
            WR=WR*WPR-WI*WPI+WR
            WI=WI*WPR+WTEMP*WPI+WI
         END DO
         MMAX=ISTEP
         GOTO 20
      END IF
      RETURN
      END

C******************************************************************* 
      SUBROUTINE MEANS ( ARRAY, RMEAN, SDEV, N)
C
C     CALCULATE THE MEAN AND STANDARD DEVIATION OF AN ARRAY
C
      REAL*8 ARRAY
      REAL RMEAN, SDEV, SUM, SUMSQ
      INTEGER N, I
      DIMENSION ARRAY(N)

      IF (N .LT. 1) PAUSE 'ROUTINE MEANS. N < 1'
      SUM=0.
      SUMSQ=0.
      SDEV=0.
      DO I=1,N
         SUM=SUM+ARRAY(I)
         SUMSQ=SUMSQ+ARRAY(I)*ARRAY(I)
      END DO
C
      RMEAN=SUM/FLOAT(N)
      IF (N .GT. 1) SDEV=SQRT((SUMSQ-SUM*SUM/N)/FLOAT(N-1))
      RETURN
      END


C*******************************************************************
      SUBROUTINE GAUSSJ(A,N,NP,B,M,MP)
      INTEGER NMAX, I, J, IROW, ICOL, K, IPIV, INDXR, INDXC
      INTEGER NP, M, N, MP, L, LL
      PARAMETER (NMAX=50)
      REAL*8 A, B, DUM, BIG, PIVINV, DABS
      DIMENSION A(NP,NP),B(NP,MP),IPIV(NMAX),INDXR(NMAX),INDXC(NMAX)
      DO 11 J=1,N
        IPIV(J)=0
11    CONTINUE
      DO 22 I=1,N
        BIG=0.D0
        DO 13 J=1,N
          IF(IPIV(J).NE.1)THEN
            DO 12 K=1,N
              IF (IPIV(K).EQ.0) THEN
                IF (DABS(A(J,K)).GE.BIG)THEN
                  BIG=DABS(A(J,K))
                  IROW=J
                  ICOL=K
                ENDIF
              ELSE IF (IPIV(K).GT.1) THEN
                PAUSE 'Singular matrix'
              ENDIF
12          CONTINUE
          ENDIF
13      CONTINUE
        IPIV(ICOL)=IPIV(ICOL)+1
        IF (IROW.NE.ICOL) THEN
          DO 14 L=1,N
            DUM=A(IROW,L)
            A(IROW,L)=A(ICOL,L)
            A(ICOL,L)=DUM
14        CONTINUE
          DO 15 L=1,M
            DUM=B(IROW,L)
            B(IROW,L)=B(ICOL,L)
            B(ICOL,L)=DUM
15        CONTINUE
        ENDIF
        INDXR(I)=IROW
        INDXC(I)=ICOL
        IF (A(ICOL,ICOL).EQ.0.) PAUSE 'Singular matrix.'
        PIVINV=1./A(ICOL,ICOL)
        A(ICOL,ICOL)=1.
        DO 16 L=1,N
          A(ICOL,L)=A(ICOL,L)*PIVINV
16      CONTINUE
        DO 17 L=1,M
          B(ICOL,L)=B(ICOL,L)*PIVINV
17      CONTINUE
        DO 21 LL=1,N
          IF(LL.NE.ICOL)THEN
            DUM=A(LL,ICOL)
            A(LL,ICOL)=0.
            DO 18 L=1,N
              A(LL,L)=A(LL,L)-A(ICOL,L)*DUM
18          CONTINUE
            DO 19 L=1,M
              B(LL,L)=B(LL,L)-B(ICOL,L)*DUM
19          CONTINUE
          ENDIF
21      CONTINUE
22    CONTINUE
      DO 24 L=N,1,-1
        IF(INDXR(L).NE.INDXC(L))THEN
          DO 23 K=1,N
            DUM=A(K,INDXR(L))
            A(K,INDXR(L))=A(K,INDXC(L))
            A(K,INDXC(L))=DUM
23        CONTINUE
        ENDIF
24    CONTINUE
      RETURN
      END


C**********************************************************
      SUBROUTINE ADJUSTEND (X, Y, N, CUTOFF, A, B)
      REAL*8 X, Y
      REAL A, B
      INTEGER N, CUTOFF
      DIMENSION X(N), Y(N)

      INTEGER MAXSIZE
      PARAMETER (MAXSIZE=8192*2+2)
      REAL*8 XP(MAXSIZE), YP(MAXSIZE)
      REAL C, SIGA, SIGB, CHI2
      INTEGER K, I

      A = 0.0
      B = 0.0
      IF (X(N) - X(1) .LT. FLOAT(CUTOFF)/365.) RETURN

      C = FLOAT(CUTOFF)/365./4.
      K = 0
      DO I=1, N
         IF ((X(I) .LE. X(1)+C) .OR. (X(I) .GE. X(N)-C)) THEN
            K=K+1
            XP(K) = X(I)
            YP(K) = Y(I)
         END IF
      END DO


      CALL FIT(XP,YP,K,A,B,SIGA,SIGB,CHI2)


      DO I=1, N
         Y(I) = Y(I) - (A + B*X(I))
      END DO
      RETURN
      END

C*************************************************************
      SUBROUTINE FIT(X,Y,NDATA,A,B,SIGA,SIGB,CHI2)
      REAL*8 X, Y
      REAL A, B, SIGA, SIGB, CHI2
      INTEGER NDATA
      DIMENSION X(NDATA),Y(NDATA)

      REAL SX, SY, ST2, SS, T,SIGDAT, SXOSS
      INTEGER I

      siga=0.0
      sigb=0.0
      chi2=0.0
      if (ndata .le. 1) then
         a = 0.0
         b = 0.0
         return
      end if
      
      if (ndata .eq. 2) then
         b = (y(2)-y(1))/(x(2)-x(1))
	 a = (y(1)-x(1)*b)
         return
      end if

      SX=0.
      SY=0.
      ST2=0.
      B=0.
        DO 12 I=1,NDATA
          SX=SX+X(I)
          SY=SY+Y(I)
12      CONTINUE
        SS=FLOAT(NDATA)
      SXOSS=SX/SS
        DO 14 I=1,NDATA
          T=X(I)-SXOSS
          ST2=ST2+T*T
          B=B+T*Y(I)
14      CONTINUE
      B=B/ST2
      A=(SY-SX*B)/SS
      SIGA=SQRT((1.+SX*SX/(SS*ST2))/SS)
      SIGB=SQRT(1./ST2)
      CHI2=0.
        DO 15 I=1,NDATA
          CHI2=CHI2+(Y(I)-A-B*X(I))**2
15      CONTINUE
        SIGDAT=SQRT(CHI2/(NDATA-2))
        SIGA=SIGA*SIGDAT
        SIGB=SIGB*SIGDAT
      RETURN
      END
