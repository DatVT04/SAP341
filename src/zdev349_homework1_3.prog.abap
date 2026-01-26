*&---------------------------------------------------------------------*
*& Report ZDEV349_HOMEWORK1_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_HOMEWORK1_3.

START-OF-SELECTION.
  DATA(lv_score) = 8.

  " COND trả về kết quả gán ngay vào biến lv_result
  DATA(lv_result) = COND string(
    WHEN lv_score < 5 THEN 'Trượt'
    ELSE 'Đỗ'
  ).

  WRITE: / |Điểm: { lv_score } -> Kết quả: { lv_result }|.
