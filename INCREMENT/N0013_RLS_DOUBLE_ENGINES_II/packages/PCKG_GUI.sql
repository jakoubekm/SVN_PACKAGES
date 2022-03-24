
  CREATE OR REPLACE PACKAGE "PDC"."PCKG_GUI"
IS
    C_PCKG_NAME   CONSTANT VARCHAR2(64) := 'PCKG_GUI';



    TYPE REC_GUI_DETAILS IS RECORD(
        STREAM_ID          VARCHAR2(256)
      , STREAM_NAME        VARCHAR2(256)
      , RUNABLE            VARCHAR2(256)
      , N_FINISHED         NUMBER
      , N_FORCE_FINISHED   NUMBER
      , N_VOID_FINISHED    NUMBER
      , N_FINISHED_ODDLY   NUMBER
      , N_RUNNABLE         NUMBER
      , N_RUNNING          NUMBER
      , N_FAILED           NUMBER
      , N_BLOCKED          NUMBER
      , N_NOT_DEFINED      NUMBER
      , N_TOTAL_NUMBER     NUMBER
    );

    TYPE REF_GUI_DETAILS IS REF CURSOR
        RETURN REC_GUI_DETAILS;


    TYPE REC_JOBS_DETAILS IS RECORD(
        JOB_ID         VARCHAR2(256)
      , JOB_NAME       VARCHAR2(256)
      , STREAM_NAME    VARCHAR2(256)
      , ENGINE_ID      VARCHAR2(256)
      , N_RUN          VARCHAR2(256)
      , LAST_UPDATE    VARCHAR2(256)
      , STATUS         VARCHAR2(256)
      , TABLE_NAME     VARCHAR2(256)
      , JOB_CATEGORY   VARCHAR2(256)
      , JOB_TYPE       VARCHAR2(256)
      , PHASE          VARCHAR2(256)
      , SYSTEM_NAME    VARCHAR2(256)
    );

    TYPE REF_JOBS_DETAILS IS REF CURSOR
        RETURN REC_JOBS_DETAILS;


    TYPE REC_SESS_JOBS IS RECORD(
        JOB_ID           VARCHAR2(256)
      , STREAM_ID        VARCHAR2(256)
      , JOB_NAME         VARCHAR2(256)
      , STREAM_NAME      VARCHAR2(256)
      , STATUS           VARCHAR2(256)
      , LAST_UPDATE      VARCHAR2(256)
      , LOAD_DATE        VARCHAR2(256)
      , PRIORITY         VARCHAR2(256)
      , CMD_LINE         VARCHAR2(1024)
      , SRC_SYS_ID       VARCHAR2(256)
      , PHASE            VARCHAR2(256)
      , TABLE_NAME       VARCHAR2(256)
      , JOB_CATEGORY     VARCHAR2(256)
      , JOB_TYPE         VARCHAR2(256)
      , TOUGHNESS        VARCHAR2(256)
      , CONT_ANYWAY      VARCHAR2(256)
      , RESTART          VARCHAR2(256)
      , ALWAYS_RESTART   VARCHAR2(256)
      , N_RUN            VARCHAR2(256)
      , MAX_RUNS         VARCHAR2(256)
      , WAITING_HR       VARCHAR2(256)
      , DEADLINE_HR      VARCHAR2(256)
      , APPLICATION_ID   VARCHAR2(256)
      , ENGINE_ID        VARCHAR2(256)
      , ABORTABLE        VARCHAR2(256)
    );

    TYPE REF_SESS_JOBS IS REF CURSOR
        RETURN REC_SESS_JOBS;


    /******************************************************************************/


    TYPE REC_GUI_STREAM_DETAILS IS RECORD(
        STREAM_ID          VARCHAR2(256)
      , STREAM_NAME        VARCHAR2(256)
      , RUNABLE            VARCHAR2(256)
      , N_FINISHED         NUMBER
      , N_FORCE_FINISHED   NUMBER
      , N_VOID_FINISHED    NUMBER
      , N_FINISHED_ODDLY   NUMBER
      , N_RUNNABLE         NUMBER
      , N_RUNNING          NUMBER
      , N_FAILED           NUMBER
      , N_BLOCKED          NUMBER
      , N_NOT_DEFINED      NUMBER
      , N_TOTAL_NUMBER     NUMBER
    );

    TYPE REF_GUI_STREAM_DETAILS IS REF CURSOR
        RETURN REC_GUI_STREAM_DETAILS;


    TYPE REC_GUI_STREAM_STATS IS RECORD(RUNABLE VARCHAR2(256), CNT VARCHAR2(256));

    TYPE REF_GUI_STREAM_STATS IS REF CURSOR
        RETURN REC_GUI_STREAM_STATS;


    TYPE REC_GUI_STREAM_DET_1 IS RECORD(
        STREAM_ID     VARCHAR(256)
      , STREAM_NAME   VARCHAR(256)
      , STREAM_DESC   VARCHAR(256)
      , NOTE          VARCHAR(256)
    );

    TYPE REF_GUI_STREAM_DET_1 IS REF CURSOR
        RETURN REC_GUI_STREAM_DET_1;



    TYPE REC_GUI_STREAM_DET_2 IS RECORD(
        STREAM_ID     VARCHAR(256)
      , STREAM_NAME   VARCHAR(256)
      , STREAM_DESC   VARCHAR(256)
      , NOTE          VARCHAR(256)
    );

    TYPE REF_GUI_STREAM_DET_2 IS REF CURSOR
        RETURN REC_GUI_STREAM_DET_2;

    TYPE REC_GUI_STREAM_DET_3 IS RECORD(JOB_ID VARCHAR(256), JOB_NAME VARCHAR(256), STREAM_ID VARCHAR(256));

    TYPE REF_GUI_STREAM_DET_3 IS REF CURSOR
        RETURN REC_GUI_STREAM_DET_3;


    TYPE REC_GUI_JOB_STATS IS RECORD(STATUS VARCHAR2(256), DESCRIPTION VARCHAR2(256), CNT VARCHAR2(256));

    TYPE REF_GUI_JOB_STATS IS REF CURSOR
        RETURN REC_GUI_JOB_STATS;


    TYPE REC_GUI_JOB_DETAILS IS RECORD(
        JOB_ID         VARCHAR(256)
      , JOB_NAME       VARCHAR(256)
      , STREAM_NAME    VARCHAR(256)
      , ENGINE_ID      VARCHAR(256)
      , N_RUN          VARCHAR(256)
      , LAST_UPDATE    VARCHAR(256)
      , STATUS         VARCHAR(256)
      , TABLE_NAME     VARCHAR(256)
      , JOB_CATEGORY   VARCHAR(256)
      , JOB_TYPE       VARCHAR(256)
      , PHASE          VARCHAR(256)
      , SYSTEM_NAME    VARCHAR(256)
    );

    TYPE REF_GUI_JOB_DETAILS IS REF CURSOR
        RETURN REC_GUI_JOB_DETAILS;


    TYPE REC_GUI_HEADER_ENG_STATUS IS RECORD(ENG_PARAM_CD CTRL_PARAMETERS.PARAM_CD%TYPE, ENG_STATUS VARCHAR2(3));

    TYPE REF_GUI_HEADER_ENG_STATUS IS REF CURSOR
        RETURN REC_GUI_HEADER_ENG_STATUS;

    TYPE REC_GUI_HEADER_SYS_STATUS IS RECORD(SYS_PARAM_CD CTRL_PARAMETERS.PARAM_VAL_CHAR%TYPE, SYS_STATUS VARCHAR2(3));

    TYPE REF_GUI_HEADER_SYS_STATUS IS REF CURSOR
        RETURN REC_GUI_HEADER_SYS_STATUS;

    TYPE REC_GUI_HEADER_SCH_STATUS IS RECORD(SCH_PARAM_CD CTRL_PARAMETERS.PARAM_CD%TYPE, SCH_STATUS VARCHAR2(3));

    TYPE REF_GUI_HEADER_SCH_STATUS IS REF CURSOR
        RETURN REC_GUI_HEADER_SCH_STATUS;

    TYPE REC_GUI_CTRL_STREAM IS RECORD(STREAM_NAME VARCHAR2(256), STREAM_DESC VARCHAR2(256), NOTE VARCHAR2(256));

    TYPE REF_GUI_CTRL_STREAM IS REF CURSOR
        RETURN REC_GUI_CTRL_STREAM;

    TYPE REC_GUI_CTRL_STREAM_DEP IS RECORD(
        STREAM_NAME   VARCHAR2(256)
      , STREAM_DESC   VARCHAR2(256)
      , NOTE          VARCHAR2(256)
      , REL_TYPE      VARCHAR2(256)
    );

    TYPE REF_GUI_CTRL_STREAM_DEP IS REF CURSOR
        RETURN REC_GUI_CTRL_STREAM_DEP;


    TYPE REC_GUI_CTRL_JOB IS RECORD(
        JOB_NAME         VARCHAR(255)
      , STREAM_NAME      VARCHAR(255)
      , PRIORITY         VARCHAR(255)
      , CMD_LINE         VARCHAR(255)
      , SRC_SYS_ID       VARCHAR(255)
      , PHASE            VARCHAR(255)
      , TABLE_NAME       VARCHAR(255)
      , JOB_CATEGORY     VARCHAR(255)
      , JOB_TYPE         VARCHAR(255)
      , TOUGHNESS        VARCHAR(255)
      , CONT_ANYWAY      VARCHAR(255)
      , MAX_RUNS         VARCHAR(255)
      , ALWAYS_RESTART   VARCHAR(255)
      , STATUS_BEGIN     VARCHAR(255)
      , WAITING_HR       VARCHAR(255)
      , DEADLINE_HR      VARCHAR(255)
      , ENGINE_ID        VARCHAR(255)
      , JOB_DESC         VARCHAR(255)
      , AUTHOR           VARCHAR(255)
      , NOTE             VARCHAR(255)
    );

    TYPE REF_GUI_CTRL_JOB IS REF CURSOR
        RETURN REC_GUI_CTRL_JOB;

    TYPE REC_GUI_CTRL_JOB_DEP IS RECORD(
        JOB_NAME         VARCHAR(255)
      , STREAM_NAME      VARCHAR(255)
      , PRIORITY         VARCHAR(255)
      , CMD_LINE         VARCHAR(255)
      , SRC_SYS_ID       VARCHAR(255)
      , PHASE            VARCHAR(255)
      , TABLE_NAME       VARCHAR(255)
      , JOB_CATEGORY     VARCHAR(255)
      , JOB_TYPE         VARCHAR(255)
      , CONT_ANYWAY      VARCHAR(255)
      , MAX_RUNS         VARCHAR(255)
      , ALWAYS_RESTART   VARCHAR(255)
      , STATUS_BEGIN     VARCHAR(255)
      , WAITING_HR       VARCHAR(255)
      , DEADLINE_HR      VARCHAR(255)
      , ENGINE_ID        VARCHAR(255)
      , JOB_DESC         VARCHAR(255)
      , AUTHOR           VARCHAR(255)
      , NOTE             VARCHAR(255)
      , REL_TYPE         VARCHAR(255)
    );

    TYPE REF_GUI_CTRL_JOB_DEP IS REF CURSOR
        RETURN REC_GUI_CTRL_JOB_DEP;


    TYPE REC_GUI_CTRL_STREAM_PLAN IS RECORD(ROW_ID ROWID, RUNPLAN_IN VARCHAR2(256), COUNTRY_CD_IN VARCHAR2(4));

    TYPE REF_GUI_CTRL_STREAM_PLAN IS REF CURSOR
        RETURN REC_GUI_CTRL_STREAM_PLAN;

    TYPE REC_GUI_CTRL_JOB_TAB_REF IS RECORD(DATABASE_NAME VARCHAR2(256), TABLE_NAME VARCHAR2(256), LOCK_TYPE VARCHAR2(256));

    TYPE REF_GUI_CTRL_JOB_TAB_REF IS REF CURSOR
        RETURN REC_GUI_CTRL_JOB_TAB_REF;


    TYPE REC_GUI_CHM IS RECORD(
        LABEL_NAME     VARCHAR2(256)
      , LABEL_STATUS   VARCHAR2(256)
      , USER_NAME      VARCHAR2(256)
      , CREATE_TS      VARCHAR2(256)
      , DESCRIPTION    VARCHAR2(256)
      , ENV            VARCHAR2(256)
    );

    TYPE REF_GUI_CHM IS REF CURSOR
        RETURN REC_GUI_CHM;

    TYPE REC_GUI_ODD_JOB IS RECORD(
        JOB_ID         SESS_JOB.JOB_ID%TYPE
      , JOB_NAME       SESS_JOB.JOB_NAME%TYPE
      , STREAM_NAME    SESS_JOB.STREAM_NAME%TYPE
      , ENGINE_ID      SESS_JOB.ENGINE_ID%TYPE
      , N_RUN          SESS_JOB.N_RUN%TYPE
      , LAST_UPDATE    SESS_JOB.LAST_UPDATE%TYPE
      , STATUS         SESS_JOB.STATUS%TYPE
      , TABLE_NAME     SESS_JOB.TABLE_NAME%TYPE
      , JOB_CATEGORY   SESS_JOB.JOB_CATEGORY%TYPE
      , JOB_TYPE       SESS_JOB.JOB_TYPE%TYPE
      , PHASE          SESS_JOB.PHASE%TYPE
      , SYSTEM_NAME    SESS_JOB.SYSTEM_NAME%TYPE
      , EXP_AVG_FINISH    SESS_JOB.LAST_UPDATE%TYPE
    );

    TYPE REF_GUI_ODD_JOB IS REF CURSOR
        RETURN REC_GUI_ODD_JOB;

    /******************************************************************************/
    -- JOB Commands
    /******************************************************************************/

    TYPE REC_GUI_RIGHTS_OUT IS RECORD( /*ACCESS_ROLE    GUI_ACCESS_ROLE_RIGHT_REF.ACCESS_ROLE%TYPE
                                     ,*/
                                      GUI_PAGE GUI_ACCESS_ROLE_RIGHT_REF.GUI_PAGE%TYPE, ACCESS_RIGHT GUI_ACCESS_ROLE_RIGHT_REF.ACCESS_RIGHT%TYPE);

    TYPE REF_GUI_RIGHTS_OUT IS REF CURSOR
        RETURN REC_GUI_RIGHTS_OUT;

    TYPE REC_LABEL_BP_DETAILS IS RECORD(CMD GUI_CHANGE_CONTROL.CMD%TYPE);

    TYPE REF_LABEL_BP_DETAILS IS REF CURSOR
        RETURN REC_LABEL_BP_DETAILS;



    TYPE REC_LOGS_STATLOGEVENTHIST IS RECORD(
        LOG_EVENT_ID             STAT_LOG_EVENT_HIST.LOG_EVENT_ID%TYPE
      , EVENT_TS                 STAT_LOG_EVENT_HIST.EVENT_TS%TYPE
      , NOTIFICATION_CD          STAT_LOG_EVENT_HIST.NOTIFICATION_CD%TYPE
      , LOAD_DATE                STAT_LOG_EVENT_HIST.LOAD_DATE%TYPE
      , JOB_NAME                 STAT_LOG_EVENT_HIST.JOB_NAME%TYPE
      , JOB_ID                   STAT_LOG_EVENT_HIST.JOB_ID%TYPE
      , SEVERITY_LEVEL_CD        STAT_LOG_EVENT_HIST.SEVERITY_LEVEL_CD%TYPE
      , ERROR_CD                 STAT_LOG_EVENT_HIST.ERROR_CD%TYPE
      , EVENT_CD                 STAT_LOG_EVENT_HIST.EVENT_CD%TYPE
      , EVENT_DS                 STAT_LOG_EVENT_HIST.EVENT_DS%TYPE
      , START_TS                 STAT_LOG_EVENT_HIST.START_TS%TYPE
      , END_TS                   STAT_LOG_EVENT_HIST.END_TS%TYPE
      , TRACKING_DURATION        STAT_LOG_EVENT_HIST.TRACKING_DURATION%TYPE
      , LAST_STATUS              STAT_LOG_EVENT_HIST.LAST_STATUS%TYPE
      , N_RUN                    STAT_LOG_EVENT_HIST.N_RUN%TYPE
      , CHECKED_STATUS           STAT_LOG_EVENT_HIST.CHECKED_STATUS%TYPE
      , MAX_N_RUN                STAT_LOG_EVENT_HIST.MAX_N_RUN%TYPE
      , AVG_DURARION_TOLERANCE   STAT_LOG_EVENT_HIST.AVG_DURARION_TOLERANCE%TYPE
      , AVG_END_TM_TOLERANCE     STAT_LOG_EVENT_HIST.AVG_END_TM_TOLERANCE%TYPE
      , ACTUAL_VALUE             STAT_LOG_EVENT_HIST.ACTUAL_VALUE%TYPE
      , THRESHOLD                STAT_LOG_EVENT_HIST.THRESHOLD%TYPE
      , OBJECT_NAME              STAT_LOG_EVENT_HIST.OBJECT_NAME%TYPE
      , NOTE                     STAT_LOG_EVENT_HIST.NOTE%TYPE
      , SENT_TS                  STAT_LOG_EVENT_HIST.SENT_TS%TYPE
      , DWH_DATE                 STAT_LOG_EVENT_HIST.DWH_DATE%TYPE
    );

    TYPE REF_LOGS_STATLOGEVENTHIST IS REF CURSOR
        RETURN REC_LOGS_STATLOGEVENTHIST;

    TYPE REC_LOGS_LOGCTRLACTION IS RECORD(
        USER_NAME   GUI_LOG_CTRL_ACTION.USER_NAME%TYPE
      , ACTION      GUI_LOG_CTRL_ACTION.ACTION%TYPE
      , ACTION_TS   GUI_LOG_CTRL_ACTION.ACTION_TS%TYPE
      , SQL_CODE    GUI_LOG_CTRL_ACTION.SQL_CODE%TYPE
      , DWH_DATE    GUI_LOG_CTRL_ACTION.DWH_DATE%TYPE
    );

    TYPE REF_LOGS_LOGCTRLACTION IS REF CURSOR
        RETURN REC_LOGS_LOGCTRLACTION;

    TYPE REC_LOGS_STATLOGMESSHIST IS RECORD(
        LOG_EVENT_ID           STAT_LOG_MESSAGE_HIST.LOG_EVENT_ID%TYPE
      , ERROR_CD               STAT_LOG_MESSAGE_HIST.ERROR_CD%TYPE
      , JOB_NAME               STAT_LOG_MESSAGE_HIST.JOB_NAME%TYPE
      , JOB_ID                 STAT_LOG_MESSAGE_HIST.JOB_ID%TYPE
      , SEVERITY               STAT_LOG_MESSAGE_HIST.SEVERITY%TYPE
      , NOTIFICATION_TYPE_CD   STAT_LOG_MESSAGE_HIST.NOTIFICATION_TYPE_CD%TYPE
      , EVENT_DS               STAT_LOG_MESSAGE_HIST.EVENT_DS%TYPE
      , RECOMMENDATION_DS      STAT_LOG_MESSAGE_HIST.RECOMMENDATION_DS%TYPE
      , NOTE                   STAT_LOG_MESSAGE_HIST.NOTE%TYPE
      , ADDRESS                STAT_LOG_MESSAGE_HIST.ADDRESS%TYPE
      , DETECTED_TS            STAT_LOG_MESSAGE_HIST.DETECTED_TS%TYPE
      , SENT_TS                STAT_LOG_MESSAGE_HIST.SENT_TS%TYPE
    );

    TYPE REF_LOGS_STATLOGMSSHST IS REF CURSOR
        RETURN REC_LOGS_STATLOGMESSHIST;



    TYPE REC_GUI_VIEW_ACCESS_ROLE IS RECORD(ACCESS_ROLE VARCHAR(256), GUI_PAGE VARCHAR(256), ACCESS_RIGHT VARCHAR(256));

    TYPE REF_GUI_VIEW_ACCESS_ROLE IS REF CURSOR
        RETURN REC_GUI_VIEW_ACCESS_ROLE;



    TYPE REC_LKP_VAL IS RECORD(LKP_VAL_DESC VARCHAR(255));

    TYPE REF_LKP_VAL IS REF CURSOR
        RETURN REC_LKP_VAL;



    ----------------------------------------------
    TYPE REC_MAN_BATCH_AV IS RECORD(JOB_ID SESS_JOB_BCKP.JOB_ID%TYPE, JOB_NAME SESS_JOB_BCKP.JOB_NAME%TYPE);

    TYPE REF_MAN_BATCH_AV IS REF CURSOR
        RETURN REC_MAN_BATCH_AV;

    ----------------------------------------------
    TYPE REC_MAN_BATCH_SEL IS RECORD(JOB_ID SESS_JOB_BCKP.JOB_ID%TYPE, JOB_NAME SESS_JOB_BCKP.JOB_NAME%TYPE);

    TYPE REF_MAN_BATCH_SEL IS REF CURSOR
        RETURN REC_MAN_BATCH_SEL;

    PROCEDURE SP_GUI_SET_CHANGE_CONTROL(USER_NAME_IN IN VARCHAR2
                                      , ACTION_IN IN  VARCHAR2
                                      , JOB_NAME_IN IN VARCHAR2
                                      , UID_INDICATOR_IN IN VARCHAR2
                                      , SQL_CODE_IN IN VARCHAR2
                                      , V_ENGINE_ID_IN IN INTEGER:= 0
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                      , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN IN VARCHAR2
                                       , ACTION_IN IN  VARCHAR2
                                       , SQL_CODE_IN IN VARCHAR2
                                       , V_ENGINE_ID_IN IN INTEGER:= 0
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GET_MY_RELATIVES(JOB_ID_IN IN  VARCHAR2
                                , REQUEST_ACC_IN IN INTEGER
                                , DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_HEADER_ENG_STAT(ENG_STATUS_OUT   OUT REF_GUI_HEADER_ENG_STATUS
                                   , ENG_NUMBER_ON   OUT NUMBER
                                   , ENG_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_HEADER_SCH_STAT(SCH_STATUS_OUT   OUT REF_GUI_HEADER_SCH_STATUS
                                   , SCH_NUMBER_ON   OUT NUMBER
                                   , SCH_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_HEADER_SYS_STAT(SYS_STATUS_OUT   OUT REF_GUI_HEADER_SYS_STATUS
                                   , SYS_NUMBER_ON   OUT NUMBER
                                   , SYS_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_JOB_ABORT(ENG_ID_IN IN  INTEGER
                             , USER_IN IN    VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_BLOCK(ENG_ID_IN IN  INTEGER
                             , USER_IN IN    VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_BLOCK_EXEC(ENG_ID_IN IN  INTEGER
                                  , JOB_ID_IN IN  NUMBER
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_JOB_MARKASFAILED(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_MARKASFINISHED(ENG_ID_IN IN  INTEGER
                                      , USER_IN IN    VARCHAR2
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                      , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_MARKASFINISHEDSUCC(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_RESTART(ENG_ID_IN IN  INTEGER
                               , USER_IN IN    VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD_OUT   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                               , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_RESUME(ENG_ID_IN IN  INTEGER
                              , USER_IN IN    VARCHAR2
                              , DEBUG_IN IN   INTEGER:= 0
                              , EXIT_CD_OUT   OUT NOCOPY NUMBER
                              , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                              , ERRCODE_OUT   OUT NOCOPY NUMBER
                              , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                              , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_JOB_UNBLOCK(ENG_ID_IN IN  INTEGER
                               , USER_IN IN    VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD_OUT   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                               , JOB_ID_IN IN  INTEGER);

    PROCEDURE SP_GUI_MBATCH_AVAIL_JBS(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                    , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                    , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                    , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                    , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                    , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_MAN_BATCH_AV);

    PROCEDURE SP_GUI_MBATCH_SEL_JBS(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                  , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                  , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                  , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                  , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                  , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , VALUES_OUT   OUT REF_MAN_BATCH_SEL);

    PROCEDURE SP_GUI_MBATCH_SETEXE(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , JOB_ID_IN     VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , REQUEST_ACC_IN IN INTEGER);

    PROCEDURE SP_GUI_MBATCH_SETFIN(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_MBATCH_SETSTART(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_MBATCH_STINIT(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , MAN_BATCH_LD_IN IN OUT NOCOPY VARCHAR2
                                 , MAN_BATCH_DESC_IN IN OUT NOCOPY LKP_APPLICATION.DESCRIPTION%TYPE);

    PROCEDURE SP_GUI_MBATCH_STRTCHCK(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_MBATCH_UNSETEXE(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , JOB_ID_IN     VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_SCHEDULER_NUM_JOB_PERM(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , RUNNING_JOBS_NO_IN IN INTEGER);

    PROCEDURE SP_GUI_SCHEDULER_NUM_JOB_TEMP(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , RUNNING_JOBS_NO_IN IN INTEGER);

    PROCEDURE SP_GUI_SCHEDULER_START(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , SCHEDULER_ID_IN IN INTEGER);

    PROCEDURE SP_GUI_SCHEDULER_STOP(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , SCHEDULER_ID_IN IN INTEGER
                                  , STOP_ALL_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_ACCESS_ROLE(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , ACCESS_ROLE_IN IN VARCHAR2
                                    , GUI_PAGE_IN IN VARCHAR2
                                    , ACCESS_RIGHT_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_ACCESS_ROLE_DEL(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , ACCESS_ROLE_IN IN VARCHAR2
                                        , GUI_PAGE_IN IN VARCHAR2
                                        , ACCESS_RIGHT_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_LABEL(ENG_ID_IN IN  INTEGER
                              , USER_IN IN    VARCHAR2
                              , DEBUG_IN IN   INTEGER:= 0
                              , EXIT_CD_OUT   OUT NOCOPY NUMBER
                              , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                              , ERRCODE_OUT   OUT NOCOPY NUMBER
                              , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                              , LABEL_NAME_IN IN VARCHAR2
                              , LABEL_STATUS_IN IN VARCHAR2
                              , DESCRIPTION_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_LABEL_BP(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , LABEL_NAME_IN IN VARCHAR2
                                 , VALUES_OUT   OUT NOCOPY REF_LABEL_BP_DETAILS);

    PROCEDURE SP_GUI_UPDT_SESS_JOB(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , JOB_ID_IN IN  SESS_JOB.JOB_ID%TYPE
                                 , LAST_UPDATE_IN IN SESS_JOB.LAST_UPDATE%TYPE
                                 , PRIORITY_IN IN SESS_JOB.PRIORITY%TYPE
                                 , CMD_LINE_IN IN SESS_JOB.CMD_LINE%TYPE
                                 , TOUGHNESS_IN IN SESS_JOB.TOUGHNESS%TYPE
                                 , MAX_RUNS_IN IN SESS_JOB.MAX_RUNS%TYPE);

    PROCEDURE SP_GUI_USER_AUTH(LOGIN_IN IN   VARCHAR2
                             , PASS_IN       VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , USER_ROLE_OUT   OUT NOCOPY NUMBER);

    PROCEDURE SP_GUI_USER_AUTH_RIGHTS(LOGIN_IN IN   VARCHAR2
                                    , GUI_PAGE_IN IN VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_RIGHTS_OUT);

    PROCEDURE SP_GUI_VIEW_ACCESS_ROLE(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , ACCESS_ROLE_IN IN VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_VIEW_ACCESS_ROLE);

    PROCEDURE SP_GUI_VIEW_CTRL_JOB(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                 , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                 , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                 , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                 , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                 , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , VALUES_OUT   OUT REF_GUI_CTRL_JOB);

    PROCEDURE SP_GUI_VIEW_CTRL_JOB_DEP(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , JOB_NAME_IN   VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                     , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                     , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                     , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                     , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                     , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_GUI_CTRL_JOB);

    PROCEDURE SP_GUI_VIEW_CTRL_JOB_DEPAC(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , JOB_NAME_IN   VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                       , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                       , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                       , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                       , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                       , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_GUI_CTRL_JOB_DEP);

    PROCEDURE SP_GUI_VIEW_CTRL_JOB_TAB_REF(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , JOB_NAME_IN   VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_CTRL_JOB_TAB_REF);

    PROCEDURE SP_GUI_VIEW_CTRL_PARAM_ENG(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_VIEW_CTRL_STREAM(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                    , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                    , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                    , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                    , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                    , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_CTRL_STREAM);

    PROCEDURE SP_GUI_VIEW_CTRL_STREAM_DEP(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , STREAM_NAME_IN VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                        , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                        , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                        , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                        , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                        , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_GUI_CTRL_STREAM);

    PROCEDURE SP_GUI_VIEW_CTRL_STREAM_DEPAC(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , STREAM_NAME_IN VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                          , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                          , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                          , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                          , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                          , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , VALUES_OUT   OUT REF_GUI_CTRL_STREAM_DEP);

    PROCEDURE SP_GUI_VIEW_CTRL_STREAM_NAME(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_VIEW_CTRL_STREAM_PLAN(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , STREAM_NAME_IN VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_CTRL_STREAM_PLAN);

    PROCEDURE SP_GUI_VIEW_GUI_DETAILS(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                    , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                    , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                    , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                    , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                    , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_DETAILS);

    PROCEDURE SP_GUI_VIEW_GUI_JOB_DETAILS(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , STATUS_IN     VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                        , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                        , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                        , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                        , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                        , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_GUI_JOB_DETAILS);

    PROCEDURE SP_GUI_VIEW_GUI_JOB_STATS(ENG_ID_IN IN  INTEGER
                                      , USER_IN IN    VARCHAR2
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                      , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                      , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                      , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                      , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                      , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                      , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                      , VALUES_OUT   OUT REF_GUI_JOB_STATS);

    PROCEDURE SP_GUI_VIEW_JOBS_ODD(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 --                                 , STATUS_IN     VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                 , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                 , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                 , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                 , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                 , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , VALUES_OUT   OUT REF_GUI_ODD_JOB);

    PROCEDURE SP_GUI_VIEW_GUI_STREAM_DET_1(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , STREAM_ID IN  VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_1);

    PROCEDURE SP_GUI_VIEW_GUI_STREAM_DET_2(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , STREAM_ID IN  VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_2);

    PROCEDURE SP_GUI_VIEW_GUI_STREAM_DET_3(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , STREAM_ID IN  VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_3);

    PROCEDURE SP_GUI_VIEW_GUI_STREAM_DETAILS(ENG_ID_IN IN  INTEGER
                                           , USER_IN IN    VARCHAR2
                                           , RUNABLE IN    VARCHAR2
                                           , DEBUG_IN IN   INTEGER:= 0
                                           , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                           , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                           , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                           , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                           , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                           , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                           , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                           , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                           , ERRCODE_OUT   OUT NOCOPY NUMBER
                                           , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                           , VALUES_OUT   OUT REF_GUI_STREAM_DETAILS);

    PROCEDURE SP_GUI_VIEW_GUI_STREAM_STATS(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_GUI_STREAM_STATS);

    PROCEDURE SP_GUI_VIEW_HEADER_MAIN(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                    , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                    , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                    , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                    , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                    , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , ENV_NAME_OUT   OUT NOCOPY VARCHAR2
                                    , ENGINE_NAME_OUT OUT NOCOPY VARCHAR2
                                    , TASK_TYPE_OUT   OUT NOCOPY VARCHAR2
                                    , PROVIDED_BY_OUT   OUT NOCOPY VARCHAR2
                                    , LOAD_DATE_OUT   OUT NOCOPY VARCHAR2
                                    , TASKS_NUMBER_OUT   OUT NOCOPY NUMBER
                                    , NUMBER_RUNNING_JOBS_OUT   OUT NOCOPY VARCHAR2
                                    , NUMBER_FAILED_JOBS_OUT   OUT NOCOPY VARCHAR2
                                    , NUMBER_READY_JOBS_OUT   OUT NOCOPY VARCHAR2
                                    , NUMBER_FINISHED_JOBS_OUT   OUT NOCOPY VARCHAR2
                                    , GUI_REFRESH_RATE_OUT   OUT NOCOPY VARCHAR2
                                    , NUMBER_ODD_JOBS_OUT   OUT NOCOPY VARCHAR2
                                    , GUI_COLOUR_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_VIEW_CHM(ENG_ID_IN IN  INTEGER
                            , USER_IN IN    VARCHAR2
                            , DEBUG_IN IN   INTEGER:= 0
                            , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                            , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                            , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                            , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                            , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                            , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                            , EXIT_CD_OUT   OUT NOCOPY NUMBER
                            , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                            , ERRCODE_OUT   OUT NOCOPY NUMBER
                            , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                            , VALUES_OUT   OUT REF_GUI_CHM);

    PROCEDURE SP_GUI_VIEW_JOBS_ALL(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                 , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                 , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                 , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                 , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                 , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_BLOCKED(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                     , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                     , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                     , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                     , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                     , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_FAILED(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                    , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                    , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                    , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                    , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                    , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_FAILED_ONLY(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                         , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                         , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                         , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                         , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                         , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_FINISHED(ENG_ID_IN IN  INTEGER
                                      , USER_IN IN    VARCHAR2
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                      , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                      , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                      , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                      , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                      , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                      , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                      , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_READY_TO_RUN(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                          , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                          , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                          , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                          , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                          , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_RUNNING(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                     , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                     , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                     , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                     , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                     , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_JOBS_UNBLOCKED(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                       , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                       , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                       , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                       , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                       , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_JOBS_DETAILS);

    PROCEDURE SP_GUI_VIEW_LKP_JOB_CATEGORY(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_VIEW_LKP_JOB_TYPE(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_VIEW_LKP_TOUGHNESS (ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL);


    PROCEDURE SP_GUI_VIEW_LKP_PHASE(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_VIEW_LOGS_LOGCTRLACTION(ENG_ID_IN IN  INTEGER
                                           , USER_IN IN    VARCHAR2
                                           , DEBUG_IN IN   INTEGER:= 0
                                           , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                           , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                           , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                           , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                           , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                           , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                           , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                           , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                           , ERRCODE_OUT   OUT NOCOPY NUMBER
                                           , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                           , VALUES_OUT   OUT REF_LOGS_LOGCTRLACTION);

    PROCEDURE SP_GUI_VIEW_LOGS_STATLOGMSSHST(ENG_ID_IN IN  INTEGER
                                           , USER_IN IN    VARCHAR2
                                           , DEBUG_IN IN   INTEGER:= 0
                                           , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                           , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                           , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                           , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                           , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                           , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                           , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                           , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                           , ERRCODE_OUT   OUT NOCOPY NUMBER
                                           , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                           , VALUES_OUT   OUT REF_LOGS_STATLOGMSSHST);

    PROCEDURE SP_GUI_VIEW_LOGS_STTLOGEVNTHST(ENG_ID_IN IN  INTEGER
                                           , USER_IN IN    VARCHAR2
                                           , DEBUG_IN IN   INTEGER:= 0
                                           , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                           , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                           , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                           , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                           , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                           , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                           , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                           , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                           , ERRCODE_OUT   OUT NOCOPY NUMBER
                                           , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                           , VALUES_OUT   OUT REF_LOGS_STATLOGEVENTHIST);

    PROCEDURE SP_GUI_VIEW_SESS_JOB(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , JOB_ID_IN     VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                 , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                 , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                 , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                 , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                 , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , VALUES_OUT   OUT REF_SESS_JOBS);

    PROCEDURE SP_GUI_VIEW_SESS_JOB_ALL(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                     , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                     , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                     , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                     , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                     , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_SESS_JOBS);

    PROCEDURE SP_GUI_VIEW_SESS_QUEUE(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , VALUES_OUT   OUT REF_LKP_VAL);

    PROCEDURE SP_GUI_DEL_CTRL_JOB(ENG_ID_IN IN  INTEGER
                                , USER_IN IN    VARCHAR2
                                , DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                , JOB_NAME_IN IN VARCHAR2
                                , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_DEL_CTRL_JOB_DEP(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , JOB_NAME_IN IN VARCHAR2
                                    , PARENT_JOB_NAME_IN IN VARCHAR2
                                    , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_DEL_CTRL_JOB_TAB_REF(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , JOB_NAME_IN IN VARCHAR2
                                        , DATABASE_NAME_IN IN VARCHAR2
                                        , TABLE_NAME_IN IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_DEL_CTRL_STREAM(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , STREAM_NAME_IN IN VARCHAR2
                                   , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_DEL_CTRL_STREAM_DEP(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , STREAM_NAME_IN IN VARCHAR2
                                       , PARENT_STREAM_NAME_IN IN VARCHAR2
                                       , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_JOB(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , JOB_NAME IN   CTRL_JOB.JOB_NAME%TYPE
                                 , STREAM_NAME IN CTRL_JOB.STREAM_NAME%TYPE
                                 , PRIORITY IN   CTRL_JOB.PRIORITY%TYPE
                                 , CMD_LINE IN   CTRL_JOB.CMD_LINE%TYPE
                                 , SRC_SYS_ID IN CTRL_JOB.SRC_SYS_ID%TYPE
                                 , PHASE IN      CTRL_JOB.PHASE%TYPE
                                 , TABLE_NAME IN CTRL_JOB.TABLE_NAME%TYPE
                                 , JOB_CATEGORY IN CTRL_JOB.JOB_CATEGORY%TYPE
                                 , JOB_TYPE IN   CTRL_JOB.JOB_TYPE%TYPE
                                 , TOUGHNESS IN  CTRL_JOB.TOUGHNESS%TYPE
                                 , CONT_ANYWAY IN CTRL_JOB.CONT_ANYWAY%TYPE
                                 , MAX_RUNS IN   CTRL_JOB.MAX_RUNS%TYPE
                                 , ALWAYS_RESTART IN CTRL_JOB.ALWAYS_RESTART%TYPE
                                 , STATUS_BEGIN IN CTRL_JOB.STATUS_BEGIN%TYPE
                                 , WAITING_HR IN CTRL_JOB.WAITING_HR%TYPE
                                 , DEADLINE_HR IN CTRL_JOB.DEADLINE_HR%TYPE
                                 , ENGINE_ID IN  CTRL_JOB.ENGINE_ID%TYPE
                                 , JOB_DESC IN   CTRL_JOB.JOB_DESC%TYPE
                                 , AUTHOR IN     CTRL_JOB.AUTHOR%TYPE
                                 , NOTE IN       CTRL_JOB.NOTE%TYPE
                                 , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_JOB_DEL(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , JOB_NAME_IN IN VARCHAR2
                                     , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_JOB_DEP(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , JOB_NAME_IN IN VARCHAR2
                                     , PARENT_JOB_NAME_IN IN VARCHAR2
                                     , JOB_DEP_TYPE_IN IN VARCHAR2
                                     , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_JOB_TAB_REF(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , JOB_NAME_IN IN VARCHAR2
                                         , DATABASE_NAME_IN IN VARCHAR2
                                         , TABLE_NAME_IN IN VARCHAR2
                                         , LOCK_TYPE_IN IN VARCHAR2
                                         , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_STREAM(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , STREAM_NAME IN VARCHAR2
                                    , STREAM_DESC IN VARCHAR2
                                    , NOTE IN       VARCHAR2
                                    , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_STREAM_DEL(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , STREAM_NAME_IN IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_CTRL_STREAM_DEP(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , STREAM_NAME_IN IN VARCHAR2
                                        , PARENT_STREAM_NAME_IN IN VARCHAR2
                                        , STREAM_DEP_TYPE_IN IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2);

    PROCEDURE SP_GUI_UPDT_USER_MNGMT(USER_IN IN    VARCHAR2
                                   , LOGIN_IN IN   VARCHAR2
                                   , PASS_IN IN    VARCHAR2
                                   , ACCESS_ROLE_IN IN VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_GUI_UPDT_USER_MNGMT_DEL(USER_IN IN    VARCHAR2
                                       , LOGIN_IN IN   VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    TYPE REC_GUI_USERS IS RECORD(USR_NAME VARCHAR(256), ACCESS_ROLE VARCHAR(256));

    TYPE REF_GUI_USERS IS REF CURSOR
        RETURN REC_GUI_USERS;


    PROCEDURE SP_GUI_VIEW_USER_MNGMT(USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , VALUES_OUT   OUT REF_GUI_USERS);

    PROCEDURE SP_GUI_UPDT_USER_MNGMT_PASS(USER_IN IN    VARCHAR2
                                        , LOGIN_IN IN   VARCHAR2
                                        , PASS_IN IN    VARCHAR2
                                        , OLD_PASS_IN IN VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

PROCEDURE SP_GUI_VIEW_CTRL_SCHED_NUM_JOB(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_LKP_VAL);

PROCEDURE SP_GUI_VIEW_LKP_COUNTRY_CD(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_LKP_VAL);

PROCEDURE SP_GUI_VIEW_LKP_RUNPLAN(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_LKP_VAL);

PROCEDURE SP_GUI_VIEW_LKP_RUNPLAN_DESC(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_LKP_VAL);

PROCEDURE SP_GUI_UPDT_CTRL_STREAM_PL_REF(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , ROW_ID        IN VARCHAR2
                                        , STREAM_NAME   IN VARCHAR2
                                        , RUNPLAN       IN VARCHAR2
                                        , COUNTRY_CD    IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2);

PROCEDURE SP_GUI_DEL_CTRL_STREAM_PL_REF(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , STREAM_NAME IN VARCHAR2
                                       , ROW_ID IN VARCHAR2
                                       , LABEL_NAME_IN IN VARCHAR2);

PROCEDURE SP_GUI_INS_CTRL_STREAM_PL_REF(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , STREAM_NAME IN VARCHAR2
                                        , RUNPLAN  IN VARCHAR2
                                        , COUNTRY_CD IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2);

PROCEDURE SP_GUI_VIEW_JOBS_EXECUTABLE(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , FLT_STREAM_NAME_IN IN CTRL_STREAM.STREAM_NAME%TYPE
                                        , FLT_JOB_NAME_IN IN CTRL_JOB.JOB_NAME%TYPE
                                        , FLT_JOB_TYPE_IN IN CTRL_JOB.JOB_TYPE%TYPE
                                        , FLT_TABLE_NAME_IN IN CTRL_JOB.TABLE_NAME%TYPE
                                        , FLT_PHASE_IN IN CTRL_JOB.PHASE%TYPE
                                        , FLT_JOB_CATEGORY_IN IN CTRL_JOB.JOB_CATEGORY%TYPE
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , VALUES_OUT   OUT REF_JOBS_DETAILS);


END;

