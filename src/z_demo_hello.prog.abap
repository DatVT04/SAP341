*&---------------------------------------------------------------------*
*& Report Z_DEMO_HELLO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_DEMO_HELLO.
*--- Khai báo tham số trên selection screen
PARAMETERS: P_NAME TYPE STRING OBLIGATORY,
            P_AGE  TYPE I OBLIGATORY.

START-OF-SELECTION.

*--- In tiêu đề với màu sắc và căn chỉnh
  WRITE: / '*** Demo Hello World ABAP ***' COLOR COL_HEADING CENTERED.

*--- Xuống dòng, in lời chào với căn chỉnh trái
  WRITE: / 'Hello' COLOR COL_POSITIVE LEFT-JUSTIFIED,
           P_NAME COLOR COL_NORMAL.

*--- In tuổi với căn chỉnh phải
  WRITE: / 'Bạn' COLOR COL_NORMAL,
           P_AGE RIGHT-JUSTIFIED COLOR COL_TOTAL,
           'tuổi' COLOR COL_NORMAL.
