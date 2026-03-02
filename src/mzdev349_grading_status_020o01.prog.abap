*----------------------------------------------------------------------*
***INCLUDE MZDEV349_GRADING_STATUS_020O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'GUI_200'. " Tạo GUI, thêm nút BACK
  SET TITLEBAR 'TIT_200' WITH 'Chi Tiết Sinh Viên'.
  DESCRIBE TABLE it_enroll LINES tc_enr-lines.
ENDMODULE.
MODULE tc_enr_modify INPUT.
  MODIFY it_enroll FROM wa_enroll INDEX tc_enr-current_line.
ENDMODULE.
MODULE user_command_0200 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.

    WHEN 'ADD'.
      CLEAR wa_enroll.
      CALL SCREEN 300 STARTING AT 20 5 ENDING AT 60 12.

    WHEN 'GRADE'.
      " Tìm môn học được tick chọn
      READ TABLE it_enroll INTO wa_enroll WITH KEY mark = 'X'.
      IF sy-subrc = 0.
        " Nạp dữ liệu vào các biến trên màn hình 300
        zenroll_dev349-enroll_id = wa_enroll-enroll_id.
        zenroll_dev349-course_id = wa_enroll-course_id.
        zcourse_dev349-course_name = wa_enroll-course_name.
        zenroll_dev349-score = wa_enroll-score.
        " Gọi Popup
        CALL SCREEN 300 STARTING AT 10 10 ENDING AT 50 20.
      ELSE.
        MESSAGE 'Vui lòng chọn 1 môn học để nhập điểm!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.
