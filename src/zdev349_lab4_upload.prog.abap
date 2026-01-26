
REPORT ZDEV349_LAB4_UPLOAD.

*--- 1. INCLUDES & TYPE POOLS ---*
TYPE-POOLS: OLE2. " Thư viện để làm việc với Excel

*--- 2. TABLES & DATA DECLARATION ---*
" Khai báo cấu trúc bảng nội bộ khớp với bảng Database
DATA: LT_COURSE  TYPE TABLE OF ZCOURSE_DEV349,
      LT_STUDENT TYPE TABLE OF ZSTUDENT_DEV349,
      LT_ENROLL  TYPE TABLE OF ZENROLL_DEV349.

DATA: LS_COURSE  TYPE ZCOURSE_DEV349,
      LS_STUDENT TYPE ZSTUDENT_DEV349,
      LS_ENROLL  TYPE ZENROLL_DEV349.

" Các biến OLE Object
DATA: GO_EXCEL     TYPE OLE2_OBJECT, " Excel Application
      GO_WORKBOOKS TYPE OLE2_OBJECT, " List of Workbooks
      GO_WORKBOOK  TYPE OLE2_OBJECT, " Specific Workbook
      GO_SHEETS    TYPE OLE2_OBJECT, " List of Sheets
      GO_SHEET     TYPE OLE2_OBJECT, " Specific Sheet
      GO_CELL      TYPE OLE2_OBJECT. " Specific Cell

DATA: GV_VALUE TYPE STRING,      " Giá trị đọc từ ô
      GV_ROW   TYPE I.           " Biến chạy dòng

*--- 3. SELECTION SCREEN ---*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_FILE TYPE STRING LOWER CASE DEFAULT 'D:\LMS_Data_Import.xlsx'.
SELECTION-SCREEN END OF BLOCK B1.

" Hỗ trợ tìm file (F4)

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_OPEN_FILE CHANGING P_FILE.

*--- 4. MAIN PROCESSING ---*
START-OF-SELECTION.

  " Bước 1: Khởi động Excel và Mở file
  PERFORM INIT_EXCEL.

  " Bước 2: Đọc Sheet 'COURSE'
  PERFORM READ_SHEET_COURSE.

  " Bước 3: Đọc Sheet 'STUDENT'
  PERFORM READ_SHEET_STUDENT.

  " Bước 4: Đọc Sheet 'ENROLL'
  PERFORM READ_SHEET_ENROLL.

  " Bước 5: Đóng Excel
  PERFORM CLOSE_EXCEL.

  " Bước 6: Lưu vào Database
  PERFORM SAVE_TO_DATABASE.

*&---------------------------------------------------------------------*
*&      Form  INIT_EXCEL
*&---------------------------------------------------------------------*
FORM INIT_EXCEL.
  CREATE OBJECT GO_EXCEL 'EXCEL.APPLICATION'.
  SET PROPERTY OF GO_EXCEL 'VISIBLE' = 0. " 0 = Ẩn Excel, 1 = Hiện Excel để debug

  CALL METHOD OF GO_EXCEL 'WORKBOOKS' = GO_WORKBOOKS.

  " Mở file theo đường dẫn
  CALL METHOD OF GO_WORKBOOKS 'OPEN' = GO_WORKBOOK
    EXPORTING #1 = P_FILE.

  IF SY-SUBRC <> 0.
    MESSAGE 'Error opening Excel file.' TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_COURSE
*&---------------------------------------------------------------------*
FORM READ_SHEET_COURSE.
  " Chọn Sheet tên là 'COURSE'
  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'COURSE'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2. " Bắt đầu đọc từ dòng 2 (Bỏ qua Header)

  DO.
    " Đọc cột A (Course ID)
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF. " Hết dữ liệu thì thoát vòng lặp
    LS_COURSE-COURSE_ID = GV_VALUE.

    " Đọc cột B (Course Name)
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    LS_COURSE-COURSE_NAME = GV_VALUE.

    " Đọc cột C (Credits)
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_COURSE-CREDITS = GV_VALUE.

    APPEND LS_COURSE TO LT_COURSE.
    CLEAR LS_COURSE.
    GV_ROW = GV_ROW + 1.
  ENDDO.
  WRITE: / 'Read Course Sheet:', LINES( LT_COURSE ), 'rows.'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_STUDENT
