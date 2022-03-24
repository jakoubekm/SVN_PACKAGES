
  CREATE OR REPLACE PACKAGE "PDC"."PCKG_FWRK"
IS
    C_PCKG_NAME   CONSTANT VARCHAR2(64) := 'pckg_fwrk';

    PROCEDURE SP_FWRK_CHECK_WD_STATUS(DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_FWRK_CHECK_SCHED_STATUS(DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_FWRK_CHECK_SNIFER(DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_FWRK_CHECK_INITIALIZATION(DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_FWRK_CHECK_NOTIFICATION(DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_FWRK_MESSAGE_GEN(DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_SAVE_STAT_LOG_EVENT_HIST(EVENT_TS_IN IN STAT_LOG_EVENT_HIST.EVENT_TS%TYPE
                                        , NOTIFICATION_CD_IN IN STAT_LOG_EVENT_HIST.NOTIFICATION_CD%TYPE
                                        , LOAD_DATE_IN IN STAT_LOG_EVENT_HIST.LOAD_DATE%TYPE
                                        , JOB_NAME_IN IN STAT_LOG_EVENT_HIST.JOB_NAME%TYPE
                                        , JOB_ID_IN IN  STAT_LOG_EVENT_HIST.JOB_ID%TYPE
                                        , SEVERITY_LEVEL_CD_IN IN STAT_LOG_EVENT_HIST.SEVERITY_LEVEL_CD%TYPE
                                        , ERROR_CD_IN IN STAT_LOG_EVENT_HIST.ERROR_CD%TYPE
                                        , EVENT_CD_IN IN STAT_LOG_EVENT_HIST.EVENT_CD%TYPE
                                        , EVENT_DS_IN IN STAT_LOG_EVENT_HIST.EVENT_DS%TYPE
                                        , START_TS_IN IN STAT_LOG_EVENT_HIST.START_TS%TYPE
                                        , END_TS_IN IN  STAT_LOG_EVENT_HIST.END_TS%TYPE
                                        , TRACKING_DURATION_IN IN STAT_LOG_EVENT_HIST.TRACKING_DURATION%TYPE
                                        , LAST_STATUS_IN IN STAT_LOG_EVENT_HIST.LAST_STATUS%TYPE
                                        , N_RUN_IN IN   STAT_LOG_EVENT_HIST.N_RUN%TYPE
                                        , CHECKED_STATUS_IN IN STAT_LOG_EVENT_HIST.CHECKED_STATUS%TYPE
                                        , MAX_N_RUN_IN IN STAT_LOG_EVENT_HIST.MAX_N_RUN%TYPE
                                        , AVG_DURARION_TOLERANCE_IN IN STAT_LOG_EVENT_HIST.AVG_DURARION_TOLERANCE%TYPE
                                        , AVG_END_TM_TOLERANCE_IN IN STAT_LOG_EVENT_HIST.AVG_END_TM_TOLERANCE%TYPE
                                        , ACTUAL_VALUE_IN IN STAT_LOG_EVENT_HIST.ACTUAL_VALUE%TYPE
                                        , THRESHOLD_IN IN STAT_LOG_EVENT_HIST.THRESHOLD%TYPE
                                        , OBJECT_NAME_IN IN STAT_LOG_EVENT_HIST.OBJECT_NAME%TYPE
                                        , NOTE_IN IN    STAT_LOG_EVENT_HIST.NOTE%TYPE
                                        , SENT_TS_IN IN STAT_LOG_EVENT_HIST.SENT_TS%TYPE
                                        , DWH_DATE_IN IN STAT_LOG_EVENT_HIST.DWH_DATE%TYPE
                                        , ENGINE_ID_IN IN STAT_LOG_EVENT_HIST.ENGINE_ID%TYPE
                                        , RECOMMENDATION_DS_IN IN STAT_LOG_EVENT_HIST.RECOMMENDATION_DS%TYPE:= NULL
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN STAT_LOG_MESSAGE_HIST.LOG_EVENT_ID%TYPE
                                          , ERROR_CD_IN   STAT_LOG_MESSAGE_HIST.ERROR_CD%TYPE
                                          , ENGINE_NAME_IN  STAT_LOG_MESSAGE_HIST.ENGINE_NAME%TYPE
                                          , JOB_NAME_IN   STAT_LOG_MESSAGE_HIST.JOB_NAME%TYPE
                                          , JOB_ID_IN     STAT_LOG_MESSAGE_HIST.JOB_ID%TYPE
                                          , SEVERITY_IN   STAT_LOG_MESSAGE_HIST.SEVERITY%TYPE := 0
                                          , NOTIFICATION_TYPE_CD_IN STAT_LOG_MESSAGE_HIST.NOTIFICATION_TYPE_CD%TYPE := 0
                                          , EVENT_DS_IN   STAT_LOG_MESSAGE_HIST.EVENT_DS%TYPE := 'N/A'
                                          , RECOMMENDATION_DS_IN STAT_LOG_MESSAGE_HIST.RECOMMENDATION_DS%TYPE
                                          , NOTE_IN       STAT_LOG_MESSAGE_HIST.NOTE%TYPE
                                          , DETECTED_TS_IN STAT_LOG_MESSAGE_HIST.DETECTED_TS%TYPE := current_timestamp
                                          , SENT_TS_IN    STAT_LOG_MESSAGE_HIST.SENT_TS%TYPE
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_SAVE_CTRL_NOTIFICATION(JOB_NAME_IN IN CTRL_NOTIFICATION.JOB_NAME%TYPE
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    FUNCTION F_GET_STATUS_FINISHED(STATUS_IN INTEGER)
        RETURN INTEGER;

    FUNCTION F_GET_CTRL_PARAMETERS(PARAM_NAME_IN VARCHAR2, COLUMN_IN VARCHAR2, ENGINE_IN INTEGER:=-1)
        RETURN VARCHAR2;

    FUNCTION F_GET_CTRL_NOTIFICATION_TYPES(NOTIFICATION_TYPE_DS_IN VARCHAR2, COLUMN_IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION F_GET_SESS_JOB_PARAM_STAT(JOB_ID_IN VARCHAR2, COLUMN_IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE SP_FWRK_CHECK_SOURCE_DELIVERY(DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);
    FUNCTION F_GET_SEVERITY_LEVEL_CD (ERROR_CD_IN VARCHAR2)
      RETURN NUMBER;
END;

