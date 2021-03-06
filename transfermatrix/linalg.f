C
C     This function calculates dot product of two square matrices:
C
C         C = A . B
C      
C      LIMX is the matrix size
C      
      SUBROUTINE SQDOT (C, A, B, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), C(LIMX, LIMX)
      DOUBLE COMPLEX ZEROC/0.0/, ONEC/1.0/
          
      CALL ZGEMM ('N', 'N',  LIMX, LIMX, LIMX,
     &  ONEC,   A, LIMX, B, LIMX,
     &  ZEROC,  C, LIMX)

      RETURN
      END
      
      SUBROUTINE SQDOTNH (C, A, B, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), C(LIMX, LIMX)
      DOUBLE COMPLEX ZEROC/0.0/, ONEC/1.0/
          
      CALL ZGEMM ('N', 'C',  LIMX, LIMX, LIMX,
     &  ONEC,   A, LIMX, B, LIMX,
     &  ZEROC,  C, LIMX)

      RETURN
      END
      
      SUBROUTINE SQDOTHN (C, A, B, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), C(LIMX, LIMX)
      DOUBLE COMPLEX ZEROC/0.0/, ONEC/1.0/
          
      CALL ZGEMM ('C', 'N',  LIMX, LIMX, LIMX,
     &  ONEC,   A, LIMX, B, LIMX,
     &  ZEROC,  C, LIMX)

      RETURN
      END
      
      SUBROUTINE SQUPDAXPY (Y, ALPHA, X, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX ALPHA
      DOUBLE COMPLEX X(LIMX, LIMX), Y(LIMX, LIMX)
          
      CALL ZAXPY (LIMX*LIMX, ALPHA, X, 1, Y, 1)
      
      RETURN
      END

      
C
C     This function calculates dot product of two square matrices,
C     and multiplies the result by a scalar alpha:     
C
C         C = alpha * A . B
C      
C      LIMX is the matrix size
C      
      SUBROUTINE SQDOTAX (C, ALPHA, A, B, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), C(LIMX, LIMX)
      DOUBLE COMPLEX ALPHA, ZEROC/0.0/
     
      CALL ZGEMM ('N', 'N',  LIMX, LIMX, LIMX,
     &  ALPHA,   A, LIMX, B, LIMX,
     &  ZEROC,   C, LIMX)

      RETURN
      END

C
C     This function calculates dot product of two square matrices,
C     and updates C according to the formula
C
C         C := beta * C + alpha * A . B
C      
C      LIMX is the matrix size
C            
      SUBROUTINE SQDOTUPD (BETA, C, ALPHA, A, B, LIMX)
      IMPLICIT NONE
      INTEGER LIMX
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), C(LIMX, LIMX)
      DOUBLE COMPLEX BETA, ALPHA
     
      CALL ZGEMM ('N', 'N',  LIMX, LIMX, LIMX,
     &  ALPHA,   A, LIMX, B, LIMX,
     &  BETA,  C, LIMX)

      RETURN
      END
      
      SUBROUTINE INVERTMATRIX(MATRIX, LIMX)
      IMPLICIT NONE
      INTEGER S
      INTEGER LIMX, PIVOT(LIMX, LIMX)
      DOUBLE COMPLEX MATRIX(LIMX, LIMX), WORK(LIMX*LIMX)
      CALL ZGETRF(LIMX, LIMX, MATRIX, LIMX, PIVOT, S)
      CALL ZGETRI(LIMX, MATRIX, LIMX, PIVOT, WORK, LIMX*LIMX, S)
      IF (S .NE. 0) THEN
         WRITE (*,*) 'NON-INVERTABLE MATRIX WITH S=', S
         STOP
      END IF

      RETURN
      END

      DOUBLE PRECISION FUNCTION DNORMDIFF (A, B, LIMX)
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX)
      DOUBLE COMPLEX D(LIMX, LIMX)
      DOUBLE PRECISION WORK (LIMX)
      DOUBLE COMPLEX MINUSONE/-1.0/
      DOUBLE PRECISION ZLANGE
      
      CALL SQCOPY    (A, D, LIMX)
      CALL SQUPDAXPY (D, MINUSONE, B, LIMX)
      DNORMDIFF = ZLANGE ('F', LIMX, LIMX, D, LIMX, WORK)

      RETURN
      END
      
      SUBROUTINE INVSOLVE(A, B, LIMX)
c     Solve A := inv(A).B      
      IMPLICIT NONE
      INTEGER S
      INTEGER LIMX, PIVOT(LIMX, LIMX)
      DOUBLE COMPLEX A(LIMX, LIMX), B(LIMX, LIMX), RHS(LIMX, LIMX)
c      DOUBLE COMPLEX SVA (LIMX, LIMX), PROD (LIMX, LIMX)
c      DOUBLE PRECISION dnormdiff
      
      CALL SQCOPY (B, RHS, LIMX)
