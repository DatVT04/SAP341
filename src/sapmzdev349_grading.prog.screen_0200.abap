PROCESS BEFORE OUTPUT.
  MODULE status_0200.
  LOOP AT it_enroll INTO wa_enroll
       WITH CONTROL tc_enr
       CURSOR tc_enr-current_line.
  ENDLOOP.

PROCESS AFTER INPUT.
  LOOP AT it_enroll.
    MODULE tc_enr_modify.
  ENDLOOP.
  MODULE user_command_0200.
