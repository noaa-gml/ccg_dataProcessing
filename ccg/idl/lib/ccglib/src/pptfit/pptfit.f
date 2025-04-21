      PROGRAM PPTFIT
ccccc 
ccccc  Modified CO2FIT so that it can be called from
ccccc  within IDL - kam 3 April 1995.
ccccc
ccccc  Fitting routine
ccccc
ccccc  by Pieter Tans 
ccccc  Dec 1986 
ccccc
ccccc  Nov 1991 ported to HP Unix, removed Dissplay graphics, added
ccccc           bootstrap sampling of flask sites.
ccccc
ccccc  Mar 1994 modified to accept files of extended data
ccccc
ccccc ******************************************************************
ccccc  On HP 9000 Series 700 workstations compile as follows
ccccc
ccccc       f77 pptfit.f +e -Wall -O -o pptfit
ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
ccccc 
ccccc  INPUT PARAMETERS
ccccc
ccccc  X 	- Array containing sample positions
ccccc  Y	- Array containing sample values
ccccc  NW	- Array containing each sample value weight
ccccc  NXY 	- Number of elements in X,Y, and WTS
ccccc  XPRED 	- Array of positions for constructing predicted values
ccccc
ccccc  This line is required to parse command-line
ccccc  arguments. kam.
ccccc
      PARAMETER(NDMAX=150,NWMAX=2000,NFFT=1024)
      PARAMETER(CUTOFF=2.0,NEXP=6,NDERIV=1)
      PARAMETER(PI=3.14159)

      INTEGER NWMAX,NDMAX
      INTEGER NFFT,NEXP,NDERIV
      INTEGER COUNT

      INTEGER NXY,NREP
      INTEGER NPRED

      REAL*8 DX
      REAL CUTOFF,PI
      REAL LAT(NDMAX)
      REAL X(NDMAX),Y(NDMAX),NW(NDMAX)
      REAL XPRED(NDMAX),YPRED(NDMAX)
      REAL XX(NWMAX),YY(NWMAX),LATSHIFT(11)
      REAL YFFT(NFFT),XCURVE(NFFT)

      CHARACTER*6 idat,ipred,idx
      CHARACTER*80 datfile,predfile

      DATA LATSHIFT/ 0.00, 0.01,-0.01, 0.02,-0.02, 
     1               0.03,-0.03, 0.04,-0.04, 0.05,-0.05/
ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc  Files:  Input:  Assimilated data in files listed in FILESLIST.
ccccc                  Number of good data points per site and sd of residuals 
ccccc                  every year in files listed in WTSLIST
ccccc          Output: OUTSRFC, DATAOUT, OUTWGT
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc  
ccccc     Fits curves to the biweekly meridional gradient defined by the smooth
ccccc  curve fits to the flask station data.  The station data can be in any
ccccc  latitude order.   The meridional gradient fits have the following 
ccccc  properties:
ccccc  1. (Optional)  Either zero derivative at the poles (in sine(lat.)
ccccc     coordinates) so that the second derivative in regular polar coord.
ccccc     is zero, or the 'natural' derivative at the poles.  This option is
ccccc     set with NDERIV=0,1 respectively.
ccccc  2. The fits should interpolate in regions where there is no data, like
ccccc     between SMO and AMS.
ccccc  3. The stations should be given weight inversely proportional to the
ccccc     standard deviation of the data.
ccccc  Property 1 is taken care of by extending the data beyond sine(lat)=
ccccc  +-1 thru mirroring with respect to the poles and fitting the extended
ccccc  data set.  Property 2 rules out global fits with sets of orthogonal
ccccc  functions because they will result in spurious wiggles in areas without
ccccc  any data.  Instead, I will use digital filtering of straight line 
ccccc  segments connecting the points.  To take care of property 3, each 
ccccc  station will be represented by a number (inv. proportional to st. dev.)
ccccc  of points spread out over an interval DX in sine(lat) space, centered
ccccc  on the original point.  The straight line segments connect all these 
ccccc  overlapping sets of points in order.  Missing data, indicated by 0.0
ccccc  or 999.99, will be skipped in each curve fit.  Results of the fits are
ccccc  stored as 41-point (including sin=+-1 endpoints) characterizations of
ccccc  the curves in sin(lat) space, at biweekly intervals.
ccccc     The fitting process is done in two steps.  First a rough fit is done
ccccc  that gives the general overall latitude trend of the data.  Then the 
ccccc  assigned points over DX are given a slope according to the rough trend,
ccccc  so that in the second, final, fit a 'staircase' effect is avoided.  The
ccccc  second fit is also more flexible (higher freq. cutoff) than the first.
ccccc
ccccc  subroutines:
ccccc  FFTFLTR     Performs frequency-domain filtering on an array
ccccc  REALFT      FFT in both directions for real input. Called by FFTFLTR
ccccc  FOUR1       Replaces an array by its complex discrete F-transform
ccccc              Called by REALFT
ccccc  SORT2       Sorts an array into ascending numerical order while making
ccccc              corresponding changes in a second array.
ccccc  SEPART      Separates identical values in an array by small amounts
ccccc  HUNT        Locates between which array values a given quantity falls
ccccc              in an ordered array.
ccccc       REALFT, FOUR1,SORT2, HUNT, are straight from: Numerical Recipes, 
ccccc       W.H. Press et al., Cambridge U. Press, 1986.
ccccc            
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc  variables:
ccccc 
ccccc  L           running latitude variable
ccccc  NXY         max of L. Number of flask stations in 'network'. 
ccccc  INDEX       keeps track of which data file
ccccc  INDX        keeps track of which weight file
ccccc  COUNT       keeps count of how often the same latitude is repeated
ccccc  DX          width in sin(latitude) space over which points are spread
ccccc              out for each station.
ccccc  NW(NXY)     number of points for each station ("weight").
ccccc  NWMAX       max number of points on the extended interval, after 
ccccc              each station has been given its NW(L) points.
ccccc  NREP        number of replicates of data of single station given by NW
ccccc  NFFT        number of points (integral power of 2) in the FFT.
ccccc  CUTOFF      cycles per unit of sin(lat) interval where filter cuts off.
ccccc  NEXP        steepness parameter of the cutoff. 
ccccc  NDERIV      parameter for zero deriv.(0) or free der.(1) at poles. 
ccccc  X(NXY)      sine latitude values as a function of stations(L). 
ccccc  Y(NXY)      CO2 values as a function of stations(L). 
ccccc  LAT(NXY)    sin(lat) coordinates of the stations (in order of Y)
ccccc  XX(NWMAX)   x-coordinates of extended set of weighted data points. 
ccccc  YY(NWMAX)   y-coordinates of same. 
ccccc              zeroes in Y(L) are ignored in constructing XX, YY. 
ccccc  NTALLY      number of points in XX and YY. 
ccccc  YFFT(NFFT)  extended array constructed from straight line segments 
ccccc              connecting the YY's and extended from -2. To +2. 
ccccc              includes end points. Will be transformed,filtered and
ccccc              back-transformed.
ccccc  XCURVE(NFFT) x-coordinates of YFFT
ccccc  DUMMY       array to protect xcurve from being corrupted by FFTFLTR
ccccc  YCRV(41)    samples from the final fitted curve for output to file
ccccc  XDIST       x-spacing between assigned points for each station.
ccccc  YDIST       y-spacing of same. Reflects the overall slope of the trend.
ccccc  SLOPE       local steepness of the rough fit.
ccccc  K1,K2       locations in the filtered curve from which slope is found. 
ccccc 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
ccccc
ccccc Get command line arguments
ccccc
      call getarg (1, datfile)
      call getarg (2, idat)
      call getarg (3, predfile)
      call getarg (4, ipred)
      call getarg (5, idx)
     
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
ccccc
ccccc Miscellaneous initialization
ccccc
      READ (idat, '(I6)') NXY
      READ (ipred, '(I6)') NPRED
      READ (idx, '(F6)') DX
