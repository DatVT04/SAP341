*&---------------------------------------------------------------------*
*& Report ZDEV349_EX1B
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_HOMEWORK1_1.

START-OF-SELECTION.
" 1. Khai báo Inline
DATA(lv_fullname) = 'Vu Tien Dat'.
DATA(lv_yob) = '2004'.
DATA(lv_job) = 'ABAP Developer'.

" 2. In ra (Sử dụng chuỗi nội suy - xem chương 2 để hiểu rõ hơn)
WRITE: / 'Tên:', lv_fullname.
WRITE: / 'Nam sinh:', lv_yob.
WRITE: / 'Vị tri:', lv_job.
