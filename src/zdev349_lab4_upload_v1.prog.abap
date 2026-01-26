*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB4_UPLOAD_V1
*&---------------------------------------------------------------------*
*& Description: Import Data from Excel (3 Sheets) to 3 Z-Tables
*& Author: DEV349 - SE1876
*& Enhanced: Progress tracking and detailed logging
*&---------------------------------------------------------------------*

REPORT ZDEV349_LAB4_UPLOAD_V1.

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

" Biến theo dõi tiến trình
DATA: GV_TOTAL_COURSE  TYPE I,
      GV_TOTAL_STUDENT TYPE I,
      GV_TOTAL_ENROLL  TYPE I,
      GV_ERROR_COUNT   TYPE I,
      GV_START_TIME    TYPE TIMESTAMP,
      GV_END_TIME      TYPE TIMESTAMP,
      GV_DURATION      TYPE I,
      GV_TOTAL_RECORD  TYPE I.

*--- 3. SELECTION SCREEN ---*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_FILE TYPE STRING LOWER CASE DEFAULT 'D:\LMS_Data_Import.xlsx'.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: P_LOG TYPE FLAG DEFAULT 'X'. " Hiển thị log chi tiết
SELECTION-SCREEN END OF BLOCK B2.

" Hỗ trợ tìm file (F4)

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_OPEN_FILE CHANGING P_FILE.

*--- 4. MAIN PROCESSING ---*
START-OF-SELECTION.

  " Ghi nhận thời gian bắt đầu
  GET TIME STAMP FIELD GV_START_TIME.

  PERFORM PRINT_HEADER.

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

  " Bước 7: Hiển thị báo cáo tổng kết
  PERFORM PRINT_SUMMARY.

*&---------------------------------------------------------------------*
*&      Form  PRINT_HEADER
*&---------------------------------------------------------------------*
FORM PRINT_HEADER.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║        LMS DATA IMPORT - PROGRESS TRACKING SYSTEM          ║' COLOR 1.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║ File:', P_FILE.
  WRITE: / '║ Start Time:', SY-DATUM, SY-UZEIT.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_EXCEL
*&---------------------------------------------------------------------*
FORM INIT_EXCEL.
  WRITE: / '► Step 1: Initializing Excel Application...' COLOR 3.

  CREATE OBJECT GO_EXCEL 'EXCEL.APPLICATION'.
  SET PROPERTY OF GO_EXCEL 'VISIBLE' = 0. " 0 = Ẩn Excel

  CALL METHOD OF GO_EXCEL 'WORKBOOKS' = GO_WORKBOOKS.

  " Mở file theo đường dẫn
  CALL METHOD OF GO_WORKBOOKS 'OPEN' = GO_WORKBOOK
    EXPORTING #1 = P_FILE.

  IF SY-SUBRC <> 0.
    WRITE: / '   ✖ ERROR: Cannot open Excel file!' COLOR 6.
    MESSAGE 'Error opening Excel file.' TYPE 'E'.
  ELSE.
    WRITE: / '   ✓ Excel Application started successfully' COLOR 5.
    WRITE: / '   ✓ Workbook opened successfully' COLOR 5.
  ENDIF.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_COURSE
*&---------------------------------------------------------------------*
FORM READ_SHEET_COURSE.
  WRITE: / '► Step 2: Reading COURSE Sheet...' COLOR 3.

  " Chọn Sheet tên là 'COURSE'
  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'COURSE'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2. " Bắt đầu đọc từ dòng 2 (Bỏ qua Header)
  GV_TOTAL_COURSE = 0.

  DO.
    " Đọc cột A (Course ID)
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    LS_COURSE-COURSE_ID = GV_VALUE.

    " Đọc cột B (Course Name)
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    LS_COURSE-COURSE_NAME = GV_VALUE.

    " Đọc cột C (Credits)
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_COURSE-CREDITS = GV_VALUE.

    APPEND LS_COURSE TO LT_COURSE.
    GV_TOTAL_COURSE = GV_TOTAL_COURSE + 1.

    " Log chi tiết nếu được yêu cầu
    IF P_LOG = 'X' AND GV_TOTAL_COURSE <= 5.
      WRITE: / '   │ Row', GV_ROW, ':', LS_COURSE-COURSE_ID, LS_COURSE-COURSE_NAME.
    ENDIF.

    CLEAR LS_COURSE.
    GV_ROW = GV_ROW + 1.
  ENDDO.

  WRITE: / '   ✓ Total COURSE records read:', GV_TOTAL_COURSE COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_STUDENT