ccccc
ccccc   WRITE(6,*),NXY,NPRED,idx,DX
ccccc 
ccccc Read X/Y data
ccccc 
      OPEN(UNIT=1,FILE=datfile)
      DO 80 L=1,NXY
        READ(1,'(3(F12.6))') X(L),Y(L),NW(L)
ccccc
ccccc  Search if this latitude has already been assigned. If so, shift it
ccccc  by 0.01.  Fit program sorts sites by latitude
ccccc
        COUNT=0
        DO 81 K=1,L
          IF(ABS(X(K)-X(L)) .LT. 1.0E-08) COUNT=COUNT+1
81        CONTINUE
        LAT(L)=X(L)+LATSHIFT(COUNT)
ccccc   WRITE(6,*),X(L),LAT(L),Y(L),NW(L)
80    CONTINUE
      CLOSE(UNIT=1)
ccccc
ccccc Read X predict file
ccccc 
      OPEN(UNIT=1,FILE=predfile)
      DO 90 L=1,NPRED
        READ(1,'(F12.6)') XPRED(L)
ccccc   WRITE(6,*),XPRED(L)
90    CONTINUE
      CLOSE(UNIT=1)
ccccc
ccccc  Start main loop. Two fits are made for each quasi-weekly time point.
ccccc 
ccccc  First throw out the stations with data missing,
ccccc  then assign points to the remaining stations according to
ccccc  their weight. Initially without a slope. 
ccccc 
      NTALLY=0
      DO 150 L=1,NXY 
        IF(ABS(Y(L)) .LT. 0.0001) GOTO 150 
