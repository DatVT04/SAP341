*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_6
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_HOMEWORK1_6.

DATA: lv_result TYPE i.

START-OF-SELECTION.

  TRY.
      lv_result = 100 / 0.
      WRITE: / 'Kết quả:', lv_result.

    CATCH cx_sy_zerodivide INTO DATA(lo_err).
      WRITE: / 'Lỗi: Chia cho 0!',
             / 'Chi tiết:', lo_err->get_text( ).
  ENDTRY.
