      SUBROUTINE CALCMULT(MULT, LIMX, WRAPX, MODD, MEVEN, E, FLUX)
	  
      INTEGER LIMX, WRAPX, SZ/1/
      INTEGER I/1/, NEIGH/1/
c$$$ CHANGED FLUX FROM DOUBLE COMPLEX TO DOUBLE PRECISION
      DOUBLE PRECISION E, FLUX
      DOUBLE COMPLEX ZEROC / 0.0 / 
      DOUBLE COMPLEX CNUM
c$$$  May need to move this
      DOUBLE COMPLEX MODD(2*LIMX, 2*LIMX), MEVEN(2*LIMX, 2*LIMX),
     + MULT(2*LIMX, 2*LIMX)

      IF ((MOD(LIMX,2) .NE. 0)) THEN
         WRITE (*,*) 'ERROR: LIMX must be even for physical results'
         STOP 
      ENDIF
c$$$  HAMMERTIME! Program terminates here if LIMX is odd

      SZ = 2 * LIMX
      
      CALL ZLASET ('A', SZ, SZ, ZEROC, ZEROC, MODD, SZ)
      CALL ZLASET ('A', SZ, SZ, ZEROC, ZEROC, MEVEN, SZ)


C$$$ FIRST ROW IS EVEN - WRAPX MAKES NO DIFF, SECOND ROW NOT, ETC.
C$$$ - WHAT MATTERS IS WHICH ROW IT IS CENTRED ON
C$$$ THERE ARE 2 TRANSFER MATRICES TO GENERATE
C$$$ THERE ARE 4 BLOCK SUBMATRICES TO FILL
C$$$ MODD DOESN'T DEPEND ON XWRAPPING, MEVEN DOES.   '
      DO I = 1, LIMX
C$$$ FILL TOP-RIGHT SUBMATRIX
         MODD(I, LIMX+I)=1
         MEVEN(I, LIMX+I)=1
C$$$ FILL BOTTOM-LEFT SUBMATRIX
         CALL ZPOLAR(2*FLUX*I, CNUM)
         MODD(I+LIMX, I)=-1*CNUM
         MEVEN(I+LIMX, I)=-1*CNUM
C$$$ FILL BOTTOM-RIGHT SUBMATRIX
         CALL ZPOLAR(FLUX*I, CNUM)
         MODD(LIMX+I,LIMX+I)=E*CNUM
         MEVEN(LIMX+I,LIMX+I)=E*CNUM

c$$$  Double-check this multiplication analytically at some stage

C$$$  THE FOLLOWING CODE WAS MODIFIED --- AVS
C$$$  NEIGHBOURING SITE FOR ODD ROW, ON THE LEFT/RIGHT, DEPENDING ON I
         NEIGH = I + (2*MOD(I,2)-1) 
C$$$     WRITE (*, *) '? I = ', I, ' NEIGH = ', NEIGH
C$$$  NEIGHBOUR CAN BE < 0, OR > LIMX. IF WRAPX IS TRUE, THIS INDICATES
C$$$  A VALID SITE. THE FOLLOWING CODE IS A BIT UGLY, AS I AM NOT SURE
C$$$  WHAT IS MOD(-1, N) IN FORTRAN.
         IF (((NEIGH.LE.LIMX).AND.(NEIGH.GT.0)).OR.(WRAPX.GT.0)) THEN
           IF (NEIGH.LE.0) THEN
               NEIGH = NEIGH + LIMX
             ELSE
               NEIGH = MOD (NEIGH - 1, LIMX) + 1
             ENDIF
C$$$         WRITE (*, *) 'PUT: I = ', I, ' NEIGH = ', NEIGH
             MODD(LIMX + I, LIMX + NEIGH) = -1*CNUM
         END IF
C$$$     NOW REPEAT THE SAME FOR EVEN ROWS, SWAPPING LEFT AND RIGHT
C$$$     AGAIN, THE CODE IS NOW RATHER UGLY.
         NEIGH = I - (2 * MOD(I, 2)  - 1)
