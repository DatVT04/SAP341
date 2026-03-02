*----------------------------------------------------------------------*
***INCLUDE MZDEV349_GRADING_F4_CLASS_HI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_CLASS_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_class_help INPUT.
  " Khai báo đúng - dùng structure có field course
  TYPES: BEGIN OF ty_class,
           course TYPE zstudent_dev349-course,
         END OF ty_class.
  DATA: lt_class  TYPE TABLE OF ty_class,
        lt_return TYPE TABLE OF ddshretval.

  SELECT DISTINCT course
    FROM zstudent_dev349
    INTO CORRESPONDING FIELDS OF TABLE lt_class.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield      = 'COURSE'
      dynpprog      = sy-repid
      dynpnr        = sy-dynnr
      dynprofield   = 'GV_CLASS'
      value_org     = 'S'
    TABLES
      value_tab     = lt_class
      return_tab    = lt_return.
ENDMODULE.
