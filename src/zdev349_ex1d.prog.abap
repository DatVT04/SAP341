*&---------------------------------------------------------------------*
*& Report ZDEV349_EX1D
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_ex1d.


WRITE: / |User={ sy-uname } Client={ sy-mandt } Lang={ sy-langu }|.
WRITE: / |Date={ sy-datum DATE = ISO } Time={ sy-uzeit TIME = ISO }|.
WRITE: / |Tcode={ sy-tcode } Host={ sy-host } DB={ sy-dbsys }|.
" Demonstrate sy-subrc with SELECT and READ TABLE
DATA lt TYPE STANDARD TABLE OF sflight WITH EMPTY KEY.
SELECT * FROM sflight INTO TABLE lt UP TO 1 ROWS.
WRITE: / |After SELECT sy-subrc={ sy-subrc } Lines={ lines( lt ) }|.
READ TABLE lt INDEX 2 INTO DATA(ls).
WRITE: / |READ idx=2 sy-subrc={ sy-subrc }|.