ccccc
ccccc  Offset sine of latitude at poles by a small amount
ccccc  so that no "real" site is at -1 or +1.
ccccc  November 1996 - kam,ppt.
ccccc
        IF (LAT(L) .EQ. 1.0) LAT(L)=LAT(L)-1.0E-06
        IF (LAT(L) .EQ. -1.0) LAT(L)=LAT(L)+1.0E-06

        NREP=MAX0(INT(NW(L)+0.499),1)
        IF(NREP .EQ. 0) STOP 'Check site weights'
        IF (NREP .EQ. 1) THEN
          XDIST=0.
        ELSE
          XDIST=DX/(NREP-1.) 
        END IF
        START=-(NREP+1.)/2.
        DO 145 NN=1,NREP 
          XX(NTALLY+1)=LAT(L)+(START+FLOAT(NN))*XDIST
          YY(NTALLY+1)=Y(L) 
          IF (XX(NTALLY+1) .LE. -1.) GO TO 145
          IF (XX(NTALLY+1) .GE. 1.) GO TO 145
          NTALLY=NTALLY+1 
145     CONTINUE
150   CONTINUE
ccccc
ccccc  Add endpoints to xx and yy.
ccccc  Connect them by straight lines.
ccccc  Expand the results to +-2. By mirroring with respect to the poles
ccccc  for zero deriv. or simple extrapolation for free derivative. 
ccccc 
      CALL SORT2(NTALLY,XX,YY)
      CALL SEPART(NTALLY,XX)
      DO 160 K=NTALLY,1,-1
        XX(K+1)=XX(K) 
        YY(K+1)=YY(K) 
160   CONTINUE
      XX(1)=-1. 
      XX(NTALLY+2)=1. 
      YY(NTALLY+2)=YY(NTALLY+1) 
      NTALLY=NTALLY+2 
c      OPEN(UNIT=1,FILE="/users/ken/model/assim/src/debug")
c      DO 999 K=1,NTALLY
c        WRITE(1,*) K,XX(K),YY(K)
c999   CONTINUE
c      CLOSE(UNIT=1)
ccccc  Construct equally spaced curve for FFT by linear interpolation.
      NBGN=NFFT/4+1 
      NEND=3*NFFT/4 
      STEP=4./(NFFT-1.) 
      J=1 
      DO 170 K=NBGN,NEND
        XCURVE(K)=-2.+(K-1.)*STEP 
        CALL HUNT(XX,NTALLY,XCURVE(K),J)
        YFFT(K)=(XCURVE(K)-XX(J))*(YY(J+1)-YY(J))/(XX(J+1)-XX(J)) 
        YFFT(K)=YY(J)+YFFT(K) 
