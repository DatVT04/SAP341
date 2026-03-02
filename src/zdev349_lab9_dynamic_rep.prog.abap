*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB9_DYNAMIC_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab9_dynamic_rep.

*--- 1. DATA DECLARATION ---*
" Định nghĩa cấu trúc dữ liệu cho báo cáo
TYPES: BEGIN OF ty_report,
         student_id TYPE zstudent_dev349-student_id,
         full_name  TYPE zstudent_dev349-full_name,
         course_id  TYPE zenroll_dev349-course_id,
         score      TYPE zenroll_dev349-score,
         status     TYPE string, " Cột tính toán thêm (Đậu/Trượt)
         color_code TYPE char4,  " Cột tô màu (C610=Đỏ, C500=Xanh...)
       END OF ty_report.
DATA: lt_report TYPE TABLE OF ty_report.
*--- 2. SELECTION SCREEN (Dynamic Filter) ---*
" Tạo các biến giả để tham chiếu kiểu dữ liệu cho Select-Options
DATA: gv_std_ref TYPE zstudent_dev349-student_id,
      gv_scr_ref TYPE zenroll_dev349-score.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  " Select-Options cho phép nhập: Single value, Ranges, Multiple selection...
  SELECT-OPTIONS: s_std FOR gv_std_ref, " Lọc theo Mã SV
  s_scr FOR gv_scr_ref. " Lọc theo Điểm (VD: 0 -> 5)
SELECTION-SCREEN END OF BLOCK b1.
*--- 3. MAIN LOGIC ---*
START-OF-SELECTION.
  " Lấy dữ liệu từ Database dựa trên bộ lọc nhập vào (IN s_...)
  SELECT a~student_id, a~full_name, b~course_id, b~score
  FROM zstudent_dev349 AS a
  INNER JOIN zenroll_dev349 AS b
  ON a~student_id = b~student_id
  WHERE a~student_id IN @s_std " Dynamic Where Clause
  AND b~score IN @s_scr
  INTO CORRESPONDING FIELDS OF TABLE @lt_report.
  IF sy-subrc <> 0.
    MESSAGE 'No data found matching criteria.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  " Xử lý dữ liệu (Tính toán cột Status và Color Code)
  " Sử dụng Field-Symbol để loop nhanh hơn và sửa trực tiếp dữ liệu
  FIELD-SYMBOLS: <fs_row> TYPE ty_report.
  LOOP AT lt_report ASSIGNING <fs_row>.
    IF <fs_row>-score >= 5.
      <fs_row>-status = 'PASS'.
      <fs_row>-color_code = ''.  " Không tô màu (mặc định)
    ELSE.
      <fs_row>-status = 'FAIL'.
      <fs_row>-color_code = 'C610'. " Tô màu đỏ cho dòng FAIL (Điểm < 5)
    ENDIF.

  ENDLOOP.
  " 4. DISPLAY ALV (Hiển thị báo cáo hiện đại)
  DATA: lo_alv TYPE REF TO cl_salv_table.
  TRY.
      " Tạo đối tượng ALV gắn với bảng dữ liệu lt_report
      cl_salv_table=>factory(
      IMPORTING
      r_salv_table = lo_alv
      CHANGING
      t_table = lt_report ).
      " Bật các chức năng tiêu chuẩn (Toolbar: Sort, Filter, Excel export)
      DATA(lo_functions) = lo_alv->get_functions( ).
      lo_functions->set_all( abap_true ).
      " Tối ưu độ rộng cột
      lo_alv->get_columns( )->set_optimize( abap_true ).
      " Đổi tên tiêu đề cột (Nếu cần)
      DATA(lo_columns) = lo_alv->get_columns( ).
      TRY.
          DATA(lo_col_score) = lo_columns->get_column( 'SCORE' ).
          lo_col_score->set_long_text( 'Final Score' ).
          lo_col_score->set_medium_text( 'Score' ).
        CATCH cx_salv_not_found.
      ENDTRY.
      " Ẩn cột COLOR_CODE (dùng để tô màu, không cần hiển thị)
      TRY.
          DATA(lo_col_color) = lo_columns->get_column( 'COLOR_CODE' ).
          lo_col_color->set_visible( abap_false ).
        CATCH cx_salv_not_found.
      ENDTRY.
      " Hiển thị lên màn hình
      lo_alv->display( ).

    CATCH cx_salv_msg.
      MESSAGE 'ALV Display Error' TYPE 'E'.
  ENDTRY.
