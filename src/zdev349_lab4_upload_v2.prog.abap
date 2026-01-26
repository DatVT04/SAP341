*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB4_UPLOAD_V2
*&---------------------------------------------------------------------*
*& Description: Import Data from Excel with Validation & Data Cleaning
*& Author: DEV349 - SE1876
*& Enhanced: Data validation, cleaning options, duplicate checking
*&---------------------------------------------------------------------*

REPORT ZDEV349_LAB4_UPLOAD_V2.

*--- 1. INCLUDES & TYPE POOLS ---*
TYPE-POOLS: OLE2.

*--- 2. TABLES & DATA DECLARATION ---*
DATA: LT_COURSE  TYPE TABLE OF ZCOURSE_DEV349,
      LT_STUDENT TYPE TABLE OF ZSTUDENT_DEV349,
      LT_ENROLL  TYPE TABLE OF ZENROLL_DEV349.

DATA: LS_COURSE  TYPE ZCOURSE_DEV349,
      LS_STUDENT TYPE ZSTUDENT_DEV349,
      LS_ENROLL  TYPE ZENROLL_DEV349.

" OLE Objects
DATA: GO_EXCEL     TYPE OLE2_OBJECT,
      GO_WORKBOOKS TYPE OLE2_OBJECT,
      GO_WORKBOOK  TYPE OLE2_OBJECT,
      GO_SHEETS    TYPE OLE2_OBJECT,
      GO_SHEET     TYPE OLE2_OBJECT,
      GO_CELL      TYPE OLE2_OBJECT.

DATA: GV_VALUE TYPE STRING,
      GV_ROW   TYPE I.

" Progress tracking variables
DATA: GV_TOTAL_COURSE    TYPE I,
      GV_TOTAL_STUDENT   TYPE I,
      GV_TOTAL_ENROLL    TYPE I,
      GV_ERROR_COUNT     TYPE I,
      GV_SKIPPED_COUNT   TYPE I,
      GV_DUPLICATE_COUNT TYPE I,
      GV_START_TIME      TYPE TIMESTAMP,
      GV_END_TIME        TYPE TIMESTAMP,
      GV_DURATION        TYPE I,
      GV_TOTAL_RECORD    TYPE I,
      GV_TOTAL_INVALID   TYPE I.
" Validation counters
DATA: GV_COURSE_VALID    TYPE I,
      GV_STUDENT_VALID   TYPE I,
      GV_ENROLL_VALID    TYPE I,
      GV_COURSE_INVALID  TYPE I,
      GV_STUDENT_INVALID TYPE I,
      GV_ENROLL_INVALID  TYPE I.

*--- 3. SELECTION SCREEN ---*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_FILE TYPE STRING LOWER CASE DEFAULT 'D:\LMS_Data_Import.xlsx'.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: P_CLEAN  TYPE FLAG DEFAULT ' ',  " Xóa dữ liệu cũ trước khi import
              P_UPDATE TYPE FLAG DEFAULT 'X', " Cập nhật nếu đã tồn tại
              P_SKIP   TYPE FLAG DEFAULT ' ', " Bỏ qua nếu đã tồn tại
              P_VALID  TYPE FLAG DEFAULT 'X'. " Bật validation
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: P_LOG TYPE FLAG DEFAULT 'X'. " Hiển thị log chi tiết
SELECTION-SCREEN END OF BLOCK B3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_OPEN_FILE CHANGING P_FILE.

  " Validate radio buttons logic

AT SELECTION-SCREEN.
  IF P_UPDATE = 'X' AND P_SKIP = 'X'.
    MESSAGE 'Cannot select both UPDATE and SKIP options!' TYPE 'E'.
  ENDIF.

*--- 4. MAIN PROCESSING ---*
START-OF-SELECTION.

  GET TIME STAMP FIELD GV_START_TIME.

  PERFORM PRINT_HEADER.

  " Bước 0: Xử lý dữ liệu cũ nếu cần
  IF P_CLEAN = 'X'.
    PERFORM CLEAN_OLD_DATA.
  ENDIF.

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

  " Bước 6: Validate dữ liệu
  IF P_VALID = 'X'.
    PERFORM VALIDATE_DATA.
  ENDIF.

  " Bước 7: Lưu vào Database
  PERFORM SAVE_TO_DATABASE.

  " Bước 8: Hiển thị báo cáo tổng kết
  PERFORM PRINT_SUMMARY.