C$$$     WRITE (*, *) '? I = ', I, ' NEIGH = ', NEIGH
         IF (((NEIGH.LE.LIMX).AND.(NEIGH.GT.0)).OR.(WRAPX.GT.0)) THEN
           IF (NEIGH.LE.0) THEN
             NEIGH = LIMX
           ELSE
             NEIGH = MOD (NEIGH - 1, LIMX) + 1
           END IF
C$$$       WRITE (*, *) 'PUT: I = ', I, ' NEIGH = ', NEIGH
           MEVEN(LIMX + I, LIMX + NEIGH) = -1*CNUM
         END IF
      END DO
c$$$  Originally the first M matrix was set here	  
      RETURN
      END


      SUBROUTINE GETTRANS(TVALS, LIMX, LIMY, MEVEN, MODD, MULT, O, IO,
     +     ABCD, A, B, C, D, T, R, TINC, RINC, TTILDEINC, RTILDEINC, 
     +     TTILDE, RTILDE)
      IMPLICIT NONE
      INTEGER I, LIMY, LIMX
      DOUBLE PRECISION TVALS(LIMX)
      DOUBLE COMPLEX   ZEROC/0.0/, ONEC/1.0/
      DOUBLE COMPLEX MODD(2*LIMX, 2*LIMX), MEVEN(2*LIMX, 2*LIMX),
     +               MULT(2*LIMX, 2*LIMX), TEMP(2*LIMX, 2*LIMX)
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX),
     +               C(LIMX, LIMX), D(LIMX, LIMX),
     +               ABCD(2*LIMX, 2*LIMX)
      DOUBLE COMPLEX T(LIMX, LIMX),    TTILDE(LIMX, LIMX),
     +               R(LIMX, LIMX),    RTILDE(LIMX, LIMX),
     +               TINC(LIMX, LIMX), TTILDEINC(LIMX, LIMX),
     +               RINC(LIMX, LIMX), RTILDEINC(LIMX, LIMX)
      DOUBLE COMPLEX O(2 *LIMX, 2*LIMX), IO(2*LIMX, 2*LIMX)

         DO I = 1, LIMY-1
            IF (MOD(LIMY,2) .EQ. 1) THEN
               IF (MOD(I,2) .EQ. 1) THEN
                  CALL ZCOPY(4*LIMX*LIMX, MEVEN, 1, MULT, 1)		
               ELSE
                  CALL ZCOPY(4*LIMX*LIMX, MODD, 1, MULT, 1)		
               END IF
            ELSE
               IF (MOD(I,2) .EQ. 1) THEN
                  CALL ZCOPY(4*LIMX*LIMX, MODD, 1, MULT, 1)		
               ELSE
                  CALL ZCOPY(4*LIMX*LIMX, MEVEN, 1, MULT, 1)		
               END IF
            END IF


            CALL GENABCD(LIMX, MULT, O, IO, ABCD, A, B, C, D)
            CALL GENTANDRINC(LIMX, TINC, RINC, TTILDEINC, RTILDEINC, 
     +           A, B, C,D)
            CALL UPDATETANDR(TINC, TTILDEINC, R, RTILDEINC, T, TTILDE,
     +           RTILDE, LIMX, RINC)
            
         END DO  
         CALL SV_DECOMP(LIMX, T, TVALS)
         ZEROC = 0.0 
         ONEC = 1.0 
         CALL ZLASET ('ALL', LIMX, LIMX, ZEROC, ONEC, T, LIMX)
         CALL ZLASET ('ALL', LIMX, LIMX, ZEROC, ONEC, TTILDE, LIMX)
         CALL ZLASET ('ALL', LIMX, LIMX, ZEROC, ZEROC, R, LIMX)
         CALL ZLASET ('ALL', LIMX, LIMX, ZEROC, ZEROC, RTILDE, LIMX)
         
         RETURN
         END
