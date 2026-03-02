FUNCTION zfm_dev349_calc_gpa.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LAB) TYPE  P
*"     REFERENCE(IV_QUIZ) TYPE  P
*"     REFERENCE(IV_FINAL) TYPE  P
*"     REFERENCE(IV_STRICT_MODE) TYPE  CHAR1 DEFAULT ' '
*"  EXPORTING
*"     REFERENCE(EV_GPA) TYPE  P
*"     REFERENCE(EV_RANK) TYPE  STRING
*"  EXCEPTIONS
*"      INVALID_SCORE
*"----------------------------------------------------------------------

  " 1. Validate input
  IF iv_lab   < 0 OR iv_lab   > 10 OR
     iv_quiz < 0 OR iv_quiz > 10 OR
     iv_final < 0 OR iv_final > 10.
    RAISE invalid_score.
  ENDIF.

  " 2. Calculate GPA
  ev_gpa = ( iv_lab * '0.2' ) +
           ( iv_quiz * '0.3' ) +
           ( iv_final * '0.5' ).

  " 3. Rank logic with STRICT MODE
  IF ev_gpa >= 9.
    ev_rank = 'Excellent'.
  ELSEIF ev_gpa >= 5.
    ev_rank = 'Pass'.
  ELSE.
    IF iv_strict_mode = 'X'.
      ev_rank = 'Critical Fail'.
    ELSE.
      ev_rank = 'Fail'.
    ENDIF.
  ENDIF.

ENDFUNCTION.