*&---------------------------------------------------------------------*
*&      Form  PRINT_HEADER
*&---------------------------------------------------------------------*
FORM PRINT_HEADER.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║    LMS DATA IMPORT - WITH VALIDATION & DATA CLEANING       ║' COLOR 1.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║ File:', P_FILE.
  WRITE: / '║ Start Time:', SY-DATUM, SY-UZEIT.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ Options:'.
  WRITE: / '║   - Clean old data   :', P_CLEAN.
  WRITE: / '║   - Update existing  :', P_UPDATE.
  WRITE: / '║   - Skip duplicates  :', P_SKIP.
  WRITE: / '║   - Validation       :', P_VALID.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CLEAN_OLD_DATA
*&---------------------------------------------------------------------*
FORM CLEAN_OLD_DATA.
  DATA: LV_COUNT TYPE I.

  WRITE: / '► Step 0: Cleaning Old Data...' COLOR 3.

  " Xóa dữ liệu ENROLL trước (có foreign key)
  SELECT COUNT(*) FROM ZENROLL_DEV349 INTO LV_COUNT.
  IF LV_COUNT > 0.
    DELETE FROM ZENROLL_DEV349.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ Deleted', LV_COUNT, 'records from ZENROLL_DEV349' COLOR 5.
    ENDIF.
  ENDIF.

  " Xóa STUDENT
  SELECT COUNT(*) FROM ZSTUDENT_DEV349 INTO LV_COUNT.
  IF LV_COUNT > 0.
    DELETE FROM ZSTUDENT_DEV349.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ Deleted', LV_COUNT, 'records from ZSTUDENT_DEV349' COLOR 5.
    ENDIF.
  ENDIF.

  " Xóa COURSE
  SELECT COUNT(*) FROM ZCOURSE_DEV349 INTO LV_COUNT.
  IF LV_COUNT > 0.
    DELETE FROM ZCOURSE_DEV349.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ Deleted', LV_COUNT, 'records from ZCOURSE_DEV349' COLOR 5.
    ENDIF.
  ENDIF.

  WRITE: / '   ✓ Old data cleaned successfully' COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_EXCEL
