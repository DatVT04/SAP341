*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_7
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_HOMEWORK1_7.

" 1. Định nghĩa Class
CLASS lcl_shape DEFINITION.
  PUBLIC SECTION.
    " Method nhận vào dài, rộng (IMPORTING) và trả về chu vi (RETURNING)
    METHODS: get_perimeter IMPORTING iv_len TYPE i
                                     iv_wid TYPE i
                           RETURNING VALUE(rv_per) TYPE i.
ENDCLASS.

" 2. Viết logic cho Class
CLASS lcl_shape IMPLEMENTATION.
  METHOD get_perimeter.
    rv_per = ( iv_len + iv_wid ) * 2.
  ENDMETHOD.
ENDCLASS.

" 3. Chạy Chủ điểm trình
START-OF-SELECTION.
  " Tạo đối tượng (Object)
  DATA(lo_shape) = NEW lcl_shape( ).

  " Gọi method
  DATA(lv_p) = lo_shape->get_perimeter( iv_len = 10 iv_wid = 5 ).

  WRITE: / |Chu vi hình chữ nhật (10, 5) là: { lv_p }|.
