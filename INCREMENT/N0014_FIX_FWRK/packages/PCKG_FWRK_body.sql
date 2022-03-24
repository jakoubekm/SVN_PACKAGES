
  CREATE OR REPLACE PACKAGE BODY "PDC"."PCKG_FWRK"
IS
    PROCEDURE SP_FWRK_CHECK_WD_STATUS(DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_CHECK_WD_STATUS
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-27
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR GET_ENGINE_ID
        IS
			SELECT   SJ.ENGINE_ID,CTRLPARAM.PARAM_VAL_CHAR AS SYSTEM_NAME
                FROM   SESS_JOB SJ
                INNER JOIN CTRL_PARAMETERS CTRLPARAM
                 ON   (CTRLPARAM.PARAM_NAME = 'ENGINE_STATUS'
                     AND CTRLPARAM.PARAM_CD = SJ.ENGINE_ID)
			GROUP BY ENGINE_ID,CTRLPARAM.PARAM_VAL_CHAR;

        --constants
        C_PROC_NAME              CONSTANT VARCHAR2(64) := 'SP_FWRK_CHECK_WD_STATUS';
        --exceptions
        EX_RUN_TIME_IN_LIMIT EXCEPTION;
        EX_RUN_TIME_OUT_OF_LIMIT EXCEPTION;
        -- local variables
        V_STEP                   VARCHAR2(1024);
        V_ALL_DBG_INFO           PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID            INTEGER := 0;
        V_ENG_RUN_TIME           INTEGER := 0;
        V_ENG_RUN_TIME_DIFF      INTEGER := 0;
        V_DWH_DATE               DATE;
        V_LOAD_DATE               DATE;
        V_CNT_NOTFINISHED_JOBS   INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        V_STEP := 'Run cursor get_engine_id';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        FOR R1 IN GET_ENGINE_ID
        LOOP
            EXIT WHEN GET_ENGINE_ID%NOTFOUND;
            V_STEP := 'Running get_engine_id';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   COUNT( * )
              INTO   V_CNT_NOTFINISHED_JOBS
              FROM   SESS_JOB SJ
             WHERE   PCKG_FWRK.F_GET_STATUS_FINISHED(SJ.STATUS) = 0
                 AND SJ.ENGINE_ID = R1.ENGINE_ID;

            IF V_CNT_NOTFINISHED_JOBS > 0
            THEN
                V_STEP := 'get_engine_id cur cnt_notfinished_jobs > 0 -> engine status';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                SELECT   PCKG_TOOLS.F_SEC_BETWEEN(PARAM_VAL_TS, CURRENT_TIMESTAMP) ENG_RUN_TIME
                  INTO   V_ENG_RUN_TIME
                  FROM   CTRL_PARAMETERS CTRLPARAM
                 WHERE   CTRLPARAM.PARAM_NAME = 'ENGINE_STATUS'
                     AND CTRLPARAM.PARAM_CD = R1.ENGINE_ID
					 AND CTRLPARAM.PARAM_VAL_CHAR= R1.SYSTEM_NAME;

                V_STEP := 'get_engine_id cur cnt_notfinished_jobs > 0 -> watchdog interval';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                SELECT   V_ENG_RUN_TIME - CTRLPARAMS.PARAM_VAL_INT
                  INTO   V_ENG_RUN_TIME_DIFF
                  FROM   CTRL_PARAMETERS CTRLPARAMS
                 WHERE   CTRLPARAMS.PARAM_NAME = 'WATCHDOG_INTERVAL_FWRK';

                IF V_ENG_RUN_TIME_DIFF > 0
                THEN

                    V_STEP := 'GET DATES';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    V_LOAD_DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date', R1.ENGINE_ID), 'DD.MM.YYYY');
                    V_DWH_DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R1.ENGINE_ID), 'DD.MM.YYYY');

                    V_STEP := 'get_engine_id cur cnt_notfinished_jobs > 0 -> engine runtime diff > 0 -> save_stat_log_event_hist';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(EVENT_TS_IN                 => CURRENT_TIMESTAMP
                                                        , NOTIFICATION_CD_IN          => 1
                                                        , LOAD_DATE_IN                => V_LOAD_DATE
                                                        , JOB_NAME_IN                 => 'ENGINE ID=' || R1.ENGINE_ID
                                                        , JOB_ID_IN                   => -3
                                                        , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('ENGINE_OFF'),8)
                                                        , ERROR_CD_IN                 => 'ENGINE_OFF'
                                                        , EVENT_CD_IN                 => NULL
                                                        , EVENT_DS_IN                 => NULL
                                                        , START_TS_IN                 => NULL
                                                        , END_TS_IN                   => NULL
                                                        , TRACKING_DURATION_IN        => NULL
                                                        , LAST_STATUS_IN              => NULL
                                                        , N_RUN_IN                    => NULL
                                                        , CHECKED_STATUS_IN           => NULL
                                                        , MAX_N_RUN_IN                => NULL
                                                        , AVG_DURARION_TOLERANCE_IN   => NULL
                                                        , AVG_END_TM_TOLERANCE_IN     => NULL
                                                        , ACTUAL_VALUE_IN             => NULL
                                                        , THRESHOLD_IN                => NULL
                                                        , OBJECT_NAME_IN              => NULL
                                                        , NOTE_IN                     => 'ENGINE ID=' || R1.ENGINE_ID || ' stopped ' || ' Generated on ' || CURRENT_TIMESTAMP
                                                        , SENT_TS_IN                  => NULL
                                                        , DWH_DATE_IN                 => V_DWH_DATE
                                                        , ENGINE_ID_IN                => R1.ENGINE_ID
														, RECOMMENDATION_DS_IN        => NULL
														, SYSTEM_NAME_IN			  => R1.SYSTEM_NAME
														, DEBUG_IN                    => DEBUG_IN
                                                        , EXIT_CD                     => EXIT_CD
                                                        , ERRMSG_OUT                  => ERRMSG_OUT
                                                        , ERRCODE_OUT                 => ERRCODE_OUT
                                                        , ERRLINE_OUT                 => ERRLINE_OUT);
                END IF;
            END IF;
        END LOOP;

        EXIT_CD := 0;
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
    END SP_FWRK_CHECK_WD_STATUS;

    PROCEDURE SP_FWRK_CHECK_SCHED_STATUS(DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_CHECK_SCHED_STATUS
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR GET_ENGINE_ID
        IS
              SELECT   SJ.ENGINE_ID
                FROM   SESS_JOB SJ
            GROUP BY   SJ.ENGINE_ID;

        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_FWRK_CHECK_SCHED_STATUS';
        -- local variables
        V_STEP                  VARCHAR2(1024);
        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
        V_MAX_CONCURRENT_JOBS   INTEGER := 0;
        V_DWH_DATE              DATE;
        V_LOAD_DATE             DATE;
        V_CNT_RUNNING_JOBS      PLS_INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'get_engine_id cur run';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        FOR R1 IN GET_ENGINE_ID
        LOOP
            EXIT WHEN GET_ENGINE_ID%NOTFOUND;
            V_STEP := 'get_engine_id cur max_concur_jobs';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   PARAM_VAL_INT
              INTO   V_MAX_CONCURRENT_JOBS
              FROM   CTRL_PARAMETERS CTRLPARAM
             WHERE   CTRLPARAM.PARAM_NAME = 'MAX_CONCURRENT_JOBS'
                 AND CTRLPARAM.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur cntrunning jobs';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   COUNT( * )
              INTO   V_CNT_RUNNING_JOBS
              FROM   SESS_JOB SJ
             WHERE   PCKG_FWRK.F_GET_STATUS_FINISHED(SJ.STATUS) = 0
                 AND SJ.ENGINE_ID = R1.ENGINE_ID;

            IF V_MAX_CONCURRENT_JOBS = 0
           AND V_CNT_RUNNING_JOBS > 0
            THEN

                V_STEP := 'GET DATES';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_LOAD_DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date', R1.ENGINE_ID), 'DD.MM.YYYY');
                V_DWH_DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R1.ENGINE_ID), 'DD.MM.YYYY');

                V_STEP := 'get_engine_id cur max_concur_jobs = 0 and cnt_running jobs > 0';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                    EVENT_TS_IN                 => CURRENT_TIMESTAMP
                  , NOTIFICATION_CD_IN          => 1
                  , LOAD_DATE_IN                => V_LOAD_DATE
                  , JOB_NAME_IN                 => 'SCHEDULER engine id = ' || R1.ENGINE_ID
                  , JOB_ID_IN                   => -2
                  , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('SCHEDULER_OFF'),8)
                  , ERROR_CD_IN                 => 'SCHEDULER_OFF'
                  , EVENT_CD_IN                 => NULL
                  , EVENT_DS_IN                 => NULL
                  , START_TS_IN                 => NULL
                  , END_TS_IN                   => NULL
                  , TRACKING_DURATION_IN        => NULL
                  , LAST_STATUS_IN              => NULL
                  , N_RUN_IN                    => NULL
                  , CHECKED_STATUS_IN           => NULL
                  , MAX_N_RUN_IN                => NULL
                  , AVG_DURARION_TOLERANCE_IN   => NULL
                  , AVG_END_TM_TOLERANCE_IN     => NULL
                  , ACTUAL_VALUE_IN             => NULL
                  , THRESHOLD_IN                => NULL
                  , OBJECT_NAME_IN              => NULL
                  , NOTE_IN                     => 'SCHEDULER engine id = ' || R1.ENGINE_ID || ' is off. ' || ' Generated on ' || CURRENT_TIMESTAMP
                  , SENT_TS_IN                  => NULL
                  , DWH_DATE_IN                 => V_DWH_DATE
                  , ENGINE_ID_IN                => R1.ENGINE_ID
                  , RECOMMENDATION_DS_IN        => NULL
				  , SYSTEM_NAME_IN				=> NULL
                  , DEBUG_IN                    => DEBUG_IN
                  , EXIT_CD                     => EXIT_CD
                  , ERRMSG_OUT                  => ERRMSG_OUT
                  , ERRCODE_OUT                 => ERRCODE_OUT
                  , ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END LOOP;

        EXIT_CD := 0;
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
    END SP_FWRK_CHECK_SCHED_STATUS;

    PROCEDURE SP_FWRK_CHECK_SNIFER(DEBUG_IN IN   INTEGER:= 0
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_CHECK_SNIFER
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR GET_NEW_REVOKED_PROC
        IS
            SELECT   SRP.TABLE_NAME
                   , SRP.SCHEMA_NAME
                   , SRP.COMMON_TABLE_NAME
                   , SRP.TABLE_TYPE
                   , SRP.SOURCE_NM
                   , SRP.EFF_LOAD_DATE
                   , SRP.LOAD_DATE
                   , SRP.INSERTED_TS
                   , SRP.OPERATED_TS
                   , SRP.REASON
              FROM   STAT_SRCTABLE_REVOKED_PROCESS SRP
             WHERE   SRP.OPERATED_TS IS NULL;

        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_FWRK_CHECK_SNIFER';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        V_DWH_DATE       DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        FOR R1 IN GET_NEW_REVOKED_PROC
        LOOP
            EXIT WHEN GET_NEW_REVOKED_PROC%NOTFOUND;
            V_STEP := 'get_new_revoked_proc cur';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'get_new_revoked_proc cur -> update stat_srctable_revoked_process';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   STAT_SRCTABLE_REVOKED_PROCESS
               SET   OPERATED_TS = CURRENT_TIMESTAMP
             WHERE   TABLE_NAME = R1.TABLE_NAME
                 AND SCHEMA_NAME = R1.SCHEMA_NAME
                 AND COMMON_TABLE_NAME = R1.COMMON_TABLE_NAME
                 AND TABLE_TYPE = R1.TABLE_TYPE
                 AND SOURCE_NM = R1.SOURCE_NM
                 AND EFF_LOAD_DATE = R1.EFF_LOAD_DATE
                 AND LOAD_DATE = R1.LOAD_DATE
                 AND INSERTED_TS = R1.INSERTED_TS
                 AND OPERATED_TS IS NULL;

            V_STEP := 'get_new_revoked_proc cur -> save_stat_log_event_hist';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                EVENT_TS_IN                 => CURRENT_TIMESTAMP
              , NOTIFICATION_CD_IN          => 1
              , LOAD_DATE_IN                => V_DWH_DATE
              , JOB_NAME_IN                 => 'REVOKED_PROCESS_BY_SNIFFER'
              , JOB_ID_IN                   => -1
              , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('REVOKED_PROCESS'),2)
              , ERROR_CD_IN                 => 'REVOKED_PROCESS'
              , EVENT_CD_IN                 => NULL
              , EVENT_DS_IN                 => NULL
              , START_TS_IN                 => NULL
              , END_TS_IN                   => NULL
              , TRACKING_DURATION_IN        => NULL
              , LAST_STATUS_IN              => NULL
              , N_RUN_IN                    => NULL
              , CHECKED_STATUS_IN           => NULL
              , MAX_N_RUN_IN                => NULL
              , AVG_DURARION_TOLERANCE_IN   => NULL
              , AVG_END_TM_TOLERANCE_IN     => NULL
              , ACTUAL_VALUE_IN             => NULL
              , THRESHOLD_IN                => NULL
              , OBJECT_NAME_IN              => NULL
              , NOTE_IN                     =>   'Processing of schema name '
                                              || R1.SCHEMA_NAME
                                              || ' table name '
                                              || R1.TABLE_NAME
                                              || ' has been revoked. Reason of revoke is '
                                              || R1.REASON
                                              || ' Generated on '
                                              || CURRENT_TIMESTAMP
              , SENT_TS_IN                  => NULL
              , DWH_DATE_IN                 => V_DWH_DATE
              , ENGINE_ID_IN                => NULL
              , DEBUG_IN                    => DEBUG_IN
              , RECOMMENDATION_DS_IN        => NULL
			  , SYSTEM_NAME_IN				=> NULL
              , EXIT_CD                     => EXIT_CD
              , ERRMSG_OUT                  => ERRMSG_OUT
              , ERRCODE_OUT                 => ERRCODE_OUT
              , ERRLINE_OUT                 => ERRLINE_OUT);
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
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
    END SP_FWRK_CHECK_SNIFER;

    PROCEDURE SP_FWRK_CHECK_INITIALIZATION(DEBUG_IN IN   INTEGER:= 0
                                         , EXIT_CD   OUT NOCOPY NUMBER
                                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_CHECK_INITIALIZATION
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR GET_ENGINE_ID
        IS
              SELECT   SJ.ENGINE_ID
                FROM   SESS_JOB SJ
            GROUP BY   SJ.ENGINE_ID;

        --constants
        C_PROC_NAME               CONSTANT VARCHAR2(64) := 'SP_FWRK_CHECK_INITIALIZATION';
        --exception
        EX_UNACCEPTABLE_RUNNING_TIME EXCEPTION;
        -- local variables
        V_STEP                    VARCHAR2(1024);
        V_ALL_DBG_INFO            PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID             INTEGER := 0;
        V_LOAD_DATE               DATE;
        V_DWH_DATE                DATE;
        V_INIT_HOUR               VARCHAR2(8);
        V_INIT_HOUR2              VARCHAR2(8);
        V_INIT_DELAY_DAYS         VARCHAR2(19);
        V_INIT_RETENTION_PERIOD   VARCHAR2(19);
        V_INIT_BASIC_START_TIME   VARCHAR2(19);
        V_INIT_MODIF_START_TIME   VARCHAR2(19);
        V_NOW                     VARCHAR2(19) := TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MI:SS');
        V_DIFF                    VARCHAR2(256);
        V_INIT_IS_RUNNING         INTEGER;
        V_INIT_BEGIN              TIMESTAMP;
        V_INIT_DURATION_MINUTES   INTEGER;
        V_EXCEPTION_REASON        VARCHAR2(1024);
        V_INIT_BEGIN_DIFF         INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;

        FOR R1 IN GET_ENGINE_ID
        LOOP
            EXIT WHEN GET_ENGINE_ID%NOTFOUND;


            SELECT   CTRLPAR2.PARAM_VAL_INT
              INTO   V_INIT_HOUR2
              --LOAD_DATE + INITIALIZATION_DELAY_DAYS*24 + INITIALIZATION_RETENTION_PERIOD*24 + INITIALIZATION_HOUR
              FROM   CTRL_PARAMETERS CTRLPAR2
             WHERE   CTRLPAR2.PARAM_NAME = 'INITIALIZATION_HOUR'
                 AND CTRLPAR2.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'get_engine_id cur -> select load_date';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR1.PARAM_VAL_DATE
              INTO   V_LOAD_DATE
              FROM   CTRL_PARAMETERS CTRLPAR1
             WHERE   CTRLPAR1.PARAM_NAME = 'LOAD_DATE'
                 AND CTRLPAR1.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select dwh_date';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR1.PARAM_VAL_DATE
              INTO   V_DWH_DATE
              FROM   CTRL_PARAMETERS CTRLPAR1
             WHERE   CTRLPAR1.PARAM_NAME = 'PREV_LOAD_DATE'
                 AND CTRLPAR1.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select init_hour';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'get_engine_id cur -> select init_delay_days';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR3.PARAM_VAL_INT
              INTO   V_INIT_DELAY_DAYS
              FROM   CTRL_PARAMETERS CTRLPAR3
             WHERE   CTRLPAR3.PARAM_NAME = 'INITIALIZATION_DELAY_DAYS'
                 AND CTRLPAR3.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select init retention period';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR4.PARAM_VAL_INT
              INTO   V_INIT_RETENTION_PERIOD
              FROM   CTRL_PARAMETERS CTRLPAR4
             WHERE   CTRLPAR4.PARAM_NAME = 'INITIALIZATION_RETENTION_PERIOD'
                 AND CTRLPAR4.PARAM_CD = R1.ENGINE_ID;

            IF V_INIT_HOUR2 >= 0
            THEN
                SELECT   TO_CHAR(TO_DATE(CTRLPAR2.PARAM_VAL_INT, 'HH24:MI:SS'), 'HH24:MI:SS')
                  INTO   V_INIT_HOUR
                  --LOAD_DATE + INITIALIZATION_DELAY_DAYS*24 + INITIALIZATION_RETENTION_PERIOD*24 + INITIALIZATION_HOUR
                  FROM   CTRL_PARAMETERS CTRLPAR2
                 WHERE   CTRLPAR2.PARAM_NAME = 'INITIALIZATION_HOUR'
                     AND CTRLPAR2.PARAM_CD = R1.ENGINE_ID;

                V_STEP := 'get_engine_id cur -> select basic start time';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                --V_INIT_BASIC_START_TIME := TO_CHAR(TO_DATE(V_LOAD_DATE  || ' ' || V_INIT_HOUR, 'DD.MM.YYYY HH24:MI:SS'), 'DD.MM.YYYY HH24:MI:SS');
                V_INIT_BASIC_START_TIME := TO_CHAR(V_LOAD_DATE, 'DD.MM.YYYY') || ' ' || V_INIT_HOUR;
            ELSE
                --V_INIT_BASIC_START_TIME := TO_CHAR(TO_DATE(V_NOW, 'DD.MM.YYYY HH24:MI:SS'), 'DD.MM.YYYY HH24:MI:SS');
                V_INIT_BASIC_START_TIME := V_NOW;
            END IF;

            V_STEP := 'V_INIT_BASIC_START_TIME = ' || V_INIT_BASIC_START_TIME;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'get_engine_id cur -> select modif start time';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_INIT_MODIF_START_TIME := TO_CHAR(TO_DATE(V_INIT_BASIC_START_TIME, 'DD.MM.YYYY HH24:MI:SS') + V_INIT_DELAY_DAYS + V_INIT_RETENTION_PERIOD, 'DD.MM.YYYY HH24:MI:SS');

            V_STEP := 'get_engine_id cur -> select diff between times';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_DIFF := PCKG_TOOLS.F_SEC_BETWEEN(TO_TIMESTAMP(V_INIT_MODIF_START_TIME, 'DD.MM.YYYY HH24:MI:SS'), TO_TIMESTAMP(V_NOW, 'DD.MM.YYYY HH24:MI:SS')) / 86400;

            V_STEP := 'get_engine_id cur -> select init is running';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR5.PARAM_VAL_INT
              INTO   V_INIT_IS_RUNNING
              FROM   CTRL_PARAMETERS CTRLPAR5
             WHERE   CTRLPAR5.PARAM_NAME = 'INITIALIZATION_IS_RUNNING'
                 AND CTRLPAR5.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select init duration mins';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR6.PARAM_VAL_INT
              INTO   V_INIT_DURATION_MINUTES
              FROM   CTRL_PARAMETERS CTRLPAR6
             WHERE   CTRLPAR6.PARAM_NAME = 'INITIALIZATION_DURATION_MINUTES'
                 AND CTRLPAR6.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select init begin';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CTRLPAR7.PARAM_VAL_TS + V_INIT_DURATION_MINUTES / 1440
              INTO   V_INIT_BEGIN
              FROM   CTRL_PARAMETERS CTRLPAR7
             WHERE   CTRLPAR7.PARAM_NAME = 'INITIALIZATION_BEGIN'
                 AND CTRLPAR7.PARAM_CD = R1.ENGINE_ID;

            V_STEP := 'get_engine_id cur -> select init begin diff';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_INIT_BEGIN_DIFF := PCKG_TOOLS.F_SEC_BETWEEN(V_INIT_BEGIN, CURRENT_TIMESTAMP);

            IF V_INIT_IS_RUNNING = 1
           AND V_INIT_BEGIN_DIFF > 0
            THEN
                V_STEP := 'get_engine_id cur -> exc Initialization took so long time';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_EXCEPTION_REASON := 'Initialization took so long time';
            END IF;

            IF V_DIFF > 0
            THEN
                V_STEP := 'get_engine_id cur -> exc Initialization delay exceed limit';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_EXCEPTION_REASON := 'Initialization delay exceed limit';
            END IF;

            IF (V_INIT_IS_RUNNING = 1
            AND V_INIT_BEGIN_DIFF > 0)
            OR (V_DIFF > 0)
            THEN
                V_STEP := 'get_engine_id cur -> save stat log event hist 3';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(EVENT_TS_IN                 => CURRENT_TIMESTAMP
                                                    , NOTIFICATION_CD_IN          => 1
                                                    , LOAD_DATE_IN                => V_LOAD_DATE
                                                    , JOB_NAME_IN                 => 'INITIALIZATION engine id = ' || R1.ENGINE_ID
                                                    , JOB_ID_IN                   => -1
                                                    , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('INITIALIZATION_FAILED'),8)
                                                    , ERROR_CD_IN                 => 'INITIALIZATION_FAILED'
                                                    , EVENT_CD_IN                 => NULL
                                                    , EVENT_DS_IN                 => NULL
                                                    , START_TS_IN                 => NULL
                                                    , END_TS_IN                   => NULL
                                                    , TRACKING_DURATION_IN        => NULL
                                                    , LAST_STATUS_IN              => NULL
                                                    , N_RUN_IN                    => NULL
                                                    , CHECKED_STATUS_IN           => NULL
                                                    , MAX_N_RUN_IN                => NULL
                                                    , AVG_DURARION_TOLERANCE_IN   => NULL
                                                    , AVG_END_TM_TOLERANCE_IN     => NULL
                                                    , ACTUAL_VALUE_IN             => NULL
                                                    , THRESHOLD_IN                => NULL
                                                    , OBJECT_NAME_IN              => NULL
                                                    , NOTE_IN                     => 'INITIALIZATION engine id = ' || R1.ENGINE_ID || ' has failed'
                                                    , SENT_TS_IN                  => NULL
                                                    , DWH_DATE_IN                 => V_DWH_DATE
                                                    , ENGINE_ID_IN                => R1.ENGINE_ID
                                                    , RECOMMENDATION_DS_IN        => NULL
													, SYSTEM_NAME_IN			  => NULL
                                                    , DEBUG_IN                    => DEBUG_IN
                                                    , EXIT_CD                     => EXIT_CD
                                                    , ERRMSG_OUT                  => ERRMSG_OUT
                                                    , ERRCODE_OUT                 => ERRCODE_OUT
                                                    , ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END LOOP;


        EXIT_CD := 0;
        ERRMSG_OUT := V_EXCEPTION_REASON;

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
    END SP_FWRK_CHECK_INITIALIZATION;

    PROCEDURE SP_FWRK_CHECK_NOTIFICATION(DEBUG_IN IN   INTEGER:= 0
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_CHECK_NOTIFICATION
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-25
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR CHCK_FAILED_JOB
        IS
            SELECT   SJ.JOB_ID
                   , SJ.STREAM_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , TO_CHAR(SJ.STATUS) STATUS
                   , SJ.LAST_UPDATE
                   , SJ.LOAD_DATE
                   , SJ.PRIORITY
                   , SJ.CMD_LINE
                   , SJ.SRC_SYS_ID
                   , SJ.PHASE
                   , SJ.TABLE_NAME
                   , SJ.JOB_CATEGORY
                   , SJ.JOB_TYPE
                   , SJ.CONT_ANYWAY
                   , SJ.RESTART
                   , SJ.ALWAYS_RESTART
                   , SJ.N_RUN
                   , SJ.MAX_RUNS
                   , SJ.WAITING_HR
                   , SJ.DEADLINE_HR
                   , SJ.APPLICATION_ID
                   , SJ.ENGINE_ID
				   , SJ.SYSTEM_NAME
                   , CJS.DESCRIPTION
                   , CTRL_NOT.ERROR_CD
              FROM           CTRL_NOTIFICATION CTRL_NOT
                         INNER JOIN
                             SESS_JOB SJ
                         ON CTRL_NOT.JOB_NAME = SJ.JOB_NAME
                     INNER JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND UPPER(CJS.RUNABLE) = UPPER('FAILED')
                    AND SJ.N_RUN = SJ.MAX_RUNS;

        CURSOR CHCK_AVG_DURARION_TOLERANCE
        IS
            SELECT   CTRL_NOT.JOB_NAME
                   , CTRL_NOT.NOTIFICATION_ENABLED
                   , CTRL_NOT.NOTIFICATION_CD
                   , NVL(CTRL_NOT.AVG_DURARION_TOLERANCE, 1) AVG_DURARION_TOLERANCE
                   , CTRL_NOT.AVG_END_TM_TOLERANCE
                   , CTRL_NOT.CHECKED_STATUS
                   , CTRL_NOT.MAX_N_RUN
                   , CTRL_NOT.ERROR_CD
                   , SJ.JOB_ID
                   , SJ.LAST_UPDATE LAST_UPDATE
                   , SJ.LOAD_DATE LOAD_DATE
                   , TO_CHAR(SJ.STATUS) STATUS
                   , SJ.N_RUN N_RUN
                   , SJ.MAX_RUNS MAX_RUNS
                   , SJ.ENGINE_ID
				   , SJ.SYSTEM_NAME
              FROM           CTRL_NOTIFICATION CTRL_NOT
                         INNER JOIN
                             SESS_JOB SJ
                         ON CTRL_NOT.JOB_NAME = SJ.JOB_NAME
                     INNER JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND UPPER(CJS.RUNABLE) = UPPER('RUNNING')
             WHERE   CTRL_NOT.NOTIFICATION_ENABLED = 1
                 AND CTRL_NOT.AVG_DURARION_TOLERANCE IS NOT NULL;

        CURSOR CHCK_AVG_END_TM_TOLERANCE
        IS
            SELECT   CTRL_NOT.JOB_NAME
                   , CTRL_NOT.NOTIFICATION_ENABLED
                   , CTRL_NOT.NOTIFICATION_CD
                   , NVL(CTRL_NOT.AVG_DURARION_TOLERANCE, 1) AVG_DURARION_TOLERANCE
                   , CTRL_NOT.AVG_END_TM_TOLERANCE
                   , CTRL_NOT.CHECKED_STATUS
                   , CTRL_NOT.MAX_N_RUN
                   , CTRL_NOT.ERROR_CD
                   , SJ.JOB_ID
                   , SJ.LAST_UPDATE LAST_UPDATE
                   , SJ.LOAD_DATE LOAD_DATE
                   , TO_CHAR(SJ.STATUS) STATUS
                   , SJ.N_RUN N_RUN
                   , SJ.MAX_RUNS MAX_RUNS
                   , SJ.ENGINE_ID
				   , SJ.SYSTEM_NAME
              FROM           CTRL_NOTIFICATION CTRL_NOT
                         INNER JOIN
                             SESS_JOB SJ
                         ON CTRL_NOT.JOB_NAME = SJ.JOB_NAME
                     INNER JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND CJS.FINISHED != 1
             WHERE   CTRL_NOT.NOTIFICATION_ENABLED = 1
                 AND CTRL_NOT.AVG_END_TM_TOLERANCE IS NOT NULL;

        CURSOR CHCK_CHECKED_STATUS
        IS
            SELECT   CTRL_NOT.JOB_NAME
                   , CTRL_NOT.NOTIFICATION_ENABLED
                   , CTRL_NOT.NOTIFICATION_CD
                   , NVL(CTRL_NOT.AVG_DURARION_TOLERANCE, 1) AVG_DURARION_TOLERANCE
                   , CTRL_NOT.AVG_END_TM_TOLERANCE
                   , CTRL_NOT.CHECKED_STATUS
                   , CTRL_NOT.MAX_N_RUN
                   , CTRL_NOT.ERROR_CD
                   , SJ.JOB_ID
                   , SJ.LAST_UPDATE LAST_UPDATE
                   , SJ.LOAD_DATE LOAD_DATE
                   , TO_CHAR(SJ.STATUS) STATUS
                   , SJ.N_RUN N_RUN
                   , SJ.MAX_RUNS MAX_RUNS
                   , SJ.ENGINE_ID
				   , SJ.SYSTEM_NAME
              FROM       CTRL_NOTIFICATION CTRL_NOT
                     INNER JOIN
                         SESS_JOB SJ
                     ON CTRL_NOT.JOB_NAME = SJ.JOB_NAME
                    AND CTRL_NOT.CHECKED_STATUS = SJ.STATUS
             WHERE   CTRL_NOT.NOTIFICATION_ENABLED = 1
                 AND CTRL_NOT.CHECKED_STATUS IS NOT NULL;

        CURSOR CHCK_MAX_N_RUN
        IS
            SELECT   CTRL_NOT.JOB_NAME
                   , CTRL_NOT.NOTIFICATION_ENABLED
                   , CTRL_NOT.NOTIFICATION_CD
                   , NVL(CTRL_NOT.AVG_DURARION_TOLERANCE, 1) AVG_DURARION_TOLERANCE
                   , CTRL_NOT.AVG_END_TM_TOLERANCE
                   , CTRL_NOT.CHECKED_STATUS
                   , CTRL_NOT.MAX_N_RUN
                   , CTRL_NOT.ERROR_CD
                   , SJ.JOB_ID
                   , SJ.ENGINE_ID
              FROM       CTRL_NOTIFICATION CTRL_NOT
                     INNER JOIN
                         SESS_JOB SJ
                     ON CTRL_NOT.JOB_NAME = SJ.JOB_NAME
                    AND CTRL_NOT.MAX_N_RUN = SJ.N_RUN
             WHERE   CTRL_NOT.NOTIFICATION_ENABLED = 1
                 AND CTRL_NOT.MAX_N_RUN IS NOT NULL;

        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_FWRK_CHECK_NOTIFICATION';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        V_VALUE1         NUMBER;
        V_VALUE2         NUMBER;
        V_VALUE3         NUMBER;
        V_VALUE4         NUMBER;
    BEGIN
        EXIT_CD := 0;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;


        FOR R0 IN CHCK_FAILED_JOB
        LOOP
            V_STEP := 'jestlize je status roven id ktere v parametricke tabulce znamena failed a pocet n_runs = max_runs ze session job potom take zapis chybu';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                EVENT_TS_IN                 => CURRENT_TIMESTAMP
              , NOTIFICATION_CD_IN          => 1
              , LOAD_DATE_IN                => R0.LOAD_DATE
              , JOB_NAME_IN                 => R0.JOB_NAME
              , JOB_ID_IN                   => R0.JOB_ID
              , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('FAILED_JOB'),4)
              , ERROR_CD_IN                 => 'FAILED_JOB' --R0.ERROR_CD
              , EVENT_CD_IN                 => NULL
              , EVENT_DS_IN                 => NULL
              , START_TS_IN                 => NULL
              , END_TS_IN                   => R0.LAST_UPDATE
              , TRACKING_DURATION_IN        => NULL
              , LAST_STATUS_IN              => R0.LAST_UPDATE
              , N_RUN_IN                    => R0.N_RUN
              , CHECKED_STATUS_IN           => NULL
              , MAX_N_RUN_IN                => R0.MAX_RUNS
              , AVG_DURARION_TOLERANCE_IN   => NULL
              , AVG_END_TM_TOLERANCE_IN     => NULL
              , ACTUAL_VALUE_IN             => NULL
              , THRESHOLD_IN                => NULL
              , OBJECT_NAME_IN              => NULL
              , NOTE_IN                     =>   'Job '
                                              || R0.JOB_NAME
                                              || ' job_id='
                                              || R0.JOB_ID
                                              || ' has failed. Status is '
                                              || R0.STATUS
                                              || ' N_RUN value is '
                                              || R0.N_RUN
                                              || ' Generated on '
                                              || CURRENT_TIMESTAMP
              , SENT_TS_IN                  => NULL
              , DWH_DATE_IN                 => TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R0.ENGINE_ID), 'DD.MM.YYYY')
              , ENGINE_ID_IN                => R0.ENGINE_ID
              , RECOMMENDATION_DS_IN        => NULL
			  , SYSTEM_NAME_IN				=> R0.SYSTEM_NAME
              , DEBUG_IN                    => DEBUG_IN
              , EXIT_CD                     => EXIT_CD
              , ERRMSG_OUT                  => ERRMSG_OUT
              , ERRCODE_OUT                 => ERRCODE_OUT
              , ERRLINE_OUT                 => ERRLINE_OUT);
        END LOOP;

        FOR R1 IN CHCK_AVG_DURARION_TOLERANCE
        LOOP
            V_STEP := 'pokud je prumerny cas behu plus tolerance mensi nez aktualni cas behu potom zapis chybu';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP || 'JOB NAME=' || R1.JOB_NAME || ' JOB_ID=' || R1.JOB_ID;

            IF   PCKG_TOOLS.F_SEC_BETWEEN(TO_TIMESTAMP(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R1.JOB_ID, 'last_update')), CURRENT_TIMESTAMP)
               - R1.AVG_DURARION_TOLERANCE
               - (PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R1.JOB_NAME, 'avg_duration') * (PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100)) > 0
            THEN
                V_VALUE1 := PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R1.JOB_NAME, 'avg_duration');
                V_VALUE2 := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100;
                V_VALUE3 := R1.AVG_DURARION_TOLERANCE;
                V_VALUE4 := V_VALUE3 + (V_VALUE1 * V_VALUE2);
                PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                    EVENT_TS_IN                 => CURRENT_TIMESTAMP
                  , NOTIFICATION_CD_IN          => 1
                  , LOAD_DATE_IN                => R1.LOAD_DATE
                  , JOB_NAME_IN                 => R1.JOB_NAME
                  , JOB_ID_IN                   => R1.JOB_ID
                  , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD(R1.ERROR_CD),2)
                  , ERROR_CD_IN                 => R1.ERROR_CD
                  , EVENT_CD_IN                 => NULL
                  , EVENT_DS_IN                 => NULL
                  , START_TS_IN                 => R1.LAST_UPDATE
                  , END_TS_IN                   => NULL
                  , TRACKING_DURATION_IN        => R1.AVG_DURARION_TOLERANCE
                                                  + (PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R1.JOB_NAME, 'avg_duration')
                                                     * (PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_FACTOR_PERCENT', 'param_val_int') / 100))
                  , LAST_STATUS_IN              => R1.LAST_UPDATE
                  , N_RUN_IN                    => R1.N_RUN
                  , CHECKED_STATUS_IN           => NULL
                  , MAX_N_RUN_IN                => R1.MAX_RUNS
                  , AVG_DURARION_TOLERANCE_IN   => PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R1.JOB_NAME, 'avg_duration')
                  , AVG_END_TM_TOLERANCE_IN     => NULL
                  , ACTUAL_VALUE_IN             => PCKG_TOOLS.F_SEC_BETWEEN(TO_TIMESTAMP(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R1.JOB_ID, 'last_update')), CURRENT_TIMESTAMP)
                  , THRESHOLD_IN                => NULL
                  , OBJECT_NAME_IN              => NULL
                  , NOTE_IN                     =>   'Job '
                                                  || R1.JOB_NAME
                                                  || ' job_id='
                                                  || R1.JOB_ID
                                                  || ' is running longer than expected. Running duration is='
                                                  || PCKG_TOOLS.F_SEC_BETWEEN(TO_TIMESTAMP(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R1.JOB_ID, 'last_update')), CURRENT_TIMESTAMP)
                                                  || ' Allowed duration is= '
                                                  || V_VALUE4
                                                  || ' Generated on '
                                                  || CURRENT_TIMESTAMP
                  , SENT_TS_IN                  => NULL
                  , DWH_DATE_IN                 => TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R1.ENGINE_ID), 'DD.MM.YYYY')
                  , ENGINE_ID_IN                => R1.ENGINE_ID
                  , RECOMMENDATION_DS_IN        => NULL
				  , SYSTEM_NAME_IN				=> R1.SYSTEM_NAME
                  , DEBUG_IN                    => DEBUG_IN
                  , EXIT_CD                     => EXIT_CD
                  , ERRMSG_OUT                  => ERRMSG_OUT
                  , ERRCODE_OUT                 => ERRCODE_OUT
                  , ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END LOOP;

        FOR R2 IN CHCK_AVG_END_TM_TOLERANCE
        LOOP
            V_STEP := 'pokud je ocekavany cas ukonceni behu jobu mensi nez aktualni cas, potom zapis chybu';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF   PCKG_TOOLS.F_SEC_BETWEEN(TO_TIMESTAMP(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R2.JOB_ID, 'last_update')), CURRENT_TIMESTAMP)
               - R2.AVG_END_TM_TOLERANCE
               - PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R2.JOB_NAME, 'avg_end_tm') > 0
            THEN
                V_VALUE1 := R2.AVG_END_TM_TOLERANCE;
                V_VALUE2 := PCKG_TOOLS.F_GET_SESS_JOB_STATISTICS(R2.JOB_NAME, 'avg_end_tm');
                V_VALUE3 := V_VALUE1 + V_VALUE2;
                PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                    EVENT_TS_IN                 => CURRENT_TIMESTAMP
                  , NOTIFICATION_CD_IN          => 1
                  , LOAD_DATE_IN                => R2.LOAD_DATE
                  , JOB_NAME_IN                 => R2.JOB_NAME
                  , JOB_ID_IN                   => R2.JOB_ID
                  , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD(R2.ERROR_CD),2)
                  , ERROR_CD_IN                 => R2.ERROR_CD
                  , EVENT_CD_IN                 => NULL
                  , EVENT_DS_IN                 => NULL
                  , START_TS_IN                 => R2.LAST_UPDATE
                  , END_TS_IN                   => NULL
                  , TRACKING_DURATION_IN        => NULL
                  , LAST_STATUS_IN              => R2.LAST_UPDATE
                  , N_RUN_IN                    => R2.N_RUN
                  , CHECKED_STATUS_IN           => NULL
                  , MAX_N_RUN_IN                => R2.MAX_RUNS
                  , AVG_DURARION_TOLERANCE_IN   => NULL
                  , AVG_END_TM_TOLERANCE_IN     => R2.AVG_END_TM_TOLERANCE
                  , ACTUAL_VALUE_IN             => NULL
                  , THRESHOLD_IN                => NULL
                  , OBJECT_NAME_IN              => NULL
                  , NOTE_IN                     =>   'Job '
                                                  || R2.JOB_NAME
                                                  || ' job_id='
                                                  || R2.JOB_ID
                                                  || ' has not finished as it is expected.'
                                                  || ' Allowed finished time = '
                                                  || V_VALUE3
                                                  || ' Generated on '
                                                  || CURRENT_TIMESTAMP
                  , SENT_TS_IN                  => NULL
                  , DWH_DATE_IN                 => TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R2.ENGINE_ID), 'DD.MM.YYYY')
                  , ENGINE_ID_IN                => R2.ENGINE_ID
                  , RECOMMENDATION_DS_IN        => NULL
				  , SYSTEM_NAME_IN				=> R2.SYSTEM_NAME
                  , DEBUG_IN                    => DEBUG_IN
                  , EXIT_CD                     => EXIT_CD
                  , ERRMSG_OUT                  => ERRMSG_OUT
                  , ERRCODE_OUT                 => ERRCODE_OUT
                  , ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END LOOP;

        FOR R3 IN CHCK_CHECKED_STATUS
        LOOP
            V_STEP := 'pokud je ocekavany cas ukonceni behu jobu mensi nez aktualni cas, potom zapis chybu 2';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF NVL(R3.CHECKED_STATUS, 0) <= NVL(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R3.JOB_ID, 'status'), 0)
            THEN
                PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(
                    EVENT_TS_IN                 => CURRENT_TIMESTAMP
                  , NOTIFICATION_CD_IN          => 1
                  , LOAD_DATE_IN                => R3.LOAD_DATE
                  , JOB_NAME_IN                 => R3.JOB_NAME
                  , JOB_ID_IN                   => R3.JOB_ID
                  , SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD(R3.ERROR_CD),1)
                  , ERROR_CD_IN                 => R3.ERROR_CD
                  , EVENT_CD_IN                 => NULL
                  , EVENT_DS_IN                 => NULL
                  , START_TS_IN                 => NULL
                  , END_TS_IN                   => R3.LAST_UPDATE
                  , TRACKING_DURATION_IN        => NULL
                  , LAST_STATUS_IN              => R3.LAST_UPDATE
                  , N_RUN_IN                    => R3.N_RUN
                  , CHECKED_STATUS_IN           => R3.CHECKED_STATUS
                  , MAX_N_RUN_IN                => R3.MAX_RUNS
                  , AVG_DURARION_TOLERANCE_IN   => NULL
                  , AVG_END_TM_TOLERANCE_IN     => NULL
                  , ACTUAL_VALUE_IN             => NULL
                  , THRESHOLD_IN                => NULL
                  , OBJECT_NAME_IN              => NULL
                  , NOTE_IN                     =>   'Expected job status '
                                                  || R3.CHECKED_STATUS
                                                  || ' with job '
                                                  || R3.JOB_NAME
                                                  || ' job_id='
                                                  || R3.JOB_ID
                                                  || ' has been reached. Generated on '
                                                  || CURRENT_TIMESTAMP
                  , SENT_TS_IN                  => NULL
                  , DWH_DATE_IN                 => TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('prev_load_date', 'param_val_date', R3.ENGINE_ID), 'DD.MM.YYYY')
                  , ENGINE_ID_IN                => R3.ENGINE_ID
                  , RECOMMENDATION_DS_IN        => NULL
				  , SYSTEM_NAME_IN				=> R3.SYSTEM_NAME
                  , DEBUG_IN                    => DEBUG_IN
                  , EXIT_CD                     => EXIT_CD
                  , ERRMSG_OUT                  => ERRMSG_OUT
                  , ERRCODE_OUT                 => ERRCODE_OUT
                  , ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END LOOP;

        /*        FOR R4 IN CHCK_MAX_N_RUN
                LOOP*/
        /*            IF NVL(R4.MAX_N_RUN, 0) <= NVL(PCKG_FWRK.F_GET_SESS_JOB_PARAM_STAT(R4.JOB_NAME, 'n_run'), 0)
                    THEN*/
        /*            V_STEP := 'max n run cur';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST(EVENT_TS_IN                 => CURRENT_TIMESTAMP
                                                        , NOTIFICATION_CD_IN          => NULL
                                                        , LOAD_DATE_IN                => NULL
                                                        , JOB_NAME_IN                 => R4.JOB_NAME
                                                        , JOB_ID_IN                   => R4.JOB_ID
                                                        , SEVERITY_LEVEL_CD_IN        => NULL
                                                        , ERROR_CD_IN                 => R4.ERROR_CD
                                                        , EVENT_CD_IN                 => NULL
                                                        , EVENT_DS_IN                 => NULL
                                                        , START_TS_IN                 => NULL
                                                        , END_TS_IN                   => NULL
                                                        , TRACKING_DURATION_IN        => NULL
                                                        , LAST_STATUS_IN              => NULL
                                                        , N_RUN_IN                    => NULL
                                                        , CHECKED_STATUS_IN           => NULL
                                                        , MAX_N_RUN_IN                => NULL
                                                        , AVG_DURARION_TOLERANCE_IN   => NULL
                                                        , AVG_END_TM_TOLERANCE_IN     => NULL
                                                        , ACTUAL_VALUE_IN             => NULL
                                                        , THRESHOLD_IN                => NULL
                                                        , OBJECT_NAME_IN              => NULL
                                                        , NOTE_IN                     => 'Max. number of runs has been reached'
                                                        , SENT_TS_IN                  => NULL
                                                        , DWH_DATE_IN                 => V_DWH_DATE
                                                        , ENGINE_ID_IN                => R4.ENGINE_ID
                                                        , DEBUG_IN                    => DEBUG_IN
                                                        , EXIT_CD                     => EXIT_CD
                                                        , ERRMSG_OUT                  => ERRMSG_OUT
                                                        , ERRCODE_OUT                 => ERRCODE_OUT
                                                        , ERRLINE_OUT                 => ERRLINE_OUT);
                --            END IF;
                END LOOP;*/

        ERRMSG_OUT := 'FINISHED OK';

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
    END SP_FWRK_CHECK_NOTIFICATION;

    PROCEDURE SP_FWRK_MESSAGE_GEN(DEBUG_IN IN   INTEGER:= 0
                                , EXIT_CD   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_FWRK_MESSAGE_GEN
        IN parameters:
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-03-01
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                      CONSTANT VARCHAR2(64) := 'SP_FWRK_MESSAGE_GEN';
        -- local variables
        V_STEP                           VARCHAR2(1024);
        V_ALL_DBG_INFO                   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID                    INTEGER := 0;
        V_MESSAGE_REITERATION_INTERVAL   INTEGER := PCKG_FWRK.F_GET_CTRL_PARAMETERS('MESSAGE_REITERATION_INTERVAL', 'param_val_int');
        V_MESSAGE_REITERATION_COUNT      INTEGER := PCKG_FWRK.F_GET_CTRL_PARAMETERS('MESSAGE_REITERATION_COUNT', 'param_val_int');
        V_SCHEDULER_OFF_COUNT            INTEGER := PCKG_FWRK.F_GET_CTRL_PARAMETERS('SCHEDULER_OFF_COUNT', 'param_val_int');
        V_INITIALIZATION_PROBLEM_COUNT   INTEGER := PCKG_FWRK.F_GET_CTRL_PARAMETERS('INITIALIZATION_PROBLEM_COUNT', 'param_val_int');
        V_GET_ERROR_CD_NAME_SHORT        LKP_ERROR_CD.ERROR_CD_NAME_SHORT%TYPE;

        CURSOR CUR_GET_ALERT_ROW
        IS
              --vyber neposlane zaznamy
              SELECT   COUNT(*) POCET_NOT_SEND
                     ,  SLEH.JOB_NAME
                     , SLEH.JOB_ID
                     , SLEH.DWH_DATE
                     , SLEH.ERROR_CD
                     , SLEH.N_RUN
                FROM   STAT_LOG_EVENT_HIST SLEH
               WHERE   SLEH.SENT_TS IS NULL
            --                 AND TO_CHAR(SLEH.DWH_DATE, 'DD.MM.YYYY') = TO_CHAR(V_DWH_DATE, 'DD.MM.YYYY')
            GROUP BY   SLEH.JOB_NAME
                     , SLEH.JOB_ID
                     , SLEH.DWH_DATE
                     , SLEH.ERROR_CD
                     , SLEH.N_RUN;

        CURSOR CUR_GET_ALERT_ROW_HIST_NR(XJOB_NAME VARCHAR2, XJOB_ID NUMBER, XDWH_DATE DATE, XERROR_CD VARCHAR2, XN_RUN NUMBER)
        IS
            --zjisti, jestli novemu zaznamu predchazely jiz poslane zaznamy
            SELECT   COUNT(DISTINCT SLEH.JOB_ID) POCET
              FROM   STAT_LOG_EVENT_HIST SLEH
             WHERE   SLEH.SENT_TS IS NOT NULL
                 AND SLEH.JOB_NAME = XJOB_NAME
                 AND SLEH.JOB_ID = XJOB_ID
                 AND SLEH.DWH_DATE = XDWH_DATE
                 AND NVL(SLEH.ERROR_CD, 1) = NVL(XERROR_CD, 1)
                 AND NVL(SLEH.N_RUN, 1) = NVL(XN_RUN, 1);

        CURSOR CUR_GET_ALERT_ROW_HIST(XJOB_NAME VARCHAR2, XJOB_ID VARCHAR2, XDWH_DATE DATE, XERROR_CD VARCHAR2, XN_RUN NUMBER)
        IS
              --zjisti historii poslanych zprav
              SELECT   COUNT(DISTINCT SLEH.SENT_TS) POCET
                     , SLEH.JOB_NAME
                     , SLEH.DWH_DATE
                     , MAX(SLEH.SENT_TS) MAX_SENT_TS
                     , MIN(SLEH.SENT_TS) MIN_SENT_TS
                FROM   STAT_LOG_EVENT_HIST SLEH
               WHERE   SLEH.SENT_TS IS NOT NULL
                   AND SLEH.JOB_NAME = XJOB_NAME
                   AND SLEH.JOB_ID = XJOB_ID
                   AND SLEH.DWH_DATE = XDWH_DATE
                   AND NVL(SLEH.ERROR_CD, 1) = NVL(XERROR_CD, 1)
                   AND NVL(SLEH.N_RUN, 1) = NVL(XN_RUN, 1)
            GROUP BY   SLEH.JOB_NAME,SLEH.JOB_ID,SLEH.DWH_DATE,SLEH.N_RUN;

        CURSOR CUR_GET_ALERT_ROW_DETAIL(XJOB_NAME VARCHAR2, XJOB_ID VARCHAR2, XDWH_DATE DATE, XERROR_CD VARCHAR2, XN_RUN NUMBER)
        IS
            --vybereme posledni platne detaily k danemu problemu
            SELECT * FROM(
              SELECT   SLEH.LOG_EVENT_ID
                     , SLEH.EVENT_TS
                     , SLEH.NOTIFICATION_CD
                     , SLEH.LOAD_DATE
                     , SLEH.JOB_NAME
                     , SLEH.JOB_ID
                     , SLEH.SEVERITY_LEVEL_CD
                     , SLEH.ERROR_CD
                     , SLEH.EVENT_CD
                     , SLEH.EVENT_DS
                     , SLEH.START_TS
                     , SLEH.END_TS
                     , SLEH.TRACKING_DURATION
                     , SLEH.LAST_STATUS
                     , SLEH.N_RUN
                     , SLEH.CHECKED_STATUS
                     , SLEH.MAX_N_RUN
                     , SLEH.AVG_DURARION_TOLERANCE
                     , SLEH.AVG_END_TM_TOLERANCE
                     , SLEH.ACTUAL_VALUE
                     , SLEH.THRESHOLD
                     , SLEH.OBJECT_NAME
                     , SLEH.NOTE
                     , SLEH.SENT_TS
                     , SLEH.DWH_DATE
                     , SLEH.ENGINE_ID
                     , SLEH.RECOMMENDATION_DS
                     , ROW_NUMBER() OVER(ORDER BY SLEH.LOG_EVENT_ID DESC) AS RN
             , SLEH.SYSTEM_NAME
                FROM   STAT_LOG_EVENT_HIST SLEH
               WHERE   SLEH.SENT_TS IS NULL
                   AND SLEH.JOB_NAME = XJOB_NAME
                   AND SLEH.JOB_ID = XJOB_ID
                   AND SLEH.DWH_DATE = XDWH_DATE
                   AND NVL(SLEH.N_RUN, 1) = NVL(N_RUN, 1)
                   AND NVL(SLEH.ERROR_CD, 1) = NVL(XERROR_CD, 1)
          ) WHERE RN=1;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        FOR R1 IN CUR_GET_ALERT_ROW
        LOOP
            V_STEP := 'najdi nove jeste nezpracovane zaznamy';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_GET_ERROR_CD_NAME_SHORT := PCKG_TOOLS.F_GET_ERROR_CD_NAME_SHORT(R1.ERROR_CD);

            FOR R5 IN CUR_GET_ALERT_ROW_HIST_NR(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
            LOOP
                V_STEP := 'zjisti, jestli se nove zaznamy opakuji';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                IF R5.POCET = 0 AND V_GET_ERROR_CD_NAME_SHORT NOT IN ('SCH', 'INIT')
                THEN
                    V_STEP := 'pokud se neopakuji, jde o prvni chybu s danym job_name, dwh_date a error_cd, potom zapis do msg a neni to chyba Scheduleru a Init';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    FOR R4 IN CUR_GET_ALERT_ROW_DETAIL(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
                    LOOP
                        V_STEP := 'zapis do stat log message hist';
                        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                        PCKG_FWRK.SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN           => R4.LOG_EVENT_ID
                                                              , ERROR_CD_IN               => R4.ERROR_CD
                                                              , ENGINE_NAME_IN            => PCKG_FWRK.F_GET_CTRL_PARAMETERS('engine_name', 'PARAM_VAL_CHAR', R4.ENGINE_ID)
                                                              , JOB_NAME_IN               => R4.JOB_NAME
                                                              , JOB_ID_IN                 => R4.JOB_ID
                                                              , SEVERITY_IN               => R4.SEVERITY_LEVEL_CD
                                                              , NOTIFICATION_TYPE_CD_IN   => R4.NOTIFICATION_CD
                                                              , EVENT_DS_IN               => R4.EVENT_DS
                                                              , RECOMMENDATION_DS_IN      => R4.RECOMMENDATION_DS
                                                              , NOTE_IN                   => R4.NOTE
                                                              , DETECTED_TS_IN            => R4.EVENT_TS
                                                              , SENT_TS_IN                => NULL
															  , SYSTEM_NAME_IN			  => R4.SYSTEM_NAME
                                                              , DEBUG_IN                  => DEBUG_IN
                                                              , EXIT_CD                   => EXIT_CD
                                                              , ERRMSG_OUT                => ERRMSG_OUT
                                                              , ERRCODE_OUT               => ERRCODE_OUT
                                                              , ERRLINE_OUT               => ERRLINE_OUT);

                        V_STEP := 'oznac zaznam jako zpracovany';
                        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                        UPDATE   STAT_LOG_EVENT_HIST SLEH
                           SET   SLEH.SENT_TS = CURRENT_TIMESTAMP
                         WHERE   SLEH.SENT_TS IS NULL
                             AND SLEH.JOB_NAME = R1.JOB_NAME
                             AND SLEH.JOB_ID = R1.JOB_ID
                             AND SLEH.DWH_DATE = R1.DWH_DATE
                             AND NVL(SLEH.N_RUN, 1) = NVL(R1.N_RUN, 1)
                             AND NVL(SLEH.ERROR_CD, 1) = NVL(R1.ERROR_CD, 1);
                    END LOOP;

                ELSIF R1.POCET_NOT_SEND >= V_SCHEDULER_OFF_COUNT AND V_GET_ERROR_CD_NAME_SHORT = 'SCH'
                THEN
                    V_STEP := 'pokud je chyba scheduler, presahne pocet iteraci, pak rozesila v intervalu';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    FOR R3 IN CUR_GET_ALERT_ROW_DETAIL(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
                    LOOP
                      PCKG_FWRK.SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN           => R3.LOG_EVENT_ID
                                                            , ERROR_CD_IN               => R3.ERROR_CD
                                                            , ENGINE_NAME_IN            => PCKG_FWRK.F_GET_CTRL_PARAMETERS('engine_name', 'PARAM_VAL_CHAR', R3.ENGINE_ID)
                                                            , JOB_NAME_IN               => R3.JOB_NAME
                                                            , JOB_ID_IN                 => R3.JOB_ID
                                                            , SEVERITY_IN               => R3.SEVERITY_LEVEL_CD
                                                            , NOTIFICATION_TYPE_CD_IN   => R3.NOTIFICATION_CD
                                                            , EVENT_DS_IN               => R3.EVENT_DS
                                                            , RECOMMENDATION_DS_IN      => R3.RECOMMENDATION_DS
                                                            , NOTE_IN                   => R3.NOTE
                                                            , DETECTED_TS_IN            => R3.EVENT_TS
                                                            , SENT_TS_IN                => NULL
                          , SYSTEM_NAME_IN			  => R3.SYSTEM_NAME
                                                            , DEBUG_IN                  => DEBUG_IN
                                                            , EXIT_CD                   => EXIT_CD
                                                            , ERRMSG_OUT                => ERRMSG_OUT
                                                            , ERRCODE_OUT               => ERRCODE_OUT
                                                            , ERRLINE_OUT               => ERRLINE_OUT);
                    END LOOP;
                    V_STEP := 'update stat log event hist';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   STAT_LOG_EVENT_HIST SLEH
                       SET   SLEH.SENT_TS = CURRENT_TIMESTAMP
                     WHERE   SLEH.SENT_TS IS NULL
                         AND SLEH.JOB_NAME = R1.JOB_NAME
                         AND SLEH.JOB_ID = R1.JOB_ID
                         AND SLEH.DWH_DATE = R1.DWH_DATE
                         AND NVL(SLEH.N_RUN, 1) = NVL(R1.N_RUN, 1)
                         AND NVL(SLEH.ERROR_CD, 1) = NVL(R1.ERROR_CD, 1);

                ELSIF R1.POCET_NOT_SEND  >= V_INITIALIZATION_PROBLEM_COUNT AND V_GET_ERROR_CD_NAME_SHORT = 'INIT'
                THEN
                    V_STEP := 'pokud je chyba initialization, presahne pocet iteraci, pak rozesila v intervalu';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    FOR R3 IN CUR_GET_ALERT_ROW_DETAIL(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
                    LOOP

                      PCKG_FWRK.SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN           => R3.LOG_EVENT_ID
                                                            , ERROR_CD_IN               => R3.ERROR_CD
                                                            , ENGINE_NAME_IN            => PCKG_FWRK.F_GET_CTRL_PARAMETERS('engine_name', 'param_val_char', R3.ENGINE_ID)
                                                            , JOB_NAME_IN               => R3.JOB_NAME
                                                            , JOB_ID_IN                 => R3.JOB_ID
                                                            , SEVERITY_IN               => R3.SEVERITY_LEVEL_CD
                                                            , NOTIFICATION_TYPE_CD_IN   => R3.NOTIFICATION_CD
                                                            , EVENT_DS_IN               => R3.EVENT_DS
                                                            , RECOMMENDATION_DS_IN      => R3.RECOMMENDATION_DS
                                                            , NOTE_IN                   => R3.NOTE
                                                            , DETECTED_TS_IN            => R3.EVENT_TS
                                                            , SENT_TS_IN                => NULL
                          , SYSTEM_NAME_IN			  => R3.SYSTEM_NAME
                                                            , DEBUG_IN                  => DEBUG_IN
                                                            , EXIT_CD                   => EXIT_CD
                                                            , ERRMSG_OUT                => ERRMSG_OUT
                                                            , ERRCODE_OUT               => ERRCODE_OUT
                                                            , ERRLINE_OUT               => ERRLINE_OUT);
                    END LOOP;
                    V_STEP := 'update stat log event hist';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   STAT_LOG_EVENT_HIST SLEH
                       SET   SLEH.SENT_TS = CURRENT_TIMESTAMP
                     WHERE   SLEH.SENT_TS IS NULL
                         AND SLEH.JOB_NAME = R1.JOB_NAME
                         AND SLEH.JOB_ID = R1.JOB_ID
                         AND SLEH.DWH_DATE = R1.DWH_DATE
                         AND NVL(SLEH.N_RUN, 1) = NVL(R1.N_RUN, 1)
                         AND NVL(SLEH.ERROR_CD, 1) = NVL(R1.ERROR_CD, 1);
                ELSE

                    IF V_GET_ERROR_CD_NAME_SHORT NOT IN ('SCH', 'INIT') THEN
                        FOR R2 IN CUR_GET_ALERT_ROW_HIST(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
                        LOOP
                            FOR R3 IN CUR_GET_ALERT_ROW_DETAIL(R1.JOB_NAME, R1.JOB_ID, R1.DWH_DATE, R1.ERROR_CD, R1.N_RUN)
                            LOOP
                                V_STEP :=
                                    'pokud se chyba opakuje, potom zjisti,jestli nejde o chybu scheduler a initialization a jestli se chyba neobjevila v nepovolenem intervalu, potom zapis do msg';
                                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                                IF R2.POCET < V_MESSAGE_REITERATION_COUNT
                               AND PCKG_TOOLS.F_SEC_BETWEEN(R2.MAX_SENT_TS, CURRENT_TIMESTAMP) >= V_MESSAGE_REITERATION_INTERVAL
                                THEN
                                    PCKG_FWRK.SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN           => R3.LOG_EVENT_ID
                                                                          , ERROR_CD_IN               => R3.ERROR_CD
                                                                          , ENGINE_NAME_IN            => PCKG_FWRK.F_GET_CTRL_PARAMETERS('engine_name', 'PARAM_VAL_CHAR', R3.ENGINE_ID)
                                                                          , JOB_NAME_IN               => R3.JOB_NAME
                                                                          , JOB_ID_IN                 => R3.JOB_ID
                                                                          , SEVERITY_IN               => R3.SEVERITY_LEVEL_CD
                                                                          , NOTIFICATION_TYPE_CD_IN   => R3.NOTIFICATION_CD
                                                                          , EVENT_DS_IN               => R3.EVENT_DS
                                                                          , RECOMMENDATION_DS_IN      => R3.RECOMMENDATION_DS
                                                                          , NOTE_IN                   => R3.NOTE
                                                                          , DETECTED_TS_IN            => R3.EVENT_TS
                                                                          , SENT_TS_IN                => NULL
                                        , SYSTEM_NAME_IN			  => R3.SYSTEM_NAME
                                                                          , DEBUG_IN                  => DEBUG_IN
                                                                          , EXIT_CD                   => EXIT_CD
                                                                          , ERRMSG_OUT                => ERRMSG_OUT
                                                                          , ERRCODE_OUT               => ERRCODE_OUT
                                                                          , ERRLINE_OUT               => ERRLINE_OUT);

                                    V_STEP := 'update stat log event hist';
                                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                                    UPDATE   STAT_LOG_EVENT_HIST SLEH
                                       SET   SLEH.SENT_TS = CURRENT_TIMESTAMP
                                     WHERE   SLEH.SENT_TS IS NULL
                                         AND SLEH.JOB_NAME = R1.JOB_NAME
                                         AND SLEH.JOB_ID = R1.JOB_ID
                                         AND SLEH.DWH_DATE = R1.DWH_DATE
                                         AND NVL(SLEH.N_RUN, 1) = NVL(R1.N_RUN, 1)
                                         AND NVL(SLEH.ERROR_CD, 1) = NVL(R1.ERROR_CD, 1);
                                ELSE
                                      V_STEP := 'pokud neodpovida chyba zadnemu z vyse uvedeneho, potom pouze updatuj zaznam jako zpracovany, aby se jiz nezpracovaval';
                                      V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                                      V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                                      UPDATE   STAT_LOG_EVENT_HIST SLEH
                                         SET   SLEH.SENT_TS = R2.MAX_SENT_TS
                                       WHERE   SLEH.SENT_TS IS NULL
                                           AND SLEH.JOB_NAME = R1.JOB_NAME
                                           AND SLEH.JOB_ID = R1.JOB_ID
                                           AND SLEH.DWH_DATE = R1.DWH_DATE
                                           AND SLEH.N_RUN = R1.N_RUN
                                           AND NVL(SLEH.N_RUN, 1) = NVL(R1.N_RUN, 1)
                                           AND NVL(SLEH.ERROR_CD, 1) = NVL(R1.ERROR_CD, 1);
                                END IF;
                            END LOOP;
                        END LOOP;
                  END IF;
                END IF;
            END LOOP;
        END LOOP;

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
    END SP_FWRK_MESSAGE_GEN;


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
										, SYSTEM_NAME_IN IN STAT_LOG_EVENT_HIST.SYSTEM_NAME%TYPE:= NULL
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SAVE_STAT_LOG_EVENT_HIST
        IN parameters:
                       EVENT_TS_IN
                       NOTIFICATION_CD_IN
                       LOAD_DATE_IN
                       JOB_NAME_IN
                       JOB_ID_IN
                       SEVERITY_LEVEL_CD_IN
                       ERROR_CD_IN
                       EVENT_CD_IN
                       EVENT_DS_IN
                       START_TS_IN
                       END_TS_IN
                       TRACKING_DURATION_IN
                       LAST_STATUS_IN
                       N_RUN_IN
                       CHECKED_STATUS_IN
                       MAX_N_RUN_IN
                       AVG_DURARION_TOLERANCE_IN
                       AVG_END_TM_TOLERANCE_IN
                       ACTUAL_VALUE_IN
                       THRESHOLD_IN
                       OBJECT_NAME_IN
                       NOTE_IN
                       SENT_TS_IN
                       DWH_DATE_IN
                       ENGINE_ID_IN
                       RECOMMENDATION_DS_IN
					   SYSTEM_NAME_IN
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version: 1.1
        Date: 2014-12-01
        Modification: ENGINE_ID ADD
        Modified:
        Version: 1.2
        Date: 2015-01-30
        Modification: RECOMMENDATION_DS ADD
		Version: 1.3
        Date: 2015-03-17
        Modification: SYSTEM_NAME ADD

        *******************************************************************************/
        --constants
        C_PROC_NAME                CONSTANT VARCHAR2(64) := 'SP_SAVE_STAT_LOG_EVENT_HIST';
        -- local variables
        V_STEP                     VARCHAR2(1024);
        V_ALL_DBG_INFO             PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID              INTEGER := 0;

        V_EVENT_TS                 STAT_LOG_EVENT_HIST.EVENT_TS%TYPE := CURRENT_TIMESTAMP; --Event discovery timestamp'
        V_NOTIFICATION_CD          STAT_LOG_EVENT_HIST.NOTIFICATION_CD%TYPE; --Notification type'
        V_LOAD_DATE                STAT_LOG_EVENT_HIST.LOAD_DATE%TYPE; --Load date'
        V_JOB_NAME                 STAT_LOG_EVENT_HIST.JOB_NAME%TYPE; --Name of the job'
        V_JOB_ID                   STAT_LOG_EVENT_HIST.JOB_ID%TYPE; --Job identification'
        V_SEVERITY_LEVEL_CD        STAT_LOG_EVENT_HIST.SEVERITY_LEVEL_CD%TYPE; --Severity of the event'
        V_ERROR_CD                 STAT_LOG_EVENT_HIST.ERROR_CD%TYPE; --Error code'
        V_EVENT_CD                 STAT_LOG_EVENT_HIST.EVENT_CD%TYPE; --Type of the event'
        V_EVENT_DS                 STAT_LOG_EVENT_HIST.EVENT_DS%TYPE; --Description of the event'
        V_START_TS                 STAT_LOG_EVENT_HIST.START_TS%TYPE; --Timestamp when job was launched'
        V_END_TS                   STAT_LOG_EVENT_HIST.END_TS%TYPE; --Timestamp when job was finished'
        V_TRACKING_DURATION        STAT_LOG_EVENT_HIST.TRACKING_DURATION%TYPE; --Trackung duration of job run'
        V_LAST_STATUS              STAT_LOG_EVENT_HIST.LAST_STATUS%TYPE; --Last job status'
        V_N_RUN                    STAT_LOG_EVENT_HIST.N_RUN%TYPE; --Number of job launch'
        V_CHECKED_STATUS           STAT_LOG_EVENT_HIST.CHECKED_STATUS%TYPE; --Job status which is monitoring'
        V_MAX_N_RUN                STAT_LOG_EVENT_HIST.MAX_N_RUN%TYPE; --Maximal number of job launch'
        V_AVG_DURARION_TOLERANCE   STAT_LOG_EVENT_HIST.AVG_DURARION_TOLERANCE%TYPE; --Average tolerance for duration tracking'
        V_AVG_END_TM_TOLERANCE     STAT_LOG_EVENT_HIST.AVG_END_TM_TOLERANCE%TYPE; --Average tolerance for end job tracking'
        V_ACTUAL_VALUE             STAT_LOG_EVENT_HIST.ACTUAL_VALUE%TYPE; --Actual value of threshold reached'
        V_THRESHOLD                STAT_LOG_EVENT_HIST.THRESHOLD%TYPE; --Threshold value for event creation'
        V_OBJECT_NAME              STAT_LOG_EVENT_HIST.OBJECT_NAME%TYPE; --Name of the object which is monitoring'
        V_NOTE                     STAT_LOG_EVENT_HIST.NOTE%TYPE; --Additional information'
        V_SENT_TS                  STAT_LOG_EVENT_HIST.SENT_TS%TYPE; --Timestamp when the event was processed'
        V_DWH_DATE                 STAT_LOG_EVENT_HIST.DWH_DATE%TYPE;
        V_ENGINE_ID                STAT_LOG_EVENT_HIST.ENGINE_ID%TYPE;
        V_RECOMMENDATION_DS        STAT_LOG_EVENT_HIST.RECOMMENDATION_DS%TYPE;
		V_SYSTEM_NAME        	   STAT_LOG_EVENT_HIST.SYSTEM_NAME%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_EVENT_TS := EVENT_TS_IN;
        V_NOTIFICATION_CD := NOTIFICATION_CD_IN;
        V_LOAD_DATE := LOAD_DATE_IN;
        V_JOB_NAME := JOB_NAME_IN;
        V_JOB_ID := JOB_ID_IN;
        V_SEVERITY_LEVEL_CD := SEVERITY_LEVEL_CD_IN;
        V_ERROR_CD := ERROR_CD_IN;
        V_EVENT_CD := EVENT_CD_IN;
        V_EVENT_DS := EVENT_DS_IN;
        V_START_TS := START_TS_IN;
        V_END_TS := END_TS_IN;
        V_TRACKING_DURATION := TRACKING_DURATION_IN;
        V_LAST_STATUS := LAST_STATUS_IN;
        V_N_RUN := N_RUN_IN;
        V_CHECKED_STATUS := CHECKED_STATUS_IN;
        V_MAX_N_RUN := MAX_N_RUN_IN;
        V_AVG_DURARION_TOLERANCE := AVG_DURARION_TOLERANCE_IN;
        V_AVG_END_TM_TOLERANCE := AVG_END_TM_TOLERANCE_IN;
        V_ACTUAL_VALUE := ACTUAL_VALUE_IN;
        V_THRESHOLD := THRESHOLD_IN;
        V_OBJECT_NAME := OBJECT_NAME_IN;
        V_NOTE := NOTE_IN;
        V_SENT_TS := SENT_TS_IN;
        V_DWH_DATE := DWH_DATE_IN;
        V_ENGINE_ID := ENGINE_ID_IN;
        V_RECOMMENDATION_DS := RECOMMENDATION_DS_IN;
		V_SYSTEM_NAME := SYSTEM_NAME_IN;

        V_STEP := 'insert into stat log event hist';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO STAT_LOG_EVENT_HIST(EVENT_TS
                                      , NOTIFICATION_CD
                                      , LOAD_DATE
                                      , JOB_NAME
                                      , JOB_ID
                                      , SEVERITY_LEVEL_CD
                                      , ERROR_CD
                                      , EVENT_CD
                                      , EVENT_DS
                                      , START_TS
                                      , END_TS
                                      , TRACKING_DURATION
                                      , LAST_STATUS
                                      , N_RUN
                                      , CHECKED_STATUS
                                      , MAX_N_RUN
                                      , AVG_DURARION_TOLERANCE
                                      , AVG_END_TM_TOLERANCE
                                      , ACTUAL_VALUE
                                      , THRESHOLD
                                      , OBJECT_NAME
                                      , NOTE
                                      , SENT_TS
                                      , DWH_DATE
                                      , ENGINE_ID
                                      , RECOMMENDATION_DS
									  , SYSTEM_NAME)
          VALUES   (V_EVENT_TS
                  , V_NOTIFICATION_CD
                  , V_LOAD_DATE
                  , V_JOB_NAME
                  , V_JOB_ID
                  , V_SEVERITY_LEVEL_CD
                  , V_ERROR_CD
                  , V_EVENT_CD
                  , V_EVENT_DS
                  , V_START_TS
                  , V_END_TS
                  , V_TRACKING_DURATION
                  , V_LAST_STATUS
                  , V_N_RUN
                  , V_CHECKED_STATUS
                  , V_MAX_N_RUN
                  , V_AVG_DURARION_TOLERANCE
                  , V_AVG_END_TM_TOLERANCE
                  , V_ACTUAL_VALUE
                  , V_THRESHOLD
                  , V_OBJECT_NAME
                  , V_NOTE
                  , V_SENT_TS
                  , V_DWH_DATE
                  , V_ENGINE_ID
                  , V_RECOMMENDATION_DS
				  , V_SYSTEM_NAME);


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
    END SP_SAVE_STAT_LOG_EVENT_HIST;

    PROCEDURE SP_SAVE_STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID_IN STAT_LOG_MESSAGE_HIST.LOG_EVENT_ID%TYPE
                                          , ERROR_CD_IN   STAT_LOG_MESSAGE_HIST.ERROR_CD%TYPE
                                          , ENGINE_NAME_IN STAT_LOG_MESSAGE_HIST.ENGINE_NAME%TYPE
                                          , JOB_NAME_IN   STAT_LOG_MESSAGE_HIST.JOB_NAME%TYPE
                                          , JOB_ID_IN     STAT_LOG_MESSAGE_HIST.JOB_ID%TYPE
                                          , SEVERITY_IN   STAT_LOG_MESSAGE_HIST.SEVERITY%TYPE:= 0
                                          , NOTIFICATION_TYPE_CD_IN STAT_LOG_MESSAGE_HIST.NOTIFICATION_TYPE_CD%TYPE:= 0
                                          , EVENT_DS_IN   STAT_LOG_MESSAGE_HIST.EVENT_DS%TYPE:= 'N/A'
                                          , RECOMMENDATION_DS_IN STAT_LOG_MESSAGE_HIST.RECOMMENDATION_DS%TYPE
                                          , NOTE_IN       STAT_LOG_MESSAGE_HIST.NOTE%TYPE
                                          , DETECTED_TS_IN STAT_LOG_MESSAGE_HIST.DETECTED_TS%TYPE:= CURRENT_TIMESTAMP
                                          , SENT_TS_IN    STAT_LOG_MESSAGE_HIST.SENT_TS%TYPE
                                          , SYSTEM_NAME_IN	  STAT_LOG_MESSAGE_HIST.SYSTEM_NAME%TYPE
                                          , DEBUG_IN IN   INTEGER:= 0
                                          , EXIT_CD   OUT NOCOPY NUMBER
                                          , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                          , ERRCODE_OUT   OUT NOCOPY NUMBER
                                          , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SAVE_STAT_LOG_MESSAGE_HIST
        IN parameters:
                       LOG_EVENT_ID_IN
                       ERROR_CD_IN
                       JOB_NAME_IN
                       JOB_ID_IN
                       SEVERITY_IN
                       NOTIFICATION_TYPE_CD_IN
                       EVENT_DS_IN
                       RECOMMENDATION_DS_IN
                       NOTE_IN
                       DETECTED_TS_IN
                       SENT_TS_IN
                       SYSTEM_NAME_IN
					   SYSTEM_NAME_IN
                       DEBUG_IN
					
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME              CONSTANT VARCHAR2(64) := 'SP_SAVE_STAT_LOG_MESSAGE_HIST';
        -- local variables
        V_STEP                   VARCHAR2(1024);
        V_ALL_DBG_INFO           PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID            INTEGER := 0;

        V_LOG_EVENT_ID           STAT_LOG_MESSAGE_HIST.LOG_EVENT_ID%TYPE := LOG_EVENT_ID_IN;
        V_ERROR_CD               STAT_LOG_MESSAGE_HIST.ERROR_CD%TYPE := ERROR_CD_IN;
        V_ENGINE_NAME            STAT_LOG_MESSAGE_HIST.ENGINE_NAME%TYPE := ENGINE_NAME_IN;
        V_JOB_NAME               STAT_LOG_MESSAGE_HIST.JOB_NAME%TYPE := JOB_NAME_IN;
        V_JOB_ID                 STAT_LOG_MESSAGE_HIST.JOB_ID%TYPE := JOB_ID_IN;
        V_SEVERITY               STAT_LOG_MESSAGE_HIST.SEVERITY%TYPE := NVL(SEVERITY_IN, 0);
        V_NOTIFICATION_TYPE_CD   STAT_LOG_MESSAGE_HIST.NOTIFICATION_TYPE_CD%TYPE := NVL(NOTIFICATION_TYPE_CD_IN, 0);
        V_EVENT_DS               STAT_LOG_MESSAGE_HIST.EVENT_DS%TYPE := NVL(EVENT_DS_IN, 'N/A');
        V_RECOMMENDATION_DS      STAT_LOG_MESSAGE_HIST.RECOMMENDATION_DS%TYPE := RECOMMENDATION_DS_IN;
        V_NOTE                   STAT_LOG_MESSAGE_HIST.NOTE%TYPE := NOTE_IN;
        V_DETECTED_TS            STAT_LOG_MESSAGE_HIST.DETECTED_TS%TYPE := NVL(DETECTED_TS_IN, CURRENT_TIMESTAMP);
        V_SENT_TS                STAT_LOG_MESSAGE_HIST.SENT_TS%TYPE := SENT_TS_IN;
		V_SYSTEM_NAME			            STAT_LOG_MESSAGE_HIST.SYSTEM_NAME%TYPE := SYSTEM_NAME_IN;
    --        V_DWH_DATE                 STAT_LOG_EVENT_HIST.DWH_DATE%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'insert into stat log message hist';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO STAT_LOG_MESSAGE_HIST(LOG_EVENT_ID
                                        , ERROR_CD
                                        , ENGINE_NAME
                                        , JOB_NAME
                                        , JOB_ID
                                        , SEVERITY
                                        , NOTIFICATION_TYPE_CD
                                        , EVENT_DS
                                        , RECOMMENDATION_DS
                                        , NOTE
                                        , DETECTED_TS
                                        , SENT_TS
										, SYSTEM_NAME)
          VALUES   (V_LOG_EVENT_ID
                  , V_ERROR_CD
                  , V_ENGINE_NAME
                  , V_JOB_NAME
                  , V_JOB_ID
                  , V_SEVERITY
                  , V_NOTIFICATION_TYPE_CD
                  , V_EVENT_DS
                  , V_RECOMMENDATION_DS
                  , V_NOTE
                  , V_DETECTED_TS
                  , V_SENT_TS
				  , V_SYSTEM_NAME);


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
    END SP_SAVE_STAT_LOG_MESSAGE_HIST;

    PROCEDURE SP_SAVE_CTRL_NOTIFICATION(JOB_NAME_IN IN CTRL_NOTIFICATION.JOB_NAME%TYPE
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SAVE_CTRL_NOTIFICATION
        IN parameters:
                       JOB_NAME_IN
                       DEBUG_IN
        OUT parameters:
                       EXIT_CD - procedure exit code (0 - OK)
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        Called from:
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-02-20
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                CONSTANT VARCHAR2(64) := 'SP_SAVE_CTRL_NOTIFICATION';
        -- local variables
        V_STEP                     VARCHAR2(1024);
        V_ALL_DBG_INFO             PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID              INTEGER := 0;

        V_JOB_NAME                 CTRL_NOTIFICATION.JOB_NAME%TYPE;
        V_NOTIFICATION_ENABLED     CTRL_NOTIFICATION.NOTIFICATION_ENABLED%TYPE;
        V_NOTIFICATION_CD          CTRL_NOTIFICATION.NOTIFICATION_CD%TYPE;
        V_AVG_DURARION_TOLERANCE   CTRL_NOTIFICATION.AVG_DURARION_TOLERANCE%TYPE;
        V_AVG_END_TM_TOLERANCE     CTRL_NOTIFICATION.AVG_END_TM_TOLERANCE%TYPE;
        V_CHECKED_STATUS           CTRL_NOTIFICATION.CHECKED_STATUS%TYPE;
        V_MAX_N_RUN                CTRL_NOTIFICATION.MAX_N_RUN%TYPE;
        V_ERROR_CD                 CTRL_NOTIFICATION.ERROR_CD%TYPE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_JOB_NAME := JOB_NAME_IN;
        V_STEP := 'get notification is enablled';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_NOTIFICATION_ENABLED := PCKG_FWRK.F_GET_CTRL_PARAMETERS('NOTIFICATION_ENABLED_DFLT', 'PARAM_VAL_INT');
        V_STEP := 'get notification cd';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_NOTIFICATION_CD := PCKG_FWRK.F_GET_CTRL_NOTIFICATION_TYPES('OPERATOR', 'notification_type_cd');
        V_CHECKED_STATUS := NULL;
        V_MAX_N_RUN := NULL;
        V_STEP := 'get error cd';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_ERROR_CD := UPPER(PCKG_FWRK.F_GET_CTRL_PARAMETERS('NOTIFICATION_DFLT', 'PARAM_VAL_CHAR'));

        DELETE FROM   CTRL_NOTIFICATION
              WHERE   JOB_NAME = JOB_NAME_IN;

        IF UPPER(PCKG_FWRK.F_GET_CTRL_PARAMETERS('NOTIFICATION_DFLT', 'PARAM_VAL_CHAR')) = UPPER('AVG_DURATION')
        THEN
            V_STEP := 'get avg duration tolerance';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_AVG_DURARION_TOLERANCE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_DURATION_TOLERANCE', 'PARAM_VAL_INT');
        ELSE
            V_STEP := 'get avg duration tolerance is null';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_AVG_DURARION_TOLERANCE := NULL;
        END IF;

        IF UPPER(PCKG_FWRK.F_GET_CTRL_PARAMETERS('NOTIFICATION_DFLT', 'PARAM_VAL_CHAR')) = UPPER('AVG_END_TM')
        THEN
            V_STEP := 'get avg tm tolerance';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_AVG_END_TM_TOLERANCE := PCKG_FWRK.F_GET_CTRL_PARAMETERS('AVG_END_TM_TOLERANCE', 'PARAM_VAL_INT');
        ELSE
            V_STEP := 'get avg tm tolerance is null';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_AVG_END_TM_TOLERANCE := NULL;
        END IF;

        V_STEP := 'insert into ctrl_notification';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO CTRL_NOTIFICATION(JOB_NAME
                                    , NOTIFICATION_ENABLED
                                    , NOTIFICATION_CD
                                    , AVG_DURARION_TOLERANCE
                                    , AVG_END_TM_TOLERANCE
                                    , CHECKED_STATUS
                                    , MAX_N_RUN
                                    , ERROR_CD)
          VALUES   (V_JOB_NAME
                  , V_NOTIFICATION_ENABLED
                  , V_NOTIFICATION_CD
                  , V_AVG_DURARION_TOLERANCE
                  , V_AVG_END_TM_TOLERANCE
                  , V_CHECKED_STATUS
                  , V_MAX_N_RUN
                  , V_ERROR_CD);


        --last steps in procedure
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
        --            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
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
    END SP_SAVE_CTRL_NOTIFICATION;


    FUNCTION F_GET_STATUS_FINISHED(STATUS_IN INTEGER)
        RETURN INTEGER
    IS
        /******************************************************************************
        Object type: UDF
        Name:  F_GET_STATUS_FINNISHED
        IN parameters:
                       STATUS_IN
        OUT parameters:
                       RETURN INTEGER
        Calling: N/A
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Marcel Samek
        Date:  2010-02-16
        -------------------------------------------------------------------------------
        Description: UDF returns finished status code : 1=staus id means finished
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME         CONSTANT VARCHAR2(64) := 'F_GET_STATUS_FINISHED';
        -- local variables
        V_STEP              VARCHAR2(1024);
        V_ALL_DBG_INFO      PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID       INTEGER := 0;
        EXIT_CD             NUMBER;
        ERRMSG_OUT          VARCHAR2(2048);
        ERRCODE_OUT         NUMBER;
        ERRLINE_OUT         VARCHAR2(2048);
        V_NUMBER_OF_STATS   INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_STEP := 'get number of stats';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT(CJS.STATUS)
          INTO   V_NUMBER_OF_STATS
          FROM   CTRL_JOB_STATUS CJS
         WHERE   CJS.FINISHED = 1
             AND CJS.STATUS = STATUS_IN;

        IF V_NUMBER_OF_STATS > 0
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
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
            RETURN -1;
        WHEN OTHERS
        THEN
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
            RETURN -1;
    END F_GET_STATUS_FINISHED;

    FUNCTION F_GET_CTRL_PARAMETERS(PARAM_NAME_IN VARCHAR2, COLUMN_IN VARCHAR2, ENGINE_IN INTEGER := -1)
        RETURN VARCHAR2
    IS
        /******************************************************************************
        Object type: UDF
        Name:  F_GET_CTRL_PARAMETERS
        IN parameters:
                       PARAM_NAME_IN
                       COLUMN_IN
        OUT parameters:
                       RETURN VARCHAR2
        Calling: N/A
        -------------------------------------------------------------------------------
        Version:        1.1
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Marcel Samek
        Date:  2010-02-20
        -------------------------------------------------------------------------------
        Description: UDF returns value from ctrl_parameters table for requested param
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2013-09-09
        Modification: PARAM_VAL_DATE - PARAM_VAL_DATE independet output format of param_val_date - DD.MM.YYYY
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'F_GET_CTRL_PARAMETERS';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        EXIT_CD          NUMBER;
        ERRMSG_OUT       VARCHAR2(2048);
        ERRCODE_OUT      NUMBER;
        ERRLINE_OUT      VARCHAR2(2048);
        V_QUERY          VARCHAR2(1024);
        V_OUT_VALUE      VARCHAR2(1024);
        V_IS_ENG_ID      VARCHAR2(1024);
        V_COLUMN_IN      VARCHAR2(1024);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;

        IF ENGINE_IN > -1
        THEN
            V_IS_ENG_ID := 'AND cpa.param_cd = ' || ENGINE_IN;
        END IF;

        --MBU: to ensure united date output
        IF UPPER(COLUMN_IN)= 'PARAM_VAL_DATE' THEN
            V_COLUMN_IN := 'TO_CHAR(cpa.PARAM_VAL_DATE,''DD.MM.YYYY'')';
        ELSE
            V_COLUMN_IN := 'cpa.' || COLUMN_IN;
        END IF;

        V_QUERY :=
               'SELECT '
            || V_COLUMN_IN
            || '
          FROM   CTRL_PARAMETERS cpa
         WHERE   upper(cpa.PARAM_NAME) = upper('''
            || PARAM_NAME_IN
            || ''')
         '
            || V_IS_ENG_ID;

        V_STEP := 'get value from ctrl_params';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        EXECUTE IMMEDIATE V_QUERY INTO   V_OUT_VALUE;

        RETURN V_OUT_VALUE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF UPPER(COLUMN_IN) = 'PARAM_VAL_INT'
            THEN
                RETURN 0;
            ELSE
                IF UPPER(COLUMN_IN) = 'PARAM_VAL_CHAR'  THEN
                  RETURN '';
                ELSE
                  RETURN '1.1.1900';
                END IF;
            END IF;

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
            IF UPPER(COLUMN_IN) = 'PARAM_VAL_INT'
            THEN
                RETURN 0;
            ELSE
                RETURN '1.1.1900';
            END IF;

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
    END F_GET_CTRL_PARAMETERS;

    FUNCTION F_GET_CTRL_NOTIFICATION_TYPES(NOTIFICATION_TYPE_DS_IN VARCHAR2, COLUMN_IN VARCHAR2)
        RETURN VARCHAR2
    IS
        /******************************************************************************
        Object type: UDF
        Name:  F_GET_CTRL_NOTIFICATION_TYPES
        IN parameters:
                       NOTIFICATION_TYPE_DS_IN
                       COLUMN_IN
        OUT parameters:
                       RETURN VARCHAR2
        Calling: N/A
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Marcel Samek
        Date:  2010-02-20
        -------------------------------------------------------------------------------
        Description: UDF returns notification type for requested column/type
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'F_GET_CTRL_NOTIFICATION_TYPES';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        EXIT_CD          NUMBER;
        ERRMSG_OUT       VARCHAR2(2048);
        ERRCODE_OUT      NUMBER;
        ERRLINE_OUT      VARCHAR2(2048);
        V_QUERY          VARCHAR2(1024);
        V_OUT_VALUE      VARCHAR2(1024);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_QUERY :=
               'SELECT cnt.'
            || COLUMN_IN
            || '
          FROM   CTRL_NOTIFICATION_TYPES cnt
         WHERE   upper(cnt.notification_type_ds) = upper('''
            || NOTIFICATION_TYPE_DS_IN
            || ''')';
        V_STEP := 'get out value from CTRL_NOTIFICATION_TYPES';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        EXECUTE IMMEDIATE V_QUERY INTO   V_OUT_VALUE;

        RETURN V_OUT_VALUE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
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
            RETURN -1;
        WHEN OTHERS
        THEN
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
            RETURN -1;
    END F_GET_CTRL_NOTIFICATION_TYPES;

    FUNCTION F_GET_SESS_JOB_PARAM_STAT(JOB_ID_IN VARCHAR2, COLUMN_IN VARCHAR2)
        RETURN VARCHAR2
    IS
        /******************************************************************************
        Object type: UDF
        Name:  F_GET_SESS_JOB_PARAM_STAT
        IN parameters:
                       JOB_ID_IN
                       COLUMN_IN
        OUT parameters:
                       RETURN VARCHAR2
        Calling: N/A
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Marcel Samek
        Date:  2010-02-20
        -------------------------------------------------------------------------------
        Description: UDF returns current status of param for requested job
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'F_GET_SESS_JOB_PARAM_STAT';
        -- local variables
        V_STEP           VARCHAR2(1024);
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
        EXIT_CD          NUMBER;
        ERRMSG_OUT       VARCHAR2(2048);
        ERRCODE_OUT      NUMBER;
        ERRLINE_OUT      VARCHAR2(2048);
        V_QUERY          VARCHAR2(1024);
        V_OUT_VALUE      VARCHAR2(1024);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_QUERY := 'SELECT sj.' || COLUMN_IN || '
          FROM   sess_job sj
         WHERE   sj.job_id = ' || JOB_ID_IN;
        V_STEP := 'get value from sess_job';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        EXECUTE IMMEDIATE V_QUERY INTO   V_OUT_VALUE;

        RETURN V_OUT_VALUE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
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
            RETURN -1;
        WHEN OTHERS
        THEN
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
            RETURN -1;
    END F_GET_SESS_JOB_PARAM_STAT;

    PROCEDURE SP_FWRK_CHECK_SOURCE_DELIVERY (
      DEBUG_IN      IN            INTEGER := 0,
      EXIT_CD          OUT NOCOPY NUMBER,
      ERRMSG_OUT       OUT NOCOPY VARCHAR2,
      ERRCODE_OUT      OUT NOCOPY NUMBER,
      ERRLINE_OUT      OUT NOCOPY VARCHAR2)
      IS
      /******************************************************************************
      Object type:   PROCEDURE
      Name:    SP_FWRK_CHECK_SOURCE_DELIVERY
      IN parameters:
                     DEBUG_IN
      OUT parameters:
                     EXIT_CD - procedure exit code (0 - OK)
                     ERRMSG_OUT
                     ERRCODE_OUT
                     ERRLINE_OUT
      Called from:
      Calling:   None
      -------------------------------------------------------------------------------
      Version:        1.0
      -------------------------------------------------------------------------------
      Project:   PDC
      Author:   Teradata - Milan Budka
      Date:    2013-09-09
      -------------------------------------------------------------------------------
      Description:
      -------------------------------------------------------------------------------
      Modified:
      Version:
      Date:
      Modification:
      *******************************************************************************/
      --constants
      C_PROC_NAME          CONSTANT VARCHAR2 (64) := 'SP_FWRK_CHECK_SOURCE_DELIVERY';
      -- local variables
      V_STEP                        VARCHAR2 (1024);
      V_ALL_DBG_INFO                PCKG_PLOG.T_VARCHAR2;
      V_DBG_INFO_ID                 INTEGER := 0;

      V_ALERT_ZONE_START_TM         INTEGER;
      V_ALERT_ZONE_END_TM           INTEGER;
      V_CRITICAL                    INTEGER;
      V_RELATED_TO_INITIALIZATION   INTEGER;
      V_INIT_END_TS                 TIMESTAMP;

      V_CURRENT_HOUR                INTEGER;
      V_CURRENT_HOUR_SNIFFER_JOB    INTEGER;
      V_DELIVERED                   INTEGER;
      V_SKIPPED                     INTEGER;
      V_UNPROCESSED                 INTEGER;
      V_PROBLEM_EXTRACTS            VARCHAR2 (2048);
      V_ERROR_CD					VARCHAR2 (2048);
	
      CURSOR SOURCE_TO_NOTIFY
      IS
          SELECT SOURCE_ID,
              SOURCE_NM,
              J.JOB_ID AS SNIFFER_JOB_ID,
              J.LOAD_DATE AS SNIFFER_LOAD_DATE,
              J.JOB_NAME AS SNIFFER_JOB_NAME,
              JT.STATUS_TS AS SNIFFER_LAST_RUN,
              J.ENGINE_ID,
              J.SYSTEM_NAME
          FROM CTRL_SOURCE S
          LEFT JOIN SESS_JOB J ON S.SNIFFER_JOB_NAME = J.JOB_NAME
          LEFT JOIN (
            SELECT JOB_ID,MAX(STATUS_TS) AS STATUS_TS FROM SESS_STATUS SS
            INNER JOIN CTRL_JOB_STATUS CJS ON SS.STATUS = CJS.STATUS AND CJS.RUNABLE NOT IN ('RUNNING','RUNABLE')
            GROUP BY JOB_ID
          )JT
          ON JT.JOB_ID = J.JOB_ID
          WHERE NOTIFICATION_ENABLED = 1;
      BEGIN

      FOR R_CURR_SOURCE IN SOURCE_TO_NOTIFY
        LOOP  -- LOOP SOURCE

         V_STEP := 'curently working on ' || R_CURR_SOURCE.SOURCE_NM;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

         IF R_CURR_SOURCE.SNIFFER_LOAD_DATE IS NULL
         THEN  --IF LOAD_DATE IS NULL = SOURCE IS NOT LOADED NOW
            V_STEP := 'load date is null for ' || R_CURR_SOURCE.SOURCE_NM;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO (V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            GOTO check_next_source_system;
         END IF;

         SELECT COUNT (*)
           INTO V_DELIVERED
           FROM STAT_SRCTABLE_LOAD_HIST
          WHERE     SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
                AND LOAD_DATE = R_CURR_SOURCE.SNIFFER_LOAD_DATE;

         SELECT COUNT (*)
           INTO V_SKIPPED
           FROM STAT_SRCTABLE_LOAD_HIST
          WHERE     SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
                AND LOAD_DATE = R_CURR_SOURCE.SNIFFER_LOAD_DATE
                AND LOAD_STATUS = 'SKIPPED';

         IF V_SKIPPED > 0
         THEN
            V_STEP := 'log skipped extracts for ' || R_CURR_SOURCE.SOURCE_NM;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO (V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            DECLARE
               CURSOR SKIPPED_CUR
               IS
                  SELECT COMMON_TABLE_NAME
                    FROM STAT_SRCTABLE_LOAD_HIST
                   WHERE     SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
                         AND LOAD_DATE = R_CURR_SOURCE.SNIFFER_LOAD_DATE
                         AND LOAD_STATUS = 'SKIPPED';
            BEGIN
               V_PROBLEM_EXTRACTS := 'Following extract/s from '
                  || R_CURR_SOURCE.SOURCE_NM
                  || ' have been skipped (not valid or delivered):';
              <<extracts_loop_1>>
               FOR R_SKIPPED_CUR IN SKIPPED_CUR
               LOOP
                  IF (  LENGTH (V_PROBLEM_EXTRACTS)
                      + LENGTH (R_SKIPPED_CUR.COMMON_TABLE_NAME)) <= 1000
                  THEN
                     V_PROBLEM_EXTRACTS :=
                           V_PROBLEM_EXTRACTS
                        || R_SKIPPED_CUR.COMMON_TABLE_NAME || ',';
                  ELSE
                     V_PROBLEM_EXTRACTS := V_PROBLEM_EXTRACTS || '....';
                     exit extracts_loop_1;
                  END IF;
               END LOOP;
                V_PROBLEM_EXTRACTS := substr(V_PROBLEM_EXTRACTS,1,LENGTH(V_PROBLEM_EXTRACTS)-1);
            END;

            PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST (
               EVENT_TS_IN                 => CURRENT_TIMESTAMP,
               NOTIFICATION_CD_IN          => 1,
               LOAD_DATE_IN                => R_CURR_SOURCE.SNIFFER_LOAD_DATE,
               JOB_NAME_IN                 => R_CURR_SOURCE.SNIFFER_JOB_NAME,
               JOB_ID_IN                   => R_CURR_SOURCE.SNIFFER_JOB_ID,
               SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD('SKIPPED_EXTRACTS'),2),
               ERROR_CD_IN                 => 'SKIPPED_EXTRACTS',
               EVENT_CD_IN                 => NULL,
               TRACKING_DURATION_IN        => NULL,
               EVENT_DS_IN                 => NULL,
               START_TS_IN                 => NULL,
               END_TS_IN                   => NULL,
               LAST_STATUS_IN              => NULL,
               N_RUN_IN                    => NULL,
               CHECKED_STATUS_IN           => NULL,
               MAX_N_RUN_IN                => NULL,
               AVG_DURARION_TOLERANCE_IN   => NULL,
               AVG_END_TM_TOLERANCE_IN     => NULL,
               ACTUAL_VALUE_IN             => NULL,
               THRESHOLD_IN                => NULL,
               OBJECT_NAME_IN              => NULL,
               NOTE_IN                     => V_PROBLEM_EXTRACTS,
               SENT_TS_IN                  => NULL,
               DWH_DATE_IN                 => R_CURR_SOURCE.SNIFFER_LOAD_DATE,
               ENGINE_ID_IN                => R_CURR_SOURCE.ENGINE_ID,
               RECOMMENDATION_DS_IN        => NULL,
			   SYSTEM_NAME_IN			  => R_CURR_SOURCE.SYSTEM_NAME,			
               DEBUG_IN                    => DEBUG_IN,
               EXIT_CD                     => EXIT_CD,
               ERRMSG_OUT                  => ERRMSG_OUT,
               ERRCODE_OUT                 => ERRCODE_OUT,
               ERRLINE_OUT                 => ERRLINE_OUT);
         END IF;

		
         IF V_DELIVERED > 0
         THEN
          V_STEP := 'stop source ' || R_CURR_SOURCE.SOURCE_NM ||' is already delivered';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
          GOTO check_next_source_system;
         END IF;

         --set initial value--
         V_ALERT_ZONE_START_TM := -1;
         V_ALERT_ZONE_END_TM := -1;
         V_CRITICAL := -1;
         V_RELATED_TO_INITIALIZATION := -1;
         DECLARE
            CURSOR PLAN_CUR
            IS
                 SELECT RUNPLAN,
                        ALERT_ZONE_START_TM,
                        ALERT_ZONE_END_TM,
                        NOWAIT_ALERT_ZONE_END_TM,
                        CRITICAL,
                        RELATED_TO_INITIALIZATION
                   FROM CTRL_SOURCE_PLAN_REF
                  WHERE SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
               ORDER BY CRITICAL DESC;
         BEGIN
            FOR R_PLAN_CUR IN PLAN_CUR
            LOOP
               V_STEP := 'Opening PLAN_CUR';
               V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
               V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
				
               IF PCKG_TOOLS.F_DATE_MATCH_RUNPLAN (
                     R_CURR_SOURCE.SNIFFER_LOAD_DATE,
                     R_PLAN_CUR.RUNPLAN) = 1
               THEN
                  V_ALERT_ZONE_START_TM :=
                     GREATEST (R_PLAN_CUR.ALERT_ZONE_START_TM, V_ALERT_ZONE_START_TM);
                  V_ALERT_ZONE_END_TM :=
                     GREATEST (R_PLAN_CUR.ALERT_ZONE_END_TM,V_ALERT_ZONE_END_TM);
                  V_CRITICAL := GREATEST (R_PLAN_CUR.CRITICAL, V_CRITICAL);
                  V_RELATED_TO_INITIALIZATION :=
                     GREATEST (R_PLAN_CUR.RELATED_TO_INITIALIZATION, V_RELATED_TO_INITIALIZATION);
               END IF;
            END LOOP;

            IF V_CRITICAL = -1
            THEN
              V_STEP := 'no runplan for ' || R_CURR_SOURCE.SOURCE_NM ||
                ' and load date: '|| TO_CHAR(R_CURR_SOURCE.SNIFFER_LOAD_DATE,'DD.MM.YYYY HH24:MI:SS');
              V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
              V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
              GOTO check_next_source_system;
            END IF;
         END;

         V_STEP := 'getting current load hour and current sniffer hour acccording to base';
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

         IF V_RELATED_TO_INITIALIZATION = 1
         THEN
            SELECT PARAM_VAL_TS
              INTO V_INIT_END_TS
              FROM CTRL_PARAMETERS
             WHERE     PARAM_NAME = 'INITIALIZATION_END'
                   AND PARAM_CD = R_CURR_SOURCE.ENGINE_ID;


            --V_CURRENT_HOUR--
            SELECT     EXTRACT (DAY FROM (CURRENT_TIMESTAMP - V_INIT_END_TS))* 24
                   + EXTRACT (HOUR FROM (CURRENT_TIMESTAMP - V_INIT_END_TS))
            INTO V_CURRENT_HOUR
            FROM DUAL;

            /*V_CURRENT_HOUR_SNIFFER_JOB IS CALCULATED, BECAUSE IT COULD HAPPEN THAT SNIFFER JOB
              WAS NOT RUNNING FOR FEW HOURS BEFORE ALERT_ZONE START AND
            	SOME COLD BE DELIVERED*/
            SELECT     EXTRACT (DAY FROM (  R_CURR_SOURCE.SNIFFER_LAST_RUN - V_INIT_END_TS))* 24
                   + EXTRACT (HOUR FROM (  R_CURR_SOURCE.SNIFFER_LAST_RUN - V_INIT_END_TS))
            INTO V_CURRENT_HOUR_SNIFFER_JOB
            FROM DUAL;
         ELSE
            --V_CURRENT_HOUR--
            SELECT     EXTRACT (DAY FROM (  CURRENT_TIMESTAMP - R_CURR_SOURCE.SNIFFER_LOAD_DATE))* 24
                   + EXTRACT (HOUR FROM (  CURRENT_TIMESTAMP - R_CURR_SOURCE.SNIFFER_LOAD_DATE))
            INTO V_CURRENT_HOUR
            FROM DUAL;

            --V_CURRENT_HOUR_SNIFFER_JOB--
            SELECT     EXTRACT ( DAY FROM (  R_CURR_SOURCE.SNIFFER_LAST_RUN - R_CURR_SOURCE.SNIFFER_LOAD_DATE))* 24
                   + EXTRACT ( HOUR FROM (  R_CURR_SOURCE.SNIFFER_LAST_RUN - R_CURR_SOURCE.SNIFFER_LOAD_DATE))
              INTO V_CURRENT_HOUR_SNIFFER_JOB
              FROM DUAL;
         END IF;

         --if alert zone is broken and sniffer was runnig after break and V_ALERT_ZONE_START_TM<>V_ALERT_ZONE_END_TM
         IF (V_CURRENT_HOUR >= V_ALERT_ZONE_START_TM
             AND V_CURRENT_HOUR_SNIFFER_JOB >= V_ALERT_ZONE_START_TM AND V_ALERT_ZONE_START_TM<>V_ALERT_ZONE_END_TM)
         THEN
          V_STEP := 'getting number of unprocessed extracts for ' || R_CURR_SOURCE.SOURCE_NM;
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
			
          SELECT COUNT (*)
            INTO V_UNPROCESSED
          FROM (
            SELECT COMMON_TABLE_NAME
            FROM CTRL_SRCTABLE CST
            WHERE CST.SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
            MINUS
            SELECT COMMON_TABLE_NAME
            FROM SESS_SRCTABLE
            WHERE SOURCE_ID = R_CURR_SOURCE.SOURCE_ID);

          IF V_UNPROCESSED > 0 THEN
            V_STEP := 'get list of missing extracts ' || R_CURR_SOURCE.SOURCE_NM;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            DECLARE CURSOR UNPROCESS_CUR
                IS
                 SELECT COMMON_TABLE_NAME
                   FROM CTRL_SRCTABLE CST
                  WHERE CST.SOURCE_ID = R_CURR_SOURCE.SOURCE_ID
                 MINUS
                 SELECT COMMON_TABLE_NAME
                   FROM SESS_SRCTABLE
                  WHERE SOURCE_ID = R_CURR_SOURCE.SOURCE_ID;
            BEGIN
              V_PROBLEM_EXTRACTS :='Following extract/s from '
              || R_CURR_SOURCE.SOURCE_NM
              || ' have not be delivered on time: ';
              <<extracts_loop_2>>
              FOR R_UNPROCESS_CUR IN UNPROCESS_CUR
              LOOP
                IF (  LENGTH (V_PROBLEM_EXTRACTS)
                  + LENGTH (R_UNPROCESS_CUR.COMMON_TABLE_NAME)) <=1000
                THEN
                  V_PROBLEM_EXTRACTS :=V_PROBLEM_EXTRACTS
                    || R_UNPROCESS_CUR.COMMON_TABLE_NAME
                    || ',';
                ELSE
                  V_PROBLEM_EXTRACTS := V_PROBLEM_EXTRACTS || '....';
                  exit extracts_loop_2;
                END IF;
              END LOOP;
              V_PROBLEM_EXTRACTS := substr(V_PROBLEM_EXTRACTS,1,LENGTH(V_PROBLEM_EXTRACTS)-1);
            END;

            IF V_CRITICAL=1 THEN
              V_ERROR_CD := 'CRITICAL_EXTRACTS_DELIVERY';
            ELSE
              V_ERROR_CD := 'EXTRACTS_DELIVERY';
            END IF;
			   				
            --SAVE MESSAGE--
            PCKG_FWRK.SP_SAVE_STAT_LOG_EVENT_HIST (
                  EVENT_TS_IN                 => CURRENT_TIMESTAMP,
                  NOTIFICATION_CD_IN          => 1,
                  LOAD_DATE_IN                => R_CURR_SOURCE.SNIFFER_LOAD_DATE,
                  JOB_NAME_IN                 => R_CURR_SOURCE.SNIFFER_JOB_NAME,
                  JOB_ID_IN                   => R_CURR_SOURCE.SNIFFER_JOB_ID,
                  SEVERITY_LEVEL_CD_IN        => NVL(PCKG_FWRK.F_GET_SEVERITY_LEVEL_CD(V_ERROR_CD),2),
                  ERROR_CD_IN                 => V_ERROR_CD,
                  EVENT_CD_IN                 => NULL,
                  TRACKING_DURATION_IN        => NULL,
                  EVENT_DS_IN                 => NULL,
                  START_TS_IN                 => NULL,
                  END_TS_IN                   => NULL,
                  LAST_STATUS_IN              => NULL,
                  N_RUN_IN                    => NULL,
                  CHECKED_STATUS_IN           => NULL,
                  MAX_N_RUN_IN                => NULL,
                  AVG_DURARION_TOLERANCE_IN   => NULL,
                  AVG_END_TM_TOLERANCE_IN     => NULL,
                  ACTUAL_VALUE_IN             => NULL,
                  THRESHOLD_IN                => NULL,
                  OBJECT_NAME_IN              => NULL,
                  NOTE_IN                     => V_PROBLEM_EXTRACTS,
                  SENT_TS_IN                  => NULL,
                  DWH_DATE_IN                 => R_CURR_SOURCE.SNIFFER_LOAD_DATE,
                  ENGINE_ID_IN                => R_CURR_SOURCE.ENGINE_ID,
                  RECOMMENDATION_DS_IN        => NULL,
				  SYSTEM_NAME_IN			  => R_CURR_SOURCE.SYSTEM_NAME,
                  DEBUG_IN                    => DEBUG_IN,
                  EXIT_CD                     => EXIT_CD,
                  ERRMSG_OUT                  => ERRMSG_OUT,
                  ERRCODE_OUT                 => ERRCODE_OUT,
                  ERRLINE_OUT                 => ERRLINE_OUT);
            END IF;
        END IF;
      <<check_next_source_system>>
          V_STEP := 'going to check next source system';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
      END LOOP; -- LOOP SOURCE

      EXIT_CD := 0;
      ERRMSG_OUT := NVL (ERRMSG_OUT, 'FINISHED OK');

      ERRCODE_OUT := NVL (ERRCODE_OUT, TO_CHAR (EXIT_CD));

      ERRLINE_OUT := NVL (ERRLINE_OUT, -1);

      IF DEBUG_IN = 1
      THEN
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := EXIT_CD;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRMSG_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRCODE_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRLINE_OUT;

         PCKG_PLOG.INFO (V_STEP);
         PCKG_PLOG.DEBUG ();
         PCKG_PLOG.SETPROCPARAMS (PROCEDURE_NAME_IN   => C_PROC_NAME,
                                  ALL_ARGUMENTS_IN    => V_ALL_DBG_INFO);
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         EXIT_CD := -1;

         ERRMSG_OUT := SUBSTR (SQLERRM, 1, 1024);

         ERRCODE_OUT := SQLCODE;

         ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := EXIT_CD;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRMSG_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRCODE_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRLINE_OUT;

         PCKG_PLOG.INFO (V_STEP);
         PCKG_PLOG.FATAL ();
         PCKG_PLOG.SETPROCPARAMS (PROCEDURE_NAME_IN   => C_PROC_NAME,
                                  ALL_ARGUMENTS_IN    => V_ALL_DBG_INFO);
      WHEN OTHERS
      THEN
         EXIT_CD := -2;

         ERRMSG_OUT := SUBSTR (SQLERRM, 1, 1024);

         ERRCODE_OUT := SQLCODE;

         ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := EXIT_CD;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRMSG_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRCODE_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRLINE_OUT;

         PCKG_PLOG.INFO (V_STEP);
         PCKG_PLOG.FATAL ();
         PCKG_PLOG.SETPROCPARAMS (PROCEDURE_NAME_IN   => C_PROC_NAME,
                                  ALL_ARGUMENTS_IN    => V_ALL_DBG_INFO);
   END SP_FWRK_CHECK_SOURCE_DELIVERY;

   FUNCTION F_GET_SEVERITY_LEVEL_CD (ERROR_CD_IN VARCHAR2)
      RETURN NUMBER
   IS
      /******************************************************************************
      Object type: UDF
      Name:  F_GET_SEVERITY_LEVEL_CD
      IN parameters:
                     ERORR_CD_IN
      OUT parameters:
                     RETURN NUMBER
      Calling: N/A
      -------------------------------------------------------------------------------
      Version:        1.0
      -------------------------------------------------------------------------------
      Project: PDC
      Author:  Teradata - Milan Budka
      Date:  2013-09-12
      -------------------------------------------------------------------------------
      Description: UDF returns severity level number
      -------------------------------------------------------------------------------
      Modified:
      Version:
      Date:
      Modification:
      *******************************************************************************/
      --constants
      C_PROC_NAME   CONSTANT VARCHAR2 (64) := 'F_GET_SEVERITY_LEVEL_CD';
      -- local variables
      V_STEP                 VARCHAR2 (1024);
      V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
      V_DBG_INFO_ID          INTEGER := 0;
      EXIT_CD                NUMBER;
      ERRMSG_OUT             VARCHAR2 (2048);
      ERRCODE_OUT            NUMBER;
      ERRLINE_OUT            VARCHAR2 (2048);
      V_SEVERITY_LEVEL_CD_OUT NUMBER;
   BEGIN
      V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
      V_ALL_DBG_INFO (V_DBG_INFO_ID) :='Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
      V_STEP := 'get severity level';
      V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
      V_ALL_DBG_INFO (V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

      SELECT SEVERITY_LEVEL_CD
        INTO V_SEVERITY_LEVEL_CD_OUT
        FROM CTRL_NOTIFICATION_SEVERITY
       WHERE ERROR_CD=ERROR_CD_IN;
	  RETURN V_SEVERITY_LEVEL_CD_OUT;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         EXIT_CD := -1;

         ERRMSG_OUT := SUBSTR (SQLERRM, 1, 1024);

         ERRCODE_OUT := SQLCODE;

         ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;

         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := EXIT_CD;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRMSG_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRCODE_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRLINE_OUT;

         PCKG_PLOG.INFO (V_STEP);
         PCKG_PLOG.FATAL ();
         PCKG_PLOG.SETPROCPARAMS (PROCEDURE_NAME_IN   => C_PROC_NAME,
                                  ALL_ARGUMENTS_IN    => V_ALL_DBG_INFO);
         RETURN -1;
      WHEN OTHERS
      THEN
         EXIT_CD := -2;

         ERRMSG_OUT := SUBSTR (SQLERRM, 1, 1024);

         ERRCODE_OUT := SQLCODE;

         ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;

         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := EXIT_CD;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRMSG_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRCODE_OUT;
         V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
         V_ALL_DBG_INFO (V_DBG_INFO_ID) := ERRLINE_OUT;

         PCKG_PLOG.INFO (V_STEP);
         PCKG_PLOG.FATAL ();
         PCKG_PLOG.SETPROCPARAMS (PROCEDURE_NAME_IN   => C_PROC_NAME,
                                  ALL_ARGUMENTS_IN    => V_ALL_DBG_INFO);
         RETURN -1;
   END F_GET_SEVERITY_LEVEL_CD;

END;