170   CONTINUE
      IF (NDERIV .EQ. 0) THEN 
ccccc  Zero derivative at poles.  Mirror with respect to poles.
        DO 180 K=1,NBGN-1 
          XCURVE(K)=-2.+(K-1.)*STEP
          YFFT(K)=YFFT(NBGN+NFFT/4-K) 
180     CONTINUE
        DO 190 K=NEND+1,NFFT
          XCURVE(K)=-2.+(K-1.)*STEP
          YFFT(K)=YFFT(2*NEND+1-K)
190     CONTINUE
      ELSE
ccccc  Free derivative at poles.  Extrapolate beyond poles.
        YSTART=0. 
        I=0
        DO 182 K=1,50
          IF(XX(K) .LT. -0.9) THEN
            YSTART=YSTART+YY(K) 
            I=I+1
          END IF
182     CONTINUE
        YSTART=YSTART/FLOAT(I) 
        DO 181 K=1,NBGN-1 
          XCURVE(K)=-2.+(K-1.)*STEP
          YFFT(K)=YSTART
181     CONTINUE
        YEND=0. 
        I=0
        DO 192 K=NTALLY,NTALLY-25,-1
          IF(XX(K) .GT. 0.9) THEN
            YEND=YEND+YY(K) 
            I=I+1
          END IF
192     CONTINUE
        YEND=YEND/FLOAT(I)
        DO 191 K=NEND+1,NFFT
          XCURVE(K)=-2.+(K-1.)*STEP
          YFFT(K)=YEND
191       CONTINUE
      END IF
ccccc 
ccccc  First round, rough low-pass filtering, with a low-frequency cutoff.
ccccc 
      CUT=MIN(2.*CUTOFF,4.) 
      CALL FFTFLTR(YFFT,NFFT,CUT,NEXP)
ccccc 
ccccc  Second round starts, to get a more detailed fit. 
ccccc  Construct XX and YY again, this time with a slope in the assigned
ccccc  points.
ccccc 
      SLOPE1=(YFFT(NBGN+20)-YFFT(NBGN))/20. 
      SLOPE2=(YFFT(NEND)-YFFT(NEND-20))/20. 
      NTALLY=0
      DO 230 L=1,NXY 
        IF (ABS(Y(L)) .LT. 0.0001) GO TO 230 
        K1=1+INT((LAT(L)-DX/2.+2.)/STEP)
        K2=1+INT((LAT(L)+DX/2.+2.)/STEP)
        SLOPE=YFFT(K2)-YFFT(K1) 
        NREP=MAX0(INT(NW(L)+0.499),1)
        IF (NREP .EQ. 1) THEN
          XDIST=0.
          YDIST=0.
        ELSE
          XDIST=DX/(NREP-1.) 
          YDIST=SLOPE/(NREP-1.)
        END IF
        START=-(NREP+1.)/2.
        DO 220 NN=1,NREP
          XX(NTALLY+1)=LAT(L)+(START+NN)*XDIST
          IF (XX(NTALLY+1) .LE. -1.) GO TO 220
          IF (XX(NTALLY+1) .GE. 1) GO TO 220
          YY(NTALLY+1)=Y(L)+(START+NN)*YDIST
          NTALLY=NTALLY+1 
220     CONTINUE
230   CONTINUE
ccccc 
ccccc  Sort YY and XX in order, add endpoints, connect them by straight 
ccccc  lines and expand the results to +-2.
ccccc 
      CALL SORT2(NTALLY,XX,YY)
      CALL SEPART(NTALLY,XX)
      DO 240 K=NTALLY,1,-1
        XX(K+1)=XX(K) 
        YY(K+1)=YY(K) 
