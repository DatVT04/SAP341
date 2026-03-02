*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB5_4
*&---------------------------------------------------------------------*
REPORT zdev349_lab5_4.

DATA: gv_my_score TYPE p DECIMALS 2 VALUE '8.21'.
WRITE: / 'Before Rounding:', gv_my_score. " In ra 8.21
" Gọi hàm có tham số CHANGING
CALL FUNCTION 'ZFM_DEV349_ROUND_SCORE'
  CHANGING
    cv_score = gv_my_score. " Biến này sẽ bị thay đổi sau khi hàm chạy xong
WRITE: / 'After Rounding:', gv_my_score. " In ra 8.30 (Đã bị thay đổi)
