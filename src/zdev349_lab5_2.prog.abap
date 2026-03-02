*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB5_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab5_2.

DATA: lt_enroll TYPE TABLE OF zenroll_dev349,
      ls_enroll TYPE zenroll_dev349,
      gv_gpa    TYPE p DECIMALS 2,
      gv_rank   TYPE string.

SELECT * FROM zenroll_dev349 INTO TABLE lt_enroll.

LOOP AT lt_enroll INTO ls_enroll.

  " Vì bảng chỉ có 1 cột SCORE, dùng SCORE cho cả 3 thành phần
  CALL FUNCTION 'ZFM_DEV349_CALC_GPA'
    EXPORTING
      iv_lab   = ls_enroll-score
      iv_quiz = ls_enroll-score
      iv_final = ls_enroll-score
    IMPORTING
      ev_gpa   = gv_gpa
      ev_rank  = gv_rank
    EXCEPTIONS
      invalid_score = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
    WRITE: / ls_enroll-student_id,
             'Score:', ls_enroll-score,
             'GPA:', gv_gpa,
             'Rank:', gv_rank.
  ENDIF.

ENDLOOP.
