*&---------------------------------------------------------------------*
*& Report ZDEV349_EXTRA4
*& Description: ALV Grid Display - Product Catalog
*&---------------------------------------------------------------------*
REPORT zdev349_extra4.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_product,
         prod_id    TYPE char10,
         prod_name  TYPE char40,
         category   TYPE char20,
         price      TYPE p DECIMALS 2,
         quantity   TYPE i,
         total      TYPE p DECIMALS 2,
       END OF ty_product.

DATA: lt_products  TYPE TABLE OF ty_product,
      ls_product   TYPE ty_product,
      lt_fieldcat  TYPE slis_t_fieldcat_alv,
      ls_fieldcat  TYPE slis_fieldcat_alv,
      ls_layout    TYPE slis_layout_alv.

START-OF-SELECTION.

  " Fill sample data
  CLEAR ls_product.
  ls_product-prod_id = 'P001'. ls_product-prod_name = 'Laptop Dell XPS'.
  ls_product-category = 'Electronics'. ls_product-price = '25000000'. ls_product-quantity = 10.
  ls_product-total = ls_product-price * ls_product-quantity.
  APPEND ls_product TO lt_products.

  CLEAR ls_product.
  ls_product-prod_id = 'P002'. ls_product-prod_name = 'Mouse Logitech'.
  ls_product-category = 'Accessories'. ls_product-price = '500000'. ls_product-quantity = 50.
  ls_product-total = ls_product-price * ls_product-quantity.
  APPEND ls_product TO lt_products.

  CLEAR ls_product.
  ls_product-prod_id = 'P003'. ls_product-prod_name = 'Keyboard Mechanical'.
  ls_product-category = 'Accessories'. ls_product-price = '1200000'. ls_product-quantity = 30.
  ls_product-total = ls_product-price * ls_product-quantity.
  APPEND ls_product TO lt_products.

  CLEAR ls_product.
  ls_product-prod_id = 'P004'. ls_product-prod_name = 'Monitor 27 inch'.
  ls_product-category = 'Electronics'. ls_product-price = '8500000'. ls_product-quantity = 15.
  ls_product-total = ls_product-price * ls_product-quantity.
  APPEND ls_product TO lt_products.

  CLEAR ls_product.
  ls_product-prod_id = 'P005'. ls_product-prod_name = 'Webcam HD 1080p'.
  ls_product-category = 'Accessories'. ls_product-price = '900000'. ls_product-quantity = 25.
  ls_product-total = ls_product-price * ls_product-quantity.
  APPEND ls_product TO lt_products.

  " Build field catalog
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PROD_ID'.
  ls_fieldcat-seltext_m = 'Product ID'.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PROD_NAME'.
  ls_fieldcat-seltext_m = 'Product Name'.
  ls_fieldcat-outputlen = 40.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_m = 'Category'.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE'.
  ls_fieldcat-seltext_m = 'Unit Price (VND)'.
  ls_fieldcat-outputlen = 18.
  ls_fieldcat-do_sum    = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QUANTITY'.
  ls_fieldcat-seltext_m = 'Qty'.
  ls_fieldcat-outputlen = 8.
  ls_fieldcat-do_sum    = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TOTAL'.
  ls_fieldcat-seltext_m = 'Total (VND)'.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-do_sum    = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  " Layout
  ls_layout-zebra             = 'X'.
  ls_layout-colwidth_optimize = 'X'.

  " Call ALV  ← bỏ I_PROGRAM_NAME
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = lt_fieldcat
      is_layout     = ls_layout
      i_save        = 'A'
    TABLES
      t_outtab      = lt_products
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error calling ALV Grid.' TYPE 'E'.
  ENDIF.
