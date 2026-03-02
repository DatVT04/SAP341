*----------------------------------------------------------------------*
***INCLUDE MZDEV349_GRADING_STATUS_010O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'GUI_100'. " Nháy đúp tạo GUI, thêm nút BACK, EXIT, CANCEL
  SET TITLEBAR 'TIT_100' WITH 'Quản Lý Lớp Học'.
  " Cập nhật số dòng cho Table Control
  DESCRIBE TABLE it_students LINES tc_stu-lines.
ENDMODULE.
MODULE tc_stu_modify INPUT.
  " Khi tick chọn checkbox, update lại Internal Table

  MODIFY it_students FROM wa_student INDEX tc_stu-current_line.
ENDMODULE.
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'SEARCH'.
      " Lấy danh sách SV theo lớp
      SELECT student_id full_name
      FROM zstudent_dev349
      INTO CORRESPONDING FIELDS OF TABLE it_students
      WHERE course = gv_class.
      IF sy-subrc <> 0.
        MESSAGE 'Không tìm thấy sinh viên lớp này!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    WHEN 'DETAIL'.
      " Tìm sinh viên được tick chọn (mark = 'X')
      READ TABLE it_students INTO wa_student WITH KEY mark = 'X'.
      IF sy-subrc = 0.
        " Đổ dữ liệu Header
        zstudent_dev349-student_id = wa_student-student_id.
        zstudent_dev349-full_name = wa_student-full_name.
        " Lấy danh sách Môn & Điểm của SV đó
        SELECT a~enroll_id, a~course_id, b~course_name, a~score
        FROM zenroll_dev349 AS a

        INNER JOIN zcourse_dev349 AS b ON a~course_id = b~course_id
        INTO CORRESPONDING FIELDS OF TABLE @it_enroll
        WHERE a~student_id = @wa_student-student_id.
        CALL SCREEN 200. " Mở màn hình 200
      ELSE.
        MESSAGE 'Vui lòng chọn 1 sinh viên!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.
