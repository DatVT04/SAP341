*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_homework1_4.

START-OF-SELECTION.
  " 1. Tạo bảng
  TYPES int4_tab TYPE STANDARD TABLE OF i WITH EMPTY KEY.
  DATA(lt_list) = VALUE int4_tab( ( 5 ) ( 10 ) ( 15 ) ).

  " 2. Duyệt và tính toán
  LOOP AT lt_list INTO DATA(lv_item).
    DATA(lv_square) = lv_item * lv_item.
    WRITE: / |{ lv_item } bình phương là { lv_square }|.
  ENDLOOP.