240   CONTINUE
      XX(1)=-1. 
      XX(NTALLY+2)=1. 
      YY(NTALLY+2)=YY(NTALLY+1) 
      NTALLY=NTALLY+2 
      J=1 
      DO 250 K=NBGN,NEND
        CALL HUNT(XX,NTALLY,XCURVE(K),J)
        YFFT(K)=(XCURVE(K)-XX(J))*(YY(J+1)-YY(J))/(XX(J+1)-XX(J)) 
        YFFT(K)=YY(J)+YFFT(K) 
250   CONTINUE
      IF (NDERIV .EQ. 0) THEN 
ccccc  Zero derivative at poles
        DO 260 K=1,NBGN-1 
          YFFT(K)=YFFT(NBGN+NFFT/4-K) 
260     CONTINUE
        DO 270 K=NEND+1,NFFT
          YFFT(K)=YFFT(2*NEND+1-K)
270     CONTINUE
      ELSE
ccccc  Free derivative at poles
        DO 261 K=1,NBGN-1 
          YFFT(K)=YSTART+(K-NBGN)*SLOPE1
261     CONTINUE
        DO 271 K=NEND+1,NFFT
          YFFT(K)=YEND+(K-NEND)*SLOPE2
271     CONTINUE
      END IF
ccccc 
ccccc  Final fit, now using filtering with the cutoff originally called for.
ccccc  Write results to file 'CO2srfc.xx' in increments corresponding to 40
ccccc  intervals between +-1 and plot results between +-1.
ccccc 
      CUT=4.*CUTOFF 
      CALL FFTFLTR(YFFT,NFFT,CUT,NEXP)
ccccc  Apparently the call to FFTFLTR can destroy some values of XCURVE....???
      DO 280 K=1,NFFT
        XCURVE(K)=-2.+(K-1.)*STEP
280   CONTINUE
      J=NFFT/4
      DO 290 L=1,NPRED
        CALL HUNT(XCURVE,NFFT,XPRED(L),J) 
        YPRED(L)=YFFT(J) 
290   CONTINUE
ccccc
ccccc Write results to predict file
ccccc
      OPEN(UNIT=2,FILE=predfile)
      DO 300 L=1,NPRED
        WRITE(2,'(2(F12.6))') XPRED(L),YPRED(L) 
300   CONTINUE
      CLOSE (UNIT=2)
      END
ccccc
ccccc
      SUBROUTINE FFTFLTR(X,NN,CUTOFF,NEXP)
CCCCC 
CCCCC  DIGITAL FILTERING IN THE FREQUENCY DOMAIN. THE INPUT ARRAY X(NN) 
CCCCC  FIRST GETS ITS TREND SUBTRACTED,THEN IS FOURIER TRANSFORMED. THE 
CCCCC  TRANSFORM IS MULTIPLIED BY A BUTTERWORTH FILTER TRANSFER FUNCTION
CCCCC  WITH FREQUENCY ROLL-OFF SPECIFIED BY 'CUTOFF' AND 'NEXP'. THE
CCCCC  PRODUCT IS BACK-TRANSFORMED INTO THE TIME DOMAIN, THE TREND IS 
CCCCC  ADDED BACK IN THE RESULT IS RETURNED AS X. THE DIMENSION OF THE
CCCCC  ARRAY NN NEEDS TO BE AN INTEGRAL POWER OF 2. 
CCCCC 
      REAL X(NN)
      FILTER(K)=1./(1.+(K/CUTOFF)**NEXP)
      RANGE=X(NN)-X(1)
      F1=RANGE/(NN-1.)
      FIRST=X(1)
      DO 100 K=1,NN 
        X(K)=X(K)-FIRST-F1*(K-1.) 
100     CONTINUE
      CALL REALFT(X,NN/2,1) 
      DO 110 K=2,NN/2 
        X(2*K-1)=X(2*K-1)*FILTER(K-1) 
        X(2*K)=X(2*K)*FILTER(K-1) 
