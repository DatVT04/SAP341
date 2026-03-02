*----------------------------------------------------------------------*
***INCLUDE MZDEV349_GRADING_STATUS_030O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET TITLEBAR 'TIT_300' WITH 'Nhập Điểm'.
ENDMODULE.
MODULE user_command_0300 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 200. " Đóng popup

    WHEN 'SAVE_SCORE'.
      " Validate điểm
      IF zenroll_dev349-score < 0 OR zenroll_dev349-score > 10.
        MESSAGE 'Điểm phải từ 0 đến 10!' TYPE 'E'.
      ENDIF.
      " Update vào Database
      UPDATE zenroll_dev349
      SET score = zenroll_dev349-score
      WHERE enroll_id = zenroll_dev349-enroll_id.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE 'Cập nhật điểm thành công!' TYPE 'S'.
        " Cập nhật lại Internal Table để màn hình 200 hiển thị điểm mới
        wa_enroll-score = zenroll_dev349-score.
        wa_enroll-mark = ' '. " Bỏ tick
        MODIFY TABLE it_enroll FROM wa_enroll.
        LEAVE TO SCREEN 200. " Đóng popup
      ELSE.
        MESSAGE 'Lỗi hệ thống, không thể lưu!' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.
