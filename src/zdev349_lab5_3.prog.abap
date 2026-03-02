*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB5_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_LAB5_3.

PARAMETERS: pa_score TYPE p DECIMALS 2.

DATA: gv_gpa  TYPE p DECIMALS 2,
      gv_rank TYPE string.

START-OF-SELECTION.

  CALL FUNCTION 'ZFM_DEV349_CALC_GPA'
    EXPORTING
      iv_lab         = pa_score
      iv_quiz        = pa_score
      iv_final       = pa_score
      iv_strict_mode = 'X'
    IMPORTING
      ev_gpa         = gv_gpa
      ev_rank        = gv_rank
    EXCEPTIONS
      invalid_score  = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    WRITE: / 'Score:', pa_score.
    WRITE: / 'GPA  :', gv_gpa.
    WRITE: / 'Rank :', gv_rank.
  ELSE.
    MESSAGE 'Invalid input score!' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
