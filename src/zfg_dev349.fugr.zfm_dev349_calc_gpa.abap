FUNCTION ZFM_DEV349_CALC_GPA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LAB) TYPE  P
*"     REFERENCE(IV_QUIZ) TYPE  P
*"     REFERENCE(IV_FINAL) TYPE  P
*"  EXPORTING
*"     REFERENCE(EV_GPA) TYPE  P
*"     REFERENCE(EV_RANK) TYPE  STRING
*"  EXCEPTIONS
*"      INVALID_SCORE
*"----------------------------------------------------------------------
" 1. Validation Logic
IF iv_lab < 0 OR iv_lab > 10 OR
iv_quiz < 0 OR iv_quiz > 10 OR
iv_final < 0 OR iv_final > 10.
" Kích hoạt Exception và dừng hàm
RAISE invalid_score.
ENDIF.
" 2. Calculation Logic
" Công thức: Lab 20%, Quiz 30%, Final 50%
ev_gpa = ( iv_lab * '0.2' ) + ( iv_quiz * '0.3' ) + ( iv_final * '0.5' ).
" 3. Ranking Logic
IF ev_gpa >= 9.
ev_rank = 'Excellent'.
ELSEIF ev_gpa >= 5.
ev_rank = 'Pass'.
ELSE.
ev_rank = 'Fail'.
ENDIF.




ENDFUNCTION.
