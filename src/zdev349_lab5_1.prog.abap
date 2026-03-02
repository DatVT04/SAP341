*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB5_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_LAB5_1.

PARAMETERS: pa_lab   TYPE p DECIMALS 2,
            pa_quiz  TYPE p DECIMALS 2,
            pa_final TYPE p DECIMALS 2.

DATA: gv_result_gpa  TYPE p DECIMALS 2,
      gv_result_rank TYPE string.

START-OF-SELECTION.

  CALL FUNCTION 'ZFM_DEV349_CALC_GPA'
    EXPORTING
      iv_lab   = pa_lab
      iv_quiz  = pa_quiz
      iv_final = pa_final
    IMPORTING
      ev_gpa   = gv_result_gpa
      ev_rank  = gv_result_rank
    EXCEPTIONS
      invalid_score = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
    PERFORM display_result USING gv_result_gpa gv_result_rank.
  ELSEIF sy-subrc = 1.
    MESSAGE 'Error: Score must be between 0 and 10' TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE 'Unknown error' TYPE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form display_result
*&---------------------------------------------------------------------*
FORM display_result USING pv_gpa  TYPE p
                           pv_rank TYPE string.

  WRITE: / '--- Report by Subroutine ---'.
  WRITE: / 'GPA :', pv_gpa COLOR 5.
  WRITE: / 'Rank:', pv_rank.

ENDFORM.