110     CONTINUE
      X(2)=X(2)*FILTER(NN/2)
      CALL REALFT(X,NN/2,-1)
      DO 120 K=1,NN 
        X(K)=X(K)*2./NN+FIRST+F1*(K-1)
120     CONTINUE
      RETURN
      END 
      SUBROUTINE SEPART(NN,X) 
CCCCC 
CCCCC  THE SPLINE INTERPOLATION ROUTINES NEED ORDERED ARRAYS. IF TWO
CCCCC  CONSECUTIVE ARRAY VALUES ARE THE SAME, THIS ROUTINE SEPARATES
CCCCC  THEM BY A LITTLE BIT.
CCCCC 
      REAL X(NN)
      DO 120 NTRY=1,5
        K=0 
        M=1
        DO 110 N=2,NN 
          IF((X(N)-X(N-M)) .LT. 1.E-6) THEN 
            K=K+1 
            M=M+1
            X(N)=X(N-M+1)+(M-1)*1.1E-6
          ELSE
            M=1
          END IF
110       CONTINUE
        IF (K .EQ. 0) RETURN
120     CONTINUE
      STOP ' SEPART-STILL DOUBLE VALUES OR ARRAY NOT ORDERED CORRECTLY' 
      END 
      SUBROUTINE SORT2(N,RA,RB) 
      DIMENSION RA(N),RB(N) 
      L=N/2+1 
      IR=N
10    CONTINUE
        IF(L.GT.1)THEN
          L=L-1 
          RRA=RA(L) 
          RRB=RB(L) 
        ELSE
          RRA=RA(IR)
          RRB=RB(IR)
          RA(IR)=RA(1)
          RB(IR)=RB(1)
          IR=IR-1 
          IF(IR.EQ.1)THEN 
            RA(1)=RRA 
            RB(1)=RRB 
            RETURN
          ENDIF 
        ENDIF 
        I=L 
        J=L+L 
20      IF(J.LE.IR)THEN 
          IF(J.LT.IR)THEN 
            IF(RA(J).LT.RA(J+1))J=J+1 
          ENDIF 
          IF(RRA.LT.RA(J))THEN
            RA(I)=RA(J) 
            RB(I)=RB(J) 
            I=J 
            J=J+J 
          ELSE
            J=IR+1
          ENDIF 
        GO TO 20
        ENDIF 
        RA(I)=RRA 
        RB(I)=RRB 
      GO TO 10
      END 
      SUBROUTINE INDEXX(N,ARRIN,INDX)
      DIMENSION ARRIN(N),INDX(N)
      DO 11 J=1,N
        INDX(J)=J
11    CONTINUE
      L=N/2+1
      IR=N
10    CONTINUE
        IF(L.GT.1)THEN
          L=L-1
          INDXT=INDX(L)
          Q=ARRIN(INDXT)
        ELSE
          INDXT=INDX(IR)
          Q=ARRIN(INDXT)
          INDX(IR)=INDX(1)
          IR=IR-1
          IF(IR.EQ.1)THEN
            INDX(1)=INDXT
            RETURN
          ENDIF
        ENDIF
        I=L
        J=L+L
20      IF(J.LE.IR)THEN
          IF(J.LT.IR)THEN
            IF(ARRIN(INDX(J)).LT.ARRIN(INDX(J+1)))J=J+1
          ENDIF
          IF(Q.LT.ARRIN(INDX(J)))THEN
            INDX(I)=INDX(J)
            I=J
            J=J+J
          ELSE
            J=IR+1
          ENDIF
        GO TO 20
        ENDIF
        INDX(I)=INDXT
      GO TO 10
      END
      SUBROUTINE HUNT(XX,N,X,JLO) 
      DIMENSION XX(N) 
      LOGICAL ASCND 
      ASCND=XX(N).GT.XX(1)
      IF(JLO.LE.0.OR.JLO.GT.N)THEN
        JLO=0 
        JHI=N+1 
        GO TO 3 
      ENDIF 
      INC=1 
      IF(X.GE.XX(JLO).EQV.ASCND)THEN