*&---------------------------------------------------------------------*
FORM READ_SHEET_STUDENT.
  WRITE: / '► Step 3: Reading STUDENT Sheet...' COLOR 3.

  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'STUDENT'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2.
  GV_TOTAL_STUDENT = 0.

  DO.
    " Col A: Student ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    LS_STUDENT-STUDENT_ID = GV_VALUE.

    " Col B: Full Name
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    LS_STUDENT-FULL_NAME = GV_VALUE.

    " Col C: DOB
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_STUDENT-DOB = GV_VALUE.

    " Col D: Course
    PERFORM GET_CELL_VALUE USING GV_ROW 4 CHANGING GV_VALUE.
    LS_STUDENT-COURSE = GV_VALUE.

    APPEND LS_STUDENT TO LT_STUDENT.
    GV_TOTAL_STUDENT = GV_TOTAL_STUDENT + 1.

    " Log chi tiết
    IF P_LOG = 'X' AND GV_TOTAL_STUDENT <= 5.
      WRITE: / '   │ Row', GV_ROW, ':', LS_STUDENT-STUDENT_ID, LS_STUDENT-FULL_NAME.
    ENDIF.

    CLEAR LS_STUDENT.
    GV_ROW = GV_ROW + 1.
  ENDDO.

  WRITE: / '   ✓ Total STUDENT records read:', GV_TOTAL_STUDENT COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_SHEET_ENROLL
*&---------------------------------------------------------------------*
FORM READ_SHEET_ENROLL.
  WRITE: / '► Step 4: Reading ENROLL Sheet...' COLOR 3.

  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'ENROLL'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2.
  GV_TOTAL_ENROLL = 0.

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
    REPLACE ',' WITH '.' INTO GV_VALUE.
    LS_ENROLL-SCORE = GV_VALUE.

    APPEND LS_ENROLL TO LT_ENROLL.
    GV_TOTAL_ENROLL = GV_TOTAL_ENROLL + 1.

    " Hiển thị tiến trình mỗi 10 dòng
    IF GV_TOTAL_ENROLL MOD 10 = 0.
      WRITE: / '   │ Processing... Row', GV_ROW, '(', GV_TOTAL_ENROLL, 'records )'.
    ENDIF.

    " Log chi tiết
    IF P_LOG = 'X' AND GV_TOTAL_ENROLL <= 5.
      WRITE: / '   │ Row', GV_ROW, ':', LS_ENROLL-ENROLL_ID, LS_ENROLL-STUDENT_ID, LS_ENROLL-COURSE_ID, LS_ENROLL-SCORE.
    ENDIF.

    CLEAR LS_ENROLL.
    GV_ROW = GV_ROW + 1.
  ENDDO.

  WRITE: / '   ✓ Total ENROLL records read:', GV_TOTAL_ENROLL COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CELL_VALUE
*&---------------------------------------------------------------------*
FORM GET_CELL_VALUE USING P_ROW TYPE I P_COL TYPE I CHANGING P_VAL.
  CALL METHOD OF GO_EXCEL 'Cells' = GO_CELL
    EXPORTING #1 = P_ROW #2 = P_COL.

  GET PROPERTY OF GO_CELL 'Value' = P_VAL.

  " Giải phóng object cell
  FREE OBJECT GO_CELL.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CLOSE_EXCEL
