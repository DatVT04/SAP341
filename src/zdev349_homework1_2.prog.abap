*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_HOMEWORK1_2.

START-OF-SELECTION.
  DATA(lv_user) = sy-uname. " Tên user đăng nhập

  " In ra với định dạng ngày ISO (YYYY-MM-DD)
  WRITE: / |Xin chào { lv_user }, hôm nay là ngày { sy-datum DATE = ISO }|.
