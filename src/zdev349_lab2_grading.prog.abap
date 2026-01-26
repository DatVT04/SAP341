*&---------------------------------------------------------------------*
*& Report zdev349_lab2_grading
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_lab2_grading.

*--- 1. INPUT PARAMETERS (Đầu vào) ---*
" OBLIGATORY: Bắt buộc phải nhập, không được để trống
PARAMETERS: PA_SID   TYPE C LENGTH 8 OBLIGATORY,    "Student ID
            PA_NAME  TYPE STRING,                   "Student Name
            PA_ASS   TYPE P DECIMALS 2 OBLIGATORY,  "Assignment Score
            PA_MID   TYPE P DECIMALS 2 OBLIGATORY,  "Midterm Score
            PA_FINAL TYPE P DECIMALS 2 OBLIGATORY.  "Final Score

*--- Giải pháp Thử thách 1: Validate đầu vào ---*
IF PA_ASS < 0 OR PA_ASS > 10 OR PA_MID < 0 OR PA_MID > 10 OR PA_FINAL < 0 OR PA_FINAL > 10.
  MESSAGE 'Dữ liệu điểm không hợp lệ (Phải từ 0-10)!' TYPE 'E'.
  " TYPE 'E' sẽ dừng chương trình và hiển thị màu đỏ
ENDIF.

*--- 2. DATA DECLARATION (Khai báo biến) ---*
DATA: GV_GPA  TYPE P DECIMALS 2, "Biến chứa điểm trung bình
      GV_RANK TYPE STRING.       "Biến chứa xếp loại

*--- 3. CONSTANTS (Hằng số - Best Practice) ---*
CONSTANTS: GC_WEIGHT_ASS   TYPE P DECIMALS 2 VALUE '0.2', "20%
           GC_WEIGHT_MID   TYPE P DECIMALS 2 VALUE '0.3', "30%
           GC_WEIGHT_FINAL TYPE P DECIMALS 2 VALUE '0.5'. "50%

*--- 4. MAIN LOGIC (Xử lý chính) ---*

" Tính GPA theo trọng số
GV_GPA = ( PA_ASS * GC_WEIGHT_ASS ) +
         ( PA_MID * GC_WEIGHT_MID ) +
         ( PA_FINAL * GC_WEIGHT_FINAL ).

" Xếp loại (Business Logic)
IF GV_GPA >= 9.
  GV_RANK = TEXT-001. "'Xuất sắc (Excellent)'.
ELSEIF GV_GPA >= 8.
  GV_RANK = TEXT-002. " 'Giỏi (Good)'.
ELSEIF GV_GPA >= 5.
  GV_RANK = 'Đạt (Pass)'.
ELSE.
  GV_RANK = 'Học lại (Retake)'.
ENDIF.

*--- 5. OUTPUT (Hiển thị) ---*
WRITE: / '--- KẾT QUẢ HỌC TẬP ---' COLOR 4.
WRITE: / 'Sinh viên:', PA_NAME, '(', PA_SID, ')'.
WRITE: / 'Điểm thành phần:', PA_ASS, '|', PA_MID, '|', PA_FINAL.
ULINE. "Kẻ đường ngang
WRITE: / 'GPA TỔNG KẾT:', GV_GPA COLOR 5. "Màu xanh lá
WRITE: / 'XẾP LOẠI:',     GV_RANK COLOR 6. "Màu đỏ