1       JHI=JLO+INC 
        IF(JHI.GT.N)THEN
          JHI=N+1 
        ELSE IF(X.GE.XX(JHI).EQV.ASCND)THEN 
          JLO=JHI 
          INC=INC+INC 
          GO TO 1 
        ENDIF 
      ELSE
        JHI=JLO 
2       JLO=JHI-INC 
        IF(JLO.LT.1)THEN
          JLO=0 
        ELSE IF(X.LT.XX(JLO).EQV.ASCND)THEN 
          JHI=JLO 
          INC=INC+INC 
          GO TO 2 
        ENDIF 
      ENDIF 
3     IF(JHI-JLO.EQ.1)RETURN
      JM=(JHI+JLO)/2
      IF(X.GT.XX(JM).EQV.ASCND)THEN 
        JLO=JM
      ELSE
        JHI=JM
      ENDIF 
      GO TO 3 
      END 
      SUBROUTINE REALFT(DATA,N,ISIGN) 
      DOUBLE PRECISION WR,WI,WPR,WPI,WTEMP,THETA
      DIMENSION DATA(*) 
      THETA=6.28318530717959D0/2.0D0/DBLE(N)
      WR=1.0D0
      WI=0.0D0
      C1=0.5
      IF (ISIGN.EQ.1) THEN
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
      ENDIF 
      WPR=-2.0D0*DSIN(0.5D0*THETA)**2 
      WPI=DSIN(THETA) 
      N2P3=2*N+3
      DO 11 I=1,N/2+1 
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
11    CONTINUE
      IF (ISIGN.EQ.1) THEN
        DATA(2)=DATA(2*N+1) 
      ELSE
        CALL FOUR1(DATA,N,-1) 
      ENDIF 
      RETURN
      END 
      SUBROUTINE FOUR1(DATA,NN,ISIGN) 
      DOUBLE PRECISION WR,WI,WPR,WPI,WTEMP,THETA
      DIMENSION DATA(*) 
      N=2*NN
      J=1 
      DO 11 I=1,N,2 
        IF(J.GT.I)THEN
          TEMPR=DATA(J) 
          TEMPI=DATA(J+1) 
          DATA(J)=DATA(I) 
          DATA(J+1)=DATA(I+1) 
          DATA(I)=TEMPR 
          DATA(I+1)=TEMPI 
        ENDIF 
        M=N/2 
1       IF ((M.GE.2).AND.(J.GT.M)) THEN 
          J=J-M 
          M=M/2 
        GO TO 1 
        ENDIF 
        J=J+M 
11    CONTINUE
      MMAX=2
2     IF (N.GT.MMAX) THEN 
        ISTEP=2*MMAX
        THETA=6.28318530717959D0/(ISIGN*MMAX) 
        WPR=-2.D0*DSIN(0.5D0*THETA)**2
        WPI=DSIN(THETA) 
        WR=1.D0 
        WI=0.D0 
        DO 13 M=1,MMAX,2
          DO 12 I=M,N,ISTEP 
            J=I+MMAX
            TEMPR=SNGL(WR)*DATA(J)-SNGL(WI)*DATA(J+1) 
            TEMPI=SNGL(WR)*DATA(J+1)+SNGL(WI)*DATA(J) 
            DATA(J)=DATA(I)-TEMPR 
            DATA(J+1)=DATA(I+1)-TEMPI 
            DATA(I)=DATA(I)+TEMPR 
            DATA(I+1)=DATA(I+1)+TEMPI 
12        CONTINUE
          WTEMP=WR
          WR=WR*WPR-WI*WPI+WR 
          WI=WI*WPR+WTEMP*WPI+WI
13      CONTINUE
        MMAX=ISTEP
      GO TO 2 
      ENDIF 
      RETURN
      END
