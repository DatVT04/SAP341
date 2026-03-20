*&---------------------------------------------------------------------*
*& Report ZDEV349_EXTRA3
*& Description: Internal Table with Structures - Student Management
*&---------------------------------------------------------------------*
REPORT zdev349_extra3.

" Define structure
TYPES: BEGIN OF ty_student,
         id      TYPE i,
         name    TYPE string,
         age     TYPE i,
         score   TYPE p DECIMALS 2,
         grade   TYPE c LENGTH 1,
       END OF ty_student.

DATA: lt_students TYPE TABLE OF ty_student,
      ls_student  TYPE ty_student,
      lv_avg      TYPE p DECIMALS 2,
      lv_total    TYPE p DECIMALS 2,
      lv_count    TYPE i.

START-OF-SELECTION.

  " Populate data
  ls_student-id = 1. ls_student-name = 'Nguyen Van A'. ls_student-age = 20. ls_student-score = '8.50'.
  APPEND ls_student TO lt_students.

  ls_student-id = 2. ls_student-name = 'Tran Thi B'.   ls_student-age = 21. ls_student-score = '7.00'.
  APPEND ls_student TO lt_students.

  ls_student-id = 3. ls_student-name = 'Le Van C'.     ls_student-age = 19. ls_student-score = '9.20'.
  APPEND ls_student TO lt_students.

  ls_student-id = 4. ls_student-name = 'Pham Thi D'.   ls_student-age = 22. ls_student-score = '5.50'.
  APPEND ls_student TO lt_students.

  ls_student-id = 5. ls_student-name = 'Hoang Van E'.  ls_student-age = 20. ls_student-score = '6.80'.
  APPEND ls_student TO lt_students.

  " Calculate total and count
  LOOP AT lt_students INTO ls_student.
    lv_total = lv_total + ls_student-score.
    lv_count = lv_count + 1.
  ENDLOOP.

  IF lv_count > 0.
    lv_avg = lv_total / lv_count.
  ENDIF.

  " Assign grades using separate loop with field-symbol
  FIELD-SYMBOLS: <fs_student> TYPE ty_student.

  LOOP AT lt_students ASSIGNING <fs_student>.
    IF <fs_student>-score >= '9.00'.
      <fs_student>-grade = 'A'.
    ELSEIF <fs_student>-score >= '8.00'.
      <fs_student>-grade = 'B'.
    ELSEIF <fs_student>-score >= '6.50'.
      <fs_student>-grade = 'C'.
    ELSEIF <fs_student>-score >= '5.00'.
      <fs_student>-grade = 'D'.
    ELSE.
      <fs_student>-grade = 'F'.
    ENDIF.
  ENDLOOP.

  " Sort by score descending
  SORT lt_students BY score DESCENDING.

  " Display
  WRITE: / '========================================'.
  WRITE: / 'ZDEV349_EXTRA3: Student Management'.
  WRITE: / '========================================'.
  WRITE: / 'ID | Name            | Age | Score | Grade'.
  WRITE: / '---+-----------------+-----+-------+------'.

  LOOP AT lt_students INTO ls_student.
    WRITE: / ls_student-id,       '|',
             ls_student-name,     '|',
             ls_student-age,      '|',
             ls_student-score,    '|',
             ls_student-grade.
  ENDLOOP.

  WRITE: / '========================================'.
  WRITE: / 'Total Students:', lv_count.
  WRITE: / 'Average Score :', lv_avg.
