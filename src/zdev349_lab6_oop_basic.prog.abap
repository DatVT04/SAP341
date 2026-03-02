*&---------------------------------------------------------------------*
*& Report ZDEV349_LAB6_OOP_BASIC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_LAB6_OOP_BASIC.

START-OF-SELECTION.

*--- Student 1 ---*
DATA(lo_student_1) =
  NEW zcl_student_dev349(
    iv_id   = 'SE001'
    iv_name = 'Pham Van A'
  ).

lo_student_1->set_gpa( iv_score = '8.5' ).
lo_student_1->display_info( ).

WRITE: / 'GPA via Getter:', lo_student_1->get_gpa( ).

IF lo_student_1->get_gpa( ) > 8.
  WRITE: / 'This student is Excellent!'.
ENDIF.

ULINE.

*--- Student 2 ---*
DATA(lo_student_2) =
  NEW zcl_student_dev349(
    iv_id   = 'SE002'
    iv_name = 'Tran Thi B'
  ).

lo_student_2->set_gpa( iv_score = '9.2' ).
lo_student_2->display_info( ).

*--- Static Attribute Demo ---*
WRITE: / 'Total Students Created:',
         zcl_student_dev349=>gv_count.
