*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_homework1_5.

START-OF-SELECTION.

  TYPES int4_tab TYPE STANDARD TABLE OF i WITH EMPTY KEY.

  DATA lt_raw TYPE int4_tab.
  DATA lv_sum TYPE i VALUE 0.

  " Tạo bảng 1..10
  DO 10 TIMES.
    APPEND sy-index TO lt_raw.
  ENDDO.

  " Lọc số chẵn + tính tổng
  LOOP AT lt_raw INTO DATA(lv_item).
    IF lv_item MOD 2 = 0.
      lv_sum = lv_sum + lv_item.
    ENDIF.
  ENDLOOP.

  WRITE: / |Tổng các số chẵn từ 1 đến 10 là: { lv_sum }|.
