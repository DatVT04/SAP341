*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB3_DB_ACCESS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab3_db_access.

*--- 1. DATA DECLARATION (Khai báo dữ liệu) ---*
" Khai báo Internal Table để chứa danh sách sinh viên lấy từ DB
" Sử dụng cú pháp hiện đại: khai báo inline ngay trong câu lệnh SELECT
" Tuy nhiên, để rõ ràng cho người mới, ta sẽ dùng biến inline bên dưới.

PARAMETERS: PA_CRSE TYPE CHAR10. " Input Course

*--- 2. MAIN LOGIC (Xử lý chính) ---*
START-OF-SELECTION.

  " Truy vấn dữ liệu từ bảng ZSTUDENT_DEV331
  " SELECT * : Lấy tất cả các cột
  " INTO TABLE @DATA(...) : Tự động tạo một bảng nội bộ (lt_students) khớp cấu trúc

  IF PA_CRSE IS NOT INITIAL.
    SELECT STUDENT_ID, FULL_NAME, DOB, COURSE " Solution Challenge 2: List columns
    FROM ZSTUDENT_DEV349
    WHERE COURSE = @PA_CRSE
    INTO TABLE @DATA(LT_STUDENTS).
  ELSE.
    SELECT STUDENT_ID, FULL_NAME, DOB, COURSE
    FROM ZSTUDENT_DEV349
    INTO TABLE @LT_STUDENTS.
  ENDIF.

  " Kiểm tra xem có lấy được dữ liệu không (sy-subrc = 0 là thành công)
  IF SY-SUBRC = 0.

    " Sắp xếp danh sách theo Tên sinh viên
    SORT LT_STUDENTS BY FULL_NAME ASCENDING.

    " In tiêu đề báo cáo
    WRITE: / '=== FPT UNIVERSITY STUDENT LIST ===' COLOR 1.
    WRITE: / 'Generated Date:', SY-DATUM.
    ULINE. " Kẻ dòng

    " Duyệt vòng lặp để in từng sinh viên ra màn hình
    LOOP AT LT_STUDENTS INTO DATA(LS_STUDENT).
      WRITE: / 'ID:',     LS_STUDENT-STUDENT_ID,
'| Name:', LS_STUDENT-FULL_NAME,
'| Course:', LS_STUDENT-COURSE.
    ENDLOOP.
    SKIP 1.
    " In tổng số lượng sinh viên tìm thấy
    " sy-dbcnt chứa số dòng dữ liệu vừa được tác động bởi câu lệnh SQL/Loop
    WRITE: / 'Total Students found:', SY-DBCNT COLOR 4.
  ELSE.
    " Trường hợp không tìm thấy dữ liệu
    WRITE: / 'No data found in database table ZSTUDENT_DEV349.' COLOR 6.
  ENDIF.