*&---------------------------------------------------------------------*
FORM INIT_EXCEL.
  WRITE: / '► Step 1: Initializing Excel Application...' COLOR 3.

  CREATE OBJECT GO_EXCEL 'EXCEL.APPLICATION'.
  SET PROPERTY OF GO_EXCEL 'VISIBLE' = 0.

  CALL METHOD OF GO_EXCEL 'WORKBOOKS' = GO_WORKBOOKS.

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

  CALL METHOD OF GO_EXCEL 'SHEETS' = GO_SHEET EXPORTING #1 = 'COURSE'.
  CALL METHOD OF GO_SHEET 'ACTIVATE'.

  GV_ROW = 2.
  GV_TOTAL_COURSE = 0.

  DO.
    " Đọc Course ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.

    " Làm sạch dữ liệu
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_COURSE-COURSE_ID = GV_VALUE.

    " Đọc Course Name
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    CONDENSE GV_VALUE.
    LS_COURSE-COURSE_NAME = GV_VALUE.

    " Đọc Credits
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_COURSE-CREDITS = GV_VALUE.

    APPEND LS_COURSE TO LT_COURSE.
    GV_TOTAL_COURSE = GV_TOTAL_COURSE + 1.

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
    " Student ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_STUDENT-STUDENT_ID = GV_VALUE.

    " Full Name
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    CONDENSE GV_VALUE.
    LS_STUDENT-FULL_NAME = GV_VALUE.

    " DOB
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    LS_STUDENT-DOB = GV_VALUE.

    " Course
    PERFORM GET_CELL_VALUE USING GV_ROW 4 CHANGING GV_VALUE.
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_STUDENT-COURSE = GV_VALUE.

    APPEND LS_STUDENT TO LT_STUDENT.
    GV_TOTAL_STUDENT = GV_TOTAL_STUDENT + 1.

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
    " Enroll ID
    PERFORM GET_CELL_VALUE USING GV_ROW 1 CHANGING GV_VALUE.
    IF GV_VALUE IS INITIAL. EXIT. ENDIF.
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_ENROLL-ENROLL_ID = GV_VALUE.

    " Student ID
    PERFORM GET_CELL_VALUE USING GV_ROW 2 CHANGING GV_VALUE.
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_ENROLL-STUDENT_ID = GV_VALUE.

    " Course ID
    PERFORM GET_CELL_VALUE USING GV_ROW 3 CHANGING GV_VALUE.
    CONDENSE GV_VALUE NO-GAPS.
    TRANSLATE GV_VALUE TO UPPER CASE.
    LS_ENROLL-COURSE_ID = GV_VALUE.

    " Score
    PERFORM GET_CELL_VALUE USING GV_ROW 4 CHANGING GV_VALUE.
    REPLACE ALL OCCURRENCES OF ',' IN GV_VALUE WITH '.'.
    CONDENSE GV_VALUE.
    LS_ENROLL-SCORE = GV_VALUE.

    APPEND LS_ENROLL TO LT_ENROLL.
    GV_TOTAL_ENROLL = GV_TOTAL_ENROLL + 1.

    IF GV_TOTAL_ENROLL MOD 10 = 0.
      WRITE: / '   │ Processing... Row', GV_ROW, '(', GV_TOTAL_ENROLL, 'records)'.
    ENDIF.

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
*&      Form  VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM VALIDATE_DATA.
  DATA: LT_COURSE_VALID  TYPE TABLE OF ZCOURSE_DEV349,
        LT_STUDENT_VALID TYPE TABLE OF ZSTUDENT_DEV349,
        LT_ENROLL_VALID  TYPE TABLE OF ZENROLL_DEV349.

  WRITE: / '► Step 5: Validating Data...' COLOR 3.

  " Validate COURSE
  LOOP AT LT_COURSE INTO LS_COURSE.
    IF LS_COURSE-COURSE_ID IS NOT INITIAL AND
       LS_COURSE-COURSE_NAME IS NOT INITIAL AND
       LS_COURSE-CREDITS > 0.
      APPEND LS_COURSE TO LT_COURSE_VALID.
      GV_COURSE_VALID = GV_COURSE_VALID + 1.
    ELSE.
      GV_COURSE_INVALID = GV_COURSE_INVALID + 1.
      IF P_LOG = 'X'.
        WRITE: / '   ⚠ Invalid COURSE:', LS_COURSE-COURSE_ID COLOR 6.
      ENDIF.
    ENDIF.
  ENDLOOP.

  " Validate STUDENT
  LOOP AT LT_STUDENT INTO LS_STUDENT.
    IF LS_STUDENT-STUDENT_ID IS NOT INITIAL AND
       LS_STUDENT-FULL_NAME IS NOT INITIAL.
      APPEND LS_STUDENT TO LT_STUDENT_VALID.
      GV_STUDENT_VALID = GV_STUDENT_VALID + 1.
    ELSE.
      GV_STUDENT_INVALID = GV_STUDENT_INVALID + 1.
      IF P_LOG = 'X'.
        WRITE: / '   ⚠ Invalid STUDENT:', LS_STUDENT-STUDENT_ID COLOR 6.
      ENDIF.
    ENDIF.
  ENDLOOP.

  " Validate ENROLL
  LOOP AT LT_ENROLL INTO LS_ENROLL.
    IF LS_ENROLL-ENROLL_ID IS NOT INITIAL AND
       LS_ENROLL-STUDENT_ID IS NOT INITIAL AND
       LS_ENROLL-COURSE_ID IS NOT INITIAL AND
       LS_ENROLL-SCORE BETWEEN 0 AND 10.
      APPEND LS_ENROLL TO LT_ENROLL_VALID.
      GV_ENROLL_VALID = GV_ENROLL_VALID + 1.
    ELSE.
      GV_ENROLL_INVALID = GV_ENROLL_INVALID + 1.
      IF P_LOG = 'X'.
        WRITE: / '   ⚠ Invalid ENROLL:', LS_ENROLL-ENROLL_ID, '(Score:', LS_ENROLL-SCORE, ')' COLOR 6.
      ENDIF.
    ENDIF.
  ENDLOOP.

  " Thay thế tables gốc bằng validated tables
  LT_COURSE  = LT_COURSE_VALID.
  LT_STUDENT = LT_STUDENT_VALID.
  LT_ENROLL  = LT_ENROLL_VALID.

  WRITE: / '   ✓ COURSE  - Valid:', GV_COURSE_VALID, '| Invalid:', GV_COURSE_INVALID COLOR 5.
  WRITE: / '   ✓ STUDENT - Valid:', GV_STUDENT_VALID, '| Invalid:', GV_STUDENT_INVALID COLOR 5.
  WRITE: / '   ✓ ENROLL  - Valid:', GV_ENROLL_VALID, '| Invalid:', GV_ENROLL_INVALID COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CELL_VALUE