*&---------------------------------------------------------------------*
FORM READ_SHEET_STUDENT.
  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'STUDENT'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2.
  DO.
    " Col A: Student ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    LS_STUDENT-STUDENT_ID = GV_VALUE.

    " Col B: Full Name
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    LS_STUDENT-FULL_NAME = GV_VALUE.

    " Col C: DOB (Cần convert Text YYYYMMDD sang Date)
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_STUDENT-DOB = GV_VALUE.

    " Col D: Course
    PERFORM GET_CELL_VALUE USING GV_ROW 4 CHANGING GV_VALUE.
    LS_STUDENT-COURSE = GV_VALUE.

    APPEND LS_STUDENT TO LT_STUDENT.
    CLEAR LS_STUDENT.
    GV_ROW = GV_ROW + 1.
  ENDDO.
  WRITE: / 'Read Student Sheet:', LINES( LT_STUDENT ), 'rows.'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_ENROLL
*&---------------------------------------------------------------------*
FORM READ_SHEET_ENROLL.
  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'ENROLL'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2.
  DO.
    " Col A: Enroll ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    LS_ENROLL-ENROLL_ID = GV_VALUE.

    " Col B: Student ID
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    LS_ENROLL-STUDENT_ID = GV_VALUE.

    " Col C: Course ID
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_ENROLL-COURSE_ID = GV_VALUE.

    " Col D: Score
    PERFORM GET_CELL_VALUE USING GV_ROW 4 CHANGING GV_VALUE.
    REPLACE ',' WITH '.' INTO GV_VALUE. " Xử lý format số thập phân nếu cần
    LS_ENROLL-SCORE = GV_VALUE.

    APPEND LS_ENROLL TO LT_ENROLL.
    CLEAR LS_ENROLL.
    GV_ROW = GV_ROW + 1.
  ENDDO.
  WRITE: / 'Read Enroll Sheet:', LINES( LT_ENROLL ), 'rows.'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CELL_VALUE
*&---------------------------------------------------------------------*
" Hàm tiện ích đọc giá trị của 1 ô (Row, Col)
FORM GET_CELL_VALUE USING P_ROW TYPE I P_COL TYPE I CHANGING P_VAL.
  CALL METHOD OF GO_EXCEL 'Cells' = GO_CELL
    EXPORTING #1 = P_ROW #2 = P_COL.

  GET PROPERTY OF GO_CELL 'Value' = P_VAL.

  " Giải phóng object cell để nhẹ bộ nhớ
  FREE OBJECT GO_CELL.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CLOSE_EXCEL
*&---------------------------------------------------------------------*
FORM CLOSE_EXCEL.
  " Đóng Workbook không save
  CALL METHOD OF GO_WORKBOOK 'Close' EXPORTING #1 = 0.
  " Thoát Excel Application
  CALL METHOD OF GO_EXCEL 'Quit'.

  FREE OBJECT: GO_SHEET, GO_SHEETS, GO_WORKBOOK, GO_WORKBOOKS, GO_EXCEL.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_TO_DATABASE
*&---------------------------------------------------------------------*
FORM SAVE_TO_DATABASE.
  IF LT_COURSE IS NOT INITIAL.
    MODIFY ZCOURSE_DEV349 FROM TABLE LT_COURSE.
    WRITE: / 'Updated ZCOURSE_DEV349 successfully.'.
  ENDIF.

  IF LT_STUDENT IS NOT INITIAL.
    MODIFY ZSTUDENT_DEV349 FROM TABLE LT_STUDENT.
    WRITE: / 'Updated ZSTUDENT_DEV349 successfully.'.
  ENDIF.

  IF LT_ENROLL IS NOT INITIAL.
    MODIFY ZENROLL_DEV349 FROM TABLE LT_ENROLL.
    WRITE: / 'Updated ZENROLL_DEV49 successfully.'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_OPEN_FILE
*&---------------------------------------------------------------------*
FORM F4_OPEN_FILE CHANGING P_FILENAME.
  DATA: LT_FILETABLE TYPE FILETABLE,
        LV_RC        TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = 'Select Excel File'
      DEFAULT_EXTENSION = 'xlsx'
      FILE_FILTER       = 'Excel Files (*.xlsx)|*.xlsx'
    CHANGING
      FILE_TABLE        = LT_FILETABLE
      RC                = LV_RC.

  READ TABLE LT_FILETABLE INTO DATA(LS_FILE) INDEX 1.
  IF SY-SUBRC = 0.
    P_FILENAME = LS_FILE-FILENAME.
  ENDIF.
ENDFORM.
