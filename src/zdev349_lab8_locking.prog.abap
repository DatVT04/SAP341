*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB8_LOCKING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab8_locking.

*--- 1. INPUT PARAMETERS ---*
PARAMETERS: pa_id    TYPE char8 OBLIGATORY, " Student ID
            pa_score TYPE p DECIMALS 2 OBLIGATORY. " New Score

START-OF-SELECTION.
  " 2. Cố gắng khóa đối tượng Sinh viên (Locking)
  " Gọi FM ENQUEUE được sinh ra từ SE11
  CALL FUNCTION 'ENQUEUE_EZSTUDENT_DEV349'
    EXPORTING
      mode_zstudent_dev349 = 'E' " E = Exclusive (Khóa độc quyền)
      student_id           = pa_id " Khóa chính xác sinh viên này
    EXCEPTIONS
      foreign_lock         = 1 " Lỗi: Đã có người khác khóa rồi
      system_failure       = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
    " 3. Xử lý khi KHÔNG khóa được (Exception Handling cơ bản)
    " sy-msgv1 thường chứa tên User đang giữ khóa
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 DISPLAY LIKE 'E'.
    WRITE: / 'Error: Student is currently locked by another user.'.
    RETURN. " Dừng chương trình
  ENDIF.
  " 4. Khu vực an toàn (Critical Section)
  " Tại đây, chỉ mình ta được quyền sửa sinh viên pa_id
  WRITE: / 'Lock acquired successfully.'.
  TRY.
      " Giả lập tính toán phức tạp có thể gây lỗi
      IF pa_score < 0 OR pa_score > 10.
        " Tự ném ra một lỗi (Business Exception)
        RAISE EXCEPTION TYPE cx_sy_range_out_of_bounds.
      ENDIF.
      " Thực hiện Update Database (Giả sử bảng ZENROLL có cột SCORE)
      UPDATE zenroll_dev349
      SET score = @pa_score
      WHERE student_id = @pa_id.
      IF sy-subrc = 0.
        WRITE: / 'Database updated successfully with score:', pa_score.
        COMMIT WORK. " Xác nhận lưu xuống DB
      ELSE.
        WRITE: / 'Student has not registered any course to update.'.
      ENDIF.
    CATCH cx_sy_range_out_of_bounds.
      " Bắt lỗi điểm số không hợp lệ
      MESSAGE 'Score must be between 0 and 10!' TYPE 'I' DISPLAY LIKE 'E'.
    CATCH cx_root INTO DATA(lx_root).
      " Bắt tất cả các lỗi khác (Catch-all)
      WRITE: / 'Runtime Error:', lx_root->get_text( ).
  ENDTRY.
  " 5. Mở khóa (Unlocking) - BẮT BUỘC PHẢI LÀM
  CALL FUNCTION 'DEQUEUE_EZSTUDENT_DEV349'
    EXPORTING
      mode_zstudent_dev349 = 'E'
      student_id           = pa_id.
  WRITE: / 'Lock released.'.
