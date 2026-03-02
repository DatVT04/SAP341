PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  LOOP AT it_students INTO wa_student
       WITH CONTROL tc_stu
       CURSOR tc_stu-current_line.
  ENDLOOP.


PROCESS AFTER INPUT.

  LOOP AT it_students.
    MODULE tc_stu_modify.
  ENDLOOP.

  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD GV_CLASS MODULE f4_class_help.
