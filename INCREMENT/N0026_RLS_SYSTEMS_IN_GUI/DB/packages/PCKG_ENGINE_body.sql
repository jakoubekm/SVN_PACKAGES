
  CREATE OR REPLACE PACKAGE BODY "PCKG_ENGINE"
AS
    PROCEDURE SP_ENG_GET_JOB_LIST(ENGINE_ID_IN IN NUMBER
                                , SYSTEM_NAME_IN IN VARCHAR2
                                , DEBUG_IN IN   INTEGER:= 0
                                , CSR   OUT NOCOPY REFCSR
                                , EXIT_CD   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_GET_JOB_LIST
        IN parameters:
                        ENGINE_ID_IN
                        DEBUG_IN
        OUT parameters:
                        CSR
                        exit_cd - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2010-01-26
        -------------------------------------------------------------------------------
        Description: Get job list for Engine
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_GET_JOB_LIST';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_LOAD_DATE        DATE;
        V_APPLICATION_ID   INTEGER;
        V_POSSIBLE_JOBS    INTEGER;
        V_RUNABLE_JOBS     INTEGER;
        V_SKIPPED_JOBS     INTEGER;
        V_STARTED_JOBS     INTEGER;
        V_RUNNING_JOBS     INTEGER;
        V_CURRENT_HOUR     INTEGER;
        V_JOB_ID           INTEGER;
        V_JOB_NAME         VARCHAR2(128);
        V_TASK_TYPE        VARCHAR2(128);
        V_TASK_SUBTYPE     VARCHAR2(128);
        V_TOUGHNESS        INTEGER;
        V_SEQ              INTEGER;
        V_PRIORITY         INTEGER;
        V_STATUS           INTEGER;
        V_JOB_TYPE         VARCHAR2(32);
        V_CMD_LINE         VARCHAR2(1024);
        V_EXECUTABLE       INTEGER;
        V_PROCESS_STATUS   VARCHAR2(128);
        V_CONFLICT         INTEGER;
        V_RETENTION_PERIOD  INTEGER;
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
		V_TOUGHNESS_CONFLICT INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Deleting from table TEMP_ENG_QUEUE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   TEMP_ENG_QUEUE
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Deleting from table TEMP_ENG_JOB_READY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   TEMP_ENG_JOB_READY
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Deleting from table TEMP_ENG_JOB_RUNNIG';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   TEMP_ENG_JOB_RUNNING
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Deleting from table TEMP_ENG_JOB_POSSIBLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   TEMP_ENG_JOB_POSSIBLE
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking value of RETENTION_PERIOD parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_RETENTION_PERIOD
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_RETENTION_PERIOD'
             AND PARAM_CD = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. LOAD_DATE: ' || TO_CHAR(V_LOAD_DATE);

        V_STEP := 'Taking value of MAX_CONCURRENT_JOBS parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_POSSIBLE_JOBS
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_possible_jobs: ' || TO_CHAR(V_POSSIBLE_JOBS);

        V_STEP := 'Taking value of APPLICATION_ID parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_APPLICATION_ID
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. APPLICATION_ID: ' || TO_CHAR(V_APPLICATION_ID);

        V_STEP := 'Taking value of v_current_hour';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   MIN(24 * EXTRACT(DAY FROM INTERVAL) + EXTRACT(HOUR FROM INTERVAL)) AS CURRENT_HOUR
          INTO   V_CURRENT_HOUR
          FROM   (SELECT   CURRENT_TIMESTAMP - CAST(PARAM_VAL_DATE AS TIMESTAMP) AS INTERVAL
                    FROM   CTRL_PARAMETERS
                   WHERE   PARAM_NAME = 'LOAD_DATE'
                       AND PARAM_CD = ENGINE_ID_IN);

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_current_hour: ' || TO_CHAR(V_CURRENT_HOUR);

        V_STEP := 'Populating table TEMP_ENG_QUEUE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO TEMP_ENG_QUEUE(SEQ, QUEUE_NUMBER, ENGINE_ID)
            SELECT   ROW_NUMBER() OVER (ORDER BY NVL(LAST_UPDATE, TO_DATE('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS')) ASC) - 1 AS SEQ, QUEUE_NUMBER, ENGINE_ID
              FROM   SESS_QUEUE
             WHERE   AVAILABLE = 1
                 AND ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Populating table TEMP_ENG_JOB_RUNNING - running and failed jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO TEMP_ENG_JOB_RUNNING(JOB_ID
                                       , JOB_NAME
                                       , JOB_TYPE
                                       , TOUGHNESS
                                       , DATABASE_NAME
                                       , TABLE_NAME
                                       , LOCK_TYPE
                                       , JOB_CATEGORY
                                       , IS_RUNNING
                                       , ENGINE_ID
                                       , SYSTEM_NAME)
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.JOB_TYPE
                   , SJ.TOUGHNESS
                   , CJTR.DATABASE_NAME
                   , CJTR.TABLE_NAME
                   , CJTR.LOCK_TYPE
                   , SJ.JOB_CATEGORY
                   , CASE WHEN CJS.RUNABLE = 'RUNNING' THEN 1 ELSE 0 END AS IS_RUNNING
                   , SJ.ENGINE_ID
                   , SQ.SYSTEM_NAME
              FROM           SESS_JOB SJ
                         JOIN
                             CTRL_JOB_STATUS CJS
                         ON SJ.STATUS = CJS.STATUS
                        AND CJS.RUNABLE IN ('RUNNING', 'FAILED')
                        JOIN SESS_QUEUE SQ
                        ON SQ.job_id = SJ.job_id
                     LEFT JOIN
                         CTRL_JOB_TABLE_REF CJTR
                     ON SJ.JOB_NAME = CJTR.JOB_NAME
              where SJ.ENGINE_ID = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Counting number of running jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT(DISTINCT JOB_ID)
          INTO   V_RUNNING_JOBS
          FROM   TEMP_ENG_JOB_RUNNING
         WHERE   IS_RUNNING = 1
             AND ENGINE_ID = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_running_jobs: ' || TO_CHAR(V_RUNNING_JOBS);

        V_STEP := 'Counting number of jobs which can be launched';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_POSSIBLE_JOBS := V_POSSIBLE_JOBS - V_RUNNING_JOBS;

        IF V_POSSIBLE_JOBS < 0
        THEN
            V_POSSIBLE_JOBS := 0;
        END IF;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_possible_jobs: ' || TO_CHAR(V_POSSIBLE_JOBS);
        V_STARTED_JOBS := 0;
        V_SKIPPED_JOBS := 0;

        V_STEP := 'Updating CTRL_TASK_PARAMETERS - setting initial values';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_TASK_PARAMETERS
           SET   PARAM_VAL_INT_CURR = 0
         WHERE   ENGINE_ID = ENGINE_ID_IN
             /*AND (SYSTEM_NAME = SYSTEM_NAME_IN OR SYSTEM_NAME IS NULL) RECALCULATE FOR ALL SYSTEMS BELOW*/
             AND VALID_FROM <= V_CURRENT_HOUR
             AND VALID_TO > V_CURRENT_HOUR
             AND PARAM_TYPE IN ('PARALLELISM_CONTROL','TASK_MIN_CONTROL');

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;



        V_STEP := 'Cursor job_cur declaration and opening for task_parametr counting (running jobs)';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DECLARE
            CURSOR JOB_CUR
            IS
                  SELECT   TEJR.JOB_ID, TEJR.JOB_CATEGORY, CTP.TASK_TYPE, TEJR.toughness, TEJR.system_name
                    FROM       TEMP_ENG_JOB_RUNNING TEJR
                           JOIN
                               CTRL_TASK_PARAMETERS CTP
                           ON TEJR.JOB_CATEGORY = CTP.TASK_SUBTYPE
                          AND CTP.ENGINE_ID = ENGINE_ID_IN
                          AND TEJR.ENGINE_ID = ENGINE_ID_IN
                          AND TEJR.IS_RUNNING = 1
                          AND PARAM_TYPE = 'PARALLELISM_CONTROL'
                GROUP BY   TEJR.JOB_ID, TEJR.JOB_CATEGORY, CTP.TASK_TYPE, TEJR.toughness, TEJR.system_name;
        BEGIN -- Level_2
            FOR R1 IN JOB_CUR
            LOOP
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                V_TASK_SUBTYPE := R1.JOB_CATEGORY;
                V_TASK_TYPE := R1.TASK_TYPE;

                V_STEP := 'Updating CTRL_TASK_PARAMETERS task_subtype';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   CTRL_TASK_PARAMETERS
                   SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + R1.toughness
                 WHERE   TASK_SUBTYPE = V_TASK_SUBTYPE
                     AND ENGINE_ID = ENGINE_ID_IN
                     AND (SYSTEM_NAME = R1.SYSTEM_NAME OR SYSTEM_NAME IS NULL)
                     AND VALID_FROM <= V_CURRENT_HOUR
                     AND VALID_TO > V_CURRENT_HOUR
                     AND PARAM_TYPE = 'PARALLELISM_CONTROL';

                UPDATE   CTRL_TASK_PARAMETERS
                   SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + 1
                 WHERE   TASK_SUBTYPE = V_TASK_SUBTYPE
                     AND ENGINE_ID = ENGINE_ID_IN
                     AND (SYSTEM_NAME = R1.SYSTEM_NAME OR SYSTEM_NAME IS NULL)
                     AND VALID_FROM <= V_CURRENT_HOUR
                     AND VALID_TO > V_CURRENT_HOUR
                     AND PARAM_TYPE = 'TASK_MIN_CONTROL';

                V_STEP := 'Updating CTRL_TASK_PARAMETERS task_type';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   CTRL_TASK_PARAMETERS
                   SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + R1.toughness
                 WHERE   TASK_SUBTYPE = V_TASK_TYPE
                     AND ENGINE_ID = ENGINE_ID_IN
                     AND (SYSTEM_NAME = R1.SYSTEM_NAME OR SYSTEM_NAME IS NULL)
                     AND VALID_FROM <= V_CURRENT_HOUR
                     AND VALID_TO > V_CURRENT_HOUR
                     AND PARAM_TYPE = 'PARALLELISM_CONTROL';

                UPDATE   CTRL_TASK_PARAMETERS
                   SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + 1
                 WHERE   TASK_SUBTYPE = V_TASK_TYPE
                     AND ENGINE_ID = ENGINE_ID_IN
                     AND (SYSTEM_NAME = R1.SYSTEM_NAME OR SYSTEM_NAME IS NULL)
                     AND VALID_FROM <= V_CURRENT_HOUR
                     AND VALID_TO > V_CURRENT_HOUR
                     AND PARAM_TYPE = 'TASK_MIN_CONTROL';

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_task_type: ' || V_TASK_TYPE || ' v_task_subtype: ' || V_TASK_SUBTYPE;
            END LOOP;

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
        END; -- Level_2



        V_STEP := 'Inserting possible launching jobs into TEMP_ENG_JOB_POSSIBLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

	      INSERT INTO TEMP_ENG_JOB_POSSIBLE(SEQ
                                        , JOB_ID
                                        , JOB_NAME
                                        , PRIORITY
                                        , STATUS
                                        , N_RUN
                                        , JOB_TYPE
                                        , JOB_CATEGORY
                                        , CMD_LINE
                                        , TASK_SUBTYPE
                                        , TASK_TYPE
                                        , toughness
                                        , ENGINE_ID)
            SELECT   ROW_NUMBER() OVER (ORDER BY NVL(SJ.PRIORITY, 2000) + SJ.N_RUN, SJ.toughness DESC, SJ.JOB_NAME) AS SEQ
                   , SJ.JOB_ID
                   , SJ.JOB_NAME
                   , NVL(SJ.PRIORITY, 2000)
                   , SJ.STATUS
                   , SJ.N_RUN
                   , SJ.JOB_TYPE
                   , SJ.JOB_CATEGORY
                   , SJ.CMD_LINE
                   , CTP.TASK_SUBTYPE
                   , CTP.TASK_TYPE
                   , SJ.toughness
                   , ENGINE_ID_IN
              FROM               SESS_JOB SJ
                             JOIN
                                 CTRL_TASK_PARAMETERS CTP
                             ON SJ.JOB_CATEGORY = CTP.TASK_SUBTYPE  AND ctp.param_type='PARALLELISM_CONTROL' AND (ctp.system_name = system_name_in OR ctp.system_name IS NULL)
                         JOIN
                             CTRL_JOB_STATUS CJS
                         ON SJ.STATUS = CJS.STATUS
                        AND SJ.N_RUN < SJ.MAX_RUNS
                        AND NVL(SJ.LAST_UPDATE, TO_TIMESTAMP('2000-01-01', 'YYYY-MM-DD')) + CJS.DELAY_MINUTES / 24 / 60 < CURRENT_TIMESTAMP
                        AND (NVL(SJ.WAITING_HR, -999999999) <= V_CURRENT_HOUR OR CJS.executable = 0)
                        AND CJS.RUNABLE IN ('RUNABLE', 'FAILED')
                        AND SJ.ENGINE_ID = ENGINE_ID_IN
                        AND CTP.ENGINE_ID = ENGINE_ID_IN
                     LEFT JOIN
                         SESS_JOB_DEPENDENCY SJD
                     ON SJ.JOB_ID = SJD.JOB_ID
             WHERE   SJD.JOB_ID IS NULL;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        V_STEP := 'Cursor job_ready_cur declaration and opening';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DECLARE
            CURSOR JOB_READY_CUR
            IS
                  SELECT   SEQ
                         , TEJP.JOB_ID
                         , TEJP.JOB_NAME
                         , NVL(TEJP.PRIORITY, 2000)
                         , TEJP.STATUS
                         , TEJP.JOB_TYPE
                         , TEJP.CMD_LINE
                         , TEJP.TASK_SUBTYPE
                         , TEJP.TASK_TYPE
                         , TEJP.toughness
                         , CJS.EXECUTABLE
                    FROM       TEMP_ENG_JOB_POSSIBLE TEJP
                           JOIN
                               CTRL_JOB_STATUS CJS
                           ON TEJP.STATUS = CJS.STATUS
                          AND TEJP.ENGINE_ID = ENGINE_ID_IN
                         JOIN  CTRL_TASK_PARAMETERS CTP
                           ON TEJP.TASK_SUBTYPE = CTP.TASK_SUBTYPE
                           AND (CTP.SYSTEM_NAME = SYSTEM_NAME_IN OR CTP.SYSTEM_NAME IS NULL)
                            AND CTP.ENGINE_ID = ENGINE_ID_IN
                            AND CTP.param_type='PARALLELISM_CONTROL'
                            AND (CJS.EXECUTABLE=0 OR ( CJS.EXECUTABLE=1 AND CTP.PARAM_VAL_INT_CURR < CTP.PARAM_VAL_INT_MAX ))
                ORDER BY   SEQ;
        BEGIN -- Level_2
            OPEN JOB_READY_CUR;

            V_STEP := 'Opening JOB_READY_CUR';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            LOOP
                FETCH JOB_READY_CUR
                INTO   V_SEQ
                     , V_JOB_ID
                     , V_JOB_NAME
                     , V_PRIORITY
                     , V_STATUS
                     , V_JOB_TYPE
                     , V_CMD_LINE
                     , V_TASK_SUBTYPE
                     , V_TASK_TYPE
                     , V_TOUGHNESS
                     , V_EXECUTABLE;

                EXIT WHEN JOB_READY_CUR%NOTFOUND;
                V_STEP := 'Job parameter';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_seq: ' || TO_CHAR(V_SEQ);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_job_id: ' || TO_CHAR(V_JOB_ID);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_job_name: ' || TO_CHAR(V_JOB_NAME);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_priority: ' || TO_CHAR(V_PRIORITY);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_status: ' || TO_CHAR(V_STATUS);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_job_type: ' || TO_CHAR(V_JOB_TYPE);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_cmd_line: ' || TO_CHAR(V_CMD_LINE);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_task_subtype: ' || TO_CHAR(V_TASK_SUBTYPE);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_task_type: ' || TO_CHAR(V_TASK_TYPE);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_toughness: ' || TO_CHAR(V_TOUGHNESS);
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_executable: ' || TO_CHAR(V_EXECUTABLE);

                IF V_STARTED_JOBS  >= V_POSSIBLE_JOBS
               AND V_PRIORITY <> 0
               --AND V_EXECUTABLE = 1 mbu20130204
                THEN
                    V_PROCESS_STATUS := 'not launched, max_jobs threshold reached';
                    -- prepsat na raise exception
                    GOTO RETURN_JOBS;
                    -- GOTO NEXT_JOB;mbu20130204
                END IF;
				V_STEP := 'Comparing current value with task_subtype and task_type threshold';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

				V_TOUGHNESS_CONFLICT:=0;

if V_EXECUTABLE = 1 then
                SELECT   CASE
                             WHEN V_PRIORITY = 0
                             THEN
                                 0
			     WHEN CHLD_TOUGHNESS.PARAM_VAL_INT_CURR >= CHLD_TOUGHNESS.PARAM_VAL_INT_MAX OR PRNT_TOUGHNESS.PARAM_VAL_INT_CURR >= PRNT_TOUGHNESS.PARAM_VAL_INT_MAX 	-- #by_MBU_20130325 - uz je prevazeno
                             THEN
                                2

			     WHEN ((CHLD_TOUGHNESS.PARAM_VAL_INT_CURR + V_TOUGHNESS) > CHLD_TOUGHNESS.PARAM_VAL_INT_MAX OR (PRNT_TOUGHNESS.PARAM_VAL_INT_CURR + V_TOUGHNESS) > PRNT_TOUGHNESS.PARAM_VAL_INT_MAX)
                AND ((CHLD_JOB_COUNT.PARAM_VAL_INT_CURR+1) < CHLD_JOB_COUNT.PARAM_VAL_INT_MAX OR (PRNT_JOB_COUNT.PARAM_VAL_INT_CURR+1) < PRNT_JOB_COUNT.PARAM_VAL_INT_MAX ) -- rezervaci by se nedosahlo minimalni paralelnosti
                            THEN
                            2
			     WHEN ((CHLD_TOUGHNESS.PARAM_VAL_INT_CURR + V_TOUGHNESS) > CHLD_TOUGHNESS.PARAM_VAL_INT_MAX OR (PRNT_TOUGHNESS.PARAM_VAL_INT_CURR + V_TOUGHNESS) > PRNT_TOUGHNESS.PARAM_VAL_INT_MAX)  -- rezervace
                            THEN
                            1
                            ELSE --spusteni
                                 0
                         END
                             AS CONFLICT
                  INTO   V_TOUGHNESS_CONFLICT
                  FROM       CTRL_TASK_PARAMETERS CHLD_TOUGHNESS
                         JOIN
                             CTRL_TASK_PARAMETERS PRNT_TOUGHNESS
                         ON CHLD_TOUGHNESS.TASK_TYPE = PRNT_TOUGHNESS.TASK_SUBTYPE
                        AND CHLD_TOUGHNESS.TASK_SUBTYPE = V_TASK_SUBTYPE
                        AND CHLD_TOUGHNESS.ENGINE_ID = ENGINE_ID_IN
                        AND (CHLD_TOUGHNESS.SYSTEM_NAME = SYSTEM_NAME_IN OR CHLD_TOUGHNESS.SYSTEM_NAME IS NULL)
                        AND CHLD_TOUGHNESS.VALID_FROM <= V_CURRENT_HOUR
                        AND CHLD_TOUGHNESS.VALID_TO > V_CURRENT_HOUR
                        AND CHLD_TOUGHNESS.PARAM_TYPE='PARALLELISM_CONTROL'

                        AND PRNT_TOUGHNESS.TASK_TYPE = V_TASK_TYPE
                        AND PRNT_TOUGHNESS.ENGINE_ID = ENGINE_ID_IN
                        AND (PRNT_TOUGHNESS.SYSTEM_NAME = SYSTEM_NAME_IN OR PRNT_TOUGHNESS.SYSTEM_NAME IS NULL)
                        AND PRNT_TOUGHNESS.VALID_FROM <= V_CURRENT_HOUR
                        AND PRNT_TOUGHNESS.VALID_TO > V_CURRENT_HOUR
                        AND PRNT_TOUGHNESS.PARAM_TYPE='PARALLELISM_CONTROL'

                        JOIN
                             CTRL_TASK_PARAMETERS CHLD_JOB_COUNT
                        ON CHLD_JOB_COUNT.TASK_SUBTYPE=CHLD_TOUGHNESS.TASK_SUBTYPE

                        JOIN
                             CTRL_TASK_PARAMETERS PRNT_JOB_COUNT

                        ON CHLD_JOB_COUNT.TASK_TYPE = PRNT_JOB_COUNT.TASK_SUBTYPE
                        AND CHLD_JOB_COUNT.TASK_SUBTYPE = V_TASK_SUBTYPE
                        AND CHLD_JOB_COUNT.ENGINE_ID = ENGINE_ID_IN
                        AND (CHLD_JOB_COUNT.SYSTEM_NAME = SYSTEM_NAME_IN OR CHLD_JOB_COUNT.SYSTEM_NAME IS NULL)
                        AND CHLD_JOB_COUNT.VALID_FROM <= V_CURRENT_HOUR
                        AND CHLD_JOB_COUNT.VALID_TO > V_CURRENT_HOUR
                        AND CHLD_JOB_COUNT.PARAM_TYPE='TASK_MIN_CONTROL'

                        AND PRNT_JOB_COUNT.TASK_TYPE = V_TASK_TYPE
                        AND PRNT_JOB_COUNT.ENGINE_ID = ENGINE_ID_IN
                        AND (PRNT_JOB_COUNT.SYSTEM_NAME = SYSTEM_NAME_IN OR PRNT_JOB_COUNT.SYSTEM_NAME IS NULL)
                        AND PRNT_JOB_COUNT.VALID_FROM <= V_CURRENT_HOUR
                        AND PRNT_JOB_COUNT.VALID_TO > V_CURRENT_HOUR
                        AND PRNT_JOB_COUNT.PARAM_TYPE='TASK_MIN_CONTROL';



                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_toughness_conflict: ' || TO_CHAR(V_TOUGHNESS_CONFLICT);
end if;
              IF V_TOUGHNESS_CONFLICT = 2
                AND V_EXECUTABLE = 1
                  THEN
                      V_PROCESS_STATUS := 'not launched due to overflowing:' || TO_CHAR(V_JOB_NAME);
                      GOTO NEXT_JOB;
                END IF;


                V_STEP := 'Counting number of table lock type conflict';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                V_CONFLICT:=0;
if V_EXECUTABLE = 1 then

                SELECT   COUNT( * )
                  INTO   V_CONFLICT
                  FROM       TEMP_ENG_JOB_RUNNING TEJR
                         JOIN
                             (SELECT   DATABASE_NAME, TABLE_NAME, LOCK_TYPE
                                FROM   CTRL_JOB_TABLE_REF CJTR
                               WHERE   JOB_NAME = V_JOB_NAME) CJTR
                         ON TEJR.DATABASE_NAME = CJTR.DATABASE_NAME
                        AND TEJR.ENGINE_ID = ENGINE_ID_IN
                        AND (TEJR.TABLE_NAME LIKE CJTR.TABLE_NAME
                          OR CJTR.TABLE_NAME LIKE TEJR.TABLE_NAME)
                        AND (UPPER(TEJR.LOCK_TYPE) = 'W'
                          OR UPPER(CJTR.LOCK_TYPE) = 'W')
                        AND TEJR.IS_RUNNING != 0; -- only running or prepared job is testing, failed is ignored

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_conflict: ' || TO_CHAR(V_CONFLICT);
end if;
                IF V_CONFLICT > 0
               AND V_EXECUTABLE = 1
                THEN
                    V_PROCESS_STATUS := 'not launched, table lock conflict found';
                    GOTO NEXT_JOB;
                END IF;

                V_STEP := 'Updating CTRL_TASK_PARAMETERS';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                IF V_EXECUTABLE = 1
                THEN
                    V_STEP := 'update ctrl_task_parameters subcategory PARALLELISM_CONTROL';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   CTRL_TASK_PARAMETERS
                       SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + V_TOUGHNESS
                     WHERE   TASK_SUBTYPE = V_TASK_SUBTYPE  AND PARAM_TYPE='PARALLELISM_CONTROL'
                        AND engine_id=ENGINE_ID_IN AND (system_name = system_name_in OR system_name IS NULL);

                    V_STEP := 'update ctrl_task_parameters category PARALLELISM_CONTROL';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   CTRL_TASK_PARAMETERS
                       SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + V_TOUGHNESS
                     WHERE   TASK_SUBTYPE = V_TASK_TYPE  AND PARAM_TYPE='PARALLELISM_CONTROL'
                        AND engine_id=ENGINE_ID_IN and (system_name = system_name_in OR system_name IS NULL);

                    IF V_TOUGHNESS_CONFLICT > 0
                    THEN
                      GOTO NEXT_JOB;-- job will be reservered only
                    END IF;

                    V_STEP := 'update ctrl_task_parameters subcategory TASK_MIN_CONTROL';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   CTRL_TASK_PARAMETERS
                       SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + 1
                     WHERE   TASK_SUBTYPE = V_TASK_SUBTYPE  AND PARAM_TYPE='TASK_MIN_CONTROL'
                        AND engine_id=ENGINE_ID_IN and (system_name = system_name_in OR system_name IS NULL);

                    V_STEP := 'update ctrl_task_parameters category TASK_MIN_CONTROL';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                    UPDATE   CTRL_TASK_PARAMETERS
                       SET   PARAM_VAL_INT_CURR = PARAM_VAL_INT_CURR + 1
                     WHERE   TASK_SUBTYPE = V_TASK_TYPE  AND PARAM_TYPE='TASK_MIN_CONTROL'
                        AND engine_id=ENGINE_ID_IN AND (system_name = system_name_in OR system_name IS NULL);

                    V_STARTED_JOBS := V_STARTED_JOBS + 1;
                ELSE
                    V_SKIPPED_JOBS := V_SKIPPED_JOBS + 1;
                END IF;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_task_type: ' || V_TASK_TYPE || ' v_task_subtype: ' || V_TASK_SUBTYPE;

                V_STEP := 'Inserting job into TEMP_ENG_JOB_READY table';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                INSERT INTO TEMP_ENG_JOB_READY(JOB_ID
                                             , JOB_NAME
                                             , JOB_AVAILABILITY
                                             , JOB_TYPE
                                             , JOB_CATEGORY
                                             , CMD_LINE
                                             , QUEUE_NUMBER
                                             , LOAD_DATE
                                             , ENGINE_ID)
                    SELECT   SJ.JOB_ID
                           , SJ.JOB_NAME
                           , CASE
                                 WHEN SJ.N_RUN = 0
                                 THEN
                                     1 -- start
                                 WHEN SJ.RESTART = 0
                                  AND SJ.ALWAYS_RESTART = 0
                                 THEN
                                     3 -- resume
                                 ELSE
                                     2 -- restart
                             END
                                 AS JOB_AVAILABILITY
                           , UPPER(SJ.JOB_TYPE) AS JOB_TYPE
                           , UPPER(SJ.JOB_CATEGORY) AS JOB_CATEGORY
                           , SJ.CMD_LINE
                           , CASE WHEN V_EXECUTABLE = 1 THEN TEQ.QUEUE_NUMBER ELSE -1 END AS QUEUE_NUMBER
                           , SJ.LOAD_DATE
                           , SJ.ENGINE_ID
                      FROM       SESS_JOB SJ
                             CROSS JOIN
                                 TEMP_ENG_QUEUE TEQ
                     WHERE   SJ.JOB_ID = V_JOB_ID
                         AND TEQ.ENGINE_ID = ENGINE_ID_IN
                         AND TEQ.SEQ = V_STARTED_JOBS;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                V_STEP := 'Inserting job into TEMP_ENG_JOB_RUNNING table';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                INSERT INTO TEMP_ENG_JOB_RUNNING(JOB_ID
                                               , JOB_NAME
                                               , JOB_TYPE
                                               , toughness
                                               , DATABASE_NAME
                                               , TABLE_NAME
                                               , LOCK_TYPE
                                               , JOB_CATEGORY
                                               , IS_RUNNING
                                               , ENGINE_ID
                                               , SYSTEM_NAME)
                    SELECT   SJ.JOB_ID
                           , SJ.JOB_NAME
                           , SJ.JOB_TYPE
                           , SJ.toughness
                           , CJTR.DATABASE_NAME
                           , CJTR.TABLE_NAME
                           , CJTR.LOCK_TYPE
                           , SJ.JOB_CATEGORY
                           , 2 --IS_RUNNING
                           , SJ.ENGINE_ID
                           , SYSTEM_NAME_IN
                      FROM       SESS_JOB SJ
                             LEFT JOIN
                                 CTRL_JOB_TABLE_REF CJTR
                             ON SJ.JOB_NAME = CJTR.JOB_NAME
                     WHERE   SJ.JOB_ID = V_JOB_ID;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> -----------------------------------------------';

                IF V_EXECUTABLE = 1
                THEN
                    V_STEP := 'Starting job';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    V_STARTED_JOBS := V_STARTED_JOBS + 1;
                    V_PROCESS_STATUS := 'launched, executable job';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_started_jobs: ' || TO_CHAR(V_STARTED_JOBS);
                ELSE
                    V_STEP := 'Skipping job';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                    V_SKIPPED_JOBS := V_SKIPPED_JOBS + 1;
                    V_PROCESS_STATUS := 'launched, skippable job';
                    V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                    V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_skipped_jobs: ' || TO_CHAR(V_SKIPPED_JOBS);
                END IF;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> -----------------------------------------------';

               <<NEXT_JOB>>
                NULL;
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ********** Job has been processed with status: ' || V_PROCESS_STATUS;
            END LOOP;

           <<RETURN_JOBS>>
            IF JOB_READY_CUR%ISOPEN
            THEN
                CLOSE JOB_READY_CUR;
            END IF;

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
        END; -- Level_2

        IF V_STARTED_JOBS + V_SKIPPED_JOBS = 0
        THEN
            V_STEP := 'Nothing to run, counting runable jobs';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   COUNT( * )
              INTO   V_RUNABLE_JOBS
              FROM       SESS_JOB SJ
                     JOIN
                         CTRL_JOB_STATUS CJS
                     ON SJ.STATUS = CJS.STATUS
                    AND SJ.ENGINE_ID = ENGINE_ID_IN
                    AND CJS.FINISHED = 0;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_runable_jobs: ' || TO_CHAR(V_RUNABLE_JOBS);

            V_STEP := 'Inserting into TEMP_ENG_JOB_READY table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            INSERT INTO TEMP_ENG_JOB_READY(JOB_ID
                                         , JOB_NAME
                                         , JOB_AVAILABILITY
                                         , JOB_TYPE
                                         , JOB_CATEGORY
                                         , CMD_LINE
                                         , QUEUE_NUMBER
                                         , LOAD_DATE
                                         , ENGINE_ID)
                SELECT   -1 --job_id
                       , '?' --job_name
                       , CASE WHEN V_RUNABLE_JOBS > 0 THEN 8 -- wait
                                                            ELSE 9 -- finished
                                                                  END AS AVAILABILITY
                       , '?' --job_type
                       , '?' --job_category
                       , '?' --cmd_line
                       , -1 --queue_number
                       , TO_DATE('2000-01-01', 'YYYY-MM-DD') AS LOAD_DATE
                       , ENGINE_ID_IN --engine_id
                  FROM   DUAL;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        END IF;

        V_STEP := 'Opening reference cursor for data output from TEMP_ENG_JOB_READY table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        OPEN CSR FOR
            SELECT   JOB_ID
                   , JOB_NAME
                   , JOB_AVAILABILITY
                   , NVL(JOB_TYPE, 'N/A')
                   , JOB_CATEGORY
                   , NVL(CMD_LINE, 'echo ON ')
                   , QUEUE_NUMBER
                   , LOAD_DATE
                   , ENGINE_ID
                   , V_RETENTION_PERIOD as RETENTION_PERIOD
              FROM   TEMP_ENG_JOB_READY
             WHERE   ENGINE_ID = ENGINE_ID_IN;


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
    END SP_ENG_GET_JOB_LIST;

    PROCEDURE SP_ENG_GET_LOAD_DATE(JOB_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , JOB_ID_OUT   OUT INTEGER
                                 , LOAD_DATE_OUT   OUT DATE
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_GET_LOAD_DATE
        IN parameters:
                        JOB_NAME_IN
                        DEBUG_IN
        OUT parameters:
                        JOB_ID_OUT
                        LOAD_DATE_OUT
                        exit_cd - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2011-09-22
        -------------------------------------------------------------------------------
        Description: Get load date
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_ENG_GET_LOAD_DATE';
        -- local variables
        V_ERRORCODE      INTEGER;
        V_ERRORTEXT      VARCHAR2(1024);
        V_STEP           VARCHAR2(1024);
        V_LOAD_DATE      DATE;
        V_JOB_ID         INTEGER;
        V_CNT            INTEGER;

        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 0;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Does job exists?';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT( * )
          INTO   V_CNT
          FROM   SESS_JOB
         WHERE   UPPER(JOB_NAME) = UPPER(JOB_NAME_IN)
             AND STATUS IN (SELECT   STATUS
                              FROM   CTRL_JOB_STATUS
                             WHERE   RUNABLE = 'RUNNING');

        IF V_CNT > 0
        THEN
            V_STEP := 'Getting JOB_ID and LOAD_DATE';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   JOB_ID,LOAD_DATE
              INTO   V_JOB_ID,V_LOAD_DATE
              FROM   SESS_JOB
             WHERE   UPPER(JOB_NAME) = UPPER(JOB_NAME_IN)
                 AND STATUS IN (SELECT   STATUS
                                  FROM   CTRL_JOB_STATUS
                                 WHERE   RUNABLE = 'RUNNING');

        ELSE
            V_JOB_ID := -1;
            V_LOAD_DATE := TO_DATE('2000-01-01', 'YYYY-MM-DD');

            RAISE NO_DATA_FOUND;
        END IF;

        JOB_ID_OUT := V_JOB_ID;
        LOAD_DATE_OUT := V_LOAD_DATE;


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
    END SP_ENG_GET_LOAD_DATE;

    PROCEDURE SP_ENG_UPDATE_STATUS(JOB_ID_IN IN  NUMBER
                                 , LAUNCH_IN IN  NUMBER
                                 , SIGNAL_IN IN  VARCHAR2
                                 , REQUEST_IN IN VARCHAR2
                                 , ENGINE_ID_IN IN NUMBER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , QUEUE_NUMBER_IN IN NUMBER
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_UPDATE_STATUS
        IN parameters:
                        JOB_ID_IN
                        LAUNCH_IN 1 - job is launching, 0 - job is finishing
                        SIGNAL_IN
                        REQUEST_IN - requested type of status change
                        ENGINE_ID_IN
                        QUEUE_NUMBER_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        PERL script %PMRootDir%\Bin\Framework\Run_job.pl
        PDC GUI application
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2010-02-07
        -------------------------------------------------------------------------------
        Description: Starting and finishing jobs
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_UPDATE_STATUS';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_STATUS_IN        CTRL_NEXT_STATUS.STATUS_IN%TYPE;
        V_STATUS_OUT       CTRL_NEXT_STATUS.STATUS_OUT%TYPE;
        V_CONT_ANYWAY      NUMBER;
        V_FINISHED         NUMBER;
        V_SIGNAL           VARCHAR2(16);
        V_APPLICATION_ID   NUMBER;
        V_STATUS_TS        TIMESTAMP(6);
        V_CNT              NUMBER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := JOB_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := LAUNCH_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SIGNAL_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := REQUEST_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := QUEUE_NUMBER_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        V_STEP := 'Taking status from SESS_JOB table 1';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXIT_CD := 0;
        RETURN_STATUS_OUT := 'N/A';


        DECLARE
        BEGIN
            SELECT   STATUS
              INTO   V_STATUS_IN
              FROM   SESS_JOB SJ
             WHERE   SJ.JOB_ID = JOB_ID_IN;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                NULL;
        END;

        V_STEP := 'Taking value of APPLICATION_ID parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_APPLICATION_ID
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENGINE_ID_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. APPLICATION_ID: ' || TO_CHAR(V_APPLICATION_ID);

        V_SIGNAL := SIGNAL_IN;

        IF UPPER(V_SIGNAL) = 'N/A'
        THEN
            V_STEP := 'Taking cont_anyway value';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF REQUEST_IN = 'FAILED'
            OR REQUEST_IN = 'DQ_CRITICAL'
            THEN
                SELECT   CASE
                             WHEN CONT_ANYWAY = 1
                              AND N_RUN >= MAX_RUNS
                             THEN
                                 1
                             ELSE
                                 0
                         END
                             AS CONT_ANYWAY
                  INTO   V_CONT_ANYWAY
                  FROM   SESS_JOB SJ
                 WHERE   SJ.JOB_ID = JOB_ID_IN;
            ELSE
                V_CONT_ANYWAY := 0;
            END IF;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Signal value not defined, taking it from request value';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) :=
                   ' STEP> '
                || V_STEP
                || ' STATUS_IN = '
                || UPPER(V_STATUS_IN)
                || ' AND REQUEST = '
                || UPPER(REQUEST_IN)
                || ' AND LAUNCH = '
                || LAUNCH_IN
                || ' AND CONT_ANYWAY = '
                || V_CONT_ANYWAY;

            SELECT   COUNT( * )
              INTO   V_CNT
              FROM   CTRL_NEXT_STATUS CNS
             WHERE   STATUS_IN = V_STATUS_IN
                 AND REQUEST = UPPER(REQUEST_IN)
                 AND LAUNCH = LAUNCH_IN
                 AND CONT_ANYWAY = V_CONT_ANYWAY;

            IF V_CNT <> 1
            THEN
                DECLARE
                BEGIN
                    RETURN_STATUS_OUT :=
                           'ERROR> job_id: '
                        || JOB_ID_IN
                        || ' status_in: '
                        || V_STATUS_IN
                        || ' request: '
                        || UPPER(REQUEST_IN)
                        || ' launch: '
                        || LAUNCH_IN
                        || ' cont_anyway: '
                        || V_CONT_ANYWAY;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        EXIT_CD := -3;

                        ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

                        ERRCODE_OUT := SQLCODE;

                        ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;
                        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                        V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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
                --RAISE;
                END;
            ELSE
                SELECT   SIGNAL
                  INTO   V_SIGNAL
                  FROM   CTRL_NEXT_STATUS CNS
                 WHERE   STATUS_IN = UPPER(V_STATUS_IN)
                     AND REQUEST = UPPER(REQUEST_IN)
                     AND LAUNCH = LAUNCH_IN
                     AND CONT_ANYWAY = V_CONT_ANYWAY;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            END IF;
        END IF;

        --        IF RETURN_STATUS_OUT <> 'error'
        V_STEP := 'Taking value of status_out from CTRL_NEXT_STATUS table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   STATUS_OUT
          INTO   V_STATUS_OUT
          FROM   CTRL_NEXT_STATUS CNS
         WHERE   CNS.STATUS_IN = V_STATUS_IN
             AND CNS.SIGNAL = V_SIGNAL;

        IF QUEUE_NUMBER_IN < 0
        THEN
            RETURN_STATUS_OUT := 'skip';
        ELSE
            RETURN_STATUS_OUT := 'run';
        END IF;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF QUEUE_NUMBER_IN >= 0
        THEN
            V_STEP := 'Updating status of the queue in SESS_QUEUE table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   SESS_QUEUE
               SET   JOB_ID = JOB_ID_IN
                   , LAST_UPDATE = CURRENT_TIMESTAMP
                   , JOB_NAME =
                         (SELECT   JOB_NAME
                            FROM   SESS_JOB
                           WHERE   JOB_ID = JOB_ID_IN)
                   , AVAILABLE = 1 - LAUNCH_IN
                   , SYSTEM_NAME = SYSTEM_NAME_IN
             WHERE   QUEUE_NUMBER = QUEUE_NUMBER_IN
                 AND ENGINE_ID = ENGINE_ID_IN;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        END IF;

        V_STEP := 'Updating last_update and, n_run and status in SESS_JOB table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF SIGNAL_IN = 'BLOCK'
       AND REQUEST_IN = 'BLOCK'
        THEN
            UPDATE   SESS_JOB SJ
               SET   SJ.STATUS = V_STATUS_OUT, SJ.LAST_UPDATE = CURRENT_TIMESTAMP, SJ.SYSTEM_NAME= SYSTEM_NAME_IN
             WHERE   SJ.JOB_ID = JOB_ID_IN;
        ELSE
            UPDATE   SESS_JOB SJ
               SET   SJ.STATUS = V_STATUS_OUT, SJ.LAST_UPDATE = CURRENT_TIMESTAMP, SJ.N_RUN = N_RUN + LAUNCH_IN, SJ.SYSTEM_NAME= SYSTEM_NAME_IN
             WHERE   SJ.JOB_ID = JOB_ID_IN;
        END IF;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Taking info if status is final from CTRL_JOB_STATUS table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   CJS.FINISHED
          INTO   V_FINISHED
          FROM   CTRL_JOB_STATUS CJS
         WHERE   STATUS = V_STATUS_OUT;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF V_FINISHED = 1
        THEN
            V_STEP := 'Deleting job dependency from SESS_JOB_DEPENDENCY table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            DELETE FROM   SESS_JOB_DEPENDENCY
                  WHERE   PARENT_JOB_ID = JOB_ID_IN;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        END IF;

        V_STEP := 'Taking status timestamp from SESS_STATUS table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   MAX(SS.STATUS_TS)
          INTO   V_STATUS_TS
          FROM   SESS_STATUS SS
         WHERE   JOB_ID = JOB_ID_IN;

        V_STATUS_TS := NVL(V_STATUS_TS, TO_TIMESTAMP('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS'));
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Correcting status_ts';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   CASE WHEN V_STATUS_TS + 1 / 24 / 60 / 60 / 1000 < CURRENT_TIMESTAMP(6) THEN CURRENT_TIMESTAMP(6) ELSE V_STATUS_TS + 1 / 24 / 60 / 60 / 100 END AS STATUS_TS
          INTO   V_STATUS_TS
          FROM   DUAL;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Inserting into SESS_STATUS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_STATUS(JOB_ID
                              , JOB_NAME
                              , STREAM_NAME
                              , STATUS_TS
                              , LOAD_DATE
                              , STATUS
                              , N_RUN
                              , SIGNAL
                              , APPLICATION_ID
                              , ENGINE_ID
                              , SYSTEM_NAME)
            SELECT   SJ.JOB_ID
                   , SJ.JOB_NAME
                   , SJ.STREAM_NAME
                   , V_STATUS_TS
                   , SJ.LOAD_DATE
                   , SJ.STATUS
                   , SJ.N_RUN
                   , V_SIGNAL
                   , V_APPLICATION_ID
                   , SJ.ENGINE_ID
                   , SYSTEM_NAME_IN
              FROM   SESS_JOB SJ
             WHERE   SJ.JOB_ID = JOB_ID_IN
                 --AND SJ.PHASE != 'INITIALIZATION' --by VKU 2012-08-21
                 ;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024)||'je to tadyxxx';

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'OTHER ERROR ' || V_STEP;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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
    END SP_ENG_UPDATE_STATUS;

    PROCEDURE SP_ENG_CHECK_WD_STATUS(ENGINE_ID_IN IN NUMBER
                                   , SYSTEM_NAME_IN IN VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , NUMBER_OF_SECONDS_OUT   OUT NOCOPY NUMBER
                                   , EXIT_CD   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_CHECK_WD_STATUS
        IN parameters:
                       ENGINE_ID_IN
                       DEBUG_IN
        OUT parameters:
                       NUMBER_OF_SECONDS_OUT
                       EXIT_CD
                       ERRMSG_OUT
                       ERRCODE_OUT
                       ERRLINE_OUT
        exit_cd - procedure exit code (0 - OK)
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2010-02-08
        -------------------------------------------------------------------------------
        Description: Checking Engine cycle
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME           CONSTANT VARCHAR2(64) := 'SP_ENG_CHECK_WD_STATUS';
        -- local variables
        V_WATCHDOG_INTERVAL   NUMBER;
        V_ERRORCODE           INTEGER;
        V_ERRORTEXT           VARCHAR2(1024);
        V_STEP                VARCHAR2(1024);
        V_ALL_DBG_INFO        PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID         INTEGER := 0;
        V_DWH_DATE            DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY');
        V_ERROR_CD_IN         LKP_ERROR_CD.ERROR_CD%TYPE := PCKG_TOOLS.F_GET_ERROR_CD('ENGINE');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'Taking difference between current time and last Engine turn';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PCKG_TOOLS.F_SEC_BETWEEN(NVL(PARAM_VAL_TS, TO_TIMESTAMP('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS')), CURRENT_TIMESTAMP) DIFF
          INTO   NUMBER_OF_SECONDS_OUT
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'ENGINE_STATUS'
             AND PARAM_CD = ENGINE_ID_IN
             AND PARAM_VAL_CHAR = SYSTEM_NAME_IN;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. number_of_seconds_out: ' || TO_CHAR(NUMBER_OF_SECONDS_OUT);

        V_STEP := 'Taking value of WATCHDOG_INTERVAL parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_WATCHDOG_INTERVAL
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'WATCHDOG_INTERVAL';

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. v_watchdog_interval: ' || TO_CHAR(V_WATCHDOG_INTERVAL);

        IF NUMBER_OF_SECONDS_OUT <= V_WATCHDOG_INTERVAL
        THEN
            NUMBER_OF_SECONDS_OUT := 0;
        END IF;

        COMMIT;
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := NUMBER_OF_SECONDS_OUT;
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
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := NUMBER_OF_SECONDS_OUT;
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
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := NUMBER_OF_SECONDS_OUT;
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
    END SP_ENG_CHECK_WD_STATUS;

    PROCEDURE SP_ENG_UPDATE_WD_STATUS(ENGINE_ID_IN IN NUMBER
                                    , SYSTEM_NAME_IN IN VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_UPDATE_WD_STATUS
        IN parameters:
                        ENGINE_ID_IN
                        DEBUG_IN
        OUT parameters:
                        EXIT_CD
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        exit_cd - procedure exit code (0 - OK)
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2010-02-10
        -------------------------------------------------------------------------------
        Description: Checking Engine cycle
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME           CONSTANT VARCHAR2(64) := 'SP_ENG_CHECK_WD_STATUS';
        -- local variables
        V_WATCHDOG_INTERVAL   NUMBER;
        V_ERRORCODE           INTEGER;
        V_ERRORTEXT           VARCHAR2(1024);
        V_STEP                VARCHAR2(1024);
        V_ALL_DBG_INFO        PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID         INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'Update ctrl_parameters param ENGINE_STATUS param_val_ts on CURRENT TIMESTAMP';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_TS = CURRENT_TIMESTAMP
         WHERE   PARAM_NAME = 'ENGINE_STATUS'
             AND PARAM_CD = ENGINE_ID_IN
             AND PARAM_VAL_CHAR = SYSTEM_NAME_IN;

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
    END SP_ENG_UPDATE_WD_STATUS;

    FUNCTION F_ENG_CHECK_WD_STATUS(ENGINE_ID_IN NUMBER)
        RETURN NUMBER
    IS
        /******************************************************************************
        Object type:   UDF
        Name:    F_ENG_CHECK_WD_STATUS
        IN parameters:
                       ENGINE_ID_IN
        RETURN:        NUMBER_OF_SECONDS_OUT

        exit_cd - procedure exit code (0 - OK)
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Marcel Samek
        Date:    2010-04-26
        -------------------------------------------------------------------------------
        Description: Checking Engine cycle for GUI
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME               CONSTANT VARCHAR2(64) := 'F_ENG_CHECK_WD_STATUS';
        -- local variables
        EXIT_CD                   NUMBER;
        ERRMSG_OUT                VARCHAR2(2048);
        ERRCODE_OUT               NUMBER;
        ERRLINE_OUT               VARCHAR2(2048);
        V_WATCHDOG_INTERVAL       NUMBER;
        V_NUMBER_OF_SECONDS_OUT   NUMBER;
        V_ERRORCODE               INTEGER;
        V_ERRORTEXT               VARCHAR2(1024);
        V_STEP                    VARCHAR2(1024);
        V_ALL_DBG_INFO            PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID             INTEGER := 0;
        V_DWH_DATE                DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY');
        V_ERROR_CD_IN             LKP_ERROR_CD.ERROR_CD%TYPE := PCKG_TOOLS.F_GET_ERROR_CD('ENGINE');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;

        V_STEP := 'Get number of seconds out';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   MIN(PCKG_TOOLS.F_SEC_BETWEEN(NVL(PARAM_VAL_TS, TO_TIMESTAMP('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS')), CURRENT_TIMESTAMP)) DIFF
          INTO   V_NUMBER_OF_SECONDS_OUT
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'ENGINE_STATUS'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Get watchdog interval';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_WATCHDOG_INTERVAL
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'WATCHDOG_INTERVAL';

        IF V_NUMBER_OF_SECONDS_OUT <= V_WATCHDOG_INTERVAL
        THEN
            V_NUMBER_OF_SECONDS_OUT := 0;
        END IF;

        RETURN V_NUMBER_OF_SECONDS_OUT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN -1;

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
            RETURN -1;

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
    END F_ENG_CHECK_WD_STATUS;

    FUNCTION F_ENG_CHECK_WD_SYS_STATUS(ENGINE_ID_IN NUMBER, SYSTEM_NAME_IN VARCHAR2)
        RETURN NUMBER
    IS
        /******************************************************************************
        Object type:   UDF
        Name:    F_ENG_CHECK_WD_STATUS
        IN parameters:
                       ENGINE_ID_IN
                       SYSTEM_NAME_IN
        RETURN:        NUMBER_OF_SECONDS_OUT

        exit_cd - procedure exit code (0 - OK)
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Milan Budka
        Date:    2015-04-15
        -------------------------------------------------------------------------------
        Description: Checking Engine system cycle for GUI
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME               CONSTANT VARCHAR2(64) := 'F_ENG_CHECK_WD_SYS_STATUS';
        -- local variables
        EXIT_CD                   NUMBER;
        ERRMSG_OUT                VARCHAR2(2048);
        ERRCODE_OUT               NUMBER;
        ERRLINE_OUT               VARCHAR2(2048);
        V_WATCHDOG_INTERVAL       NUMBER;
        V_NUMBER_OF_SECONDS_OUT   NUMBER;
        V_ERRORCODE               INTEGER;
        V_ERRORTEXT               VARCHAR2(1024);
        V_STEP                    VARCHAR2(1024);
        V_ALL_DBG_INFO            PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID             INTEGER := 0;
        V_DWH_DATE                DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY');
        V_ERROR_CD_IN             LKP_ERROR_CD.ERROR_CD%TYPE := PCKG_TOOLS.F_GET_ERROR_CD('ENGINE');
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;

        V_STEP := 'Get number of seconds out';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PCKG_TOOLS.F_SEC_BETWEEN(NVL(PARAM_VAL_TS, TO_TIMESTAMP('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS')), CURRENT_TIMESTAMP) DIFF
          INTO   V_NUMBER_OF_SECONDS_OUT
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'ENGINE_STATUS'
             AND PARAM_CD = ENGINE_ID_IN
             AND PARAM_VAL_CHAR=SYSTEM_NAME_IN;

        V_STEP := 'Get watchdog interval';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_WATCHDOG_INTERVAL
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'WATCHDOG_INTERVAL';

        IF V_NUMBER_OF_SECONDS_OUT <= V_WATCHDOG_INTERVAL
        THEN
            V_NUMBER_OF_SECONDS_OUT := 0;
        END IF;

        RETURN V_NUMBER_OF_SECONDS_OUT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN -1;

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
            RETURN -1;

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
    END F_ENG_CHECK_WD_SYS_STATUS;

    PROCEDURE SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN IN  NUMBER
                                     , LAUNCH_IN IN  NUMBER
                                     , SIGNAL_IN IN  VARCHAR2
                                     , REQUEST_IN IN VARCHAR2
                                     , ENGINE_ID_IN IN NUMBER
                                     , DEBUG_IN IN   INTEGER:= 0
                                     , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                     , EXIT_CD   OUT NOCOPY NUMBER
                                     , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                     , ERRCODE_OUT   OUT NOCOPY NUMBER
                                     , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_UPDATE_STATUS
        IN parameters:
                        JOB_ID_IN
                        LAUNCH_IN 1 - job is launching, 0 - job is finishing
                        SIGNAL_IN
                        REQUEST_IN - requested type of status change
                        ENGINE_ID_IN
                        QUEUE_NUMBER_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        PERL script %PMRootDir%\Bin\Framework\Run_job.pl
        PDC GUI application
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2010-02-07
        -------------------------------------------------------------------------------
        Description: Starting and finishing jobs
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_GUI_UPDATE_STATUS';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_STATUS_IN        CTRL_NEXT_STATUS.STATUS_IN%TYPE;
        V_STATUS_OUT       CTRL_NEXT_STATUS.STATUS_OUT%TYPE;
        V_CONT_ANYWAY      NUMBER;
        V_FINISHED         NUMBER;
        V_SIGNAL           VARCHAR2(16);
        V_APPLICATION_ID   NUMBER;
        V_STATUS_TS        TIMESTAMP(6);
        V_CNT              NUMBER;
        QUEUE_NUMBER_IN    SESS_QUEUE.QUEUE_NUMBER%TYPE := -1;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := JOB_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := LAUNCH_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SIGNAL_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := REQUEST_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := QUEUE_NUMBER_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        V_STEP := 'Taking status from SESS_JOB table  2';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXIT_CD := 0;
        RETURN_STATUS_OUT := '?';

        DECLARE
        BEGIN
            DECLARE
            BEGIN
                SELECT   SQ.QUEUE_NUMBER
                  INTO   QUEUE_NUMBER_IN
                  FROM   SESS_QUEUE SQ
                 WHERE   SQ.ENGINE_ID = ENGINE_ID_IN
                     AND SQ.JOB_ID = JOB_ID_IN;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    QUEUE_NUMBER_IN := -1;
                    ERRLINE_OUT := ERRLINE_OUT || ' Not a valid QUEUE_NUMBER for job_id ' || JOB_ID_IN || ' found.';
                WHEN OTHERS
                THEN
                    QUEUE_NUMBER_IN := -1;
                    ERRLINE_OUT := ERRLINE_OUT || ' Not a valid QUEUE_NUMBER for job_id ' || JOB_ID_IN || ' found.';
            END;

            DECLARE
            BEGIN
                SELECT   STATUS
                  INTO   V_STATUS_IN
                  FROM   SESS_JOB SJ
                 WHERE   SJ.JOB_ID = JOB_ID_IN;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    QUEUE_NUMBER_IN := -1;
                WHEN OTHERS
                THEN
                    QUEUE_NUMBER_IN := -1;
            END;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Taking value of APPLICATION_ID parameter';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            DECLARE
            BEGIN
                SELECT   PARAM_VAL_INT
                  INTO   V_APPLICATION_ID
                  FROM   CTRL_PARAMETERS
                 WHERE   PARAM_NAME = 'APPLICATION_ID'
                     AND PARAM_CD = ENGINE_ID_IN;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    QUEUE_NUMBER_IN := -1;
                WHEN OTHERS
                THEN
                    QUEUE_NUMBER_IN := -1;
            END;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP || '. APPLICATION_ID: ' || TO_CHAR(V_APPLICATION_ID);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                QUEUE_NUMBER_IN := -1;
            WHEN OTHERS
            THEN
                QUEUE_NUMBER_IN := -1;
        END;

        V_SIGNAL := SIGNAL_IN;

        IF UPPER(V_SIGNAL) = 'N/A'
        THEN
            V_STEP := 'Taking cont_anyway value';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF REQUEST_IN = 'FAILED'
            OR REQUEST_IN = 'DQ_CRITICAL'
            THEN
                SELECT   CASE
                             WHEN CONT_ANYWAY = 1
                              AND N_RUN >= MAX_RUNS
                             THEN
                                 1
                             ELSE
                                 0
                         END
                             AS CONT_ANYWAY
                  INTO   V_CONT_ANYWAY
                  FROM   SESS_JOB SJ
                 WHERE   SJ.JOB_ID = JOB_ID_IN;
            ELSE
                V_CONT_ANYWAY := 0;
            END IF;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Signal value not defined, taking it from request value';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   COUNT( * )
              INTO   V_CNT
              FROM   CTRL_NEXT_STATUS CNS
             WHERE   STATUS_IN = V_STATUS_IN
                 AND REQUEST = UPPER(REQUEST_IN)
                 AND LAUNCH = LAUNCH_IN
                 AND CONT_ANYWAY = V_CONT_ANYWAY;

            IF V_CNT <> 1
            THEN
                RETURN_STATUS_OUT := 'error';
            ELSE
                SELECT   SIGNAL
                  INTO   V_SIGNAL
                  FROM   CTRL_NEXT_STATUS CNS
                 WHERE   STATUS_IN = V_STATUS_IN
                     AND REQUEST = UPPER(REQUEST_IN)
                     AND LAUNCH = LAUNCH_IN
                     AND CONT_ANYWAY = V_CONT_ANYWAY;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            END IF;
        END IF;

        IF RETURN_STATUS_OUT <> 'error'
        THEN
            V_STEP := 'Taking value of status_out from CTRL_NEXT_STATUS table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   STATUS_OUT
              INTO   V_STATUS_OUT
              FROM   CTRL_NEXT_STATUS CNS
             WHERE   CNS.STATUS_IN = V_STATUS_IN
                 AND CNS.SIGNAL = V_SIGNAL;

            IF QUEUE_NUMBER_IN < 0
            THEN
                RETURN_STATUS_OUT := 'skip';
            ELSE
                RETURN_STATUS_OUT := 'run';
            END IF;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF QUEUE_NUMBER_IN >= 0
            THEN
                V_STEP := 'Updating status of the queue in SESS_QUEUE table';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   SESS_QUEUE
                   SET   JOB_ID = JOB_ID_IN
                       , LAST_UPDATE = CURRENT_TIMESTAMP
                       , JOB_NAME =
                             (SELECT   JOB_NAME
                                FROM   SESS_JOB
                               WHERE   JOB_ID = JOB_ID_IN)
                       , AVAILABLE = 1 - LAUNCH_IN
                 WHERE   QUEUE_NUMBER = QUEUE_NUMBER_IN
                     AND ENGINE_ID = ENGINE_ID_IN;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            END IF;

            V_STEP := 'Updating last_update and, n_run and status in SESS_JOB table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   SESS_JOB SJ
               SET   SJ.STATUS = V_STATUS_OUT, SJ.LAST_UPDATE = CURRENT_TIMESTAMP, SJ.N_RUN = N_RUN + LAUNCH_IN
             WHERE   SJ.JOB_ID = JOB_ID_IN;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Taking info if status is final from CTRL_JOB_STATUS table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CJS.FINISHED
              INTO   V_FINISHED
              FROM   CTRL_JOB_STATUS CJS
             WHERE   STATUS = V_STATUS_OUT;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF V_FINISHED = 1
            THEN
                V_STEP := 'Deleting job dependency from SESS_JOB_DEPENDENCY table';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                DELETE FROM   SESS_JOB_DEPENDENCY
                      WHERE   PARENT_JOB_ID = JOB_ID_IN;

                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            END IF;

            V_STEP := 'Taking status timestamp from SESS_STATUS table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   MAX(SS.STATUS_TS)
              INTO   V_STATUS_TS
              FROM   SESS_STATUS SS
             WHERE   JOB_ID = JOB_ID_IN;

            V_STATUS_TS := NVL(V_STATUS_TS, TO_TIMESTAMP('2000-01-01 12:00:00', 'YYYY-MM-DD HH:MI:SS'));
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Correcting status_ts';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            SELECT   CASE WHEN V_STATUS_TS + 1 / 24 / 60 / 60 / 1000 < CURRENT_TIMESTAMP(6) THEN CURRENT_TIMESTAMP(6) ELSE V_STATUS_TS + 1 / 24 / 60 / 60 / 100 END AS STATUS_TS
              INTO   V_STATUS_TS
              FROM   DUAL;

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            V_STEP := 'Inserting into SESS_STATUS';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

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
                SELECT   SJ.JOB_ID
                       , SJ.JOB_NAME
                       , SJ.STREAM_NAME
                       , V_STATUS_TS
                       , SJ.LOAD_DATE
                       , SJ.STATUS
                       , SJ.N_RUN
                       , V_SIGNAL
                       , V_APPLICATION_ID
                       , SJ.ENGINE_ID
                  FROM   SESS_JOB SJ
                 WHERE   SJ.JOB_ID = JOB_ID_IN
                     AND SJ.PHASE != 'INITIALIZATION';

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        END IF;
/*
        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := NVL(ERRLINE_OUT, -1);
*/
        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            EXIT_CD := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'NO DATA FOUND ' || V_STEP;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := RETURN_STATUS_OUT;
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
    END SP_ENG_GUI_UPDATE_STATUS;


    --------------------------------------------------------------------------------------------------------------


       PROCEDURE SP_ENG_SYSTEM_ENABLE(
                                   SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_SYSTEM_ENABLE
        IN parameters:
                        SYSTEM_NAME_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\System_enable.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2015-02-23
        -------------------------------------------------------------------------------
        Description: Enable processing on system
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_SYSTEM_ENABLE';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SYSTEM_NAME_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        V_STEP := 'Enabling system';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXIT_CD := 0;
        RETURN_STATUS_OUT := 'N/A';

        UPDATE CTRL_PARAMETERS
        SET
          param_val_int = 0
        WHERE param_name = 'SYSTEM_OFF'
        AND param_val_char = system_name_in;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Returning back maximal values in CTRL_TASK_PARAMETERS table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE CTRL_TASK_PARAMETERS
        SET
          param_val_int_max = param_val_int_default
        WHERE param_type = 'PARALLELISM_CONTROL'
        AND system_name = system_name_in;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP ;


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
    END SP_ENG_SYSTEM_ENABLE;

  PROCEDURE SP_ENG_SYSTEM_DISABLE(
                                   SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_SYSTEM_DISABLE
        IN parameters:
                        SYSTEM_NAME_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\System_disable.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2015-02-23
        -------------------------------------------------------------------------------
        Description: Disable processing on system
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_SYSTEM_DISABLE';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SYSTEM_NAME_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        V_STEP := 'Disabling system';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXIT_CD := 0;
        RETURN_STATUS_OUT := 'N/A';

        UPDATE CTRL_PARAMETERS
        SET
          param_val_int = 1
        WHERE param_name = 'SYSTEM_OFF'
        AND param_val_char = system_name_in;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Setting maximal values in CTRL_TASK_PARAMETERS table to 0';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE CTRL_TASK_PARAMETERS
        SET
          param_val_int_max = 0
        WHERE param_type = 'PARALLELISM_CONTROL'
        AND system_name = system_name_in;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP ;


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
    END SP_ENG_SYSTEM_DISABLE;

  PROCEDURE SP_ENG_TAKE_CONTROL(
                                   ENGINE_ID_IN INTEGER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_VALUE_OUT   OUT NOCOPY NUMBER
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_TAKE_CONTROL
        IN parameters:
                        ENGINE_ID_IN
                        SYSTEM_NAME_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2015-02-23
        -------------------------------------------------------------------------------
        Description: Taking control in Get job list
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_TAKE_CONTROL';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_CNT              NUMBER;
        V_CNT_OFF          NUMBER;

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SYSTEM_NAME_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;
        RETURN_STATUS_OUT := 'N/A';


        V_STEP := 'CHECK IF SYSTEM IS ENABLED';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT( * )
              INTO   V_CNT_OFF
        FROM CTRL_PARAMETERS
        WHERE param_name = 'SYSTEM_OFF'
        AND param_val_char = system_name_in
        AND param_val_int = 1;

        /* 0 - SYSTEM IS ENABLED*/
        IF V_CNT_OFF=0 THEN

          V_STEP := 'Traying take control';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

          UPDATE CTRL_PARAMETERS
          SET
            param_val_char = system_name_in,
            param_val_int = 1,
            param_val_ts = CURRENT_TIMESTAMP
          WHERE param_name = 'ENGINE_CONTROL'
          AND param_cd = engine_id_in
          AND param_val_int = 0;

          V_STEP := 'Checking success of taking control';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

          SELECT   COUNT( * )
                INTO   V_CNT
          FROM CTRL_PARAMETERS
          WHERE param_name = 'ENGINE_CONTROL'
          AND param_cd = engine_id_in
          AND param_val_char = system_name_in
          AND param_val_int = 1;

          IF V_CNT > 0
          THEN
            /*SUCCESFULLY LOCKED*/
            return_value_out := 0;
          ELSE
            return_value_out := 1;
            RETURN_STATUS_OUT := 'Another system took the control under engine.';
          END IF;
        ELSE
            /*SYSTEM OFF*/
            return_value_out := 1;
            RETURN_STATUS_OUT := 'System is off.';
        END IF;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP ;


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
    END SP_ENG_TAKE_CONTROL;

  PROCEDURE SP_ENG_GIVE_CONTROL(
                                   ENGINE_ID_IN INTEGER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_ENG_GIVE_CONTROL
        IN parameters:
                        ENGINE_ID_IN
                        SYSTEM_NAME_IN
                        DEBUG_IN
        OUT parameters:
                        DEBUG_IN
                        RETURN_STATUS_OUT
                        EXIT_CD - procedure exit code (0 - OK)
                        ERRMSG_OUT
                        ERRCODE_OUT
                        ERRLINE_OUT
        Called from:   PERL script %PMRootDir%\Bin\Framework\Engine.pl
        Calling:   None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project:   PDC
        Author:   Teradata - Petr Stefanek
        Date:    2015-02-23
        -------------------------------------------------------------------------------
        Description: Giving control in Get job list
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_ENG_GIVE_CONTROL';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_CNT              NUMBER;

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := SYSTEM_NAME_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        V_STEP := 'Giving control';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        EXIT_CD := 0;
        RETURN_STATUS_OUT := 'N/A';

        UPDATE CTRL_PARAMETERS
        SET
          param_val_char = system_name_in,
          param_val_int = 0,
          param_val_ts = CURRENT_TIMESTAMP
        WHERE param_name = 'ENGINE_CONTROL'
        AND param_cd = engine_id_in
        AND param_val_char = system_name_in
        AND param_val_int = 1;


        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'DEBUG> ' || V_STEP ;


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
    END SP_ENG_GIVE_CONTROL;





    ------------------------------------------------------------------------------------------------------------------

END PCKG_ENGINE;

