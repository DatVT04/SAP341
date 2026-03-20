*&---------------------------------------------------------------------*
*& Report ZDEV349_EXTRA2
*& Description: Date & Time Calculations
*&---------------------------------------------------------------------*
REPORT zdev349_extra2.

DATA: lv_date       TYPE d,
      lv_time       TYPE t,
      lv_date_str   TYPE string,
      lv_day        TYPE string,
      lv_month      TYPE string,
      lv_year       TYPE string,
      lv_diff       TYPE i,
      lv_future     TYPE d,
      lv_past       TYPE d.

START-OF-SELECTION.

  lv_date = sy-datum.
  lv_time = sy-uzeit.

  " Extract parts
  lv_day   = lv_date+6(2).
  lv_month = lv_date+4(2).
  lv_year  = lv_date+0(4).

  " Add 30 days
  lv_future = lv_date + 30.

  " Subtract 10 days
  lv_past = lv_date - 10.

  " Difference between two dates
  DATA: lv_date1 TYPE d VALUE '20240101',
        lv_date2 TYPE d VALUE '20241231'.
  lv_diff = lv_date2 - lv_date1.

  WRITE: / '========================================'.
  WRITE: / 'ZDEV349_EXTRA2: Date & Time'.
  WRITE: / '========================================'.
  WRITE: / 'Today         :', lv_date.
  WRITE: / 'Current Time  :', lv_time.
  WRITE: / 'Day           :', lv_day.
  WRITE: / 'Month         :', lv_month.
  WRITE: / 'Year          :', lv_year.
  WRITE: / '+30 Days      :', lv_future.
  WRITE: / '-10 Days      :', lv_past.
  WRITE: / 'Days in 2024  :', lv_diff.
  WRITE: / 'SY-DATUM      :', sy-datum.
  WRITE: / 'SY-UZEIT      :', sy-uzeit.
  WRITE: / 'SY-UNAME      :', sy-uname.
  WRITE: / 'SY-MANDT      :', sy-mandt.