c     CALL SQCOPY (A, SVA, LIMX)
      CALL ZGETRF(LIMX, LIMX, A, LIMX, PIVOT, S)
      IF (S .NE. 0) THEN
         WRITE (*,*) 'INVSOLVE: NON-INVERTABLE MATRIX WITH S=', S
         STOP
      END IF

      CALL ZGETRS('N', LIMX, LIMX, A, LIMX, PIVOT, RHS, LIMX, S)
      IF (S .NE. 0) THEN
         WRITE (*,*) 'INVSOLVE: NON-SOLVABLE SYSTEM WITH S=', S
         STOP
      END IF
c      call sqdot (prod, SVA, rhs, LIMX) 
c      write (*, *) 'quality: ', dnormdiff (B, PROD, LIMX)
       
      CALL SQCOPY (RHS, A, LIMX)
      
      RETURN
      END

      

      SUBROUTINE SV_DECOMP(LIMX, MATRIX, OUTPUTS)

      INTEGER LIMX, MSIZE, S
      DOUBLE PRECISION SVALS(LIMX), OUTPUTS(LIMX), RWORK(5*LIMX)
      DOUBLE COMPLEX MATRIX(LIMX, LIMX), TEMP2(LIMX, LIMX),
     + SVCPY(LIMX, LIMX), WORK(4*LIMX*LIMX)

      MSIZE=4*LIMX*LIMX

C$$$ MAKE COPY OF MATRIX FOR SVD SINCE IT IS DESTROYED
C$$$      SVCPY=MATRIX
      CALL SQCOPY(MATRIX, SVCPY, LIMX)
      CALL ZGESVD('N', 'N', LIMX, LIMX, SVCPY, LIMX, SVALS, TEMP2,
     + LIMX, TEMP2, LIMX , WORK, MSIZE, RWORK, S)
      IF (S .NE. 0) THEN
         WRITE (*,*) 'SVD FAILED WITH S=', S
         STOP
      END IF

      CALL DCOPY(LIMX, SVALS, 1, OUTPUTS, 1)

      RETURN
      END

      DOUBLE PRECISION FUNCTION CHECKUNI(LIMX, T,R,TTILDE,RTILDE)
      IMPLICIT NONE

      INTEGER LIMX, X/1/, Y/1/
      DOUBLE PRECISION ZLANGE
      EXTERNAL SQUNIT
      DOUBLE COMPLEX T(LIMX,LIMX), BETA/-1/,ALPHA/1/,
     + R(LIMX,LIMX),TTILDE(LIMX,LIMX),RTILDE(LIMX,LIMX),
     + U(LIMX*2,LIMX*2), CHECK(LIMX*2,LIMX*2)


C$$$ TEST CASES OF T,R,T~ R~
C$$$ FILLS A UNIT MATRIX
      CALL SQUNIT (CHECK, 2*LIMX)
      DO X=1, LIMX
         DO Y=1, LIMX
C$$$  TOP LEFT
            U(X,Y)=T(X,Y)
C$$$  BOTTOM LEFT
            U(X+LIMX,Y)=R(X,Y)
C$$$  TOP RIGHT
            U(X,Y+LIMX)=RTILDE(X,Y)
C$$$  BOTTOM RIGHT
            U(X+LIMX,Y+LIMX)=TTILDE(X,Y)
         END DO
      END DO

C$$$  ZGEMM HAS INBUILT FUNCTION TO FIND U**H
      CALL ZGEMM('N', 'C', 2*LIMX, 2*LIMX, 2*LIMX, ALPHA, U,
     +     2*LIMX, U, 2*LIMX, BETA, CHECK, 2*LIMX)
C$$$  ZLANGE FINDS MATRIX NORM
      CHECKUNI = ZLANGE('F', 2*LIMX, 2*LIMX, CHECK, 2*LIMX)
      RETURN
      END

C$$$  ROUTINE TO CHECK FOR UNITARY MATRICES

      DOUBLE PRECISION FUNCTION CHECKUNI2(LIMX, T,R,TTILDE,RTILDE)
      IMPLICIT NONE
 
      INTEGER LIMX
      DOUBLE PRECISION ZLANGE
      EXTERNAL SQUNIT
      DOUBLE PRECISION DNORM1, DNORM2, DNORM3, DNORM
      DOUBLE PRECISION ONED/1.0/
      DOUBLE COMPLEX ZEROC/0.0/, ONEC/1.0/
      DOUBLE COMPLEX T(LIMX,LIMX), R(LIMX,LIMX),
     +               TTILDE(LIMX,LIMX),RTILDE(LIMX,LIMX),
     +               CK(LIMX, LIMX)


C$$$ TEST CASES OF T,R,T~ R~

C$$$ FILLS A UNIT MATRIX