*&---------------------------------------------------------------------*
FORM CLOSE_EXCEL.
  WRITE: / '► Step 5: Closing Excel Application...' COLOR 3.

  " Đóng Workbook không save
  CALL METHOD OF GO_WORKBOOK 'Close' EXPORTING #1 = 0.
  " Thoát Excel Application
  CALL METHOD OF GO_EXCEL 'Quit'.

  FREE OBJECT: GO_SHEET, GO_SHEETS, GO_WORKBOOK, GO_WORKBOOKS, GO_EXCEL.

  WRITE: / '   ✓ Excel closed successfully' COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_TO_DATABASE
*&---------------------------------------------------------------------*
FORM SAVE_TO_DATABASE.
  WRITE: / '► Step 6: Saving to Database...' COLOR 3.

  " Lưu COURSE
  IF LT_COURSE IS NOT INITIAL.
    WRITE: / '   │ Updating ZCOURSE_DEV0349...' COLOR 4.
    MODIFY ZCOURSE_DEV349 FROM TABLE LT_COURSE.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ ZCOURSE_DEV349: ', GV_TOTAL_COURSE, 'records updated' COLOR 5.
    ELSE.
      WRITE: / '   ✖ ZCOURSE_DEV349: Update failed!' COLOR 6.
      GV_ERROR_COUNT = GV_ERROR_COUNT + 1.
    ENDIF.
  ENDIF.

  " Lưu STUDENT
  IF LT_STUDENT IS NOT INITIAL.
    WRITE: / '   │ Updating ZSTUDENT_DEV349...' COLOR 4.
    MODIFY ZSTUDENT_DEV349 FROM TABLE LT_STUDENT.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ ZSTUDENT_DEV349:', GV_TOTAL_STUDENT, 'records updated' COLOR 5.
    ELSE.
      WRITE: / '   ✖ ZSTUDENT_DEV349: Update failed!' COLOR 6.
      GV_ERROR_COUNT = GV_ERROR_COUNT + 1.
    ENDIF.
  ENDIF.

  " Lưu ENROLL
  IF LT_ENROLL IS NOT INITIAL.
    WRITE: / '   │ Updating ZENROLL_DEV349...' COLOR 4.
    MODIFY ZENROLL_DEV349 FROM TABLE LT_ENROLL.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ ZENROLL_DEV349: ', GV_TOTAL_ENROLL, 'records updated' COLOR 5.
    ELSE.
      WRITE: / '   ✖ ZENROLL_DEV349: Update failed!' COLOR 6.
      GV_ERROR_COUNT = GV_ERROR_COUNT + 1.
    ENDIF.
  ENDIF.

  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PRINT_SUMMARY
*&---------------------------------------------------------------------*
FORM PRINT_SUMMARY.
  " Tính thời gian thực hiện
  GET TIME STAMP FIELD GV_END_TIME.
  GV_DURATION = GV_END_TIME - GV_START_TIME.
  GV_TOTAL_RECORD = GV_TOTAL_COURSE + GV_TOTAL_STUDENT + GV_TOTAL_ENROLL.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║                    IMPORT SUMMARY REPORT                    ║' COLOR 1.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║ End Time    :', SY-DATUM, SY-UZEIT.
  WRITE: / '║ Duration    :', GV_DURATION, 'seconds'.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ COURSE Table :', GV_TOTAL_COURSE, 'records' COLOR 5.
  WRITE: / '║ STUDENT Table:', GV_TOTAL_STUDENT, 'records' COLOR 5.
  WRITE: / '║ ENROLL Table :', GV_TOTAL_ENROLL, 'records' COLOR 5.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ Total Records:', GV_TOTAL_RECORD COLOR 3.
  WRITE: / '║ Errors       :', GV_ERROR_COUNT.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.

  IF GV_ERROR_COUNT = 0.
    WRITE: / '║           ✓ ALL DATA IMPORTED SUCCESSFULLY!                ║' COLOR 5.
  ELSE.
    WRITE: / '║           ⚠ IMPORT COMPLETED WITH ERRORS!                  ║' COLOR 6.
  ENDIF.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
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