*&---------------------------------------------------------------------*
FORM GET_CELL_VALUE USING P_ROW TYPE I P_COL TYPE I CHANGING P_VAL.
  CALL METHOD OF GO_EXCEL 'Cells' = GO_CELL
    EXPORTING #1 = P_ROW #2 = P_COL.

  GET PROPERTY OF GO_CELL 'Value' = P_VAL.

  FREE OBJECT GO_CELL.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CLOSE_EXCEL
*&---------------------------------------------------------------------*
FORM CLOSE_EXCEL.
  WRITE: / '► Step 6: Closing Excel Application...' COLOR 3.

  CALL METHOD OF GO_WORKBOOK 'Close' EXPORTING #1 = 0.
  CALL METHOD OF GO_EXCEL 'Quit'.

  FREE OBJECT: GO_SHEET, GO_SHEETS, GO_WORKBOOK, GO_WORKBOOKS, GO_EXCEL.

  WRITE: / '   ✓ Excel closed successfully' COLOR 5.
  SKIP 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_TO_DATABASE
*&---------------------------------------------------------------------*
FORM SAVE_TO_DATABASE.
  DATA: LT_EXISTING_COURSE  TYPE TABLE OF ZCOURSE_DEV349,
        LT_EXISTING_STUDENT TYPE TABLE OF ZSTUDENT_DEV349,
        LT_EXISTING_ENROLL  TYPE TABLE OF ZENROLL_DEV349,
        LT_TO_INSERT        TYPE TABLE OF ZCOURSE_DEV349,
        LS_EXISTING         TYPE ZCOURSE_DEV349.

  WRITE: / '► Step 7: Saving to Database...' COLOR 3.

  " === COURSE ===
  IF LT_COURSE IS NOT INITIAL.
    WRITE: / '   │ Processing ZCOURSE_DEV349...' COLOR 4.

    IF P_SKIP = 'X'.
      " Chỉ insert records mới
      SELECT * FROM ZCOURSE_DEV349 INTO TABLE LT_EXISTING_COURSE.

      LOOP AT LT_COURSE INTO LS_COURSE.
        READ TABLE LT_EXISTING_COURSE INTO LS_EXISTING
          WITH KEY COURSE_ID = LS_COURSE-COURSE_ID.
        IF SY-SUBRC <> 0.
          APPEND LS_COURSE TO LT_TO_INSERT.
        ELSE.
          GV_SKIPPED_COUNT = GV_SKIPPED_COUNT + 1.
        ENDIF.
      ENDLOOP.

      IF LT_TO_INSERT IS NOT INITIAL.
        INSERT ZCOURSE_DEV349 FROM TABLE LT_TO_INSERT.
        WRITE: / '   ✓ ZCOURSE_DEV349:', LINES( LT_TO_INSERT ), 'inserted,', GV_SKIPPED_COUNT, 'skipped' COLOR 5.
      ENDIF.
    ELSE.
      " Update/Insert mode
      MODIFY ZCOURSE_DEV349 FROM TABLE LT_COURSE.
      IF SY-SUBRC = 0.
        WRITE: / '   ✓ ZCOURSE_DEV349:', GV_COURSE_VALID, 'records updated' COLOR 5.
      ELSE.
        WRITE: / '   ✖ ZCOURSE_DEV349: Update failed!' COLOR 6.
        GV_ERROR_COUNT = GV_ERROR_COUNT + 1.
      ENDIF.
    ENDIF.
  ENDIF.

  " === STUDENT ===
  IF LT_STUDENT IS NOT INITIAL.
    WRITE: / '   │ Processing ZSTUDENT_DEV349...' COLOR 4.
    MODIFY ZSTUDENT_DEV349 FROM TABLE LT_STUDENT.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ ZSTUDENT_DEV349:', GV_STUDENT_VALID, 'records updated' COLOR 5.
    ELSE.
      WRITE: / '   ✖ ZSTUDENT_DEV349: Update failed!' COLOR 6.
      GV_ERROR_COUNT = GV_ERROR_COUNT + 1.
    ENDIF.
  ENDIF.

  " === ENROLL ===
  IF LT_ENROLL IS NOT INITIAL.
    WRITE: / '   │ Processing ZENROLL_DEV349...' COLOR 4.
    MODIFY ZENROLL_DEV349 FROM TABLE LT_ENROLL.
    IF SY-SUBRC = 0.
      WRITE: / '   ✓ ZENROLL_DEV349:', GV_ENROLL_VALID, 'records updated' COLOR 5.
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
  GET TIME STAMP FIELD GV_END_TIME.
  GV_DURATION = GV_END_TIME - GV_START_TIME.
  GV_TOTAL_RECORD = GV_COURSE_VALID + GV_STUDENT_VALID + GV_ENROLL_VALID.
  GV_TOTAL_INVALID = GV_COURSE_INVALID + GV_STUDENT_INVALID + GV_ENROLL_INVALID.

  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║                    IMPORT SUMMARY REPORT                    ║' COLOR 1.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.
  WRITE: / '║ End Time    :', SY-DATUM, SY-UZEIT.
  WRITE: / '║ Duration    :', GV_DURATION, 'seconds'.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ COURSE Table :'.
  WRITE: / '║   - Read     :', GV_TOTAL_COURSE.
  WRITE: / '║   - Valid    :', GV_COURSE_VALID COLOR 5.
  WRITE: / '║   - Invalid  :', GV_COURSE_INVALID COLOR 6.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ STUDENT Table:'.
  WRITE: / '║   - Read     :', GV_TOTAL_STUDENT.
  WRITE: / '║   - Valid    :', GV_STUDENT_VALID COLOR 5.
  WRITE: / '║   - Invalid  :', GV_STUDENT_INVALID COLOR 6.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ ENROLL Table :'.
  WRITE: / '║   - Read     :', GV_TOTAL_ENROLL.
  WRITE: / '║   - Valid    :', GV_ENROLL_VALID COLOR 5.
  WRITE: / '║   - Invalid  :', GV_ENROLL_INVALID COLOR 6.
  WRITE: / '├───────────────────────────────────────────────────────────────'.
  WRITE: / '║ Total Valid  :', GV_TOTAL_RECORD COLOR 3.
  WRITE: / '║ Total Invalid:', GV_TOTAL_INVALID COLOR 6.
  WRITE: / '║ Skipped      :', GV_SKIPPED_COUNT.
  WRITE: / '║ Errors       :', GV_ERROR_COUNT.
  WRITE: / '═══════════════════════════════════════════════════════════════' COLOR 1.

  IF GV_ERROR_COUNT = 0 AND GV_TOTAL_INVALID = 0.
    WRITE: / '║           ✓ ALL DATA IMPORTED SUCCESSFULLY!                ║' COLOR 5.
  ELSEIF GV_ERROR_COUNT > 0.
    WRITE: / '║           ⚠ IMPORT COMPLETED WITH ERRORS!                  ║' COLOR 6.
  ELSE.
    WRITE: / '║           ⚠ IMPORT COMPLETED WITH VALIDATION ISSUES!       ║' COLOR 6.
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
