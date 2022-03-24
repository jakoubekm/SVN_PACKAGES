
  CREATE OR REPLACE PACKAGE BODY "PDC"."PCKG_GUI"
AS
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
                                    , GUI_COLOUR_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_HEADER_MAIN
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_HEADER_MAIN';
        C_PROC_VERSION         CONSTANT VARCHAR2(16) := '1.0';
        -- local variables

        V_ENV_NAME             VARCHAR2(256);
        V_ENGINE_NAME          VARCHAR2(256);
        V_LOAD_DATE            VARCHAR2(20);
        V_BASE_LOAD_DATE       VARCHAR2(20);
        V_ENG_ID_IN            VARCHAR2(2048);
        V_STEP                 VARCHAR(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
        V_DURATION_PERCENT     CTRL_PARAMETERS.PARAM_VAL_INT%TYPE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100;
        V_DURATION_TOLERANCE   CTRL_PARAMETERS.PARAM_VAL_INT%TYPE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_TOLERANCE', 'param_val_int');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);

        V_STEP := '10 - LOAD_DATE';

        DECLARE
        BEGIN
            SELECT   TO_CHAR(CTPAC.PARAM_VAL_DATE, 'DD.MM.YYYY HH24:MI:SS')
              INTO   V_BASE_LOAD_DATE
              FROM   CTRL_PARAMETERS CTPAC
             WHERE   CTPAC.PARAM_NAME = 'LOAD_DATE'
                 AND PARAM_CD = V_ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                EXIT_CD_OUT := -1;
                ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
                ERRCODE_OUT := SQLCODE;
                ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            WHEN OTHERS
            THEN
                EXIT_CD_OUT := -2;
                ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
                ERRCODE_OUT := SQLCODE;
                ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
        END;

        IF V_BASE_LOAD_DATE IS NOT NULL
        THEN
            V_STEP := '20 - ENV_NAME';

            SELECT   CTPAB.PARAM_VAL_CHAR
              INTO   V_ENV_NAME
              FROM   CTRL_PARAMETERS CTPAB
             WHERE   CTPAB.PARAM_NAME = 'ENVIRONMENT' /* AND PARAM_CD = V_ENG_ID_IN */
                                                     ;

            ENV_NAME_OUT := V_ENV_NAME;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '21 - ENGINE_NAME';

            SELECT   CTPAB.PARAM_VAL_CHAR
              INTO   V_ENGINE_NAME
              FROM   CTRL_PARAMETERS CTPAB
             WHERE   CTPAB.PARAM_NAME = 'ENGINE_NAME'
              AND PARAM_CD = V_ENG_ID_IN;

            ENGINE_NAME_OUT := V_ENGINE_NAME;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            DECLARE
            BEGIN
                V_STEP := '30 - MANUAL BATCH LOAD_DATE';

                SELECT   TO_CHAR(CTPAC.PARAM_VAL_DATE, 'DD.MM.YYYY HH24:MI:SS')
                  INTO   V_LOAD_DATE
                  FROM   CTRL_PARAMETERS CTPAC
                 WHERE   CTPAC.PARAM_NAME = 'MANUAL_BATCH_LOAD_DATE'
                     AND PARAM_CD = V_ENG_ID_IN;

                IF DEBUG_IN = 1
                THEN
                    INSERT INTO PROC_LOG(PROCESS_NM
                                       , VERSION_NUM
                                       , PROCESS_TS
                                       , RUN_NUM
                                       , START_DT
                                       , END_DT
                                       , STAT_CD
                                       , DESCRIPTION
                                       , PROCESS_STEP
                                       , SEQ_NUM)
                      VALUES   (C_PROC_NAME
                              , C_PROC_VERSION
                              , SYSDATE
                              , NULL
                              , NULL
                              , NULL
                              , EXIT_CD_OUT
                              , ERRMSG_OUT
                              , V_STEP
                              , PROC_LOG_SEQ.NEXTVAL);

                    COMMIT;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    EXIT_CD_OUT := -1;
                    ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
                    ERRCODE_OUT := SQLCODE;
                    ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

                    INSERT INTO PROC_LOG(PROCESS_NM
                                       , VERSION_NUM
                                       , PROCESS_TS
                                       , RUN_NUM
                                       , START_DT
                                       , END_DT
                                       , STAT_CD
                                       , DESCRIPTION
                                       , PROCESS_STEP
                                       , SEQ_NUM)
                      VALUES   (C_PROC_NAME
                              , C_PROC_VERSION
                              , SYSDATE
                              , NULL
                              , NULL
                              , NULL
                              , EXIT_CD_OUT
                              , ERRMSG_OUT
                              , V_STEP
                              , PROC_LOG_SEQ.NEXTVAL);

                    COMMIT;
                WHEN OTHERS
                THEN
                    EXIT_CD_OUT := -2;
                    ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
                    ERRCODE_OUT := SQLCODE;
                    ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

                    INSERT INTO PROC_LOG(PROCESS_NM
                                       , VERSION_NUM
                                       , PROCESS_TS
                                       , RUN_NUM
                                       , START_DT
                                       , END_DT
                                       , STAT_CD
                                       , DESCRIPTION
                                       , PROCESS_STEP
                                       , SEQ_NUM)
                      VALUES   (C_PROC_NAME
                              , C_PROC_VERSION
                              , SYSDATE
                              , NULL
                              , NULL
                              , NULL
                              , EXIT_CD_OUT
                              , ERRMSG_OUT
                              , V_STEP
                              , PROC_LOG_SEQ.NEXTVAL);

                    COMMIT;
            END;

            IF EXIT_CD_OUT = 0
            THEN
                IF PCKG_FWRK.F_GET_CTRL_PARAMETERS('APPLICATION_ID', 'param_val_int', V_ENG_ID_IN) <= 100
                THEN
                    V_LOAD_DATE := V_BASE_LOAD_DATE;
                END IF;

                /*                IF V_LOAD_DATE IS NULL
                                THEN
                                    V_LOAD_DATE := V_BASE_LOAD_DATE;
                                END IF;
                */
                LOAD_DATE_OUT := V_LOAD_DATE;

                V_STEP := '40 - TASK NUMBER';

                SELECT   SUM(NVL(A.PARAM_VAL_INT, 0))
                  INTO   TASKS_NUMBER_OUT
                  FROM   CTRL_PARAMETERS A
                 WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS'
                     AND PARAM_CD = V_ENG_ID_IN;

                IF DEBUG_IN = 1
                THEN
                    INSERT INTO PROC_LOG(PROCESS_NM
                                       , VERSION_NUM
                                       , PROCESS_TS
                                       , RUN_NUM
                                       , START_DT
                                       , END_DT
                                       , STAT_CD
                                       , DESCRIPTION
                                       , PROCESS_STEP
                                       , SEQ_NUM)
                      VALUES   (C_PROC_NAME
                              , C_PROC_VERSION
                              , SYSDATE
                              , NULL
                              , NULL
                              , NULL
                              , EXIT_CD_OUT
                              , ERRMSG_OUT
                              , V_STEP
                              , PROC_LOG_SEQ.NEXTVAL);

                    COMMIT;
                END IF;
            END IF;

            V_STEP := '50 - RUNNING JOBS NUMBER';

            SELECT   COUNT( * ) CNT
              INTO   NUMBER_RUNNING_JOBS_OUT
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'RUNNING'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '60 - FAILED JOBS NUMBER';

            SELECT   COUNT( * ) CNT
              INTO   NUMBER_FAILED_JOBS_OUT
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'FAILED'
                    AND SJ.N_RUN >= SJ.MAX_RUNS
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '70 - READY JOBS NUMBER';

            SELECT   COUNT( * ) CNT
              INTO   NUMBER_READY_JOBS_OUT
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    --                  AND (CJS.EXECUTABLE = 1)
                    AND FINISHED = 0
                    AND RUNABLE != 'RUNNING'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '80 - FINISHED JOBS NUMBER';

            SELECT   COUNT( * ) CNT
              INTO   NUMBER_FINISHED_JOBS_OUT
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND (CJS.FINISHED = 1)
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '90 - GUI REFRESH RATE';

            SELECT   A.PARAM_VAL_INT
              INTO   GUI_REFRESH_RATE_OUT
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'GUI_REFRESH_RATE';

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '100 - TASK TYPE';

            SELECT   CASE WHEN A.PARAM_VAL_INT < 100 THEN 'AUTOMATIC' ELSE 'MANUAL' END AS X
              INTO   TASK_TYPE_OUT
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'APPLICATION_ID'
                 AND PARAM_CD = ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '110 - PROVIDED BY';

            SELECT   A.PARAM_VAL_CHAR
              INTO   PROVIDED_BY_OUT
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'SCHEDULER_PROVIDED_BY'
              AND PARAM_CD = ENG_ID_IN;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;


            V_STEP := '120 - Oddly jobs';

            NUMBER_ODD_JOBS_OUT:= 0;

            SELECT SUM(ODD_JOB)
            INTO   NUMBER_ODD_JOBS_OUT
            FROM (
            SELECT
              CASE WHEN (PCKG_TOOLS.F_SEC_BETWEEN(SJ.LAST_UPDATE, CURRENT_TIMESTAMP) -
              SJS.AVG_DURATION * (PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100))>0
              THEN 1 ELSE 0 END AS ODD_JOB
            FROM
              SESS_JOB SJ
              INNER JOIN  SESS_JOB_STATISTICS SJS
              ON SJ.JOB_NAME = SJS.JOB_NAME
              INNER JOIN CTRL_JOB_STATUS CJS
              ON SJ.STATUS = CJS.STATUS
              AND UPPER(CJS.RUNABLE) = UPPER('RUNNING')
              WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
              ) C;

            IF NUMBER_ODD_JOBS_OUT IS NULL THEN
              NUMBER_ODD_JOBS_OUT:= 0;
            END IF;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            V_STEP := '125 - GUI COLOUR';


           BEGIN
                SELECT   A.PARAM_VAL_CHAR
                  INTO   GUI_COLOUR_OUT
                  FROM   CTRL_PARAMETERS A
                 WHERE   A.PARAM_NAME = 'GUI_COLOUR';
           EXCEPTION
            WHEN NO_DATA_FOUND /*It can be not specified*/
            THEN
              IF DEBUG_IN = 1
              THEN

              INSERT INTO PROC_LOG(PROCESS_NM
                                 , VERSION_NUM
                                 , PROCESS_TS
                                 , RUN_NUM
                                 , START_DT
                                 , END_DT
                                 , STAT_CD
                                 , DESCRIPTION
                                 , PROCESS_STEP
                                 , SEQ_NUM)
                VALUES   (C_PROC_NAME
                        , C_PROC_VERSION
                        , SYSDATE
                        , NULL
                        , NULL
                        , 'GUI COLOUR NOT SPECIFIED'
                        , NULL
                        , NULL
                        , V_STEP
                        , PROC_LOG_SEQ.NEXTVAL);

              COMMIT;
              END IF;
            END;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;

            IF DEBUG_IN = 1
            THEN
                INSERT INTO PROC_LOG(PROCESS_NM
                                   , VERSION_NUM
                                   , PROCESS_TS
                                   , RUN_NUM
                                   , START_DT
                                   , END_DT
                                   , STAT_CD
                                   , DESCRIPTION
                                   , PROCESS_STEP
                                   , SEQ_NUM)
                  VALUES   (C_PROC_NAME
                          , C_PROC_VERSION
                          , SYSDATE
                          , NULL
                          , NULL
                          , NULL
                          , EXIT_CD_OUT
                          , ERRMSG_OUT
                          , V_STEP
                          , PROC_LOG_SEQ.NEXTVAL);

                COMMIT;
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_HEADER_MAIN;


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
                                    , VALUES_OUT   OUT REF_GUI_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_DETAILS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_HEADER_MAIN';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_GUI_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   STREAM_ID
                     , STREAM_NAME
                     , RUNABLE
                     , COALESCE(SUM(N_FINISHED), 0) N_FINISHED
                     , COALESCE(SUM(N_FORCE_FINISHED), 0) N_FORCE_FINISHED
                     , COALESCE(SUM(N_VOID_FINISHED), 0) N_VOID_FINISHED
                     , COALESCE(SUM(N_FINISHED_ODDLY), 0) N_FINISHED_ODDLY
                     , COALESCE(SUM(N_RUNABLE), 0) N_RUNABLE
                     , COALESCE(SUM(N_RUNNING), 0) N_RUNNING
                     , COALESCE(SUM(N_FAILED), 0) N_FAILED
                     , COALESCE(SUM(N_BLOCKED), 0) N_BLOCKED
                     , COALESCE(SUM(N_NOT_DEFINED), 0) N_NOT_DEFINED
                     , COALESCE(SUM(N_TOTAL), 0) N_TOTAL
                FROM   (SELECT   SJ.STREAM_ID
                               , SJ.STREAM_NAME
                               , CJS.RUNABLE
                               , CASE WHEN RUNABLE = 'FINISHED' THEN 1 END N_FINISHED
                               , CASE WHEN RUNABLE = 'FORCE_FINISHED' THEN 1 END N_FORCE_FINISHED
                               , CASE WHEN RUNABLE = 'VOID_FINISHED' THEN 1 END N_VOID_FINISHED
                               , CASE WHEN RUNABLE = 'FINISHED_ODDLY' THEN 1 END N_FINISHED_ODDLY
                               , CASE WHEN RUNABLE = 'RUNABLE' THEN 1 END N_RUNABLE
                               , CASE WHEN RUNABLE = 'RUNNING' THEN 1 END N_RUNNING
                               , CASE WHEN RUNABLE = 'FAILED' THEN 1 END N_FAILED
                               , CASE WHEN RUNABLE = 'BLOCKED' THEN 1 END N_BLOCKED
                               , CASE WHEN RUNABLE = 'NOT_DEFINED' THEN 1 END N_NOT_DEFINED
                               , CASE WHEN 1 = 1 THEN 1 END N_TOTAL
                          FROM       SESS_JOB SJ
                                 JOIN
                                     CTRL_JOB_STATUS CJS
                                 ON SJ.STATUS = CJS.STATUS
                         WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                             AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                             AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                             AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                             AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                             AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                             AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN)
            GROUP BY   STREAM_ID, STREAM_NAME, RUNABLE
            ORDER BY   STREAM_NAME;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_GUI_DETAILS;

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
                                 , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_ALL
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_ALL';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_ALL;

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
                                    , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_FAILED
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_FAILED';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'FAILED'
                    AND SJ.N_RUN >= SJ.MAX_RUNS
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_FAILED;

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
                                      , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_FINISHED
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_FINISHED';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
    BEGIN
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND (CJS.FINISHED = 1)
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_FINISHED;

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
                                     , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_RUNNING
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_RUNNING';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
    BEGIN
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'RUNNING'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_RUNNING;

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
                                          , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_READY_TO_RUN
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_READY_TO_RUN';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
    BEGIN
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    --                  AND (CJS.EXECUTABLE = 1)
                    AND FINISHED = 0
                    AND RUNABLE != 'RUNNING'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_READY_TO_RUN;

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
                                 , VALUES_OUT   OUT REF_SESS_JOBS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_SESS_JOB
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_SESS_JOB';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_SESS_JOBS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_JOB_ID_IN             VARCHAR(2048);

        V_STEP                  VARCHAR2(1024);
    BEGIN
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_JOB_ID_IN := JOB_ID_IN;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.STREAM_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.STATUS
                   , SJ.LAST_UPDATE
                   , SJ.LOAD_DATE
                   , SJ.PRIORITY
                   , SJ.CMD_LINE
                   , SJ.SRC_SYS_ID
                   , SJ.PHASE
                   , SJ.TABLE_NAME
                   , SJ.JOB_CATEGORY
                   , SJ.JOB_TYPE
                   , SJ.TOUGHNESS
                   , SJ.CONT_ANYWAY
                   , SJ.RESTART
                   , SJ.ALWAYS_RESTART
                   , SJ.N_RUN
                   , SJ.MAX_RUNS
                   , SJ.WAITING_HR
                   , SJ.DEADLINE_HR
                   , SJ.APPLICATION_ID
                   , SJ.ENGINE_ID
                   , LJC.ABORTABLE
              FROM       SESS_JOB SJ
                     JOIN
                         LKP_JOB_CATEGORY LJC
                     ON SJ.JOB_CATEGORY = LJC.JOB_CATEGORY
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
                 AND SJ.JOB_ID = V_JOB_ID_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_SESS_JOB;

    /******************************************************************************/

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
                                           , VALUES_OUT   OUT REF_GUI_STREAM_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_DETAILS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_HEADER_MAIN';
        -- local variables
        LC_CURSOR              REF_GUI_STREAM_DETAILS;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_RUNABLE_IN           VARCHAR(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_RUNABLE_IN := RUNABLE;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   STREAM_ID
                     , STREAM_NAME
                     , V_RUNABLE_IN AS RUNABLE
                     , COALESCE(SUM(N_FINISHED), 0) N_FINISHED
                     , COALESCE(SUM(N_FORCE_FINISHED), 0) N_FORCE_FINISHED
                     , COALESCE(SUM(N_VOID_FINISHED), 0) N_VOID_FINISHED
                     , COALESCE(SUM(N_FINISHED_ODDLY), 0) N_FINISHED_ODDLY
                     , COALESCE(SUM(N_RUNABLE), 0) N_RUNABLE
                     , COALESCE(SUM(N_RUNNING), 0) N_RUNNING
                     , COALESCE(SUM(N_FAILED), 0) N_FAILED
                     , COALESCE(SUM(N_BLOCKED), 0) N_BLOCKED
                     , COALESCE(SUM(N_NOT_DEFINED), 0) N_NOT_DEFINED
                     , COALESCE(SUM(N_TOTAL), 0) N_TOTAL
                FROM   (SELECT   SJ.STREAM_ID
                               , SJ.STREAM_NAME
                               , CJS.RUNABLE
                               , CASE WHEN RUNABLE = 'FINISHED' THEN 1 END N_FINISHED
                               , CASE WHEN RUNABLE = 'FORCE_FINISHED' THEN 1 END N_FORCE_FINISHED
                               , CASE WHEN RUNABLE = 'VOID_FINISHED' THEN 1 END N_VOID_FINISHED
                               , CASE WHEN RUNABLE = 'FINISHED_ODDLY' THEN 1 END N_FINISHED_ODDLY
                               , CASE WHEN RUNABLE = 'RUNABLE' THEN 1 END N_RUNABLE
                               , CASE WHEN RUNABLE = 'RUNNING' THEN 1 END N_RUNNING
                               , CASE WHEN RUNABLE = 'FAILED' THEN 1 END N_FAILED
                               , CASE WHEN RUNABLE = 'BLOCKED' THEN 1 END N_BLOCKED
                               , CASE WHEN RUNABLE = 'NOT_DEFINED' THEN 1 END N_NOT_DEFINED
                               , CASE WHEN 1 = 1 THEN 1 END N_TOTAL
                          FROM       SESS_JOB SJ
                                 JOIN
                                     CTRL_JOB_STATUS CJS
                                 ON SJ.STATUS = CJS.STATUS
                         WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                             AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                             AND STREAM_ID IN
                             (
                              SELECT STREAM_ID
                              FROM (
                              SELECT SJ.STREAM_ID ,CJS.RUNABLE, ROW_NUMBER() OVER (PARTITION BY SJ.STREAM_ID ORDER BY CJS.SORTING_ORDER DESC) RN
                              FROM SESS_JOB SJ
                              JOIN CTRL_JOB_STATUS CJS
                                ON SJ.STATUS = CJS.STATUS
                              WHERE   SJ.ENGINE_ID = 0)
                              WHERE RN = 1 AND RUNABLE = V_RUNABLE_IN)
                             )
            GROUP BY   STREAM_ID, STREAM_NAME
            ORDER BY   STREAM_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_STREAM_DETAILS;

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
                                         , VALUES_OUT   OUT REF_GUI_STREAM_STATS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_DETAILS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_HEADER_MAIN';
        -- local variables
        LC_CURSOR              REF_GUI_STREAM_STATS;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   X.RUNABLE, X.CNT
                FROM       (  SELECT   RUNABLE, COUNT( * ) CNT
                                FROM   (SELECT   RUNABLE, SORTING_ORDER
                                          FROM   (SELECT   CJS.RUNABLE, CJS.SORTING_ORDER, ROW_NUMBER() OVER (PARTITION BY SJ.STREAM_ID ORDER BY CJS.SORTING_ORDER DESC) RN
                                                    FROM       SESS_JOB SJ
                                                           JOIN
                                                               CTRL_JOB_STATUS CJS
                                                           ON SJ.STATUS = CJS.STATUS
                                                   WHERE   SJ.ENGINE_ID = V_ENG_ID_IN)
                                         WHERE   RN = 1)
                            GROUP BY   RUNABLE) X
                       JOIN
                           (  SELECT   RUNABLE, MIN(SORTING_ORDER) SORTING_ORDER
                                FROM   CTRL_JOB_STATUS CJS
                            GROUP BY   RUNABLE) Y
                       ON X.RUNABLE = Y.RUNABLE
            ORDER BY   Y.SORTING_ORDER;


        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_STREAM_STATS;


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
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_1)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_STREAM_DET_1
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_GUI_STREAM_DET_1';
        -- local variables
        LC_CURSOR              REF_GUI_STREAM_DET_1;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STREAM_ID            VARCHAR(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STREAM_ID := STREAM_ID;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   DISTINCT SJ.STREAM_ID
                            , CS.STREAM_NAME
                            , CS.STREAM_DESC
                            , CS.NOTE
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_STREAM CS
                     ON CS.STREAM_NAME = SJ.STREAM_NAME
             WHERE   SJ.STREAM_ID = V_STREAM_ID;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_STREAM_DET_1;

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
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_STREAM_DET_2
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_GUI_STREAM_DET_2';
        -- local variables
        LC_CURSOR              REF_GUI_STREAM_DET_2;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STREAM_ID            VARCHAR(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STREAM_ID := STREAM_ID;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   DISTINCT SJ.STREAM_ID
                            , CS.STREAM_NAME
                            , CS.STREAM_DESC
                            , CS.NOTE
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_STREAM CS
                     ON CS.STREAM_NAME = SJ.STREAM_NAME
             WHERE   SJ.STREAM_ID = V_STREAM_ID;


        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_STREAM_DET_2;


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
                                         , VALUES_OUT   OUT REF_GUI_STREAM_DET_3)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_STREAM_DET_3
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_GUI_STREAM_DET_3';
        -- local variables
        LC_CURSOR              REF_GUI_STREAM_DET_3;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);


        V_STREAM_ID            VARCHAR(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STREAM_ID := STREAM_ID;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID, SJ.JOB_NAME, SJ.STREAM_ID
              FROM   SESS_JOB SJ
             WHERE   SJ.STREAM_ID = V_STREAM_ID;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_STREAM_DET_3;

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
                                      , VALUES_OUT   OUT REF_GUI_JOB_STATS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_JOB_STATS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_GUI_JOB_STATS';
        -- local variables
        LC_CURSOR              REF_GUI_JOB_STATS;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   STATUS, DESCRIPTION, CNT
                FROM   (  SELECT   CJS.STATUS
                                 , CJS.DESCRIPTION
                                 , COUNT( * ) CNT
                                 , CJS.SORTING_ORDER
                            FROM       SESS_JOB SJ
                                   JOIN
                                       CTRL_JOB_STATUS CJS
                                   ON SJ.STATUS = CJS.STATUS
                           WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                        GROUP BY   CJS.STATUS, CJS.DESCRIPTION, CJS.SORTING_ORDER)
            ORDER BY   SORTING_ORDER;


        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_JOB_STATS;

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
                                        , VALUES_OUT   OUT REF_GUI_JOB_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_JOB_DETAILS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_GUI_JOB_DETAILS';
        -- local variables
        LC_CURSOR               REF_GUI_JOB_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STATUS_IN             VARCHAR(2048);

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));

        V_STATUS_IN := STATUS_IN;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.JOB_ID
                     , SJ.JOB_NAME
                     , SJ.STREAM_NAME
                     , SJ.ENGINE_ID
                     , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                     , SJ.LAST_UPDATE
                     , SJ.STATUS
                     , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                     , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                     , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                     , NVL(SJ.PHASE, 'N/A') PHASE
                     , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
                FROM       SESS_JOB SJ
                       JOIN
                           CTRL_JOB_STATUS CJS
                       ON SJ.STATUS = CJS.STATUS
               WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                   AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                   AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                   AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                   AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                   AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                   AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
                   AND SJ.STATUS = V_STATUS_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_GUI_JOB_DETAILS;

    PROCEDURE SP_GUI_HEADER_ENG_STAT(ENG_STATUS_OUT   OUT REF_GUI_HEADER_ENG_STATUS
                                   , ENG_NUMBER_ON   OUT NUMBER
                                   , ENG_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_HEADER_ENG_STAT
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                CONSTANT VARCHAR2(64) := 'SP_GUI_HEADER_ENG_STAT';
        -- local variables
        LC_GUI_HEADER_ENG_STATUS   REF_GUI_HEADER_ENG_STATUS;

        V_STEP                     VARCHAR2(1024);
        V_ALL_DBG_INFO             PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID              INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        OPEN LC_GUI_HEADER_ENG_STATUS FOR
            SELECT   A.PARAM_CD, CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_STATUS(A.PARAM_CD) = 0 THEN 'ON' ELSE 'OFF' END ENG_STATUS
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS' --                 AND PARAM_CD = SELECTED_ENG_ID_IN
                                                         ;

        ENG_STATUS_OUT := LC_GUI_HEADER_ENG_STATUS;

        SELECT   COUNT(ENG_STATUS) POCET_ON
          INTO   ENG_NUMBER_ON
          FROM   (SELECT   CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_STATUS(A.PARAM_CD) = 0 THEN 'ON' ELSE 'OFF' END ENG_STATUS
                    FROM   CTRL_PARAMETERS A
                   WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS' --                       AND PARAM_CD = SELECTED_ENG_ID_IN
                                                               )
         WHERE   UPPER(ENG_STATUS) = 'ON';

        SELECT   COUNT(ENG_STATUS) POCET_OFF
          INTO   ENG_NUMBER_OFF
          FROM   (SELECT   CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_STATUS(A.PARAM_CD) = 0 THEN 'ON' ELSE 'OFF' END ENG_STATUS
                    FROM   CTRL_PARAMETERS A
                   WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS' --                       AND PARAM_CD = SELECTED_ENG_ID_IN
                                                               )
         WHERE   UPPER(ENG_STATUS) = 'OFF';

        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_HEADER_ENG_STAT;

    PROCEDURE SP_GUI_HEADER_SCH_STAT(SCH_STATUS_OUT   OUT REF_GUI_HEADER_SCH_STATUS
                                   , SCH_NUMBER_ON   OUT NUMBER
                                   , SCH_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_HEADER_SCH_STAT
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                CONSTANT VARCHAR2(64) := 'SP_GUI_HEADER_MAIN';
        -- local variables
        LC_GUI_HEADER_SCH_STATUS   REF_GUI_HEADER_SCH_STATUS;


        V_STEP                     VARCHAR2(1024);
        V_ALL_DBG_INFO             PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID              INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        OPEN LC_GUI_HEADER_SCH_STATUS FOR
              SELECT   A.PARAM_CD, CASE WHEN NVL(A.PARAM_VAL_INT, 0) > 0 THEN 'ON' ELSE 'OFF' END STATUS
                FROM   CTRL_PARAMETERS A
               WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS'
            --                   AND PARAM_CD = SELECTED_ENG_ID_IN
            ORDER BY   A.PARAM_CD;

        SCH_STATUS_OUT := LC_GUI_HEADER_SCH_STATUS;

        SELECT   COUNT(STATUS) POCET_ON
          INTO   SCH_NUMBER_ON
          FROM   (SELECT   CASE WHEN NVL(A.PARAM_VAL_INT, 0) > 0 THEN 'ON' ELSE 'OFF' END STATUS
                    FROM   CTRL_PARAMETERS A
                   WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS' --                       AND PARAM_CD = SELECTED_ENG_ID_IN
                                                               )
         WHERE   UPPER(STATUS) = 'ON';

        SELECT   COUNT(STATUS) POCET_OFF
          INTO   SCH_NUMBER_OFF
          FROM   (SELECT   CASE WHEN NVL(A.PARAM_VAL_INT, 0) > 0 THEN 'ON' ELSE 'OFF' END STATUS
                    FROM   CTRL_PARAMETERS A
                   WHERE   A.PARAM_NAME = 'MAX_CONCURRENT_JOBS' --                       AND PARAM_CD = SELECTED_ENG_ID_IN
                                                               )
         WHERE   UPPER(STATUS) = 'OFF';

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_HEADER_SCH_STAT;

   PROCEDURE SP_GUI_HEADER_SYS_STAT(SYS_STATUS_OUT   OUT REF_GUI_HEADER_SYS_STATUS
                                   , SYS_NUMBER_ON   OUT NUMBER
                                   , SYS_NUMBER_OFF   OUT NUMBER
                                   , SELECTED_ENG_ID_IN IN OUT VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_HEADER_SYS_STAT
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                CONSTANT VARCHAR2(64) := 'SP_GUI_HEADER_SYS_STAT';
        -- local variables
        LC_GUI_HEADER_SYS_STATUS   REF_GUI_HEADER_SYS_STATUS;

        V_STEP                     VARCHAR2(1024);
        V_ALL_DBG_INFO             PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID              INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        OPEN LC_GUI_HEADER_SYS_STATUS FOR
            SELECT   A.PARAM_VAL_CHAR, CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_SYS_STATUS(A.PARAM_CD,A.PARAM_VAL_CHAR) = 0 THEN 'ON' ELSE 'OFF' END SYS_STATUS
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'ENGINE_STATUS'
             AND A.PARAM_CD=SELECTED_ENG_ID_IN;

        SYS_STATUS_OUT := LC_GUI_HEADER_SYS_STATUS;

        SELECT   COUNT(SYS_STATUS) POCET_ON
          INTO   SYS_NUMBER_ON
          FROM   (SELECT   A.PARAM_VAL_CHAR, CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_SYS_STATUS(A.PARAM_CD,A.PARAM_VAL_CHAR) = 0 THEN 'ON' ELSE 'OFF' END SYS_STATUS
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'ENGINE_STATUS'
             AND A.PARAM_CD=SELECTED_ENG_ID_IN)
         WHERE   UPPER(SYS_STATUS) = 'ON';

        SELECT   COUNT(SYS_STATUS) POCET_OFF
          INTO   SYS_NUMBER_OFF
          FROM   (SELECT   A.PARAM_VAL_CHAR, CASE WHEN PCKG_ENGINE.F_ENG_CHECK_WD_SYS_STATUS(A.PARAM_CD,A.PARAM_VAL_CHAR) = 0 THEN 'ON' ELSE 'OFF' END SYS_STATUS
              FROM   CTRL_PARAMETERS A
             WHERE   A.PARAM_NAME = 'ENGINE_STATUS'
             AND A.PARAM_CD=SELECTED_ENG_ID_IN)
         WHERE   UPPER(SYS_STATUS) = 'OFF';

        --last steps in procedure
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_HEADER_SYS_STAT;

    /**UPDATE PROC **********************************************************************/
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
                                    , LABEL_NAME_IN IN VARCHAR2)
    IS
        /***************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_STREAM
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       STREAM_NAME
                       STREAM_DESC
                       NOTE
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GUI_SET_CHANGE_CONTROL
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description: The purpose of this stored procedure is merge of information to the CTRL_STREAM table.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_STREAM';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_STREAM_NAME       CTRL_STREAM.STREAM_NAME%TYPE := STREAM_NAME;
        V_STREAM_DESC       CTRL_STREAM.STREAM_DESC%TYPE := STREAM_DESC;
        V_NOTE              CTRL_STREAM.NOTE%TYPE := NOTE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_STREAM SJ
             USING   DUAL
                ON   (SJ.STREAM_NAME = V_STREAM_NAME)
        WHEN MATCHED
        THEN
            UPDATE SET SJ.STREAM_DESC = REPLACE(V_STREAM_DESC, 'NULL', NULL), SJ.NOTE = REPLACE(V_NOTE, 'NULL', NULL)
        WHEN NOT MATCHED
        THEN
            INSERT              (SJ.STREAM_NAME, SJ.STREAM_DESC, SJ.NOTE)
                VALUES   (REPLACE(V_STREAM_NAME, 'NULL', NULL), REPLACE(V_STREAM_DESC, 'NULL', NULL), REPLACE(V_NOTE, 'NULL', NULL));

        SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => STREAM_NAME
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO   CTRL_STREAM SJ USING DUAL ON   (SJ.STREAM_NAME = REPLACE('''
                                 || STREAM_NAME
                                 || ''', ''NULL'', NULL)) WHEN MATCHED THEN UPDATE SET SJ.STREAM_DESC = REPLACE('''
                                 || STREAM_DESC
                                 || ''', ''NULL'', NULL), SJ.NOTE = REPLACE('''
                                 || NOTE
                                 || ''', ''NULL'', NULL) WHEN NOT MATCHED THEN INSERT (STREAM_NAME, STREAM_DESC, NOTE) VALUES (REPLACE('''
                                 || STREAM_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || STREAM_DESC
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || NOTE
                                 || ''', ''NULL'', NULL));'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_STREAM;



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
                                    , VALUES_OUT   OUT REF_GUI_CTRL_STREAM)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_GUI_DETAILS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_STREAMD';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_STREAM;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   STREAM_NAME, STREAM_DESC, NOTE
                FROM   CTRL_STREAM SJ
               WHERE   UPPER(COALESCE(SJ.STREAM_NAME, 'N/A')) LIKE V_FLT_STREAM_NAME_IN
            ORDER BY   SJ.STREAM_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_STREAM;



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
                                 , TOUGHNESS IN   CTRL_JOB.TOUGHNESS%TYPE
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
                                 , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_JOB
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_JOB';
        C_PROC_VERSION     CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_JOB_NAME         CTRL_JOB.JOB_NAME%TYPE := JOB_NAME;
        V_STREAM_NAME      CTRL_JOB.STREAM_NAME%TYPE := STREAM_NAME;
        V_PRIORITY         CTRL_JOB.PRIORITY%TYPE := PRIORITY;
        V_CMD_LINE         CTRL_JOB.CMD_LINE%TYPE := CMD_LINE;
        V_SRC_SYS_ID       CTRL_JOB.SRC_SYS_ID%TYPE := SRC_SYS_ID;
        V_PHASE            CTRL_JOB.PHASE%TYPE := PHASE;
        V_TABLE_NAME       CTRL_JOB.TABLE_NAME%TYPE := TABLE_NAME;
        V_JOB_CATEGORY     CTRL_JOB.JOB_CATEGORY%TYPE := JOB_CATEGORY;
        V_JOB_TYPE         CTRL_JOB.JOB_TYPE%TYPE := JOB_TYPE;
        V_TOUGHNESS         CTRL_JOB.TOUGHNESS%TYPE := TOUGHNESS;
        V_CONT_ANYWAY      CTRL_JOB.CONT_ANYWAY%TYPE := CONT_ANYWAY;
        V_MAX_RUNS         CTRL_JOB.MAX_RUNS%TYPE := MAX_RUNS;
        V_ALWAYS_RESTART   CTRL_JOB.ALWAYS_RESTART%TYPE := ALWAYS_RESTART;
        V_STATUS_BEGIN     CTRL_JOB.STATUS_BEGIN%TYPE := STATUS_BEGIN;
        V_WAITING_HR       CTRL_JOB.WAITING_HR%TYPE := WAITING_HR;
        V_DEADLINE_HR      CTRL_JOB.DEADLINE_HR%TYPE := DEADLINE_HR;
        V_ENGINE_ID        CTRL_JOB.ENGINE_ID%TYPE := ENGINE_ID;
        V_JOB_DESC         CTRL_JOB.JOB_DESC%TYPE := JOB_DESC;
        V_AUTHOR           CTRL_JOB.AUTHOR%TYPE := AUTHOR;
        V_NOTE             CTRL_JOB.NOTE%TYPE := NOTE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_JOB SJ
             USING   DUAL
                ON   (SJ.JOB_NAME = V_JOB_NAME)
        WHEN MATCHED
        THEN
            UPDATE SET SJ.STREAM_NAME = REPLACE(V_STREAM_NAME, 'NULL', NULL)
                     , SJ.PRIORITY = REPLACE(V_PRIORITY, 'NULL', NULL)
                     , SJ.CMD_LINE = REPLACE(V_CMD_LINE, 'NULL', NULL)
                     , SJ.SRC_SYS_ID = REPLACE(V_SRC_SYS_ID, 'NULL', NULL)
                     , SJ.PHASE = REPLACE(V_PHASE, 'NULL', NULL)
                     , SJ.TABLE_NAME = REPLACE(V_TABLE_NAME, 'NULL', NULL)
                     , SJ.JOB_CATEGORY = REPLACE(V_JOB_CATEGORY, 'NULL', NULL)
                     , SJ.JOB_TYPE = REPLACE(V_JOB_TYPE, 'NULL', NULL)
                     , SJ.TOUGHNESS = REPLACE(V_TOUGHNESS, 'NULL', NULL)
                     , SJ.CONT_ANYWAY = REPLACE(V_CONT_ANYWAY, 'NULL', NULL)
                     , SJ.MAX_RUNS = REPLACE(V_MAX_RUNS, 'NULL', NULL)
                     , SJ.ALWAYS_RESTART = REPLACE(V_ALWAYS_RESTART, 'NULL', NULL)
                     , SJ.STATUS_BEGIN = REPLACE(V_STATUS_BEGIN, 'NULL', NULL)
                     , SJ.WAITING_HR = REPLACE(V_WAITING_HR, 'NULL', NULL)
                     , SJ.DEADLINE_HR = REPLACE(V_DEADLINE_HR, 'NULL', NULL)
                     , SJ.ENGINE_ID = REPLACE(V_ENGINE_ID, 'NULL', NULL)
                     , SJ.JOB_DESC = REPLACE(V_JOB_DESC, 'NULL', NULL)
                     , SJ.AUTHOR = REPLACE(V_AUTHOR, 'NULL', NULL)
                     , SJ.NOTE = REPLACE(V_NOTE, 'NULL', NULL)
        WHEN NOT MATCHED
        THEN
            INSERT              (SJ.JOB_NAME
                               , SJ.STREAM_NAME
                               , SJ.PRIORITY
                               , SJ.CMD_LINE
                               , SJ.SRC_SYS_ID
                               , SJ.PHASE
                               , SJ.TABLE_NAME
                               , SJ.JOB_CATEGORY
                               , SJ.JOB_TYPE
                               , SJ.TOUGHNESS
                               , SJ.CONT_ANYWAY
                               , SJ.MAX_RUNS
                               , SJ.ALWAYS_RESTART
                               , SJ.STATUS_BEGIN
                               , SJ.WAITING_HR
                               , SJ.DEADLINE_HR
                               , SJ.ENGINE_ID
                               , SJ.JOB_DESC
                               , SJ.AUTHOR
                               , SJ.NOTE)
                VALUES   (REPLACE(V_JOB_NAME, 'NULL', NULL)
                        , REPLACE(V_STREAM_NAME, 'NULL', NULL)
                        , REPLACE(V_PRIORITY, 'NULL', NULL)
                        , REPLACE(V_CMD_LINE, 'NULL', NULL)
                        , REPLACE(V_SRC_SYS_ID, 'NULL', NULL)
                        , REPLACE(V_PHASE, 'NULL', NULL)
                        , REPLACE(V_TABLE_NAME, 'NULL', NULL)
                        , REPLACE(V_JOB_CATEGORY, 'NULL', NULL)
                        , REPLACE(V_JOB_TYPE, 'NULL', NULL)
                        , REPLACE(V_TOUGHNESS, 'NULL', NULL)
                        , REPLACE(V_CONT_ANYWAY, 'NULL', NULL)
                        , REPLACE(V_MAX_RUNS, 'NULL', NULL)
                        , REPLACE(V_ALWAYS_RESTART, 'NULL', NULL)
                        , REPLACE(V_STATUS_BEGIN, 'NULL', NULL)
                        , REPLACE(V_WAITING_HR, 'NULL', NULL)
                        , REPLACE(V_DEADLINE_HR, 'NULL', NULL)
                        , REPLACE(V_ENGINE_ID, 'NULL', NULL)
                        , REPLACE(V_JOB_DESC, 'NULL', NULL)
                        , REPLACE(V_AUTHOR, 'NULL', NULL)
                        , REPLACE(V_NOTE, 'NULL', NULL));

        COMMIT;
        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => NULL
          , JOB_NAME_IN        => JOB_NAME
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO CTRL_JOB SJ USING DUAL ON (SJ.JOB_NAME = REPLACE('''
                                 || V_JOB_NAME
                                 || ''', ''NULL'', NULL)) WHEN MATCHED THEN UPDATE SET SJ.STREAM_NAME = REPLACE('''
                                 || STREAM_NAME
                                 || ''', ''NULL'', NULL), SJ.PRIORITY = REPLACE('''
                                 || PRIORITY
                                 || ''', ''NULL'', NULL), SJ.CMD_LINE = REPLACE('''
                                 || CMD_LINE
                                 || ''', ''NULL'', NULL), SJ.SRC_SYS_ID = REPLACE('''
                                 || SRC_SYS_ID
                                 || ''', ''NULL'', NULL), SJ.PHASE = REPLACE('''
                                 || PHASE
                                 || ''', ''NULL'', NULL), SJ.TABLE_NAME = REPLACE('''
                                 || TABLE_NAME
                                 || ''', ''NULL'', NULL), SJ.JOB_CATEGORY = REPLACE('''
                                 || JOB_CATEGORY
                                 || ''', ''NULL'', NULL), SJ.JOB_TYPE = REPLACE('''
                                 || JOB_TYPE
                                 || ''', ''NULL'', NULL), SJ.TOUGHNESS = REPLACE('''
                                 || TOUGHNESS
                                 || ''', ''NULL'', NULL), SJ.CONT_ANYWAY = REPLACE('''
                                 || CONT_ANYWAY
                                 || ''', ''NULL'', NULL), SJ.MAX_RUNS = REPLACE('''
                                 || MAX_RUNS
                                 || ''', ''NULL'', NULL), SJ.ALWAYS_RESTART = REPLACE('''
                                 || ALWAYS_RESTART
                                 || ''', ''NULL'', NULL), SJ.STATUS_BEGIN = REPLACE('''
                                 || STATUS_BEGIN
                                 || ''', ''NULL'', NULL), SJ.WAITING_HR = REPLACE('''
                                 || WAITING_HR
                                 || ''', ''NULL'', NULL), SJ.DEADLINE_HR = REPLACE('''
                                 || DEADLINE_HR
                                 || ''', ''NULL'', NULL), SJ.ENGINE_ID = REPLACE('''
                                 || ENGINE_ID
                                 || ''', ''NULL'', NULL), SJ.JOB_DESC = REPLACE('''
                                 || JOB_DESC
                                 || ''', ''NULL'', NULL), SJ.AUTHOR = REPLACE('''
                                 || AUTHOR
                                 || ''', ''NULL'', NULL), SJ.NOTE = REPLACE('''
                                 || NOTE
                                 || ''', ''NULL'', NULL) WHEN NOT MATCHED THEN INSERT (JOB_NAME, STREAM_NAME, PRIORITY, CMD_LINE, SRC_SYS_ID, PHASE, TABLE_NAME, JOB_CATEGORY, JOB_TYPE, CONT_ANYWAY, MAX_RUNS, ALWAYS_RESTART, STATUS_BEGIN, WAITING_HR, DEADLINE_HR, ENGINE_ID, JOB_DESC, AUTHOR, NOTE) VALUES (REPLACE('''
                                 || JOB_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || STREAM_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || PRIORITY
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || CMD_LINE
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || SRC_SYS_ID
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || PHASE
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || TABLE_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || JOB_CATEGORY
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || JOB_TYPE
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || CONT_ANYWAY
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || MAX_RUNS
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || ALWAYS_RESTART
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || STATUS_BEGIN
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || WAITING_HR
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || DEADLINE_HR
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || ENGINE_ID
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || JOB_DESC
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || AUTHOR
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || NOTE
                                 || ''', ''NULL'', NULL));'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);


        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 0
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_JOB;

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
                                 , VALUES_OUT   OUT REF_GUI_CTRL_JOB)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_JOB
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_JOB';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_JOB;

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);
        V_FLT_JOB_CATEGORY_IN  VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   JOB_NAME
                     , STREAM_NAME
                     , PRIORITY
                     , CMD_LINE
                     , SRC_SYS_ID
                     , PHASE
                     , TABLE_NAME
                     , JOB_CATEGORY
                     , JOB_TYPE
                     , TOUGHNESS
                     , CONT_ANYWAY
                     , MAX_RUNS
                     , ALWAYS_RESTART
                     , STATUS_BEGIN
                     , WAITING_HR
                     , DEADLINE_HR
                     , ENGINE_ID
                     , JOB_DESC
                     , AUTHOR
                     , NOTE
                FROM   CTRL_JOB SJ
               WHERE   UPPER(NVL(SJ.JOB_NAME, 'N/A')) LIKE V_FLT_JOB_NAME_IN
                       AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                       AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                       AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                       AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                       AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
                       AND ENGINE_ID=V_ENG_ID_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_JOB;


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
                                        , VALUES_OUT   OUT REF_GUI_CTRL_STREAM)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_STREAM_DEP
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_STREAM_DEP';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_STREAM;

        V_STREAM_NAME_IN       VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_STREAM_NAME_IN := STREAM_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.STREAM_NAME
                     , SJ.STREAM_DESC
                     , SJ.NOTE
                FROM   CTRL_STREAM SJ
               WHERE   UPPER(COALESCE(SJ.STREAM_NAME, 'N/A')) LIKE V_FLT_STREAM_NAME_IN
                   AND SJ.STREAM_NAME <> V_STREAM_NAME_IN
                   AND SJ.STREAM_NAME NOT IN (SELECT   STREAM_NAME
                                                FROM   CTRL_STREAM_DEPENDENCY
                                               WHERE   PARENT_STREAM_NAME = V_STREAM_NAME_IN
                                              UNION ALL
                                              SELECT   PARENT_STREAM_NAME AS STREAM_NAME
                                                FROM   CTRL_STREAM_DEPENDENCY
                                               WHERE   STREAM_NAME = V_STREAM_NAME_IN)
            ORDER BY   SJ.STREAM_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_STREAM_DEP;



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
                                        , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_STREAM_DEP
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       STREAM_NAME_IN
                       PARENT_STREAM_NAME_IN
                       STREAM_DEP_TYPE_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is merge of information to the CTRL_STREAM_DEPENDENCY table.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_STREAM_DEP';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_STREAM_DEPENDENCY SJ
             USING   DUAL
                ON   (STREAM_NAME = STREAM_NAME_IN
                  AND PARENT_STREAM_NAME = PARENT_STREAM_NAME_IN)
        WHEN MATCHED
        THEN
            UPDATE SET REL_TYPE = STREAM_DEP_TYPE_IN
        WHEN NOT MATCHED
        THEN
            INSERT              (STREAM_NAME, PARENT_STREAM_NAME, REL_TYPE)
                VALUES   (STREAM_NAME_IN, PARENT_STREAM_NAME_IN, STREAM_DEP_TYPE_IN);

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => NULL
          , JOB_NAME_IN        => STREAM_NAME_IN
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO   CTRL_STREAM_DEPENDENCY SJ USING DUAL  ON   (STREAM_NAME = '''
                                 || STREAM_NAME_IN
                                 || ''' AND PARENT_STREAM_NAME = '''
                                 || PARENT_STREAM_NAME_IN
                                 || ''') WHEN MATCHED THEN UPDATE SET SJ.REL_TYPE='''
                                 || STREAM_DEP_TYPE_IN
                                 || ''' WHEN NOT MATCHED THEN INSERT (STREAM_NAME, PARENT_STREAM_NAME, REL_TYPE) VALUES ('''
                                 || STREAM_NAME_IN
                                 || ''', '''
                                 || PARENT_STREAM_NAME_IN
                                 || ''',  '''
                                 || STREAM_DEP_TYPE_IN
                                 || ''');'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_STREAM_DEP;



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
                                     , VALUES_OUT   OUT REF_GUI_CTRL_JOB)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_JOB_DEP
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_JOB_DEP';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_JOB;

        V_JOB_NAME_IN          VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_JOB_NAME_IN := JOB_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.JOB_NAME
                     , STREAM_NAME
                     , PRIORITY
                     , CMD_LINE
                     , SRC_SYS_ID
                     , PHASE
                     , TABLE_NAME
                     , JOB_CATEGORY
                     , JOB_TYPE
                     , TOUGHNESS
                     , CONT_ANYWAY
                     , MAX_RUNS
                     , ALWAYS_RESTART
                     , STATUS_BEGIN
                     , WAITING_HR
                     , DEADLINE_HR
                     , ENGINE_ID
                     , JOB_DESC
                     , AUTHOR
                     , NOTE
                FROM   CTRL_JOB SJ
               WHERE   UPPER(COALESCE(SJ.JOB_NAME, 'N/A')) LIKE V_FLT_JOB_NAME_IN
                   AND SJ.JOB_NAME <> V_JOB_NAME_IN
                   AND SJ.JOB_NAME NOT IN (SELECT   JOB_NAME
                                             FROM   CTRL_JOB_DEPENDENCY
                                            WHERE   PARENT_JOB_NAME = V_JOB_NAME_IN
                                           UNION ALL
                                           SELECT   PARENT_JOB_NAME AS JOB_NAME
                                             FROM   CTRL_JOB_DEPENDENCY
                                            WHERE   JOB_NAME = V_JOB_NAME_IN)
                   AND ENGINE_ID=V_ENG_ID_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_JOB_DEP;


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
                                     , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_JOB_DEP
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_JOB_DEP';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_JOB_DEPENDENCY SJ
             USING   DUAL
                ON   (JOB_NAME = JOB_NAME_IN
                  AND PARENT_JOB_NAME = PARENT_JOB_NAME_IN)
        WHEN MATCHED
        THEN
            UPDATE SET REL_TYPE = JOB_DEP_TYPE_IN
        WHEN NOT MATCHED
        THEN
            INSERT              (JOB_NAME, PARENT_JOB_NAME, REL_TYPE)
                VALUES   (JOB_NAME_IN, PARENT_JOB_NAME_IN, JOB_DEP_TYPE_IN);

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => NULL
          , JOB_NAME_IN        => JOB_NAME_IN
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO   CTRL_JOB_DEPENDENCY SJ USING DUAL ON   (JOB_NAME = '''
                                 || JOB_NAME_IN
                                 || ''' AND PARENT_JOB_NAME = '''
                                 || PARENT_JOB_NAME_IN
                                 || ''') WHEN MATCHED THEN UPDATE SET REL_TYPE='''
                                 || JOB_DEP_TYPE_IN
                                 || ''' WHEN NOT MATCHED THEN INSERT (JOB_NAME, PARENT_JOB_NAME, REL_TYPE) VALUES ('''
                                 || JOB_NAME_IN
                                 || ''', '''
                                 || PARENT_JOB_NAME_IN
                                 || ''', '''
                                 || JOB_DEP_TYPE_IN
                                 || ''');'
          , V_ENGINE_ID_IN     => NULL
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_JOB_DEP;



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
                                         , VALUES_OUT   OUT REF_GUI_CTRL_STREAM_PLAN)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_STREAM_PLAN
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_STREAM_PLAN';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_STREAM_PLAN;

        V_STREAM_NAME_IN       VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_STREAM_NAME_IN := STREAM_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.ROWID AS ROW_ID, SJ.RUNPLAN, SJ.COUNTRY_CD
              FROM             CTRL_STREAM_PLAN_REF SJ
              WHERE SJ.STREAM_NAME = V_STREAM_NAME_IN
            ORDER BY   SJ.RUNPLAN;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_STREAM_PLAN;

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
                                         , VALUES_OUT   OUT REF_GUI_CTRL_JOB_TAB_REF)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_JOB_TAB_REF
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_JOB_TAB_REF';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_JOB_TAB_REF;

        V_JOB_NAME_IN          VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_JOB_NAME_IN := JOB_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   DATABASE_NAME, TABLE_NAME, LOCK_TYPE
                FROM   CTRL_JOB_TABLE_REF SJ
               WHERE   (SJ.JOB_NAME = V_JOB_NAME_IN)
            ORDER BY   SJ.DATABASE_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_JOB_TAB_REF;



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
                                         , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_JOB_TAB_REF
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_JOB_TAB_REF';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_JOB_TABLE_REF SJ
             USING   DUAL
                ON   (JOB_NAME = JOB_NAME_IN
                  AND DATABASE_NAME = DATABASE_NAME_IN
                  AND TABLE_NAME = TABLE_NAME_IN)
        WHEN MATCHED
        THEN
            UPDATE SET LOCK_TYPE = LOCK_TYPE_IN
        WHEN NOT MATCHED
        THEN
            INSERT              (JOB_NAME
                               , DATABASE_NAME
                               , TABLE_NAME
                               , LOCK_TYPE)
                VALUES   (JOB_NAME_IN
                        , DATABASE_NAME_IN
                        , TABLE_NAME_IN
                        , LOCK_TYPE_IN);

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => NULL
          , JOB_NAME_IN        => JOB_NAME_IN
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO CTRL_JOB_TABLE_REF SJ USING DUAL ON   (JOB_NAME = '''
                                 || JOB_NAME_IN
                                 || ''' AND DATABASE_NAME = '''
                                 || DATABASE_NAME_IN
                                 || ''' AND TABLE_NAME = '''
                                 || TABLE_NAME_IN
                                 || ''') WHEN MATCHED THEN UPDATE SET SJ.LOCK_TYPE = '''
                                 || LOCK_TYPE_IN
                                 || ''' WHEN NOT MATCHED THEN INSERT (JOB_NAME, DATABASE_NAME, TABLE_NAME, LOCK_TYPE) VALUES ('''
                                 || JOB_NAME_IN
                                 || ''', '''
                                 || DATABASE_NAME_IN
                                 || ''', '''
                                 || TABLE_NAME_IN
                                 || ''', '''
                                 || LOCK_TYPE_IN
                                 || ''');'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_JOB_TAB_REF;


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
                            , VALUES_OUT   OUT REF_GUI_CHM)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CHM
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CHM';
        -- local variables
        LC_CURSOR              REF_GUI_CHM;


        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);


        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   LABEL_NAME
                     , LABEL_STATUS
                     , USER_NAME
                     , CREATE_TS
                     , DESCRIPTION
                     , ENV
                FROM   GUI_CHANGE_MANAGEMENT SJ
               WHERE   (SJ.LABEL_STATUS = 'OPEN')
            ORDER BY   SJ.LABEL_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CHM;


    PROCEDURE SP_GUI_UPDT_LABEL(ENG_ID_IN IN  INTEGER
                              , USER_IN IN    VARCHAR2
                              , DEBUG_IN IN   INTEGER:= 0
                              , EXIT_CD_OUT   OUT NOCOPY NUMBER
                              , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                              , ERRCODE_OUT   OUT NOCOPY NUMBER
                              , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                              , LABEL_NAME_IN IN VARCHAR2
                              , LABEL_STATUS_IN IN VARCHAR2
                              , DESCRIPTION_IN IN VARCHAR2)
    IS
        /******************************************************************************
         Object type:   PROCEDURE
         Name:    SP_GUI_UPDT_LABEL
         IN parameters: ENG_ID_IN
                        USER_IN
                        DEBUG_IN
                        LABEL_NAME_IN
                        LABEL_STATUS_IN
                        DESCRIPTION_IN
         OUT parameters:EXIT_CD_OUT
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
         EXIT_CD_OUT - procedure exit code (0 - OK)
         Called from: GUI
         Calling:   None
         -------------------------------------------------------------------------------
         Version:        1.0
         -------------------------------------------------------------------------------
         Project:   PDC
         Author:   Teradata - Marcel Samek
         Date:    2011-10-17
         -------------------------------------------------------------------------------
         Description:The purpose of this stored procedure is
                     insert of label name to the GUI_CHANGE_MANAGEMENT table.
         -------------------------------------------------------------------------------
         Modified:
         Version:
         Date:
         Modification:
         *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_LABEL';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_NR_OF_LABL_LIST   INTEGER := NULL;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   COUNT( * )
          INTO   V_NR_OF_LABL_LIST
          FROM   GUI_CHANGE_MANAGEMENT
         WHERE   LABEL_NAME = LABEL_NAME_IN --AND LABEL_STATUS = LABEL_STATUS_IN
                                           ;

        IF V_NR_OF_LABL_LIST > 0
        THEN
            INSERT INTO GUI_CHANGE_MANAGEMENT(LABEL_NAME
                                            , LABEL_STATUS
                                            , USER_NAME
                                            , CREATE_TS
                                            , DESCRIPTION
                                            , ENV)
              VALUES   (LABEL_NAME_IN || '_' || TO_CHAR(SYSDATE, 'j')
                      , LABEL_STATUS_IN
                      , USER_IN
                      , CURRENT_TIMESTAMP
                      , DESCRIPTION_IN
                      , 'PROD');
        ELSE
            INSERT INTO GUI_CHANGE_MANAGEMENT(LABEL_NAME
                                            , LABEL_STATUS
                                            , USER_NAME
                                            , CREATE_TS
                                            , DESCRIPTION
                                            , ENV)
              VALUES   (LABEL_NAME_IN
                      , LABEL_STATUS_IN
                      , USER_IN
                      , CURRENT_TIMESTAMP
                      , DESCRIPTION_IN
                      , 'PROD');
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_LABEL;

    PROCEDURE SP_GUI_UPDT_LABEL_BP(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , LABEL_NAME_IN IN VARCHAR2
                                 , VALUES_OUT   OUT NOCOPY REF_LABEL_BP_DETAILS)
    IS
        /******************************************************************************
       Object type:   PROCEDURE
       Name:    SP_GUI_UPDT_LABEL_BP
       IN parameters: ENG_ID_IN
                      USER_IN
                      DEBUG_IN
                      LABEL_NAME_IN
                      VALUES_OUT
       OUT parameters:EXIT_CD_OUT
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
       EXIT_CD_OUT - procedure exit code (0 - OK)
       Called from: GUI
       Calling:   None
       -------------------------------------------------------------------------------
       Version:        1.0
       -------------------------------------------------------------------------------
       Project:   PDC
       Author:   Teradata - Marcel Samek
       Date:    2011-10-17
       -------------------------------------------------------------------------------
       Description:The purpose of this stored procedure is
                   update of label name to CLOSED status in the GUI_CHANGE_MANAGEMENT table.
       -------------------------------------------------------------------------------
       Modified:
       Version:
       Date:
       Modification:
       *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_LABEL_BP';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR        REF_LABEL_BP_DETAILS;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        UPDATE   GUI_CHANGE_MANAGEMENT
           SET   LABEL_STATUS = 'Closed', DESCRIPTION = DESCRIPTION || '. Closed on ' || CURRENT_TIMESTAMP || ' by ' || USER_IN
         WHERE   LABEL_NAME = LABEL_NAME_IN;

        OPEN LC_CURSOR FOR
              SELECT   A.CMD
                FROM   GUI_CHANGE_CONTROL A
               WHERE   A.LABEL_NAME = LABEL_NAME_IN
            ORDER BY   A.SEQ_NUM;

        VALUES_OUT := LC_CURSOR;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_LABEL_BP;

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
                                     , VALUES_OUT   OUT REF_SESS_JOBS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_SESS_JOB_ALL
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.1
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon, Milan Budka
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_SESS_JOB_ALL';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_SESS_JOBS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.STREAM_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.STATUS
                   , SJ.LAST_UPDATE
                   , SJ.LOAD_DATE
                   , SJ.PRIORITY
                   , SJ.CMD_LINE
                   , SJ.SRC_SYS_ID
                   , SJ.PHASE
                   , SJ.TABLE_NAME
                   , SJ.JOB_CATEGORY
                   , SJ.JOB_TYPE
                   , SJ.TOUGHNESS
                   , SJ.CONT_ANYWAY
                   , SJ.RESTART
                   , SJ.ALWAYS_RESTART
                   , SJ.N_RUN
                   , SJ.MAX_RUNS
                   , SJ.WAITING_HR
                   , SJ.DEADLINE_HR
                   , SJ.APPLICATION_ID
                   , SJ.ENGINE_ID
                   , LJC.ABORTABLE
              FROM       SESS_JOB SJ
                     JOIN
                         LKP_JOB_CATEGORY LJC
                     ON SJ.JOB_CATEGORY = LJC.JOB_CATEGORY
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_SESS_JOB_ALL;

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
                                 , MAX_RUNS_IN IN SESS_JOB.MAX_RUNS%TYPE)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_SESS_JOB
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Milan Budka
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_SESS_JOB';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.1';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        UPDATE   SESS_JOB A
           SET   LAST_UPDATE = LAST_UPDATE_IN, PRIORITY = PRIORITY_IN, CMD_LINE = CMD_LINE_IN, TOUGHNESS=TOUGHNESS_IN, MAX_RUNS = MAX_RUNS_IN
         WHERE   A.JOB_ID = JOB_ID_IN
             AND A.ENGINE_ID = ENG_ID_IN;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_SESS_JOB;

    PROCEDURE SP_GUI_USER_AUTH(LOGIN_IN IN   VARCHAR2
                             , PASS_IN       VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , USER_ROLE_OUT   OUT NOCOPY NUMBER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_USER_AUTH
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_USER_AUTH';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;

        V_COUNT          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        USER_ROLE_OUT := -1;


        --INSERT INTO GUI_AUTH(USR_ID,USR_NAME,USR_PASSWD,USR_LEVEL)
        --VALUES(cast(dbms_random.value(100000,999999) as INTEGER), LOGIN_IN, PASS_IN, 1);

        SELECT   USR_LEVEL
          INTO   V_COUNT
          FROM   GUI_AUTH
         WHERE   USR_NAME = LOGIN_IN
             AND USR_PASSWD = PASS_IN;

        IF V_COUNT IS NOT NULL
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'OK - ' || LOGIN_IN;
            USER_ROLE_OUT := V_COUNT;
        ELSE
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := 'Login error - ' || LOGIN_IN;
            USER_ROLE_OUT := -1;
        END IF;


        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_USER_AUTH;

    /******************************************************************************/
    -- JOB Commands
    /******************************************************************************/
    PROCEDURE SP_GUI_JOB_ABORT(ENG_ID_IN IN  INTEGER
                             , USER_IN IN    VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_ABORT
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is ABORT of running jobs.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME          CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_ABORT';
        C_PROC_VERSION       CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP               VARCHAR2(1024);
        V_ALL_DBG_INFO       PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID        INTEGER := 0;
        V_JOB_ID_IN          VARCHAR2(2048);
        V_RUNABLE            CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN           VARCHAR2(20);
        V_JOB_NAME           SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS       CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID    SESS_JOB.ENGINE_ID%TYPE;

        V_ENGINE_ID          VARCHAR2(2) := V_SELECTED_ENG_ID;
        V_QUEUE_NUMBER       VARCHAR2(2);
        V_ABORT_JOB_NAME     VARCHAR2(128);
        V_CMD_LINE           VARCHAR2(1024);
        V_ABORTABLE          NUMBER;
        V_QUEUE_NUMBER_CNT   NUMBER := NULL;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   LJC.ABORTABLE
          INTO   V_ABORTABLE
          FROM       LKP_JOB_CATEGORY LJC
                 JOIN
                     SESS_JOB SJ
                 ON SJ.JOB_CATEGORY = LJC.JOB_CATEGORY
         WHERE   JOB_ID = JOB_ID_IN;

        IF V_ABORTABLE = 1
        THEN
            SELECT   COUNT( * )
              INTO   V_QUEUE_NUMBER_CNT
              FROM   SESS_QUEUE
             WHERE   JOB_ID = JOB_ID_IN
                 AND AVAILABLE = 0;

            IF V_QUEUE_NUMBER_CNT = 1
            THEN
                SELECT   LTRIM(TO_CHAR(ENGINE_ID, '09'))
                  INTO   V_ENGINE_ID
                  FROM   SESS_JOB
                 WHERE   JOB_ID = JOB_ID_IN;

                SELECT   LTRIM(TO_CHAR(QUEUE_NUMBER, '09'))
                  INTO   V_QUEUE_NUMBER
                  FROM   SESS_QUEUE
                 WHERE   JOB_ID = JOB_ID_IN
                     AND AVAILABLE = 0;

                SELECT   CMD_LINE
                  INTO   V_CMD_LINE
                  FROM   SESS_JOB
                 WHERE   JOB_ID = JOB_ID_IN;

                V_ABORT_JOB_NAME := 'ABORT_JOB_' || V_ENGINE_ID || '_' || V_QUEUE_NUMBER;

                UPDATE   SESS_JOB
                   SET   CMD_LINE = V_CMD_LINE
                       , STATUS = 0
                       , N_RUN = 0
                       , LAST_UPDATE = NULL
                 WHERE   JOB_NAME = V_ABORT_JOB_NAME;

                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'ABORTJOB'
                  , SQL_CODE_IN      => 'UPDATE SESS_JOB SET CMD_LINE = ' || V_CMD_LINE || ', STATUS = 0,N_RUN = 0, LAST_UPDATE = NULL WHERE JOB_NAME = ' || V_ABORT_JOB_NAME
                  , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                INSERT INTO SESS_STATUS(JOB_ID
                                      , JOB_NAME
                                      , STREAM_NAME
                                      , STATUS_TS
                                      , LOAD_DATE
                                      , STATUS
                                      , N_RUN
                                      , SIGNAL
                                      , APPLICATION_ID
                                      , ENGINE_ID)
                    SELECT   JOB_ID
                           , JOB_NAME
                           , STREAM_NAME
                           , SYSDATE --STATUS_TS
                           , LOAD_DATE
                           , STATUS
                           , N_RUN
                           , 'RESTART' -- SIGNAL
                           , 6 -- APPLICATION_ID
                           , ENGINE_ID
                      FROM   SESS_JOB
                     WHERE   JOB_NAME = V_ABORT_JOB_NAME;

                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'ABORTJOB'
                  , SQL_CODE_IN      => 'INSERT INTO SESS_STATUS(JOB_ID, JOB_NAME, STREAM_NAME, STATUS_TS, LOAD_DATE, STATUS, N_RUN, SIGNAL, APPLICATION_ID, ENGINE_ID) SELECT JOB_ID, JOB_NAME, STREAM_NAME, SYSDATE, LOAD_DATE, STATUS, N_RUN, ''RESTART'', 6, ENGINE_ID FROM SESS_JOB WHERE JOB_NAME = '
                                       || V_ABORT_JOB_NAME
                  , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                COMMIT;
            ELSE
                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                                  , ACTION_IN        => 'ABORTJOB'
                                                  , SQL_CODE_IN      => 'Unabortable job abort executed. JOB_ID = ' || JOB_ID_IN
                                                  , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
                                                  , DEBUG_IN         => DEBUG_IN
                                                  , EXIT_CD          => EXIT_CD_OUT
                                                  , ERRMSG_OUT       => ERRMSG_OUT
                                                  , ERRCODE_OUT      => ERRCODE_OUT
                                                  , ERRLINE_OUT      => ERRLINE_OUT);

                COMMIT;
            END IF;
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_ABORT;

    PROCEDURE SP_GUI_JOB_BLOCK_EXEC(ENG_ID_IN IN  INTEGER
                                  , JOB_ID_IN IN  NUMBER
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_BLOCK_EXEC
        IN parameters: ENG_ID_IN
                       JOB_ID_IN
                       DEBUG_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description: The purpose of this stored procedure is execution of set status BLOCKED on dependent jobs - root job is in finished state.
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2015-04-17
        Modification: Fix and revision of code
        *******************************************************************************/
        V_ENGINE_ID         NUMBER;
        V_STEP              VARCHAR2(1024);
        V_NEXT_JOB_ID       NUMBER;
        V_RUNABLE           VARCHAR2(16);
        V_ERR_CD            INTEGER := 0;
        EXIT_CD_B           NUMBER;
        RETURN_STATUS_OUT   VARCHAR2(32000);
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_BLOCK_EXEC';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        V_ENGINE_ID := ENG_ID_IN;
        -- Get actual status
        SELECT   CJS.RUNABLE
          INTO   V_RUNABLE
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   SJ.JOB_ID = JOB_ID_IN
              AND ENGINE_ID= V_ENGINE_ID;

        -- If blocked just return
        IF UPPER(V_RUNABLE) <> 'BLOCKED'
        THEN
            -- Job does not have status as blocked thus try process

            -- If job can be blocked, do it
            IF UPPER(V_RUNABLE) = 'RUNABLE'
            OR UPPER(V_RUNABLE) = 'FAILED'
            THEN
                PCKG_ENGINE.SP_ENG_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN
                                               , LAUNCH_IN           => 1
                                               , SIGNAL_IN           => 'BLOCK'
                                               , REQUEST_IN          => 'BLOCK'
                                               , ENGINE_ID_IN        => V_ENGINE_ID
                                               , SYSTEM_NAME_IN        => 'GUI'
                                               , QUEUE_NUMBER_IN     => -1
                                               , DEBUG_IN            => 0
                                               , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                               , EXIT_CD             => EXIT_CD_OUT
                                               , ERRMSG_OUT          => ERRMSG_OUT
                                               , ERRCODE_OUT         => ERRCODE_OUT
                                               , ERRLINE_OUT         => ERRLINE_OUT);
            ELSE -- Job can't be blocked, block child jobs
                DECLARE
                    CURSOR JOB_CUR
                    IS
                          SELECT   SJD.JOB_ID
                            FROM           SESS_JOB_DEPENDENCY_BCKP SJD
                                       JOIN
                                           SESS_JOB SJ
                                       ON SJD.JOB_ID = SJ.JOB_ID
                                   JOIN
                                       CTRL_JOB_STATUS CJS
                                   ON SJ.STATUS = CJS.STATUS
                                  AND UPPER(CJS.RUNABLE) != 'BLOCKED'
                           WHERE   SJD.PARENT_JOB_ID = JOB_ID_IN
                        GROUP BY   SJD.JOB_ID;
                BEGIN -- Level_2
                    FOR V_NEXT_JOB_ID IN JOB_CUR
                    LOOP
                        SP_GUI_JOB_BLOCK_EXEC(ENG_ID_IN  => V_ENGINE_ID
                                            , JOB_ID_IN     => V_NEXT_JOB_ID.JOB_ID
                                            , DEBUG_IN      => DEBUG_IN
                                            , EXIT_CD_OUT       => EXIT_CD_OUT
                                            , ERRMSG_OUT    => ERRMSG_OUT
                                            , ERRCODE_OUT   => ERRCODE_OUT
                                            , ERRLINE_OUT   => ERRLINE_OUT);
                    END LOOP;
                END;
            END IF;
        ELSE -- Job is already blocked
            EXIT_CD_OUT := 0;
        END IF;
    END SP_GUI_JOB_BLOCK_EXEC;


    PROCEDURE SP_GUI_JOB_BLOCK(ENG_ID_IN IN  INTEGER
                             , USER_IN IN    VARCHAR2
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD_OUT   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                             , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_BLOCK
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_ENGINE.SP_ENG_UPDATE_STATUS
                   SP_GUI_JOB_BLOCK_EXEC
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status BLOCKED.
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2015-04-17
        Modification: Fix and revision of code
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_BLOCK';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN
              AND ENGINE_ID= ENG_ID_IN;


        -- Procedure body
        IF V_RUNABLE != 'BLOCKED'
        THEN
            RUNABLE_IN := 'BLOCKJOB';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'BLOCKJOB'
        -- If blocked just return
        -- Job does not have status as blocked thus try process

        -- If job can be blocked, do it
        IF UPPER(V_RUNABLE) = 'RUNABLE'
        OR UPPER(V_RUNABLE) = 'FAILED'
        THEN
            PCKG_ENGINE.SP_ENG_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN
                                           , LAUNCH_IN           => 0
                                           , SIGNAL_IN           => 'BLOCK'
                                           , REQUEST_IN          => 'BLOCK'
                                           , ENGINE_ID_IN        => ENG_ID_IN
                                           , SYSTEM_NAME_IN      => 'GUI'
                                           , QUEUE_NUMBER_IN     => -1
                                           , DEBUG_IN            => 0
                                           , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                           , EXIT_CD             => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);
        ELSE -- Job can't be blocked, block child jobs
           PCKG_GUI.SP_GUI_JOB_BLOCK_EXEC(ENG_ID_IN              => ENG_ID_IN
                                           , JOB_ID_IN           => JOB_ID_IN
                                           , DEBUG_IN            => 0
                                           , EXIT_CD_OUT         => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);
        END IF;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'blockjob'
          , SQL_CODE_IN      =>   'PCKG_GUI.SP_GUI_BLOCK_JOB(JOB_ID_IN=>'
                               || JOB_ID_IN
                               || ',DEBUG_IN=>'
                               || DEBUG_IN
                               || ',RETURN_STATUS_OUT=>'
                               || RETURN_STATUS_OUT
                               || ',EXIT_CD=>'
                               || EXIT_CD_OUT
                               || ',ERRMSG_OUT=>'
                               || ERRMSG_OUT
                               || ',ERRCODE_OUT=>'
                               || ERRCODE_OUT
                               || ',ERRLINE_OUT=>'
                               || ERRLINE_OUT
                               || ')'
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'BLOCKJOB'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := JOB_ID_IN || ' has been already blocked. It is in ' || V_RUNABLE || ' state.';
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_BLOCK;

    PROCEDURE SP_GUI_JOB_MARKASFAILED(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_MARKASFAILED
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status FAILED.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_MARKASFAILED';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        LAUNCH_IN           PLS_INTEGER := 1;
        SIGNAL_IN           VARCHAR2(20) := 'FAILED';
        REQUEST_IN          VARCHAR2(20) := 'FAILED';
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;


        -- Procedure body
        IF V_RUNABLE = 'RUNNING'
        THEN
            RUNABLE_IN := 'MARKASFAILED';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'MARKASFAILED'
        PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN -- id jobu
                                           , LAUNCH_IN           => LAUNCH_IN -- = 1=start, 0=ukonceni; pro mark as finished pouzijeme 0
                                           , SIGNAL_IN           => SIGNAL_IN -- 'SUCCESS' -- pro mark as failed 'FAILED'
                                           , REQUEST_IN          => REQUEST_IN -- 'SUCCESS'-- pro mark as failed 'FAILED'
                                           , ENGINE_ID_IN        => V_SELECTED_ENG_ID -- engine#
                                           , DEBUG_IN            => DEBUG_IN
                                           , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                           , EXIT_CD             => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);



        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'jobmarkasfailed'
          , SQL_CODE_IN      =>   'PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN=>'
                               || JOB_ID_IN
                               || ',LAUNCH_IN=>'
                               || LAUNCH_IN
                               || ',SIGNAL_IN=>'
                               || SIGNAL_IN
                               || ',REQUEST_IN=>'
                               || REQUEST_IN
                               || ',ENGINE_ID_IN=>'
                               || V_SELECTED_ENG_ID
                               || ',DEBUG_IN=>'
                               || DEBUG_IN
                               || ',RETURN_STATUS_OUT=>'
                               || RETURN_STATUS_OUT
                               || ',EXIT_CD=>'
                               || EXIT_CD_OUT
                               || ',ERRMSG_OUT=>'
                               || ERRMSG_OUT
                               || ',ERRCODE_OUT=>'
                               || ERRCODE_OUT
                               || ',ERRLINE_OUT=>'
                               || ERRLINE_OUT
                               || ')'
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'MARKASFAILED'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_MARKASFAILED;

    PROCEDURE SP_GUI_JOB_MARKASFINISHED(ENG_ID_IN IN  INTEGER
                                      , USER_IN IN    VARCHAR2
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                      , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_MARKASFINISHED
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status FINISHED.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_MARKASFINISHED';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        LAUNCH_IN           PLS_INTEGER := 0;
        SIGNAL_IN           VARCHAR2(20) := 'MARK_FINISHED';
        REQUEST_IN          VARCHAR2(20) := 'MARK_FINISHED';
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;


        -- Procedure body
        IF V_RUNABLE IN ('FAILED', 'RUNABLE')
        THEN
            RUNABLE_IN := 'MARKASFINISHED';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'MARKFINISHED'
        PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN -- id jobu
                                           , LAUNCH_IN           => LAUNCH_IN -- = 1=start, 0=ukonceni; pro mark as finished pouzijeme 0
                                           , SIGNAL_IN           => SIGNAL_IN -- 'SUCCESS' -- pro mark as failed 'FAILED'
                                           , REQUEST_IN          => REQUEST_IN -- 'SUCCESS'-- pro mark as failed 'FAILED'
                                           , ENGINE_ID_IN        => V_SELECTED_ENG_ID -- engine#
                                           , DEBUG_IN            => DEBUG_IN
                                           , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                           , EXIT_CD             => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);



        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'jobmarkasfinished'
          , SQL_CODE_IN      =>   'PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN=>'
                               || JOB_ID_IN
                               || ',LAUNCH_IN=>'
                               || LAUNCH_IN
                               || ',SIGNAL_IN=>'
                               || SIGNAL_IN
                               || ',REQUEST_IN=>'
                               || REQUEST_IN
                               || ',ENGINE_ID_IN=>'
                               || V_SELECTED_ENG_ID
                               || ',DEBUG_IN=>'
                               || DEBUG_IN
                               || ',RETURN_STATUS_OUT=>'
                               || RETURN_STATUS_OUT
                               || ',EXIT_CD=>'
                               || EXIT_CD_OUT
                               || ',ERRMSG_OUT=>'
                               || ERRMSG_OUT
                               || ',ERRCODE_OUT=>'
                               || ERRCODE_OUT
                               || ',ERRLINE_OUT=>'
                               || ERRLINE_OUT
                               || ')'
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'RESTARTFINISHED'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_MARKASFINISHED;

    PROCEDURE SP_GUI_JOB_MARKASFINISHEDSUCC(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_MARKASFINISHEDSUCC
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status FINISHED_SUCC.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_MARKASFINISHEDSUCC';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        LAUNCH_IN           PLS_INTEGER := 1;
        SIGNAL_IN           VARCHAR2(20) := 'SUCCESS';
        REQUEST_IN          VARCHAR2(20) := 'SUCCESS';
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;


        -- Procedure body
        IF V_RUNABLE = 'RUNNING'
        THEN
            RUNABLE_IN := 'MARKASFINISHEDSUCC';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'MARKASFINISHEDSUCC'
        PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN -- id jobu
                                           , LAUNCH_IN           => LAUNCH_IN -- = 1=start, 0=ukonceni; pro mark as finished pouzijeme 0
                                           , SIGNAL_IN           => SIGNAL_IN -- 'SUCCESS' -- pro mark as failed 'FAILED'
                                           , REQUEST_IN          => REQUEST_IN -- 'SUCCESS'-- pro mark as failed 'FAILED'
                                           , ENGINE_ID_IN        => V_SELECTED_ENG_ID -- engine#
                                           , DEBUG_IN            => DEBUG_IN
                                           , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                           , EXIT_CD             => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);



        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'jobmarkasfinishedsucc'
          , SQL_CODE_IN      =>   'PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN=>'
                               || JOB_ID_IN
                               || ',LAUNCH_IN=>'
                               || LAUNCH_IN
                               || ',SIGNAL_IN=>'
                               || SIGNAL_IN
                               || ',REQUEST_IN=>'
                               || REQUEST_IN
                               || ',ENGINE_ID_IN=>'
                               || V_SELECTED_ENG_ID
                               || ',DEBUG_IN=>'
                               || DEBUG_IN
                               || ',RETURN_STATUS_OUT=>'
                               || RETURN_STATUS_OUT
                               || ',EXIT_CD=>'
                               || EXIT_CD_OUT
                               || ',ERRMSG_OUT=>'
                               || ERRMSG_OUT
                               || ',ERRCODE_OUT=>'
                               || ERRCODE_OUT
                               || ',ERRLINE_OUT=>'
                               || ERRLINE_OUT
                               || ')'
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'MARKASFINISHEDSUCC'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_MARKASFINISHEDSUCC;

    PROCEDURE SP_GUI_JOB_RESTART(ENG_ID_IN IN  INTEGER
                               , USER_IN IN    VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD_OUT   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                               , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_RESTART
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GUI_SET_LOG_CTRL_ACTION
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status RESTART.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_RESTART';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;

        -- Procedure body
        IF V_RUNABLE = 'FAILED'
        THEN
            RUNABLE_IN := 'RESTARTFAILED';
        ELSIF V_RUNABLE = 'FINISHED'
        THEN
            RUNABLE_IN := 'RESTARTFINISHED';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        IF RUNABLE_IN = 'RESTARTFINISHED'
        THEN
            --begin RUNABLE_IN = 'RESTARTFINISHED'
            SELECT   MAX_RUNS
              INTO   V_SEL_MAX_RUNS
              FROM   CTRL_JOB
             WHERE   JOB_NAME = V_JOB_NAME;

            UPDATE   SESS_JOB
               SET   LAST_UPDATE = NULL
                   , MAX_RUNS = N_RUN + V_SEL_MAX_RUNS
                   , RESTART = 0
                   , STATUS = 0
             WHERE   JOB_ID = JOB_ID_IN;

            PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                USER_NAME_IN     => USER_IN
              , ACTION_IN        => 'jobrestartfinished'
              , SQL_CODE_IN      => 'UPDATE SESS_JOB SET LAST_UPDATE = NULL, MAX_RUNS = N_RUN +' || V_SEL_MAX_RUNS || ', RESTART = 0, STATUS = 0 WHERE JOB_ID = ' || JOB_ID_IN
              , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
              , DEBUG_IN         => DEBUG_IN
              , EXIT_CD          => EXIT_CD_OUT
              , ERRMSG_OUT       => ERRMSG_OUT
              , ERRCODE_OUT      => ERRCODE_OUT
              , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'RESTARTFINISHED'
        ELSIF RUNABLE_IN = 'RESTARTFAILED'
        THEN
            --begin RUNABLE_IN = 'RESTARTFAILEDSETRESTART'

            SELECT   MAX_RUNS
              INTO   V_SEL_MAX_RUNS
              FROM   CTRL_JOB
             WHERE   JOB_NAME = V_JOB_NAME;

            UPDATE   SESS_JOB
               SET   LAST_UPDATE = NULL, MAX_RUNS = MAX_RUNS + V_SEL_MAX_RUNS, RESTART = 1
             WHERE   JOB_ID = JOB_ID_IN;

            PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                USER_NAME_IN     => USER_IN
              , ACTION_IN        => 'jobrestfailedsetrestart'
              , SQL_CODE_IN      => 'UPDATE SESS_JOB SET LAST_UPDATE = NULL, MAX_RUNS = MAX_RUNS +' || V_SEL_MAX_RUNS || ', RESTART = 1 WHERE JOB_ID = ' || JOB_ID_IN
              , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
              , DEBUG_IN         => DEBUG_IN
              , EXIT_CD          => EXIT_CD_OUT
              , ERRMSG_OUT       => ERRMSG_OUT
              , ERRCODE_OUT      => ERRCODE_OUT
              , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'RESTARTFAILEDSETRESTART'
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_RESTART;

    PROCEDURE SP_GUI_JOB_RESUME(ENG_ID_IN IN  INTEGER
                              , USER_IN IN    VARCHAR2
                              , DEBUG_IN IN   INTEGER:= 0
                              , EXIT_CD_OUT   OUT NOCOPY NUMBER
                              , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                              , ERRCODE_OUT   OUT NOCOPY NUMBER
                              , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                              , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_RESUME
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GUI_SET_LOG_CTRL_ACTION
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status RESUME.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_RESUME';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;


        -- Procedure body
        IF V_RUNABLE = 'FAILED'
        THEN
            RUNABLE_IN := 'RESTARTFAILED';
        ELSIF V_RUNABLE = 'FINISHED'
        THEN
            RUNABLE_IN := 'RESTARTFINISHED';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'RESTARTFAILEDSETRESUME'
        SELECT   MAX_RUNS
          INTO   V_SEL_MAX_RUNS
          FROM   CTRL_JOB
         WHERE   JOB_NAME = V_JOB_NAME;

        UPDATE   SESS_JOB
           SET   LAST_UPDATE = NULL, MAX_RUNS = MAX_RUNS + V_SEL_MAX_RUNS, RESTART = ALWAYS_RESTART
         WHERE   JOB_ID = JOB_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'jobrestfailedsetresume'
          , SQL_CODE_IN      => 'UPDATE SESS_JOB SET LAST_UPDATE = NULL, MAX_RUNS = MAX_RUNS +' || V_SEL_MAX_RUNS || ', RESTART = 0 WHERE JOB_ID = ' || JOB_ID_IN
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'RESTARTFAILEDSETRESUME'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_RESUME;

    PROCEDURE SP_GUI_JOB_UNBLOCK(ENG_ID_IN IN  INTEGER
                               , USER_IN IN    VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD_OUT   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                               , JOB_ID_IN IN  INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_JOB_UNBLOCK
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is determination of jobs
                    which will be updated to the status UNBLOCK.
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2015-04-17
        Modification: LAUNCH_IN -> N_RUN is not increased after unblock
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_JOB_UNBLOCK';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- exceptions
        E_NOT_VALID_JOB_STATUS_FOUND EXCEPTION;
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_JOB_ID_IN         VARCHAR2(2048);
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        LAUNCH_IN           PLS_INTEGER := 0;
        SIGNAL_IN           VARCHAR2(20) := 'UNBLOCK';
        REQUEST_IN          VARCHAR2(20) := 'BLOCK';
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CJS.RUNABLE, SJ.JOB_NAME, SJ.ENGINE_ID
          INTO   V_RUNABLE, V_JOB_NAME, V_SELECTED_ENG_ID
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
         WHERE   JOB_ID = JOB_ID_IN;


        -- Procedure body
        IF V_RUNABLE = 'BLOCKED'
        THEN
            RUNABLE_IN := 'UNBLOCKJOB';
        ELSE
            RAISE E_NOT_VALID_JOB_STATUS_FOUND;
        END IF;

        --begin RUNABLE_IN = 'UNBLOCKJOB'
        PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN           => JOB_ID_IN -- id jobu
                                           , LAUNCH_IN           => LAUNCH_IN -- = 1=start, 0=ukonceni; pro mark as finished pouzijeme 0
                                           , SIGNAL_IN           => SIGNAL_IN -- 'SUCCESS' -- pro mark as failed 'FAILED'
                                           , REQUEST_IN          => REQUEST_IN -- 'SUCCESS'-- pro mark as failed 'FAILED'
                                           , ENGINE_ID_IN        => V_SELECTED_ENG_ID -- engine#
                                           , DEBUG_IN            => DEBUG_IN
                                           , RETURN_STATUS_OUT   => RETURN_STATUS_OUT
                                           , EXIT_CD             => EXIT_CD_OUT
                                           , ERRMSG_OUT          => ERRMSG_OUT
                                           , ERRCODE_OUT         => ERRCODE_OUT
                                           , ERRLINE_OUT         => ERRLINE_OUT);

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'jobunblockjob'
          , SQL_CODE_IN      =>   'PCKG_ENGINE.SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN=>'
                               || JOB_ID_IN
                               || ',LAUNCH_IN=>'
                               || LAUNCH_IN
                               || ',SIGNAL_IN=>'
                               || SIGNAL_IN
                               || ',REQUEST_IN=>'
                               || REQUEST_IN
                               || ',ENGINE_ID_IN=>'
                               || V_SELECTED_ENG_ID
                               || ',DEBUG_IN=>'
                               || DEBUG_IN
                               || ',RETURN_STATUS_OUT=>'
                               || RETURN_STATUS_OUT
                               || ',EXIT_CD=>'
                               || EXIT_CD_OUT
                               || ',ERRMSG_OUT=>'
                               || ERRMSG_OUT
                               || ',ERRCODE_OUT=>'
                               || ERRCODE_OUT
                               || ',ERRLINE_OUT=>'
                               || ERRLINE_OUT
                               || ')'
          , V_ENGINE_ID_IN   => V_SELECTED_ENG_ID
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);
        --end RUNABLE_IN = 'UNBLOCKJOB'

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_NOT_VALID_JOB_STATUS_FOUND
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Pro job_id ' || JOB_ID_IN || ' nebyl nalezen zaznam s odpovidajicim statusem. Nalezeny status byl ' || V_RUNABLE;
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_JOB_UNBLOCK;



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
                                          , VALUES_OUT   OUT REF_GUI_CTRL_STREAM_DEP)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_STREAM_DEPAC
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_STREAM_DEPAC';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_STREAM_DEP;

        V_STREAM_NAME_IN       VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_STREAM_NAME_IN := STREAM_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.PARENT_STREAM_NAME AS STREAM_NAME
                     , PJ.STREAM_DESC
                     , PJ.NOTE
                     , SJ.REL_TYPE
                FROM       CTRL_STREAM_DEPENDENCY SJ --stream child
                       JOIN
                           CTRL_STREAM PJ --stream parent
                       ON SJ.STREAM_NAME = V_STREAM_NAME_IN
                      AND SJ.PARENT_STREAM_NAME = PJ.STREAM_NAME
              WHERE   UPPER(COALESCE(SJ.PARENT_STREAM_NAME, 'N/A')) LIKE V_FLT_STREAM_NAME_IN
            ORDER BY   PJ.STREAM_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_STREAM_DEPAC;

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
                                       , VALUES_OUT   OUT REF_GUI_CTRL_JOB_DEP)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_JOB_DEPAC
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_JOB_DEPAC';
        -- local variables
        LC_CURSOR              REF_GUI_CTRL_JOB_DEP;

        V_JOB_NAME_IN          VARCHAR2(2048);

        V_ENG_ID_IN            VARCHAR2(2048);
        V_FLT_STREAM_NAME_IN   VARCHAR2(2048);
        V_FLT_JOB_NAME_IN      VARCHAR2(2048);
        V_FLT_JOB_TYPE_IN      VARCHAR2(2048);
        V_FLT_TABLE_NAME_IN    VARCHAR2(2048);
        V_FLT_PHASE_IN         VARCHAR2(2048);

        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_JOB_NAME_IN := JOB_NAME_IN;

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.PARENT_JOB_NAME AS JOB_NAME
                     , PJ.STREAM_NAME
                     , PJ.PRIORITY
                     , PJ.CMD_LINE
                     , PJ.SRC_SYS_ID
                     , PJ.PHASE
                     , PJ.TABLE_NAME
                     , PJ.JOB_CATEGORY
                     , PJ.JOB_TYPE
                     , PJ.CONT_ANYWAY
                     , PJ.MAX_RUNS
                     , PJ.ALWAYS_RESTART
                     , PJ.STATUS_BEGIN
                     , PJ.WAITING_HR
                     , PJ.DEADLINE_HR
                     , PJ.ENGINE_ID
                     , PJ.JOB_DESC
                     , PJ.AUTHOR
                     , PJ.NOTE
                     , SJ.REL_TYPE
                FROM       CTRL_JOB_DEPENDENCY SJ --child
                       JOIN
                           CTRL_JOB PJ --parent
                       ON SJ.JOB_NAME = V_JOB_NAME_IN
                      AND SJ.PARENT_JOB_NAME = PJ.JOB_NAME
                WHERE UPPER(NVL(SJ.PARENT_JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
            ORDER BY   PJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_JOB_DEPAC;

    PROCEDURE SP_GUI_USER_AUTH_RIGHTS(LOGIN_IN IN   VARCHAR2
                                    , GUI_PAGE_IN IN VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_RIGHTS_OUT)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_USER_AUTH_RIGHTS
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2011-10-18
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_USER_AUTH_RIGHTS';
        -- local variables
        LC_CURSOR        REF_GUI_RIGHTS_OUT;

        V_LOGIN_IN       VARCHAR2(2048);
        V_GUI_PAGE_IN    VARCHAR2(2048);

        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_LOGIN_IN := LOGIN_IN;
        V_GUI_PAGE_IN := GUI_PAGE_IN;



        V_STEP := '10 - GET VALUES';

        IF V_GUI_PAGE_IN = 'ALL'
        THEN
            OPEN LC_CURSOR FOR
                  SELECT   DISTINCT GUI_PAGE, 'SHOW' AS ACCESS_RIGHT
                    FROM           GUI_ACCESS_ROLE_RIGHT_REF RR
                               JOIN
                                   GUI_ACCESS_GROUP_ROLE_REF GR
                               ON RR.ACCESS_ROLE = GR.ACCESS_ROLE
                           JOIN
                               GUI_ACCESS_USER_GROUP_REF UG
                           ON GR.DOMAIN_GROUP = UG.DOMAIN_GROUP
                   WHERE   USER_NAME = V_LOGIN_IN
                ORDER BY   GUI_PAGE, ACCESS_RIGHT;
        ELSE
            OPEN LC_CURSOR FOR
                  SELECT   DISTINCT GUI_PAGE, ACCESS_RIGHT
                    FROM           GUI_ACCESS_ROLE_RIGHT_REF RR
                               JOIN
                                   GUI_ACCESS_GROUP_ROLE_REF GR
                               ON RR.ACCESS_ROLE = GR.ACCESS_ROLE
                           JOIN
                               GUI_ACCESS_USER_GROUP_REF UG
                           ON GR.DOMAIN_GROUP = UG.DOMAIN_GROUP
                   WHERE   USER_NAME = V_LOGIN_IN
                       AND GUI_PAGE = V_GUI_PAGE_IN
                ORDER BY   GUI_PAGE, ACCESS_RIGHT;
        END IF;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_USER_AUTH_RIGHTS;

    PROCEDURE SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN IN VARCHAR2
                                       , ACTION_IN IN  VARCHAR2
                                       , SQL_CODE_IN IN VARCHAR2
                                       , V_ENGINE_ID_IN IN INTEGER:= 0
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_SET_LOG_CTRL_ACTION
        IN parameters: USER_NAME_IN IN VARCHAR2
                       ACTION_IN IN  VARCHAR2
                       SQL_CODE_IN IN VARCHAR2
                       V_ENGINE_ID_IN IN INTEGER:= 0
                       DEBUG_IN IN   INTEGER:= 0
        OUT parameters:EXIT_CD
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-05
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is insert LOG information
                    to the GUI_LOG_CTRL_ACTION table.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_SET_LOG_CTRL_ACTION';
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        V_ACTION_TS      TIMESTAMP := CURRENT_TIMESTAMP;
        V_DWH_DATE VARCHAR2(10)
                := NVL(TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('MANUAL_BATCH_LOAD_DATE', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY')
                     , TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY'));
        V_LABEL_NAME     VARCHAR2(1024) := NULL;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        INSERT INTO GUI_LOG_CTRL_ACTION(USER_NAME
                                      , ACTION
                                      , ACTION_TS
                                      , SQL_CODE
                                      , DWH_DATE)
          VALUES   (USER_NAME_IN
                  , ACTION_IN
                  , V_ACTION_TS
                  , SQL_CODE_IN
                  , V_DWH_DATE);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SET_LOG_CTRL_ACTION;

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
                                         , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_FAILED_ONLY
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_FAILED_ONLY';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'FAILED'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_FAILED_ONLY;

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
                                     , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_BLOCKED
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_BLOCKED';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE = 'BLOCKED'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_BLOCKED;

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
                                       , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_UNBLOCKED
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan, Vladimir Duchon
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_UNBLOCKED';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.RUNABLE <> 'BLOCKED'
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_UNBLOCKED;

    PROCEDURE SP_GUI_SCHEDULER_START(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , SCHEDULER_ID_IN IN INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_SCHEDULER_START
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       SCHEDULER_ID_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is update of CTRL_PARAMETERS table which cause start of SCHEDULER
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_SCHEDULER_START';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        V_PARAM_VAL_INT     CTRL_PARAMETERS.PARAM_VAL_INT%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   CP2.PARAM_VAL_INT
          INTO   V_PARAM_VAL_INT
          FROM   CTRL_PARAMETERS CP2
         WHERE   CP2.PARAM_CD = ENG_ID_IN
             AND CP2.PARAM_NAME = 'MAX_CONCURRENT_JOBS_BCKP';

        UPDATE   CTRL_PARAMETERS CP1
           SET   CP1.PARAM_VAL_INT = V_PARAM_VAL_INT
         WHERE   CP1.PARAM_CD = ENG_ID_IN
             AND CP1.PARAM_NAME = 'MAX_CONCURRENT_JOBS';

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'SCHEDSTART'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS CP1 SET CP1.PARAM_VAL_INT =(SELECT CP2.PARAM_VAL_INT FROM CTRL_PARAMETERS CP2 WHERE CP1.PARAM_CD = CP2.PARAM_CD AND CP2.PARAM_NAME = ''MAX_CONCURRENT_JOBS_BCKP'') WHERE CP1.PARAM_CD = '
                               || ENG_ID_IN
                               || ' AND CP1.PARAM_NAME = ''MAX_CONCURRENT_JOBS'''
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SCHEDULER_START;

    PROCEDURE SP_GUI_SCHEDULER_STOP(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , SCHEDULER_ID_IN IN INTEGER
                                  , STOP_ALL_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_SCHEDULER_STOP
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       SCHEDULER_ID_IN
                       STOP_ALL_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is update of CTRL_PARAMETERS table which cause STOP of SCHEDULER
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_SCHEDULER_STOP';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
        V_RUNABLE               CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN              VARCHAR2(20);
        V_JOB_NAME              SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS          CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID       SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT       VARCHAR2(256) := 'N/A';
        V_MAX_CONCURRENT_JOBS   CTRL_PARAMETERS.PARAM_VAL_INT%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body
        IF UPPER(STOP_ALL_IN) = 'N'
        THEN
            SELECT   CP2.PARAM_VAL_INT
              INTO   V_MAX_CONCURRENT_JOBS
              FROM   CTRL_PARAMETERS CP2
             WHERE   CP2.PARAM_CD = ENG_ID_IN
                 AND CP2.PARAM_NAME = 'MAX_CONCURRENT_JOBS';

            IF V_MAX_CONCURRENT_JOBS > 0
            THEN
                UPDATE   CTRL_PARAMETERS CP1
                   SET   CP1.PARAM_VAL_INT = V_MAX_CONCURRENT_JOBS
                 WHERE   CP1.PARAM_CD = ENG_ID_IN
                     AND CP1.PARAM_NAME = 'MAX_CONCURRENT_JOBS_BCKP';

                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'schedstop'
                  , SQL_CODE_IN      =>   'UPDATE CTRL_PARAMETERS CP1 SET CP1.PARAM_VAL_INT = '
                                       || V_MAX_CONCURRENT_JOBS
                                       || ' WHERE CP1.PARAM_CD = '
                                       || ENG_ID_IN
                                       || ' AND CP1.PARAM_NAME = ''MAX_CONCURRENT_JOBS_BCKP'''
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_INT = 0
                 WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
                     AND PARAM_CD = ENG_ID_IN;

                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'schedstop'
                  , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = 0 WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS'' AND PARAM_CD = ' || ENG_ID_IN
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);
            END IF;
        ELSIF UPPER(STOP_ALL_IN) = 'Y'
        THEN
            FOR R0 IN (SELECT   CP2.PARAM_VAL_INT
                         FROM   CTRL_PARAMETERS CP2
                        WHERE   CP2.PARAM_NAME = 'MAX_CONCURRENT_JOBS')
            LOOP
                V_MAX_CONCURRENT_JOBS := R0.PARAM_VAL_INT;

                IF V_MAX_CONCURRENT_JOBS > 0
                THEN
                    UPDATE   CTRL_PARAMETERS CP1
                       SET   CP1.PARAM_VAL_INT = V_MAX_CONCURRENT_JOBS
                     WHERE   CP1.PARAM_NAME = 'MAX_CONCURRENT_JOBS_BCKP';

                    PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                        USER_NAME_IN     => USER_IN
                      , ACTION_IN        => 'schedstop'
                      , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS CP1 SET CP1.PARAM_VAL_INT = ' || V_MAX_CONCURRENT_JOBS || ' WHERE CP1.PARAM_NAME = ''MAX_CONCURRENT_JOBS_BCKP'''
                      , V_ENGINE_ID_IN   => ENG_ID_IN
                      , DEBUG_IN         => DEBUG_IN
                      , EXIT_CD          => EXIT_CD_OUT
                      , ERRMSG_OUT       => ERRMSG_OUT
                      , ERRCODE_OUT      => ERRCODE_OUT
                      , ERRLINE_OUT      => ERRLINE_OUT);

                    UPDATE   CTRL_PARAMETERS
                       SET   PARAM_VAL_INT = 0
                     WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS';

                    PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                                      , ACTION_IN        => 'schedstop'
                                                      , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = 0 WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS'''
                                                      , V_ENGINE_ID_IN   => ENG_ID_IN
                                                      , DEBUG_IN         => DEBUG_IN
                                                      , EXIT_CD          => EXIT_CD_OUT
                                                      , ERRMSG_OUT       => ERRMSG_OUT
                                                      , ERRCODE_OUT      => ERRCODE_OUT
                                                      , ERRLINE_OUT      => ERRLINE_OUT);
                END IF;
            END LOOP;
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        /*        IF DEBUG_IN = 1
                THEN
          */
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

        PCKG_PLOG.INFO(V_STEP);
        PCKG_PLOG.DEBUG();
        PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    --    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SCHEDULER_STOP;


    PROCEDURE SP_GUI_SCHEDULER_NUM_JOB_TEMP(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , RUNNING_JOBS_NO_IN IN INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_SCHEDULER_NUM_JOB_TEMP
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_SCHEDULER_NUM_JOB_TEMP';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body
        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = RUNNING_JOBS_NO_IN
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'schednumjobtmp'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = ' || RUNNING_JOBS_NO_IN || ' WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS'' AND PARAM_CD = ' || ENG_ID_IN
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SCHEDULER_NUM_JOB_TEMP;

    PROCEDURE SP_GUI_SCHEDULER_NUM_JOB_PERM(ENG_ID_IN IN  INTEGER
                                          , USER_IN IN    VARCHAR2
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                          , RUNNING_JOBS_NO_IN IN INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_SCHEDULER_NUM_JOB_PERM
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       RUNNING_JOBS_NO_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is update of CTRL_PARAMETERS table
                  , parameters MAX_CONCURRENT_JOBS, MAX_CONCURRENT_JOBS_DFLT.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_SCHEDULER_NUM_JOB_PERM';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = RUNNING_JOBS_NO_IN
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'schednumjobperm'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = ' || RUNNING_JOBS_NO_IN || ' WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS'' AND PARAM_CD = ' || ENG_ID_IN
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = RUNNING_JOBS_NO_IN
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS_DFLT'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'schednumjobperm2'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = ' || RUNNING_JOBS_NO_IN || ' WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS_DFLT'' AND PARAM_CD = ' || ENG_ID_IN
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SCHEDULER_NUM_JOB_PERM;

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
                                      , LABEL_NAME_IN IN VARCHAR2)
    IS
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_SET_CHANGE_CONTROL';
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        V_ACTION_TS      TIMESTAMP := CURRENT_TIMESTAMP;
        EX_NO_LABEL_NAME_EXISTS EXCEPTION;
    /*        V_DWH_DATE VARCHAR2(10)
                    := NVL(TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('MANUAL_BATCH_LOAD_DATE', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY')
                         , TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY'));
            V_LABEL_NAME     VARCHAR2(1024) := NULL;*/
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        /*
                DECLARE
                BEGIN
                    SELECT   NVL(MAX(A.LABEL_NAME), 'You have to choose label')
                      INTO   V_LABEL_NAME
                      FROM   GUI_CHANGE_MNGMNT_CURR A, GUI_CHANGE_MANAGEMENT B
                     WHERE   A.USER_NAME = USER_NAME_IN
                         AND B.LABEL_NAME = A.LABEL_NAME
                         AND B.LABEL_STATUS = 'OPEN';
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        V_LABEL_NAME := 'You have to choose label';
                    WHEN OTHERS
                    THEN
                        V_LABEL_NAME := 'You have to choose label';
                END;
        */
        IF LABEL_NAME_IN IS NOT NULL --V_LABEL_NAME != 'You have to choose label'
        THEN
            INSERT INTO GUI_CHANGE_CONTROL(LABEL_NAME
                                         , USER_NAME
                                         , JOB_NAME
                                         , UID_INDICATOR
                                         , CMD_TS
                                         , CMD)
              VALUES   (LABEL_NAME_IN --V_LABEL_NAME
                      , USER_NAME_IN
                      , JOB_NAME_IN
                      , UID_INDICATOR_IN
                      , V_ACTION_TS
                      , SQL_CODE_IN);
        ELSIF LABEL_NAME_IN IS NULL
        THEN
            RAISE EX_NO_LABEL_NAME_EXISTS;
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN EX_NO_LABEL_NAME_EXISTS
        THEN
            ROLLBACK;

            EXIT_CD := 1;

            ERRMSG_OUT := 'You have to select label name before changes will be applied to the DB.';

            ERRCODE_OUT := 1;

            ERRLINE_OUT := 'No label name is selected. Step = ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_SET_CHANGE_CONTROL;

    PROCEDURE SP_GUI_DEL_CTRL_STREAM(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , STREAM_NAME_IN IN VARCHAR2
                                   , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_STREAM
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       STREAM_NAME_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is deletion of
                    stream from table CTRL_STREAM.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_STREAM';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body

        DELETE FROM   CTRL_STREAM SJ
              WHERE   SJ.STREAM_NAME = STREAM_NAME_IN;

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(USER_NAME_IN       => USER_IN
                                         , ACTION_IN          => RUNABLE_IN
                                         , JOB_NAME_IN        => STREAM_NAME_IN
                                         , UID_INDICATOR_IN   => 'D'
                                         , SQL_CODE_IN        => 'DELETE FROM CTRL_STREAM SJ WHERE SJ.STREAM_NAME = ''' || STREAM_NAME_IN || ''';'
                                         , V_ENGINE_ID_IN     => ENG_ID_IN
                                         , DEBUG_IN           => DEBUG_IN
                                         , EXIT_CD            => EXIT_CD_OUT
                                         , ERRMSG_OUT         => ERRMSG_OUT
                                         , ERRCODE_OUT        => ERRCODE_OUT
                                         , ERRLINE_OUT        => ERRLINE_OUT
                                         , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_STREAM;

    PROCEDURE SP_GUI_DEL_CTRL_STREAM_DEP(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , STREAM_NAME_IN IN VARCHAR2
                                       , PARENT_STREAM_NAME_IN IN VARCHAR2
                                       , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_STREAM_DEP
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       STREAM_NAME_IN
                       PARENT_STREAM_NAME_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is deletion of
                    stream dependency from table CTRL_STREAM_DEPENDENCY.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_STREAM_DEP';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body

        DELETE FROM   CTRL_STREAM_DEPENDENCY
              WHERE   STREAM_NAME = STREAM_NAME_IN --z bodu 1
                  AND PARENT_STREAM_NAME = PARENT_STREAM_NAME_IN --z bodu 2
                                                                ;

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => STREAM_NAME_IN
          , UID_INDICATOR_IN   => 'D'
          , SQL_CODE_IN        =>   'DELETE FROM CTRL_STREAM_DEPENDENCY WHERE STREAM_NAME = '''
                                 || STREAM_NAME_IN
                                 || ''' AND PARENT_STREAM_NAME = '''
                                 || PARENT_STREAM_NAME_IN
                                 || ''';'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_STREAM_DEP;

    PROCEDURE SP_GUI_DEL_CTRL_JOB(ENG_ID_IN IN  INTEGER
                                , USER_IN IN    VARCHAR2
                                , DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                , JOB_NAME_IN IN VARCHAR2
                                , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_JOB
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_NAME_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is deletion of
                    job from table CTRL_JOB.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_JOB';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body
        DELETE FROM   CTRL_JOB SJ
              WHERE   SJ.JOB_NAME = JOB_NAME_IN;

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(USER_NAME_IN       => USER_IN
                                         , ACTION_IN          => RUNABLE_IN
                                         , JOB_NAME_IN        => JOB_NAME_IN
                                         , UID_INDICATOR_IN   => 'D'
                                         , SQL_CODE_IN        => 'DELETE FROM CTRL_JOB SJ WHERE SJ.JOB_NAME = ''' || JOB_NAME_IN || ''';'
                                         , V_ENGINE_ID_IN     => ENG_ID_IN
                                         , DEBUG_IN           => DEBUG_IN
                                         , EXIT_CD            => EXIT_CD_OUT
                                         , ERRMSG_OUT         => ERRMSG_OUT
                                         , ERRCODE_OUT        => ERRCODE_OUT
                                         , ERRLINE_OUT        => ERRLINE_OUT
                                         , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_JOB;

    PROCEDURE SP_GUI_DEL_CTRL_JOB_DEP(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , JOB_NAME_IN IN VARCHAR2
                                    , PARENT_JOB_NAME_IN IN VARCHAR2
                                    , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_JOB_DEP
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_NAME_IN
                       PARENT_JOB_NAME_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is deletion of
                    job dependency from table CTRL_JOB_DEPENDENCY.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_JOB_DEP';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body
        DELETE FROM   CTRL_JOB_DEPENDENCY
              WHERE   JOB_NAME = JOB_NAME_IN --z bodu 1
                  AND PARENT_JOB_NAME = PARENT_JOB_NAME_IN --z bodu 2
                                                          ;

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => JOB_NAME_IN
          , UID_INDICATOR_IN   => 'D'
          , SQL_CODE_IN        => 'DELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_JOB_DEP;

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
                                        , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_JOB_TAB_REF
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       JOB_NAME_IN
                       DATABASE_NAME_IN
                       TABLE_NAME_IN
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is deletion of
                    database and table references from table CTRL_JOB_TABLE_REF.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_JOB_TAB_REF';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_JOB_NAME          SESS_JOB.JOB_NAME%TYPE;
        V_SEL_MAX_RUNS      CTRL_JOB.MAX_RUNS%TYPE;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body
        DELETE FROM   CTRL_JOB_TABLE_REF SJ
              WHERE   SJ.JOB_NAME = JOB_NAME_IN
                  AND SJ.DATABASE_NAME = DATABASE_NAME_IN
                  AND SJ.TABLE_NAME = TABLE_NAME_IN;

        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => JOB_NAME_IN
          , UID_INDICATOR_IN   => 'D'
          , SQL_CODE_IN        =>   'DELETE FROM CTRL_JOB_TABLE_REF WHERE JOB_NAME = '''
                                 || JOB_NAME_IN
                                 || ''' AND DATABASE_NAME = '''
                                 || DATABASE_NAME_IN
                                 || ''' AND TABLE_NAME = '''
                                 || TABLE_NAME_IN
                                 || ''';'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_JOB_TAB_REF;

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
                                           , VALUES_OUT   OUT REF_LOGS_LOGCTRLACTION)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LOGS_LogCtrlAction
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-18
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is return of GUI_LOG_CTRL_ACTION table content.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LOGS_LogCtrlAction';
        -- local variables
        LC_CURSOR        REF_LOGS_LOGCTRLACTION;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   A.USER_NAME
                     , A.ACTION
                     , A.ACTION_TS
                     , A.SQL_CODE
                     , A.DWH_DATE
                FROM   GUI_LOG_CTRL_ACTION A
            ORDER BY   A.ACTION_TS DESC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LOGS_LOGCTRLACTION;

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
                                           , VALUES_OUT   OUT REF_LOGS_STATLOGMSSHST)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LOGS_StatLogMessHist
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-18
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is return of STAT_LOG_MESSAGE_HIST table content.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LOGS_StatLogMessHist';
        -- local variables
        LC_CURSOR           REF_LOGS_STATLOGMSSHST;
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_FLT_JOB_NAME_IN   VARCHAR2(2048);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));

        OPEN LC_CURSOR FOR
              SELECT   A.LOG_EVENT_ID
                     , A.ERROR_CD
                     , A.JOB_NAME
                     , A.JOB_ID
                     , A.SEVERITY
                     , A.NOTIFICATION_TYPE_CD
                     , A.EVENT_DS
                     , A.RECOMMENDATION_DS
                     , A.NOTE
                     , A.ADDRESS
                     , A.DETECTED_TS
                     , A.SENT_TS
                FROM   STAT_LOG_MESSAGE_HIST A
               WHERE   UPPER(NVL(A.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
            ORDER BY   A.SENT_TS DESC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LOGS_STATLOGMSSHST;

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
                                           , VALUES_OUT   OUT REF_LOGS_STATLOGEVENTHIST)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LOGS_StatLogEventHist
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-18
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is return of STAT_LOG_EVENT_HIST table content.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LOGS_StatLogEventHist';
        -- local variables
        LC_CURSOR           REF_LOGS_STATLOGEVENTHIST;
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_FLT_JOB_NAME_IN   VARCHAR2(2048);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));

        OPEN LC_CURSOR FOR
              SELECT   A.LOG_EVENT_ID
                     , A.EVENT_TS
                     , A.NOTIFICATION_CD
                     , A.LOAD_DATE
                     , A.JOB_NAME
                     , A.JOB_ID
                     , A.SEVERITY_LEVEL_CD
                     , A.ERROR_CD
                     , A.EVENT_CD
                     , A.EVENT_DS
                     , A.START_TS
                     , A.END_TS
                     , A.TRACKING_DURATION
                     , A.LAST_STATUS
                     , A.N_RUN
                     , A.CHECKED_STATUS
                     , A.MAX_N_RUN
                     , A.AVG_DURARION_TOLERANCE
                     , A.AVG_END_TM_TOLERANCE
                     , A.ACTUAL_VALUE
                     , A.THRESHOLD
                     , A.OBJECT_NAME
                     , A.NOTE
                     , A.SENT_TS
                     , A.DWH_DATE
                FROM   STAT_LOG_EVENT_HIST A
               WHERE   UPPER(NVL(A.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
            ORDER BY   A.SENT_TS DESC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LOGS_STTLOGEVNTHST;



    PROCEDURE SP_GUI_VIEW_ACCESS_ROLE(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , ACCESS_ROLE_IN IN VARCHAR2
                                    , VALUES_OUT   OUT REF_GUI_VIEW_ACCESS_ROLE)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_ACCESS_ROLE
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       ACCESS_ROLE_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is return
                    of GUI_ACCESS_ROLE_RIGHT_REF table content(application access roles preview).
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_ACCESS_ROLE';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;

        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_ACCESS_ROLE_IN    VARCHAR2(256);

        LC_CURSOR           REF_GUI_VIEW_ACCESS_ROLE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_ACCESS_ROLE_IN := ACCESS_ROLE_IN;

        IF V_ACCESS_ROLE_IN = 'ALL'
        THEN
            OPEN LC_CURSOR FOR -- Procedure body
                              SELECT   ACCESS_ROLE, GUI_PAGE, ACCESS_RIGHT FROM GUI_ACCESS_ROLE_RIGHT_REF --WHERE
                                                                                                          --ACCESS_ROLE   = V_ACCESS_ROLE_IN
            ;
        ELSE
            OPEN LC_CURSOR FOR
                -- Procedure body
                SELECT   ACCESS_ROLE, GUI_PAGE, ACCESS_RIGHT
                  FROM   GUI_ACCESS_ROLE_RIGHT_REF
                 WHERE   ACCESS_ROLE = V_ACCESS_ROLE_IN;
        END IF;

        VALUES_OUT := LC_CURSOR;

        --         PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
        --             USER_NAME_IN       => USER_IN
        --           , ACTION_IN          => RUNABLE_IN
        --           , JOB_NAME_IN        => JOB_NAME_IN
        --           , UID_INDICATOR_IN   => 'D'
        --           , SQL_CODE_IN        => 'DELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
        --           , V_ENGINE_ID_IN     => ENG_ID_IN
        --           , DEBUG_IN           => DEBUG_IN
        --           , EXIT_CD            => EXIT_CD_OUT
        --           , ERRMSG_OUT         => ERRMSG_OUT
        --           , ERRCODE_OUT        => ERRCODE_OUT
        --           , ERRLINE_OUT        => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_ACCESS_ROLE;


    PROCEDURE SP_GUI_UPDT_ACCESS_ROLE(ENG_ID_IN IN  INTEGER
                                    , USER_IN IN    VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                    , ACCESS_ROLE_IN IN VARCHAR2
                                    , GUI_PAGE_IN IN VARCHAR2
                                    , ACCESS_RIGHT_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_ACCESS_ROLE
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       ACCESS_ROLE_IN
                       GUI_PAGE_IN
                       ACCESS_RIGHT_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is update
                    of GUI_ACCESS_ROLE_RIGHT_REF table content(application access roles).
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_ACCESS_ROLE';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;

        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_ACCESS_ROLE_IN    VARCHAR2(256);
        V_GUI_PAGE_IN       VARCHAR2(256);
        V_ACCESS_RIGHT_IN   VARCHAR2(256);

        LC_CURSOR           REF_GUI_VIEW_ACCESS_ROLE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_ACCESS_ROLE_IN := ACCESS_ROLE_IN;
        V_GUI_PAGE_IN := GUI_PAGE_IN;
        V_ACCESS_RIGHT_IN := ACCESS_RIGHT_IN;

        --         MERGE INTO   GUI_ACCESS_ROLE_RIGHT_REF SJ
        --              USING   DUAL
        --                 ON   (ACCESS_ROLE = ACCESS_ROLE_IN
        --                   AND GUI_PAGE = GUI_PAGE_IN
        --                   AND ACCESS_RIGHT = ACCESS_RIGHT_IN)
        --         WHEN MATCHED
        --         THEN
        --             UPDATE SET REL_TYPE = STREAM_DEP_TYPE_IN
        --         WHEN NOT MATCHED
        --         THEN
        --             INSERT              (STREAM_NAME, PARENT_STREAM_NAME, REL_TYPE)
        --                 VALUES   (STREAM_NAME_IN, PARENT_STREAM_NAME_IN, STREAM_DEP_TYPE_IN);

        INSERT INTO GUI_ACCESS_ROLE_RIGHT_REF(ACCESS_ROLE, GUI_PAGE, ACCESS_RIGHT)
          VALUES   (ACCESS_ROLE_IN, GUI_PAGE_IN, ACCESS_RIGHT_IN);



        --         PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
        --             USER_NAME_IN       => USER_IN
        --           , ACTION_IN          => NULL
        --           , JOB_NAME_IN        => NULL
        --           , UID_INDICATOR_IN   => 'D'
        --           , SQL_CODE_IN        => 'XXXDELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
        --           , V_ENGINE_ID_IN     => ENG_ID_IN
        --           , DEBUG_IN           => DEBUG_IN
        --           , EXIT_CD            => EXIT_CD_OUT
        --           , ERRMSG_OUT         => ERRMSG_OUT
        --           , ERRCODE_OUT        => ERRCODE_OUT
        --           , ERRLINE_OUT        => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_ACCESS_ROLE;

    PROCEDURE SP_GUI_UPDT_ACCESS_ROLE_DEL(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , ACCESS_ROLE_IN IN VARCHAR2
                                        , GUI_PAGE_IN IN VARCHAR2
                                        , ACCESS_RIGHT_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_ACCESS_ROLE_DEL
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       ACCESS_ROLE_IN
                       GUI_PAGE_IN
                       ACCESS_RIGHT_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is delete of role
                    from the GUI_ACCESS_ROLE_RIGHT_REF table(application access roles).
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_ACCESS_ROLE_DEL';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;

        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_ACCESS_ROLE_IN    VARCHAR2(256);
        V_GUI_PAGE_IN       VARCHAR2(256);
        V_ACCESS_RIGHT_IN   VARCHAR2(256);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_ACCESS_ROLE_IN := ACCESS_ROLE_IN;
        V_GUI_PAGE_IN := GUI_PAGE_IN;
        V_ACCESS_RIGHT_IN := ACCESS_RIGHT_IN;


        DELETE FROM   GUI_ACCESS_ROLE_RIGHT_REF
              WHERE   (ACCESS_ROLE = ACCESS_ROLE_IN
                   AND GUI_PAGE = GUI_PAGE_IN
                   AND ACCESS_RIGHT = ACCESS_RIGHT_IN);

        --         PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
        --             USER_NAME_IN       => USER_IN
        --           , ACTION_IN          => NULL
        --           , JOB_NAME_IN        => NULL
        --           , UID_INDICATOR_IN   => 'D'
        --           , SQL_CODE_IN        => 'XXXDELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
        --           , V_ENGINE_ID_IN     => ENG_ID_IN
        --           , DEBUG_IN           => DEBUG_IN
        --           , EXIT_CD            => EXIT_CD_OUT
        --           , ERRMSG_OUT         => ERRMSG_OUT
        --           , ERRCODE_OUT        => ERRCODE_OUT
        --           , ERRLINE_OUT        => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_ACCESS_ROLE_DEL;


    PROCEDURE SP_GUI_VIEW_LKP_PHASE(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_PHASE
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_PHASE';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.JOB_PHASE AS LKP_VAL_DESC
                FROM   LKP_PHASE A
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_PHASE;


    PROCEDURE SP_GUI_VIEW_LKP_JOB_TYPE(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_JOB_TYPE
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_JOB_TYPE';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.JOB_TYPE AS LKP_VAL_DESC
                FROM   LKP_JOB_TYPE A
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_JOB_TYPE;

    PROCEDURE SP_GUI_VIEW_LKP_TOUGHNESS (ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_TOUGHNESS
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2013-08-17
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_TOUGHNESS';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        V_ENGINE_ID_IN   INTEGER := NVL(ENG_ID_IN, 0);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;


        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.PARAM_NAME AS LKP_VAL_DESC
                FROM   ctrl_task_parameters A
                WHERE PARAM_TYPE='TOUGH_CATEGORY_CONTROL'
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_TOUGHNESS;

    PROCEDURE SP_GUI_VIEW_LKP_JOB_CATEGORY(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_JOB_CATEGORY
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_JOB_CATEGORY';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.JOB_CATEGORY AS LKP_VAL_DESC
                FROM   LKP_JOB_CATEGORY A
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_JOB_CATEGORY;


    PROCEDURE SP_GUI_VIEW_SESS_QUEUE(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_SESS_QUEUE
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_SESS_QUEUE';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.ENGINE_ID AS LKP_VAL_DESC
                FROM   SESS_QUEUE A
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_SESS_QUEUE;


    PROCEDURE SP_GUI_VIEW_CTRL_STREAM_NAME(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_STREAM_NAME
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_STREAM_NAME';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   A.STREAM_NAME AS LKP_VAL_DESC
                FROM   CTRL_STREAM A
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_STREAM_NAME;


    PROCEDURE SP_GUI_VIEW_CTRL_PARAM_ENG(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_PARAM_ENG
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_PARAM_ENG';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.PARAM_CD AS LKP_VAL_DESC
                FROM   CTRL_PARAMETERS A
               WHERE   A.PARAM_CD IS NOT NULL
            ORDER BY   LKP_VAL_DESC ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_PARAM_ENG;

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
                                    , VALUES_OUT   OUT REF_MAN_BATCH_AV)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_AVAIL_JBS
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-20
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is show all jobs
                    available for manual batch processing.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_AVAIL_JBS';
        -- local variables
        LC_CURSOR               REF_MAN_BATCH_AV;
        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;
        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));

        OPEN LC_CURSOR FOR
              SELECT   SJ.JOB_ID, SJ.JOB_NAME
                FROM   SESS_JOB_BCKP SJ
               WHERE   SJ.STATUS = 100
                   AND SJ.ENGINE_ID = ENG_ID_IN
                   AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                   AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                   AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                   AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                   AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                   AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_AVAIL_JBS;

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
                                  , VALUES_OUT   OUT REF_MAN_BATCH_SEL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_SEL_JBS
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-20
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is show all jobs
                    available for manual batch processing which was already selected.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_SEL_JBS';
        -- local variables
        LC_CURSOR               REF_MAN_BATCH_SEL;
        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));

        OPEN LC_CURSOR FOR
              SELECT   SJ.JOB_ID, SJ.JOB_NAME
                FROM   SESS_JOB_BCKP SJ
               WHERE   SJ.STATUS = 0
                   AND SJ.ENGINE_ID = ENG_ID_IN
                   AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                   AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                   AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                   AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                   AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                   AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_SEL_JBS;

    PROCEDURE SP_GET_MY_RELATIVES(JOB_ID_IN IN  VARCHAR2
                                , REQUEST_ACC_IN IN INTEGER
                                , DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GET_MY_RELATIVES';

        CURSOR GET_JOB_ID
        IS
            SELECT   A.JOB_ID
              FROM   SESS_JOB_BCKP A
             WHERE   A.JOB_ID IN (JOB_ID_IN);

        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        FOR R0 IN GET_JOB_ID
        LOOP
            IF REQUEST_ACC_IN IN (2, 4)
            THEN
                UPDATE   SESS_JOB_BCKP SJ
                   SET   SJ.STATUS = 0
                 WHERE   SJ.JOB_ID IN (SELECT   R0.JOB_ID FROM DUAL
                                       UNION ALL
                                           SELECT   JOB_ID
                                             FROM   (  SELECT   A.JOB_ID, A.PARENT_JOB_ID
                                                         FROM   SESS_JOB_DEPENDENCY_BCKP A
                                                     GROUP BY   A.JOB_ID, A.PARENT_JOB_ID)
                                       START WITH   JOB_ID = R0.JOB_ID
                                       CONNECT BY   NOCYCLE PRIOR JOB_ID = PARENT_JOB_ID)
                     AND SJ.STATUS = 100
                     AND CASE
                             WHEN JOB_NAME LIKE '%STREAM_BEGIN' THEN 1
                             WHEN JOB_NAME LIKE '%STREAM_END' THEN 1
                             ELSE 0
                         END = 0;
            END IF;

            IF REQUEST_ACC_IN IN (3, 4)
            THEN
                UPDATE   SESS_JOB_BCKP SJ
                   SET   SJ.STATUS = 0
                 WHERE   SJ.JOB_ID IN (SELECT   R0.JOB_ID FROM DUAL
                                       UNION ALL
                                           SELECT   PARENT_JOB_ID
                                             FROM   (  SELECT   A.JOB_ID, A.PARENT_JOB_ID
                                                         FROM   SESS_JOB_DEPENDENCY_BCKP A
                                                     GROUP BY   A.JOB_ID, A.PARENT_JOB_ID)
                                       START WITH   JOB_ID = R0.JOB_ID
                                       CONNECT BY   NOCYCLE PRIOR PARENT_JOB_ID = JOB_ID)
                     AND SJ.STATUS = 100
                     AND CASE
                             WHEN JOB_NAME LIKE '%STREAM_BEGIN' THEN 1
                             WHEN JOB_NAME LIKE '%STREAM_END' THEN 1
                             ELSE 0
                         END = 0;
            END IF;
        END LOOP;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := REQUEST_ACC_IN;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GET_MY_RELATIVES;

    PROCEDURE SP_GUI_MBATCH_SETEXE(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , JOB_ID_IN     VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , REQUEST_ACC_IN IN INTEGER)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_SETEXE
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       REQUEST_ACC_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GET_MY_RELATIVES
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-20
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is mark selected jobs
                    as already selected for manual batch.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_SETEXE';
        -- local variables
        V_BATCH_CHOICE_IN       VARCHAR2(20) := NULL;
        V_NR_OF_RECS            INTEGER;
        V_MAX_CONCURRENT_JOBS   INTEGER;
        --filter begin
        --        V_DYN_SQL              VARCHAR2(32000) := NULL;

        V_CONDITION             VARCHAR2(4096) := NULL;
        V_VARIABLE              VARCHAR2(4096) := NULL;
        V_JOB_NAME_IN           VARCHAR2(2048);
        V_STREAM_NAME_IN        VARCHAR2(2048);
        V_TABLE_NAME_IN         VARCHAR2(2048);
        V_JOB_TYPE_IN           VARCHAR2(2048);
        V_PHASE_IN              VARCHAR2(2048);
        V_JOB_CATEGORY_IN       VARCHAR2(2048);
        V_SPECIAL_IN            VARCHAR2(2048);
        V_SELECTED_ENG_ID_IN    VARCHAR2(2048);
        V_OPERATOR              VARCHAR2(10) := ' AND ';
        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        IF REQUEST_ACC_IN = '1'
        THEN
            UPDATE   SESS_JOB_BCKP SJ
               SET   SJ.STATUS = 0
             WHERE   SJ.JOB_ID IN (JOB_ID_IN)
                 AND SJ.STATUS = 100;
        ELSIF REQUEST_ACC_IN IN (2, 3, 4)
        THEN
            SP_GET_MY_RELATIVES(JOB_ID_IN        => JOB_ID_IN
                              , REQUEST_ACC_IN   => REQUEST_ACC_IN
                              , DEBUG_IN         => DEBUG_IN
                              , EXIT_CD_OUT      => EXIT_CD_OUT
                              , ERRMSG_OUT       => ERRMSG_OUT
                              , ERRCODE_OUT      => ERRCODE_OUT
                              , ERRLINE_OUT      => ERRLINE_OUT);
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'REQUEST_ACC_IN ' || REQUEST_ACC_IN;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_SETEXE;

    PROCEDURE SP_GUI_MBATCH_UNSETEXE(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , JOB_ID_IN     VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_UNSETEXE
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-04-14
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is unmark selected jobs
                    from already selected for manual batch.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_UNSETEXE';
        -- local variables
        V_BATCH_CHOICE_IN       VARCHAR2(20) := NULL;
        V_NR_OF_RECS            INTEGER;
        V_MAX_CONCURRENT_JOBS   INTEGER;
        --filter begin
        --        V_DYN_SQL              VARCHAR2(32000) := NULL;

        V_CONDITION             VARCHAR2(4096) := NULL;
        V_VARIABLE              VARCHAR2(4096) := NULL;
        V_JOB_NAME_IN           VARCHAR2(2048);
        V_STREAM_NAME_IN        VARCHAR2(2048);
        V_TABLE_NAME_IN         VARCHAR2(2048);
        V_JOB_TYPE_IN           VARCHAR2(2048);
        V_PHASE_IN              VARCHAR2(2048);
        V_JOB_CATEGORY_IN       VARCHAR2(2048);
        V_SPECIAL_IN            VARCHAR2(2048);
        V_SELECTED_ENG_ID_IN    VARCHAR2(2048);
        V_OPERATOR              VARCHAR2(10) := ' AND ';
        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        --            EXECUTE IMMEDIATE ('UPDATE   SESS_JOB SJ SET   SJ.STATUS = 100 WHERE   SJ.JOB_ID IN (' || JOB_ID_IN || ')');
        UPDATE   SESS_JOB_BCKP SJ
           SET   SJ.STATUS = 100
         WHERE   SJ.JOB_ID IN (JOB_ID_IN);

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                          , ACTION_IN        => 'MBUNSETEXE'
                                          , SQL_CODE_IN      => 'UPDATE   SESS_JOB SJ SET   SJ.STATUS = 100 WHERE   SJ.JOB_ID IN (' || JOB_ID_IN || ')'
                                          , V_ENGINE_ID_IN   => ENG_ID_IN
                                          , DEBUG_IN         => DEBUG_IN
                                          , EXIT_CD          => EXIT_CD_OUT
                                          , ERRMSG_OUT       => ERRMSG_OUT
                                          , ERRCODE_OUT      => ERRCODE_OUT
                                          , ERRLINE_OUT      => ERRLINE_OUT);
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_UNSETEXE;

    PROCEDURE SP_GUI_MBATCH_SETSTART(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_SETSTART
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-04-14
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is start of manual batch.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_SETSTART';
        -- local variables
        V_BATCH_CHOICE_IN       VARCHAR2(20) := NULL;
        V_NR_OF_RECS            INTEGER;
        V_MAX_CONCURRENT_JOBS   INTEGER;
        --filter begin
        --        V_DYN_SQL              VARCHAR2(32000) := NULL;

        V_CONDITION             VARCHAR2(4096) := NULL;
        V_VARIABLE              VARCHAR2(4096) := NULL;
        V_JOB_NAME_IN           VARCHAR2(2048);
        V_STREAM_NAME_IN        VARCHAR2(2048);
        V_TABLE_NAME_IN         VARCHAR2(2048);
        V_JOB_TYPE_IN           VARCHAR2(2048);
        V_PHASE_IN              VARCHAR2(2048);
        V_JOB_CATEGORY_IN       VARCHAR2(2048);
        V_SPECIAL_IN            VARCHAR2(2048);
        V_SELECTED_ENG_ID_IN    VARCHAR2(2048);
        V_OPERATOR              VARCHAR2(10) := ' AND ';
        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        PCKG_INIT.SP_GUI_INIT_INITIALIZE_STRT(ENGINE_ID_IN   => ENG_ID_IN
                                            , DEBUG_IN       => DEBUG_IN
                                            , EXIT_CD        => EXIT_CD_OUT
                                            , ERRMSG_OUT     => ERRMSG_OUT
                                            , ERRCODE_OUT    => ERRCODE_OUT
                                            , ERRLINE_OUT    => ERRLINE_OUT);

        SELECT   PCKG_FWRK.F_GET_CTRL_PARAMETERS('MAX_CONCURRENT_JOBS_DFLT', 'PARAM_VAL_INT', ENG_ID_IN) INTO V_MAX_CONCURRENT_JOBS FROM DUAL;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = V_MAX_CONCURRENT_JOBS
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'MBSETSTART'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = ' || V_MAX_CONCURRENT_JOBS || ' WHERE   PARAM_NAME = ''MAX_CONCURRENT_JOBS'' AND PARAM_CD = ' || ENG_ID_IN
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_SETSTART;

    PROCEDURE SP_GUI_MBATCH_SETFIN(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_SETFIN
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-04-14
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is set as finished manual batch processing.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_SETFIN';
        -- local variables
        V_BATCH_CHOICE_IN       VARCHAR2(20) := NULL;
        V_NR_OF_RECS            INTEGER;
        V_MAX_CONCURRENT_JOBS   INTEGER;
        --filter begin
        --        V_DYN_SQL              VARCHAR2(32000) := NULL;

        V_CONDITION             VARCHAR2(4096) := NULL;
        V_VARIABLE              VARCHAR2(4096) := NULL;
        V_JOB_NAME_IN           VARCHAR2(2048);
        V_STREAM_NAME_IN        VARCHAR2(2048);
        V_TABLE_NAME_IN         VARCHAR2(2048);
        V_JOB_TYPE_IN           VARCHAR2(2048);
        V_PHASE_IN              VARCHAR2(2048);
        V_JOB_CATEGORY_IN       VARCHAR2(2048);
        V_SPECIAL_IN            VARCHAR2(2048);
        V_SELECTED_ENG_ID_IN    VARCHAR2(2048);
        V_OPERATOR              VARCHAR2(10) := ' AND ';
        --filter end
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        DELETE FROM   SESS_JOB_DEPENDENCY SJD
              WHERE   SJD.JOB_ID IN (SELECT   JOB_ID
                                       FROM   SESS_JOB SJ
                                      WHERE   SJ.ENGINE_ID = ENG_ID_IN);

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'MBSETFIN'
          , SQL_CODE_IN      => 'DELETE FROM SESS_JOB_DEPENDENCY SJD WHERE SJD.JOB_ID IN (SELECT JOB_ID FROM SESS_JOB SJ WHERE SJ.ENGINE_ID = ' || ENG_ID_IN || ')'
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);


        DELETE FROM   SESS_JOB SJ
              WHERE   SJ.ENGINE_ID = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                          , ACTION_IN        => 'MBSETFIN'
                                          , SQL_CODE_IN      => 'DELETE FROM SESS_JOB SJ WHERE SJ.ENGINE_ID = ' || ENG_ID_IN
                                          , V_ENGINE_ID_IN   => ENG_ID_IN
                                          , DEBUG_IN         => DEBUG_IN
                                          , EXIT_CD          => EXIT_CD_OUT
                                          , ERRMSG_OUT       => ERRMSG_OUT
                                          , ERRCODE_OUT      => ERRCODE_OUT
                                          , ERRLINE_OUT      => ERRLINE_OUT);

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = 0
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                          , ACTION_IN        => 'MBSETFIN'
                                          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = 0 WHERE PARAM_NAME = ''APPLICATION_ID'' AND PARAM_CD = ' || ENG_ID_IN
                                          , V_ENGINE_ID_IN   => ENG_ID_IN
                                          , DEBUG_IN         => DEBUG_IN
                                          , EXIT_CD          => EXIT_CD_OUT
                                          , ERRMSG_OUT       => ERRMSG_OUT
                                          , ERRCODE_OUT      => ERRCODE_OUT
                                          , ERRLINE_OUT      => ERRLINE_OUT);

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_DATE = NULL
         WHERE   PARAM_NAME = 'MANUAL_BATCH_LOAD_DATE'
             AND PARAM_CD = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
            USER_NAME_IN     => USER_IN
          , ACTION_IN        => 'MBSETFIN'
          , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_DATE = NULL WHERE PARAM_NAME = ''MANUAL_BATCH_LOAD_DATE'' AND PARAM_CD = ' || ENG_ID_IN
          , V_ENGINE_ID_IN   => ENG_ID_IN
          , DEBUG_IN         => DEBUG_IN
          , EXIT_CD          => EXIT_CD_OUT
          , ERRMSG_OUT       => ERRMSG_OUT
          , ERRCODE_OUT      => ERRCODE_OUT
          , ERRLINE_OUT      => ERRLINE_OUT);

        UPDATE   LKP_APPLICATION
           SET   IS_ACTIVE = 0
         WHERE   IS_ACTIVE = 1
             AND ENGINE_ID = ENG_ID_IN;

        PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(USER_NAME_IN     => USER_IN
                                          , ACTION_IN        => 'MBSETFIN'
                                          , SQL_CODE_IN      => 'UPDATE LKP_APPLICATION SET IS_ACTIVE = 0 WHERE IS_ACTIVE = 1 AND ENGINE_ID = ' || ENG_ID_IN
                                          , V_ENGINE_ID_IN   => ENG_ID_IN
                                          , DEBUG_IN         => DEBUG_IN
                                          , EXIT_CD          => EXIT_CD_OUT
                                          , ERRMSG_OUT       => ERRMSG_OUT
                                          , ERRCODE_OUT      => ERRCODE_OUT
                                          , ERRLINE_OUT      => ERRLINE_OUT);

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_CHAR = NULL
         WHERE   PARAM_NAME = 'SCHEDULER_PROVIDED_BY'
             AND PARAM_CD = ENG_ID_IN;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_SETFIN;

    PROCEDURE SP_GUI_MBATCH_STRTCHCK(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_STRTCHCK
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-20
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is check of scheduler status for manual batch.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        C_PROC_NAME                   CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_STRTCHCK';
        V_ENGINE_ID_IN                INTEGER := NVL(ENG_ID_IN, 0);
        EX_COULDNT_MAKE_MANBATCH EXCEPTION;
        EX_COULD_MAKE_MANBATCH EXCEPTION;
        EX_PREP_MANBATCH_SEL_LD EXCEPTION;
        EX_PREP_MANBATCH_SEL_DESC EXCEPTION;
        EX_PREP_MANBATCH_SEL_JOBS EXCEPTION;
        EX_RUN_MANBATCH_IN_PROGRESS EXCEPTION;
        EX_RUN_MANBATCH_FIN EXCEPTION;

        V_STEP                        VARCHAR2(1024);
        V_ALL_DBG_INFO                PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID                 INTEGER := 0;
        V_POCET_NEUKONCENYCH          INTEGER := 0;
        V_NUM_APP_ID                  INTEGER := -1;
        V_NUM_IS_FIN                  INTEGER := -1;
        V_CNT_SESS_JOB                INTEGER := -1;
        CNT_MAN_BATCH_DESC_IN         INTEGER;
        V_CURR_MAN_BTCH_LD            VARCHAR2(10) := PCKG_FWRK.F_GET_CTRL_PARAMETERS('MANUAL_BATCH_LOAD_DATE', 'param_val_date', V_ENGINE_ID_IN);
        V_POCET_SEL_V_SESS_JOB_BCKP   INTEGER := -1;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        --jede radne zpracovani
        SELECT   COUNT( * ) POCET_NEUKONCENYCH
          INTO   V_POCET_NEUKONCENYCH
          FROM           SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                 JOIN
                     CTRL_NEXT_STATUS CNS
                 ON CJS.STATUS = CNS.STATUS_IN
         WHERE   SJ.ENGINE_ID = V_ENGINE_ID_IN
             AND CJS.FINISHED = 0;

        IF V_POCET_NEUKONCENYCH > 0
       AND V_CURR_MAN_BTCH_LD IS NULL
        THEN
            RAISE EX_COULDNT_MAKE_MANBATCH;
        END IF;

        --nejede radne zpracovani
        IF V_POCET_NEUKONCENYCH = 0
       AND V_CURR_MAN_BTCH_LD IS NULL
        THEN
            RAISE EX_COULD_MAKE_MANBATCH;
        END IF;

        --priprava manbatch - vybrano datum zpracovani
        SELECT   COUNT(APPLICATION_ID)
          INTO   CNT_MAN_BATCH_DESC_IN
          FROM   LKP_APPLICATION
         WHERE   ENGINE_ID = V_ENGINE_ID_IN;

        IF V_CURR_MAN_BTCH_LD IS NOT NULL
       AND CNT_MAN_BATCH_DESC_IN = 0
       AND V_POCET_NEUKONCENYCH = 0
        THEN
            RAISE EX_PREP_MANBATCH_SEL_LD;
        END IF;

        --priprava manbatch - vybrany nazev zpracovani a zahajena inicializace(prozatim zadne joby nejsou vybranydo manbatxh zpracovani-prava strana obrazovky)
        SELECT   COUNT( * )
          INTO   V_POCET_SEL_V_SESS_JOB_BCKP
          FROM   SESS_JOB_BCKP SJB
         WHERE   STATUS = 0;

        IF V_CURR_MAN_BTCH_LD IS NOT NULL
       AND CNT_MAN_BATCH_DESC_IN > 0
       AND V_POCET_NEUKONCENYCH = 0
       AND V_POCET_SEL_V_SESS_JOB_BCKP = 0
        THEN
            RAISE EX_PREP_MANBATCH_SEL_DESC;
        END IF;

        --priprava manbatch - vybrany nektere joby
        IF V_CURR_MAN_BTCH_LD IS NOT NULL
       AND CNT_MAN_BATCH_DESC_IN > 0
       AND V_POCET_NEUKONCENYCH = 0
       AND V_POCET_SEL_V_SESS_JOB_BCKP > 0
        THEN
            RAISE EX_PREP_MANBATCH_SEL_JOBS;
        END IF;

        --bezi manbatch
        IF V_CURR_MAN_BTCH_LD IS NOT NULL
       AND CNT_MAN_BATCH_DESC_IN > 0
       AND V_POCET_NEUKONCENYCH > 0
        THEN
            RAISE EX_RUN_MANBATCH_IN_PROGRESS;
        END IF;

        --dokonceny beh manbatch

        SELECT   COUNT( * )
          INTO   V_NUM_IS_FIN
          FROM       SESS_JOB SJ
                 INNER JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
                AND CJS.FINISHED = 0;

        SELECT   COUNT( * )
          INTO   V_NUM_APP_ID
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_VAL_INT < 100;

        SELECT   COUNT( * ) INTO V_CNT_SESS_JOB FROM SESS_JOB;

        IF V_NUM_IS_FIN = 0
       AND V_NUM_APP_ID = 0
       AND V_CNT_SESS_JOB > 0
        THEN
            RAISE EX_RUN_MANBATCH_FIN;
        END IF;

        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN EX_COULDNT_MAKE_MANBATCH
        THEN
            EXIT_CD_OUT := 1;

            ERRMSG_OUT := 'Unable to run manual batch now, because some jobs are still running. Try it later, please.';

            ERRCODE_OUT := 1;

            ERRLINE_OUT := 'Unable to run manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_COULD_MAKE_MANBATCH
        THEN
            EXIT_CD_OUT := 0;

            ERRMSG_OUT := 'Everything is OK, you can rock''n''roll for manual batch';

            ERRCODE_OUT := 0;

            ERRLINE_OUT := 'You can prepare manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_PREP_MANBATCH_SEL_LD
        THEN
            EXIT_CD_OUT := 2;

            ERRMSG_OUT := 'Manual bacth preparation in progress. Load Date only is selected.';

            ERRCODE_OUT := 2;

            ERRLINE_OUT := 'You can prepare manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_PREP_MANBATCH_SEL_DESC
        THEN
            EXIT_CD_OUT := 2;

            ERRMSG_OUT := 'Manual bacth preparation in progress. Load Date and description is selected.';

            ERRCODE_OUT := 2;

            ERRLINE_OUT := 'You can prepare manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_PREP_MANBATCH_SEL_JOBS
        THEN
            EXIT_CD_OUT := 2;

            ERRMSG_OUT := 'Manual bacth preparation in progress. Some jobs are selected but execution is not started.';

            ERRCODE_OUT := 2;

            ERRLINE_OUT := 'You can prepare manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_RUN_MANBATCH_IN_PROGRESS
        THEN
            EXIT_CD_OUT := 2;

            ERRMSG_OUT := 'Manual batch execution is in progress.';

            ERRCODE_OUT := 2;

            ERRLINE_OUT := 'Manual batch exec in progress.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_RUN_MANBATCH_FIN
        THEN
            EXIT_CD_OUT := 3;

            ERRMSG_OUT := 'Manual batch execution is finished.';

            ERRCODE_OUT := 3;

            ERRLINE_OUT := 'Manual batch execution is finished.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_STRTCHCK;

    PROCEDURE SP_GUI_MBATCH_STINIT(ENG_ID_IN IN  INTEGER
                                 , USER_IN IN    VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                 , MAN_BATCH_LD_IN IN OUT NOCOPY VARCHAR2
                                 , MAN_BATCH_DESC_IN IN OUT NOCOPY LKP_APPLICATION.DESCRIPTION%TYPE)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_MBATCH_STINIT
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       MAN_BATCH_LD_IN
                       MAN_BATCH_DESC_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-20
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is initialization
                    of environment for manual batch.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_MBATCH_STINIT';
        V_ENGINE_ID_IN          INTEGER := NVL(ENG_ID_IN, 0);
        EX_COULDNT_MAKE_MANBATCH EXCEPTION;
        EX_MANBATCH_EXISTS EXCEPTION;
        V_STATUS_IN             CTRL_NEXT_STATUS.STATUS_IN%TYPE;
        V_STATUS_OUT            CTRL_NEXT_STATUS.STATUS_OUT%TYPE;
        V_CNT                   INTEGER;
        V_POCET_NEUKONCENYCH    INTEGER := 0;
        V_DWH_DATE VARCHAR2(10)
                := NVL(TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('MANUAL_BATCH_LOAD_DATE', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY')
                     , TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY'));
        V_CURR_MAN_BTCH_LD      VARCHAR2(10) := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('MANUAL_BATCH_LOAD_DATE', 'param_val_date', V_ENGINE_ID_IN), 'DD.MM.YYYY');
        V_LKP_APPLICATION_ID    PLS_INTEGER;
        V_DESC_NR               PLS_INTEGER;
        V_MAN_BATCH_DESC_IN     VARCHAR2(256) := MAN_BATCH_DESC_IN;
        CNT_MAN_BATCH_DESC_IN   INTEGER;
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
        V_MAN_BATCH_CURR_DATE   VARCHAR2(256) := NULL;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   COUNT( * ) POCET_NEUKONCENYCH
          INTO   V_POCET_NEUKONCENYCH
          FROM           SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                 JOIN
                     CTRL_NEXT_STATUS CNS
                 ON CJS.STATUS = CNS.STATUS_IN
         WHERE   SJ.ENGINE_ID = V_ENGINE_ID_IN
             AND CJS.FINISHED = 0;

        IF V_POCET_NEUKONCENYCH > 0
       AND V_CURR_MAN_BTCH_LD IS NULL
        THEN
            RAISE EX_COULDNT_MAKE_MANBATCH;
        ELSE
            IF V_CURR_MAN_BTCH_LD IS NULL
            THEN
                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_DATE = MAN_BATCH_LD_IN
                 WHERE   PARAM_NAME = 'MANUAL_BATCH_LOAD_DATE'
                     AND PARAM_CD = V_ENGINE_ID_IN;


                PCKG_GUI.SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'MBSTBUSDAY'
                  , SQL_CODE_IN      =>   'UPDATE CTRL_PARAMETERS SET PARAM_VAL_DATE = '
                                       || MAN_BATCH_LD_IN
                                       || ' WHERE PARAM_NAME = ''MANUAL_BATCH_LOAD_DATE'' AND PARAM_CD = '
                                       || V_ENGINE_ID_IN
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);
            ELSE
                RAISE EX_MANBATCH_EXISTS;
            END IF;

            DELETE FROM   SESS_JOB_BCKP
                  WHERE   ENGINE_ID = ENG_ID_IN;

            DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
                  WHERE   JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP)
                       OR PARENT_JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP);

            SELECT   LKP_APPLICATION_APP_ID_SEQ.NEXTVAL INTO V_LKP_APPLICATION_ID FROM DUAL;

            SELECT   COUNT(A.APPLICATION_ID) POCET
              INTO   V_DESC_NR
              FROM   LKP_APPLICATION A
             WHERE   A.DESCRIPTION = MAN_BATCH_DESC_IN
                 AND A.ENGINE_ID = V_ENGINE_ID_IN;

            --
            IF V_DESC_NR = 0
            THEN
                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_INT = V_LKP_APPLICATION_ID
                 WHERE   PARAM_NAME = 'APPLICATION_ID'
                     AND PARAM_CD = V_ENGINE_ID_IN;

                SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'MBSETINIT'
                  , SQL_CODE_IN      =>   'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = '
                                       || V_LKP_APPLICATION_ID
                                       || ' WHERE PARAM_NAME = ''APPLICATION_ID'' AND PARAM_CD = '
                                       || V_ENGINE_ID_IN
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_INT = 0
                 WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
                     AND PARAM_CD = V_ENGINE_ID_IN;

                SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'MBSETINIT'
                  , SQL_CODE_IN      => 'UPDATE CTRL_PARAMETERS SET PARAM_VAL_INT = 0 WHERE PARAM_NAME = ''MAX_CONCURRENT_JOBS'' AND PARAM_CD = ' || V_ENGINE_ID_IN
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);


                INSERT INTO LKP_APPLICATION(APPLICATION_ID
                                          , IGNORE_STATS
                                          , DESCRIPTION
                                          , ENGINE_ID
                                          , IS_ACTIVE)
                  VALUES   (V_LKP_APPLICATION_ID
                          , 1
                          , V_MAN_BATCH_DESC_IN
                          , V_ENGINE_ID_IN
                          , 1);

                SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'MBSETINIT'
                  , SQL_CODE_IN      =>   'INSERT INTO LKP_APPLICATION(APPLICATION_ID, IGNORE_STATS, DESCRIPTION, ENGINE_ID, IS_ACTIVE) VALUES ('
                                       || V_LKP_APPLICATION_ID
                                       || ', 1, '
                                       || V_MAN_BATCH_DESC_IN
                                       || ', '
                                       || V_ENGINE_ID_IN
                                       || ', 1)'
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                PCKG_INIT.SP_GUI_INIT_INITIALIZE(ENGINE_ID_IN   => ENG_ID_IN
                                               , DEBUG_IN       => DEBUG_IN
                                               , EXIT_CD        => EXIT_CD_OUT
                                               , ERRMSG_OUT     => ERRMSG_OUT
                                               , ERRCODE_OUT    => ERRCODE_OUT
                                               , ERRLINE_OUT    => ERRLINE_OUT);


                SP_GUI_SET_LOG_CTRL_ACTION(
                    USER_NAME_IN     => USER_IN
                  , ACTION_IN        => 'MBSETINIT'
                  , SQL_CODE_IN      =>   'SP_GUI_INIT_INITIALIZE(ENG_ID_IN   => '
                                       || V_ENGINE_ID_IN
                                       || '
                                     , DEBUG_IN       => '
                                       || DEBUG_IN
                                       || '
                                     , EXIT_CD        => '
                                       || EXIT_CD_OUT
                                       || '
                                     , ERRMSG_OUT     => '
                                       || ERRMSG_OUT
                                       || '
                                     , ERRCODE_OUT    => '
                                       || ERRCODE_OUT
                                       || '
                                     , ERRLINE_OUT    => '
                                       || ERRLINE_OUT
                                       || ')'
                  , V_ENGINE_ID_IN   => ENG_ID_IN
                  , DEBUG_IN         => DEBUG_IN
                  , EXIT_CD          => EXIT_CD_OUT
                  , ERRMSG_OUT       => ERRMSG_OUT
                  , ERRCODE_OUT      => ERRCODE_OUT
                  , ERRLINE_OUT      => ERRLINE_OUT);

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_CHAR = USER_IN
                 WHERE   PARAM_NAME = 'SCHEDULER_PROVIDED_BY'
                     AND PARAM_CD = ENG_ID_IN;
            END IF;
        END IF;

        DECLARE
            EXITCD   INTEGER;
        BEGIN
            IF MAN_BATCH_LD_IN IS NULL
            THEN
                MAN_BATCH_LD_IN := V_CURR_MAN_BTCH_LD;
            END IF;

            /*
                        IF MAN_BATCH_LD_IN IS NOT NULL
                        THEN
                            MAN_BATCH_LD_IN := REPLACE(to_char(to_date(MAN_BATCH_LD_IN, 'DD.MM.YYYY'), 'DD.MM.YYYY'), '01.01.0001', '');
                        END IF;*/

            IF MAN_BATCH_DESC_IN IS NULL
            THEN
                SELECT   COUNT(APPLICATION_ID)
                  INTO   CNT_MAN_BATCH_DESC_IN
                  FROM   LKP_APPLICATION
                 WHERE   ENGINE_ID = V_ENGINE_ID_IN;

                IF CNT_MAN_BATCH_DESC_IN > 0
                THEN
                    SELECT   DESCRIPTION
                      INTO   MAN_BATCH_DESC_IN
                      FROM   LKP_APPLICATION
                     WHERE   IS_ACTIVE = 1
                         AND ENGINE_ID = V_ENGINE_ID_IN;
                END IF;
            END IF;

            EXITCD := 0;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                EXITCD := 1;
            WHEN OTHERS
            THEN
                EXITCD := 1;
        END;

        COMMIT;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN EX_COULDNT_MAKE_MANBATCH
        THEN
            EXIT_CD_OUT := 1;

            ERRMSG_OUT := 'Unable to run manual batch now, because some jobs are still running. Try it later, please.';

            ERRCODE_OUT := 1;

            ERRLINE_OUT := 'Unable to run manual batch.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN EX_MANBATCH_EXISTS
        THEN
            EXIT_CD_OUT := 2;

            ERRMSG_OUT := 'Manual batch already exists for selected Engine ID.';

            ERRCODE_OUT := 1;

            ERRLINE_OUT := 'Error = ManBatch already exists.V_STEP= ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_MBATCH_STINIT;

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
                                 , VALUES_OUT   OUT REF_GUI_ODD_JOB)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_ODD
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       FLT_STREAM_NAME_IN
                       FLT_JOB_NAME_IN
                       FLT_JOB_TYPE_IN
                       FLT_TABLE_NAME_IN
                       FLT_PHASE_IN
                       FLT_JOB_CATEGORY_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
                       VALUES_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-11-02
        -------------------------------------------------------------------------------
        Description:The purpose of this stored procedure is show all odd
                    jobs currently present in processing.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_ODD';
        -- local variables
        LC_CURSOR               REF_GUI_ODD_JOB;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STATUS_IN             VARCHAR(2048);

        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
        V_DURATION_PERCENT      CTRL_PARAMETERS.PARAM_VAL_INT%TYPE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100;
        V_DURATION_TOLERANCE    CTRL_PARAMETERS.PARAM_VAL_INT%TYPE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_TOLERANCE', 'param_val_int');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));

        --        V_STATUS_IN := STATUS_IN;

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
              SELECT   SJ.JOB_ID
                     , SJ.JOB_NAME
                     , SJ.STREAM_NAME
                     , SJ.ENGINE_ID
                     , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                     , SJ.LAST_UPDATE
                     , SJ.STATUS
                     , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                     , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                     , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                     , NVL(SJ.PHASE, 'N/A') PHASE
                     , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
                     , to_timestamp(to_char(to_char(SJ.LAST_UPDATE, 'SSSSS')+SJS.AVG_DURATION),'SSSSS') EXP_AVG_FINISH
                FROM           SESS_JOB SJ
                           JOIN
                               CTRL_JOB_STATUS CJS
                           ON SJ.STATUS = CJS.STATUS
                          AND CJS.RUNABLE = 'RUNNING'
                       JOIN
                           SESS_JOB_STATISTICS SJS
                       ON SJS.JOB_NAME = SJ.JOB_NAME
                      AND SJS.LOAD_DATE = SJ.LOAD_DATE
                      --AND SJS.AVG_DURATION * V_DURATION_PERCENT + V_DURATION_TOLERANCE > FLOOR(PCKG_TOOLS.F_SEC_BETWEEN(CURRENT_TIMESTAMP, LAST_UPDATE)) /*CURRENT_DURATION*/
                      AND (PCKG_TOOLS.F_SEC_BETWEEN(SJ.LAST_UPDATE, CURRENT_TIMESTAMP) - SJS.AVG_DURATION * (PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100))>0
               WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                   AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                   AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                   AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                   AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                   AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                   AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN
            --                   AND SJ.STATUS = V_STATUS_IN
            ORDER BY   SJ.JOB_NAME;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_JOBS_ODD;

    PROCEDURE SP_GUI_UPDT_CTRL_STREAM_DEL(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , STREAM_NAME_IN IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_STREAM_DEL
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_STREAM_DEL';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;

        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_STREAM_NAME_IN    VARCHAR2(256);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_STREAM_NAME_IN := STREAM_NAME_IN;


        DELETE FROM   CTRL_STREAM
              WHERE   (STREAM_NAME = V_STREAM_NAME_IN);

        --         PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
        --             USER_NAME_IN       => USER_IN
        --           , ACTION_IN          => NULL
        --           , JOB_NAME_IN        => NULL
        --           , UID_INDICATOR_IN   => 'D'
        --           , SQL_CODE_IN        => 'XXXDELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
        --           , V_ENGINE_ID_IN     => ENG_ID_IN
        --           , DEBUG_IN           => DEBUG_IN
        --           , EXIT_CD            => EXIT_CD_OUT
        --           , ERRMSG_OUT         => ERRMSG_OUT
        --           , ERRCODE_OUT        => ERRCODE_OUT
        --           , ERRLINE_OUT        => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_STREAM_DEL;

    PROCEDURE SP_GUI_UPDT_CTRL_JOB_DEL(ENG_ID_IN IN  INTEGER
                                     , USER_IN IN    VARCHAR2
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                     , JOB_NAME_IN IN VARCHAR2
                                     , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_JOB_DEL
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)






        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2011-10-10
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_JOB_DEL';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;

        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
        V_JOB_NAME_IN       VARCHAR2(256);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;
        V_JOB_NAME_IN := JOB_NAME_IN;


        DELETE FROM   CTRL_JOB
              WHERE   (JOB_NAME = V_JOB_NAME_IN);

        --         PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(
        --             USER_NAME_IN       => USER_IN
        --           , ACTION_IN          => NULL
        --           , JOB_NAME_IN        => NULL
        --           , UID_INDICATOR_IN   => 'D'
        --           , SQL_CODE_IN        => 'XXXDELETE FROM CTRL_JOB_DEPENDENCY WHERE JOB_NAME = ''' || JOB_NAME_IN || ''' AND PARENT_JOB_NAME = ''' || PARENT_JOB_NAME_IN || ''';'
        --           , V_ENGINE_ID_IN     => ENG_ID_IN
        --           , DEBUG_IN           => DEBUG_IN
        --           , EXIT_CD            => EXIT_CD_OUT
        --           , ERRMSG_OUT         => ERRMSG_OUT
        --           , ERRCODE_OUT        => ERRCODE_OUT
        --           , ERRLINE_OUT        => ERRLINE_OUT);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_JOB_DEL;

    PROCEDURE SP_GUI_UPDT_USER_MNGMT(USER_IN IN    VARCHAR2
                                   , LOGIN_IN IN   VARCHAR2
                                   , PASS_IN IN    VARCHAR2
                                   , ACCESS_ROLE_IN IN VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_USER_MNGMT
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_USER_MNGMT';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;

        V_COUNT          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;


        IF PASS_IN IS NOT NULL
        -- New User create entry
        THEN
            INSERT INTO GUI_AUTH(USR_ID
                               , USR_NAME
                               , USR_PASSWD
                               , USR_LEVEL)
              --VALUES(cast(dbms_random.value(100000,999999) as INTEGER), LOGIN_IN, PASS_IN, 1);
              VALUES   (0
                      , LOGIN_IN
                      , PASS_IN
                      , 1);

            INSERT INTO GUI_ACCESS_USER_GROUP_REF(USER_NAME, DOMAIN_GROUP)
              VALUES   (LOGIN_IN, ACCESS_ROLE_IN);
        -- Update existing user role
        ELSE
            UPDATE   GUI_ACCESS_USER_GROUP_REF
               SET   DOMAIN_GROUP = ACCESS_ROLE_IN
             WHERE   USER_NAME = LOGIN_IN;
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_USER_MNGMT;


    PROCEDURE SP_GUI_UPDT_USER_MNGMT_DEL(USER_IN IN    VARCHAR2
                                       , LOGIN_IN IN   VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_USER_MNGMT_DEL
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_USER_MNGMT_DEL';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;

        V_COUNT          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;


        DELETE FROM   GUI_AUTH
              WHERE   USR_NAME = LOGIN_IN;

        DELETE FROM   GUI_ACCESS_USER_GROUP_REF
              WHERE   USER_NAME = LOGIN_IN;



        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_USER_MNGMT_DEL;



    PROCEDURE SP_GUI_VIEW_USER_MNGMT(USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , VALUES_OUT   OUT REF_GUI_USERS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_USER_MNGMT
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_USER_MNGMT';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR        REF_GUI_USERS;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;

        V_COUNT          INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;



        OPEN LC_CURSOR FOR
              SELECT   USR_NAME, AR.DOMAIN_GROUP ACCESS_ROLE
                FROM       GUI_AUTH SJ
                       JOIN
                           GUI_ACCESS_USER_GROUP_REF AR
                       ON SJ.USR_NAME = AR.USER_NAME
            ORDER BY   SJ.USR_NAME;

        VALUES_OUT := LC_CURSOR;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_USER_MNGMT;



    PROCEDURE SP_GUI_UPDT_USER_MNGMT_PASS(USER_IN IN    VARCHAR2
                                        , LOGIN_IN IN   VARCHAR2
                                        , PASS_IN IN    VARCHAR2
                                        , OLD_PASS_IN IN VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_USER_MNGMT_PASS
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-08-30
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_USER_MNGMT_PASS';
        C_PROC_VERSION   CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;

        V_COUNT          INTEGER := 0;
        -- exceptions
        E_WRONG_OLD_PASS EXCEPTION;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        SELECT   COUNT( * )
          INTO   V_COUNT
          FROM   GUI_AUTH
         WHERE   USR_PASSWD = OLD_PASS_IN;

        IF V_COUNT = 1
        THEN
            UPDATE   GUI_AUTH
               SET   USR_PASSWD = PASS_IN
             WHERE   USR_PASSWD = OLD_PASS_IN;
        ELSE
            RAISE E_WRONG_OLD_PASS;
        END IF;

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'Password changed.');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN E_WRONG_OLD_PASS
        THEN
            EXIT_CD_OUT := 1;
            ERRMSG_OUT := 'Wrong old password!';
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'User defined exception, step ' || V_STEP;
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_USER_MNGMT_PASS;

PROCEDURE SP_GUI_VIEW_CTRL_SCHED_NUM_JOB(ENG_ID_IN IN  INTEGER
                                       , USER_IN IN    VARCHAR2
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                       , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_CTRL_SCHED_NUM_JOB
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_CTRL_SCHED_NUM_JOB';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              --SELECT   DISTINCT A.PARAM_CD AS LKP_VAL_DESC
              select rownum-1 as LKP_VAL_DESC
              from all_objects
              where rownum <= (select param_val_int from CTRL_PARAMETERS where PARAM_NAME = 'MAX_CONCURRENT_JOBS_SET' ) + 1
              ORDER BY LKP_VAL_DESC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_CTRL_SCHED_NUM_JOB;

    PROCEDURE SP_GUI_VIEW_LKP_COUNTRY_CD(ENG_ID_IN IN  INTEGER
                                         , USER_IN IN    VARCHAR2
                                         , DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                         , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_COUNTRY_CD
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2011-11-13
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_COUNTRY_CD';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   NULL AS LKP_VAL_DESC FROM DUAL
              UNION ALL
              SELECT * FROM
              (SELECT   A.COUNTRY_CD AS LKP_VAL_DESC
              FROM   LKP_COUNTRY A ORDER BY   LKP_VAL_DESC ASC);

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_COUNTRY_CD;

    PROCEDURE SP_GUI_VIEW_LKP_RUNPLAN(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_PHASE
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_RUNPLAN';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   DISTINCT A.RUNPLAN AS LKP_VAL_DESC
                FROM   LKP_PLAN A
            ORDER BY   RUNPLAN ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_RUNPLAN;

    PROCEDURE SP_GUI_VIEW_LKP_RUNPLAN_DESC(ENG_ID_IN IN  INTEGER
                                  , USER_IN IN    VARCHAR2
                                  , DEBUG_IN IN   INTEGER:= 0
                                  , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                  , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                  , ERRCODE_OUT   OUT NOCOPY NUMBER
                                  , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                  , VALUES_OUT   OUT REF_LKP_VAL)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_LKP_PHASE
        IN parameters:
        OUT parameters:
        exit_cd - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Michal Marusan
        Date:    2011-10-25
        -------------------------------------------------------------------------------
        Description: Returns
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_LKP_RUNPLAN_DESC';
        -- local variables
        LC_CURSOR        REF_LKP_VAL;
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        OPEN LC_CURSOR FOR
              SELECT   (A.RUNPLAN || ' - ' || A.DESCRIPTION) AS LKP_VAL_DESC
                FROM   LKP_PLAN A
            ORDER BY   RUNPLAN ASC;

        VALUES_OUT := LC_CURSOR;
        --last steps in procedure
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_VIEW_LKP_RUNPLAN_DESC;

    PROCEDURE SP_GUI_UPDT_CTRL_STREAM_PL_REF(ENG_ID_IN IN  INTEGER
                                        , USER_IN IN    VARCHAR2
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                        , ROW_ID IN VARCHAR2
                                        , STREAM_NAME IN VARCHAR2
                                        , RUNPLAN  IN VARCHAR2
                                        , COUNTRY_CD IN VARCHAR2
                                        , LABEL_NAME_IN IN VARCHAR2)
    IS
        /***************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_UPDT_CTRL_STREAM_PL_REF
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       ROW_ID
                       STREAM_NAME
                       RUNPLAN
                       COUNTRY_CD
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GUI_SET_CHANGE_CONTROL
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2013-11-22
        -------------------------------------------------------------------------------
        Description: The purpose of this stored procedure is update information in CTRL_STREAM_PLAN_REF table.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_UPDT_CTRL_STREAM_PL_REF';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        RUNABLE_IN          VARCHAR2(20);
        V_ROWID       		ROWID := ROW_ID;
        V_STREAM_NAME       CTRL_STREAM_PLAN_REF.STREAM_NAME%TYPE := STREAM_NAME;
        V_RUNPLAN       CTRL_STREAM_PLAN_REF.RUNPLAN%TYPE := RUNPLAN;
        V_COUNTRY_CD       CTRL_STREAM_PLAN_REF.COUNTRY_CD%TYPE := COUNTRY_CD;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_STREAM_PLAN_REF SJ
             USING   DUAL
                ON   (SJ.ROWID = V_ROWID)
        WHEN MATCHED
        THEN
            UPDATE SET SJ.RUNPLAN = REPLACE(V_RUNPLAN, 'NULL', NULL), SJ.COUNTRY_CD = REPLACE(V_COUNTRY_CD, 'NULL', NULL)
        WHEN NOT MATCHED
        THEN
            INSERT              (SJ.STREAM_NAME, SJ.RUNPLAN, SJ.COUNTRY_CD)
                VALUES   (REPLACE(V_STREAM_NAME, 'NULL', NULL), REPLACE(V_RUNPLAN, 'NULL', NULL), REPLACE(V_COUNTRY_CD, 'NULL', NULL));

        SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => V_STREAM_NAME
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO   CTRL_STREAM_PLAN_REF SJ USING DUAL ON   (SJ.ROWID = REPLACE('''
                                 || V_ROWID
                                 || ''', ''NULL'', NULL)) WHEN MATCHED THEN UPDATE SET SJ.RUNPLAN = REPLACE('''
                                 || V_RUNPLAN
                                 || ''', ''NULL'', NULL), SJ.COUNTRY_CD = REPLACE('''
                                 || V_COUNTRY_CD
                                 || ''', ''NULL'', NULL) WHEN NOT MATCHED THEN INSERT (STREAM_NAME, RUNPLAN, COUNTRY_CD) VALUES (REPLACE('''
                                 || V_STREAM_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || V_RUNPLAN
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || V_COUNTRY_CD
                                 || ''', ''NULL'', NULL));'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_UPDT_CTRL_STREAM_PL_REF;

    PROCEDURE SP_GUI_DEL_CTRL_STREAM_PL_REF(ENG_ID_IN IN  INTEGER
                                   , USER_IN IN    VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD_OUT   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2
                                   , STREAM_NAME IN VARCHAR2
                                   , ROW_ID IN VARCHAR2
                                   , LABEL_NAME_IN IN VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_DEL_CTRL_STREAM_PL_REF
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       ROW_ID
                       STREAM_NAME
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2011-11-22
        -------------------------------------------------------------------------------
        Description: The purpose of this stored procedure is deletion of
                    RUNPLAN for stream from table CTRL_STREAM_PLAN_REF.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_DEL_CTRL_STREAM_PL_REF';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        V_RUNABLE           CTRL_JOB_STATUS.RUNABLE%TYPE;
        RUNABLE_IN          VARCHAR2(20);
        V_ROWID				      ROWID:=ROW_ID;
        V_STREAM_NAME       CTRL_STREAM_PLAN_REF.STREAM_NAME%TYPE:=STREAM_NAME;
        V_SELECTED_ENG_ID   SESS_JOB.ENGINE_ID%TYPE:=ENG_ID_IN;
        RETURN_STATUS_OUT   VARCHAR2(256) := 'N/A';
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        -- Procedure body

        DELETE FROM CTRL_STREAM_PLAN_REF WHERE ROWID = V_ROWID;


        PCKG_GUI.SP_GUI_SET_CHANGE_CONTROL(USER_NAME_IN       => USER_IN
                                         , ACTION_IN          => RUNABLE_IN
                                         , JOB_NAME_IN        => V_STREAM_NAME
                                         , UID_INDICATOR_IN   => 'D'
                                         , SQL_CODE_IN        => 'DELETE FROM CTRL_STREAM_PLAN_REF  WHERE ROWID = REPLACE('''
                                                                  || V_ROWID || ''', ''NULL'', NULL) ;'
                                         , V_ENGINE_ID_IN     => ENG_ID_IN
                                         , DEBUG_IN           => DEBUG_IN
                                         , EXIT_CD            => EXIT_CD_OUT
                                         , ERRMSG_OUT         => ERRMSG_OUT
                                         , ERRCODE_OUT        => ERRCODE_OUT
                                         , ERRLINE_OUT        => ERRLINE_OUT
                                         , LABEL_NAME_IN      => LABEL_NAME_IN);

        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_DEL_CTRL_STREAM_PL_REF;

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
                                        , LABEL_NAME_IN IN VARCHAR2)
    IS
        /***************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_INS_CTRL_STREAM_PL_REF
        IN parameters: ENG_ID_IN
                       USER_IN
                       DEBUG_IN
                       STREAM_NAME
                       RUNPLAN
                       COUNTRY_CD
                       LABEL_NAME_IN
        OUT parameters:EXIT_CD_OUT
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   SP_GUI_SET_CHANGE_CONTROL
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2013-11-22
        -------------------------------------------------------------------------------
        Description: The purpose of this stored procedure is update information in CTRL_STREAM_PLAN_REF table.
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'SP_GUI_INS_CTRL_STREAM_PL_REF';
        C_PROC_VERSION      CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        RUNABLE_IN          VARCHAR2(20);
        V_STREAM_NAME       CTRL_STREAM_PLAN_REF.STREAM_NAME%TYPE := STREAM_NAME;
        V_RUNPLAN       CTRL_STREAM_PLAN_REF.RUNPLAN%TYPE := RUNPLAN;
        V_COUNTRY_CD       CTRL_STREAM_PLAN_REF.COUNTRY_CD%TYPE := COUNTRY_CD;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD_OUT := 0;

        MERGE INTO   CTRL_STREAM_PLAN_REF SJ
             USING   DUAL
                ON   (REPLACE(V_STREAM_NAME, 'NULL', NULL)=SJ.STREAM_NAME AND SJ.COUNTRY_CD = REPLACE(V_COUNTRY_CD, 'NULL', NULL) AND SJ.RUNPLAN = REPLACE(V_RUNPLAN, 'NULL', NULL))
        WHEN NOT MATCHED
        THEN
            INSERT              (SJ.STREAM_NAME, SJ.RUNPLAN, SJ.COUNTRY_CD)
                VALUES   (REPLACE(V_STREAM_NAME, 'NULL', NULL), REPLACE(V_RUNPLAN, 'NULL', NULL), REPLACE(V_COUNTRY_CD, 'NULL', NULL));

        SP_GUI_SET_CHANGE_CONTROL(
            USER_NAME_IN       => USER_IN
          , ACTION_IN          => RUNABLE_IN
          , JOB_NAME_IN        => V_STREAM_NAME
          , UID_INDICATOR_IN   => 'M'
          , SQL_CODE_IN        =>   'MERGE INTO   CTRL_STREAM_PLAN_REF SJ USING DUAL ON   (SJ.STREAM_NAME = REPLACE('''
                                 || V_STREAM_NAME
                                 || ''', ''NULL'', NULL) AND SJ.COUNTRY_CD = REPLACE('''
                                 || V_COUNTRY_CD
                                 || ''', ''NULL'', NULL) AND SJ.RUNPLAN = REPLACE('''
                                 || V_RUNPLAN
                                 || ''', ''NULL'', NULL)) WHEN  NOT MATCHED THEN INSERT INTO  (SJ.STREAM_NAME, SJ.RUNPLAN, SJ.COUNTRY_CD) VALUES (REPLACE('''
                                 || V_STREAM_NAME
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || V_RUNPLAN
                                 || ''', ''NULL'', NULL), REPLACE('''
                                 || V_COUNTRY_CD
                                 || ''', ''NULL'', NULL));'
          , V_ENGINE_ID_IN     => ENG_ID_IN
          , DEBUG_IN           => DEBUG_IN
          , EXIT_CD            => EXIT_CD_OUT
          , ERRMSG_OUT         => ERRMSG_OUT
          , ERRCODE_OUT        => ERRCODE_OUT
          , ERRLINE_OUT        => ERRLINE_OUT
          , LABEL_NAME_IN      => LABEL_NAME_IN);
        --last steps in procedure
        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.DEBUG();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD_OUT := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRLINE_OUT;

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);
    END SP_GUI_INS_CTRL_STREAM_PL_REF;

    PROCEDURE SP_GUI_VIEW_JOBS_EXECUTABLE (ENG_ID_IN IN  INTEGER
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
                                          , VALUES_OUT   OUT REF_JOBS_DETAILS)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_GUI_VIEW_JOBS_EXECUTABLE
        IN parameters:
        OUT parameters:
        EXIT_CD_OUT - procedure exit code (0 - OK)
        Called from: GUI
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2014-03-17
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_GUI_VIEW_JOBS_EXECUTABLE';
        C_PROC_VERSION          CONSTANT VARCHAR2(16) := '1.0';
        -- local variables
        LC_CURSOR               REF_JOBS_DETAILS;

        V_ENG_ID_IN             CTRL_PARAMETERS.PARAM_CD%TYPE;
        V_FLT_STREAM_NAME_IN    CTRL_STREAM.STREAM_NAME%TYPE;
        V_FLT_JOB_NAME_IN       CTRL_JOB.JOB_NAME%TYPE;
        V_FLT_JOB_TYPE_IN       CTRL_JOB.JOB_TYPE%TYPE;
        V_FLT_TABLE_NAME_IN     CTRL_JOB.TABLE_NAME%TYPE;
        V_FLT_PHASE_IN          CTRL_JOB.PHASE%TYPE;
        V_FLT_JOB_CATEGORY_IN   CTRL_JOB.JOB_CATEGORY%TYPE;

        V_STEP                  VARCHAR2(1024);
    BEGIN
        EXIT_CD_OUT := 0;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');
        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD_OUT));
        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        V_ENG_ID_IN := NVL(ENG_ID_IN, 0);
        V_FLT_STREAM_NAME_IN := UPPER(NVL(TRIM(FLT_STREAM_NAME_IN), ''));
        V_FLT_JOB_NAME_IN := UPPER(NVL(TRIM(FLT_JOB_NAME_IN), ''));
        V_FLT_JOB_TYPE_IN := UPPER(NVL(TRIM(FLT_JOB_TYPE_IN), ''));
        V_FLT_JOB_CATEGORY_IN := UPPER(NVL(TRIM(FLT_JOB_CATEGORY_IN), ''));
        V_FLT_TABLE_NAME_IN := UPPER(NVL(TRIM(FLT_TABLE_NAME_IN), ''));
        V_FLT_PHASE_IN := UPPER(NVL(TRIM(FLT_PHASE_IN), ''));

        V_STEP := '10 - GET VALUES';

        OPEN LC_CURSOR FOR
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , SJ.ENGINE_ID
                   , SJ.N_RUN || '/' || SJ.MAX_RUNS N_RUN
                   , SJ.LAST_UPDATE
                   , SJ.STATUS
                   , NVL(SJ.TABLE_NAME, 'N/A') TABLE_NAME
                   , NVL(SJ.JOB_CATEGORY, 'N/A') JOB_CATEGORY
                   , NVL(SJ.JOB_TYPE, 'N/A') JOB_TYPE
                   , NVL(SJ.PHASE, 'N/A') PHASE
                   , NVL(SJ.SYSTEM_NAME, 'N/A') SYSTEM_NAME
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                                      AND (CJS.EXECUTABLE = 1)
                    AND FINISHED = 0
                    AND RUNABLE NOT IN ('RUNNING','FAILED')
             WHERE   SJ.ENGINE_ID = V_ENG_ID_IN
                 AND UPPER(NVL(SJ.STREAM_NAME, 'NA')) LIKE V_FLT_STREAM_NAME_IN
                 AND UPPER(NVL(SJ.JOB_NAME, 'NA')) LIKE V_FLT_JOB_NAME_IN
                 AND UPPER(NVL(SJ.JOB_TYPE, 'NA')) LIKE V_FLT_JOB_TYPE_IN
                 AND UPPER(NVL(SJ.JOB_CATEGORY, 'NA')) LIKE V_FLT_JOB_CATEGORY_IN
                 AND UPPER(NVL(SJ.PHASE, 'NA')) LIKE V_FLT_PHASE_IN
                 AND UPPER(NVL(SJ.TABLE_NAME, 'NA')) LIKE V_FLT_TABLE_NAME_IN;

        VALUES_OUT := LC_CURSOR;

        IF DEBUG_IN = 1
        THEN
            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            EXIT_CD_OUT := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
        WHEN OTHERS
        THEN
            EXIT_CD_OUT := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

            INSERT INTO PROC_LOG(PROCESS_NM
                               , VERSION_NUM
                               , PROCESS_TS
                               , RUN_NUM
                               , START_DT
                               , END_DT
                               , STAT_CD
                               , DESCRIPTION
                               , PROCESS_STEP
                               , SEQ_NUM)
              VALUES   (C_PROC_NAME
                      , C_PROC_VERSION
                      , SYSDATE
                      , NULL
                      , NULL
                      , NULL
                      , EXIT_CD_OUT
                      , ERRMSG_OUT
                      , V_STEP
                      , PROC_LOG_SEQ.NEXTVAL);

            COMMIT;
    END SP_GUI_VIEW_JOBS_EXECUTABLE;

END PCKG_GUI;

