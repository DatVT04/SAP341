*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB4_ADV_SQL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab4_adv_sql.

*--- 1. SELECTION SCREEN (Màn hình lọc) ---*
PARAMETERS: pa_sid TYPE char8. " Lọc theo mã sinh viên (Tùy chọn)
*--- 2. MAIN LOGIC ---*
START-OF-SELECTION.
  " Thực hiện JOIN 3 bảng để lấy đầy đủ thông tin:
  " SV(Tên) -> Đăng ký(Điểm) -> Môn học(Tên môn, Tín chỉ)
  " AS a, AS b, AS c là Alias (tên giả) để viết code cho ngắn gọn
  SELECT a~student_id, a~full_name,
  b~course_id, b~score,
  c~course_name, c~credits
  FROM zstudent_dev349 AS a " Bảng Sinh viên (Gốc)
  INNER JOIN zenroll_dev349 AS b " Nối với bảng Đăng ký
  ON a~student_id = b~student_id
  INNER JOIN zcourse_dev349 AS c " Nối tiếp với bảng Môn học
  ON b~course_id = c~course_id
  WHERE a~student_id = @pa_sid OR @pa_sid IS INITIAL " Lọc nếu user nhập ID
  INTO TABLE @DATA(lt_report).
  IF sy-subrc = 0.
    SORT lt_report BY student_id course_id.
    WRITE: / '=== STUDENT ACADEMIC TRANSCRIPT ===' COLOR 1.
    ULINE.
    " Duyệt và in báo cáo
    LOOP AT lt_report INTO DATA(ls_row).
      " Kỹ thuật in: In Mã SV và Tên 1 lần duy nhất cho mỗi nhóm (ON CHANGE OF)
      " Giúp báo cáo dễ nhìn hơn
      AT NEW student_id.
        WRITE: / 'Student:', ls_row-student_id, ls_row-full_name COLOR 4.
      ENDAT.
      WRITE: /15 ls_row-course_id, " Thụt vào cột 15
      ls_row-course_name,
      'Credits:', ls_row-credits,
      'Score:', ls_row-score COLOR 5.
    ENDLOOP.
  ELSE.
    MESSAGE 'No enrollment data found.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