C      DO X = 1, 2*LIMX
C         DO Y = 1, 2*LIMX
C            CHECK(X, Y) = (0.0, 0.0)
C         END DO
C       CHECK(X, X) = 1.0
C      END DO

C$$$ ZGEMM HAS INBUILT FUNCTION TO FIND U**H
C$$   CALL PRINTT (U, 2*LIMX, 'U1 ')

c     Unitarity can be also checked using subblocks only
c     The definition of unitarity can be easily cast into the form
c     |T|^2 + |R|^2 = 1, T*R~ + R* T~ = 0

c     Check that T * T + R* R = 1   (* is the Hermitian conjugate)
c     Here I use zherk, which does T^+T
c     Beware: it computes only the upper-diagonal part!
      CALL SQUNIT (CK, LIMX)
      CALL ZHERK ('U', 'C', LIMX, LIMX, ONED, T, LIMX,
     +  -ONED, CK, LIMX)
      CALL ZHERK ('U', 'C', LIMX, LIMX, ONED, R, LIMX,
     +  ONED, CK, LIMX)
C$$$ ZLANGE FINDS MATRIX NORM
      DNORM1 = ZLANGE ('F', LIMX, LIMX, CK, LIMX)

c     Check that T~* T~ + R~* R~ = 1
      CALL SQUNIT (CK, LIMX)
      CALL ZHERK ('U', 'C', LIMX, LIMX, ONED, TTILDE, LIMX,
     +  -ONED, CK, LIMX)
      CALL ZHERK ('U', 'C', LIMX, LIMX, ONED, RTILDE, LIMX,
     +  ONED, CK, LIMX)
      DNORM2 = ZLANGE ('F', LIMX, LIMX, CK, LIMX)

c     Now check that T* R~ + R* T~ = 0
      CALL ZGEMM ('C', 'N', LIMX, LIMX, LIMX, ONEC, T,
     +           LIMX, RTILDE, LIMX, ZEROC, CK, LIMX)
      CALL ZGEMM ('C', 'N', LIMX, LIMX, LIMX, ONEC, R,
     +           LIMX, TTILDE, LIMX, ONEC, CK, LIMX)
      DNORM3 = ZLANGE ('F', LIMX, LIMX, CK, LIMX)

C$$   CALL PRINTT (CHECK, 2 * LIMX, 'C2 ')
c     ZHERK does only the upper-triangular part. Therefore, the norm
c     DNORM1 should be roughly doubled, ditto DNORM2
c     There are two related off-diagonal blocks in the cross-product,
c     this doubles the norm DNORM3. (The relation is not exact,
c     since, the diagonal is not doubled)
      DNORM = 2.0* DNORM1 + 2.0 * DNORM2 + 2.0 * DNORM3
c     WRITE (*, *) 'CHECKUNI2:', DNORM1, DNORM2, DNORM3, DNORM
      CHECKUNI2 = DNORM
      RETURN
      END
C$$$  ROUTINE TO CHECK FOR UNITARY MATRICES

      DOUBLE PRECISION FUNCTION CHECKUNI3(LIMX, T,R,TTILDE,RTILDE)
      IMPLICIT NONE

      INTEGER LIMX, X/1/, Y/1/
      DOUBLE PRECISION ZLANGE
      EXTERNAL SQUNIT
      DOUBLE PRECISION ONED/1.0/
      DOUBLE COMPLEX T(LIMX,LIMX),
     + R(LIMX,LIMX),TTILDE(LIMX,LIMX),RTILDE(LIMX,LIMX),
     + U(LIMX*2,LIMX*2), CHECK(LIMX*2,LIMX*2)


C$$$ TEST CASES OF T,R,T~ R~

C$$$ FILLS A UNIT MATRIX
      CALL SQUNIT (CHECK, 2*LIMX)
      DO X=1, LIMX
         DO Y=1, LIMX
C$$$  TOP LEFT
            U(X,Y)=T(X,Y)
C$$$  BOTTOM LEFT
            U(X+LIMX,Y)=R(X,Y)
C$$$  TOP RIGHT
            U(X,Y+LIMX)=RTILDE(X,Y)
C$$$  BOTTOM RIGHT
            U(X+LIMX,Y+LIMX)=TTILDE(X,Y)
         END DO
      END DO

C$$$  ZHERK calculates U^H * U, and then subtracts 1.
C$$$  However, this is perfomed in the upper triangular part only
C$$   Therefore, we double the norm.
      CALL ZHERK('U', 'C', 2*LIMX, 2*LIMX, ONED, U, 2*LIMX,
     +     -ONED, CHECK, 2*LIMX)
C$$$  ZLANGE FINDS MATRIX NORM
      CHECKUNI3 = 2 * ZLANGE('F', 2*LIMX, 2*LIMX, CHECK, 2*LIMX)
      RETURN
      END
