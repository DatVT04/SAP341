*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB7_INHERITANCE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab7_inheritance.

DATA:
  lo_student  TYPE REF TO zcl_dev349_student_adv,
  lo_lecturer TYPE REF TO zcl_dev349_lecturer_adv,
  lo_person   TYPE REF TO zcl_dev349_person.

DATA: lt_list TYPE TABLE OF REF TO zcl_dev349_person.

START-OF-SELECTION.

* Student
  lo_student = NEW #( ).
  lo_student->set_core_info(
    iv_id   = 'SV01'
    iv_name = 'Nguyen Van A'
  ).
  lo_student->set_academic_info( iv_gpa = '8.5' ).
  APPEND lo_student TO lt_list.

* Lecturer
  lo_lecturer = NEW #( ).
  lo_lecturer->set_core_info(
    iv_id   = 'GV01'
    iv_name = 'Thay Le'
  ).
  lo_lecturer->set_job_info( iv_salary = '2000' ).
  APPEND lo_lecturer TO lt_list.

  WRITE: / '--- POLYMORPHISM DEMO ---'.

  LOOP AT lt_list INTO lo_person.
    WRITE: / lo_person->get_info( ).
    lo_person->zif_dev349_print~print_log( ).
    ULINE.
  ENDLOOP.
