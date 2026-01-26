*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB5_MODULARIZATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab5_modularization.

PARAMETERS: pa_lab   TYPE p DECIMALS 2,
            pa_quiz  TYPE p DECIMALS 2,
            pa_final TYPE p DECIMALS 2.
DATA: gv_result_gpa  TYPE p DECIMALS 2,
      gv_result_rank TYPE string.

START-OF-SELECTION.
  " Gọi Function Module
  " Tips: Trong Editor, nhấn nút 'Pattern' -> Nhập tên FM -> Enter
  " Code sẽ tự sinh ra.
  CALL FUNCTION 'ZFM_DEV349_CALC_GPA'
    EXPORTING
      iv_lab        = pa_lab
      iv_quiz       = pa_quiz
      iv_final      = pa_final
    IMPORTING
      ev_gpa        = gv_result_gpa
      ev_rank       = gv_result_rank
    EXCEPTIONS
      invalid_score = 1 " Nếu hàm RAISE exception, sy-subrc sẽ bằng 1
      OTHERS        = 2.

  " Kiểm tra kết quả gọi hàm
  IF sy-subrc = 0.
    " Thành công
    WRITE: / 'Calculation Successful!'.
    WRITE: / 'GPA:', gv_result_gpa.
    WRITE: / 'Rank:', gv_result_rank.
  ELSEIF sy-subrc = 1.
    " Bắt lỗi Invalid Score
    MESSAGE 'Error: Input scores must be between 0 and 10.' TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE 'Unknown Error occurred.' TYPE 'E'.
  ENDIF.
