FUNCTION zfm_dev349_round_score.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(CV_SCORE) TYPE  P
*"----------------------------------------------------------------------
  " Sử dụng hàm làm tròn có sẵn của ABAP 7.4+
  " round( val = ... dec = ... mode = ... )
  " Mode 2 = ROUND_UP (Làm tròn lên). Ví dụ: 8.21 -> 8.3
  cv_score = round( val = cv_score dec = 1 mode = 2 ).

ENDFUNCTION.
