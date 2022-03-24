
  CREATE OR REPLACE PACKAGE BODY "PDC"."PCKG_SNFR"
IS

    PROCEDURE SP_SNFR_ALERT_ZONE(SOURCE_NM_IN IN VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SNFR_ALERT_ZONA
        IN parameters:
                       ENGINE_ID_IN
                       SOURCE_NM_IN
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
        Date:    2010-03-11
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2013-09-13
        Modification: Rewritten
        *******************************************************************************/
        --constants
        C_PROC_NAME                  CONSTANT VARCHAR2(64) := 'SP_SNFR_ALERT_ZONE';
        --exceptions
        EX_RUN_TIME_IN_LIMIT EXCEPTION;
        EX_RUN_TIME_OUT_OF_LIMIT EXCEPTION;
        -- local variables
        V_STEP                       VARCHAR2(1024);
        V_ALL_DBG_INFO               PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID                INTEGER := 0;

        V_RUNPLAN                    CHAR(9);
        V_CRITICAL                   INTEGER;
        V_ALERT_ZONE_END_TM          INTEGER;
        V_NOWAIT_ALERT_ZONE_END_TM   INTEGER;
        V_WAITING_TM                 INTEGER;
        V_LOAD_DATE                  DATE;
        V_SOURCE_ID                  INTEGER;
        V_DELIVERED                  INTEGER;
        V_RELATED_TO_INITIALIZATION   INTEGER;
        V_ENGINE_ID                  INTEGER;
        V_INIT_END_TS                 TIMESTAMP;
        V_CURRENT_MINUTE             INTEGER;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'Get parameters';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   SOURCE_ID
          INTO   V_SOURCE_ID
          FROM   CTRL_SOURCE
         WHERE   SOURCE_NM = SOURCE_NM_IN;

        V_STEP := 'Get parameters load date and engine_id';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   CP.PARAM_VAL_DATE,CJ.ENGINE_ID
          INTO   V_LOAD_DATE,V_ENGINE_ID
        FROM
            CTRL_SOURCE CS
        INNER JOIN
            CTRL_JOB CJ
                ON
                CS.SNIFFER_JOB_NAME = CJ.JOB_NAME
        INNER JOIN
            CTRL_PARAMETERS CP
                ON
                CP.PARAM_CD = CJ.ENGINE_ID
                AND
                CP.PARAM_NAME = 'LOAD_DATE'
        WHERE
          CS.SOURCE_NM = SOURCE_NM_IN;

        V_STEP := 'Open cursor';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        --set initial value--
        V_ALERT_ZONE_END_TM := -1;
        V_NOWAIT_ALERT_ZONE_END_TM := -1;
        V_CRITICAL := -1;
        V_RELATED_TO_INITIALIZATION := -1;
        DECLARE
            CURSOR PLAN_CUR
            IS
                SELECT RUNPLAN,
                        (CASE WHEN ALERT_TM_IN_MINUTES=0 THEN  ALERT_ZONE_END_TM*60 ELSE ALERT_ZONE_END_TM END) AS ALERT_ZONE_END_TM,
                        (CASE WHEN ALERT_TM_IN_MINUTES=0 THEN NOWAIT_ALERT_ZONE_END_TM*60 ELSE NOWAIT_ALERT_ZONE_END_TM END) AS NOWAIT_ALERT_ZONE_END_TM,
                        CRITICAL,
                        RELATED_TO_INITIALIZATION
                   FROM CTRL_SOURCE_PLAN_REF
                  WHERE SOURCE_ID = V_SOURCE_ID
                 ORDER BY CRITICAL DESC;
        BEGIN -- Level_2
            FOR R_PLAN_CUR IN PLAN_CUR
            LOOP
                V_STEP := 'Opening PLAN_CUR';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                 IF PCKG_TOOLS.F_DATE_MATCH_RUNPLAN (V_LOAD_DATE, R_PLAN_CUR.RUNPLAN) = 1
                 THEN
                    V_ALERT_ZONE_END_TM :=
                       GREATEST (R_PLAN_CUR.ALERT_ZONE_END_TM,V_ALERT_ZONE_END_TM);
                    V_CRITICAL := GREATEST (R_PLAN_CUR.CRITICAL, V_CRITICAL);
                    V_RELATED_TO_INITIALIZATION :=
                       GREATEST (R_PLAN_CUR.RELATED_TO_INITIALIZATION, V_RELATED_TO_INITIALIZATION);
                 END IF;
                 V_NOWAIT_ALERT_ZONE_END_TM :=
                       GREATEST (R_PLAN_CUR.NOWAIT_ALERT_ZONE_END_TM, V_NOWAIT_ALERT_ZONE_END_TM);
            END LOOP;

            IF V_CRITICAL = -1
            THEN
                V_STEP := 'no plan for load_date ' || TO_CHAR(V_LOAD_DATE,'DD.MM.YYYY HH24:MI:SS');
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                V_WAITING_TM := V_NOWAIT_ALERT_ZONE_END_TM;
            ELSE
                V_WAITING_TM := V_ALERT_ZONE_END_TM;
            END IF;

            V_STEP := 'getting current hour';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF V_RELATED_TO_INITIALIZATION = 1
             THEN
                SELECT PARAM_VAL_TS
                  INTO V_INIT_END_TS
                  FROM CTRL_PARAMETERS
                 WHERE     PARAM_NAME = 'INITIALIZATION_END'
                       AND PARAM_CD = V_ENGINE_ID;

                --V_CURRENT_HOUR--
                SELECT     EXTRACT (DAY FROM (CURRENT_TIMESTAMP - V_INIT_END_TS))* 24*60
                       + EXTRACT (HOUR FROM (CURRENT_TIMESTAMP - V_INIT_END_TS))*60
                       + EXTRACT (MINUTE FROM (CURRENT_TIMESTAMP - V_INIT_END_TS))
                INTO V_CURRENT_MINUTE
                FROM DUAL;
            ELSE
                --V_CURRENT_HOUR--
                SELECT     EXTRACT (DAY FROM (  CURRENT_TIMESTAMP - V_LOAD_DATE))* 24 *60
                   + EXTRACT (HOUR FROM (  CURRENT_TIMESTAMP - V_LOAD_DATE))*60
                   + EXTRACT (MINUTE FROM (CURRENT_TIMESTAMP - V_LOAD_DATE))
                INTO V_CURRENT_MINUTE
                FROM DUAL;
            END IF;

            SELECT COUNT (*)
              INTO V_DELIVERED
            FROM STAT_SRCTABLE_LOAD_HIST
              WHERE     SOURCE_ID = V_SOURCE_ID
              AND LOAD_DATE = V_LOAD_DATE;

            EXIT_CD := 0;
            IF(V_CURRENT_MINUTE <= V_WAITING_TM AND V_DELIVERED = 0)
              OR (V_CRITICAL = 1 AND V_DELIVERED = 0)
                    THEN
                        V_STEP := 'source has not been delivered yet and source is critical or alert zone not ended';
                        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
                        EXIT_CD := -9;
            END IF;
        END;

        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := SUBSTR(NVL(ERRLINE_OUT, -1), 1, 1024);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

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

            ERRLINE_OUT := SUBSTR('NO DATA FOUND ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);

        WHEN OTHERS
        THEN
            EXIT_CD := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := SUBSTR('OTHER ERROR ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);


    END SP_SNFR_ALERT_ZONE;


        PROCEDURE SP_SNFR_JOB_SNIFFED(JOB_ID_SNIFFER_IN IN NUMBER
                               , JOB_NAME_IN IN VARCHAR2
                               , UNMASKED_TABLE_NAME_IN IN VARCHAR2
                               , UNMASKED_LOG_NAME_IN IN VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SNFR_JOB_SNIFFED
        IN parameters:
                       JOB_NAME_IN
                       UNMASKED_TABLE_NAME_IN
                       UNMASKED_LOG_NAME_IN
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
        Author:   Teradata - Vladimir Duchon
        Date:    2011-09-11
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                  CONSTANT VARCHAR2(64) := 'SP_SNFR_JOB_SNIFFED';
        --exceptions
        EX_RUN_TIME_IN_LIMIT EXCEPTION;
        EX_RUN_TIME_OUT_OF_LIMIT EXCEPTION;
        -- local variables
        V_STEP                       VARCHAR2(1024);
        V_ALL_DBG_INFO               PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID                INTEGER := 0;
        V_ENG_RUN_TIME               INTEGER := 0;
        V_ENG_RUN_TIME_DIFF          INTEGER := 0;
        --V_DWH_DATE                   DATE := TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY');
        V_ERRORCODE                  INTEGER;
        V_ERRORTEXT                  VARCHAR2(1024);

        V_DEP_JOB_NAME               VARCHAR2(1024);
        V_DEP_PARENT_JOB_NAME        VARCHAR2(1024);

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        V_STEP := 'UPSERT SESS_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        MERGE INTO SESS_SRCTABLE T  USING (
             SELECT
               UNMASKED_TABLE_NAME_IN AS TABLE_NAME
               ,UNMASKED_LOG_NAME_IN AS LOG_NAME
               , CST.COMMON_TABLE_NAME
               , CS.SCHEMA_NAME
                , CST.SOURCE_ID
                , SJ.JOB_ID
                , CST.JOB_NAME
                , NULL EFF_LOAD_DATE
                , CP.PARAM_VAL_DATE AS LOAD_DATE
                , 'PREPARED' LOAD_STATUS
                , sysdate INSERT_TS
             FROM
               CTRL_SRCTABLE CST
             INNER JOIN
               CTRL_SOURCE CS
                 ON CST.SOURCE_ID = CS.SOURCE_ID
             INNER JOIN
                CTRL_JOB CJ
                    ON
                    CS.SNIFFER_JOB_NAME = CJ.JOB_NAME
             INNER JOIN
                CTRL_PARAMETERS CP
                    ON
                    CP.PARAM_CD = CJ.ENGINE_ID
                    AND
                    CP.PARAM_NAME = 'LOAD_DATE'
             INNER JOIN
               SESS_JOB SJ
                 ON SJ.JOB_NAME = CST.JOB_NAME
             WHERE CST.JOB_NAME = JOB_NAME_IN
        ) S
             ON (S.JOB_NAME = T.JOB_NAME)
             WHEN NOT MATCHED THEN
             INSERT
              (TABLE_NAME,LOG_NAME,COMMON_TABLE_NAME,SCHEMA_NAME,SOURCE_ID,JOB_ID,JOB_NAME,EFF_LOAD_DATE,LOAD_DATE,LOAD_STATUS,INSERT_TS)
              VALUES (S.TABLE_NAME,S.LOG_NAME,S.COMMON_TABLE_NAME,S.SCHEMA_NAME,S.SOURCE_ID,S.JOB_ID,S.JOB_NAME,S.EFF_LOAD_DATE,S.LOAD_DATE,S.LOAD_STATUS,S.INSERT_TS)
             WHEN MATCHED THEN
            UPDATE SET
                 TABLE_NAME = TABLE_NAME
                 ,LOG_NAME = LOG_NAME
                 ,COMMON_TABLE_NAME = COMMON_TABLE_NAME
                 ,SCHEMA_NAME = SCHEMA_NAME
                 ,SOURCE_ID = SOURCE_ID
                 ,JOB_ID = JOB_ID
                 ,EFF_LOAD_DATE = EFF_LOAD_DATE
                 ,LOAD_DATE = LOAD_DATE
                 ,LOAD_STATUS = LOAD_STATUS
                 ,INSERT_TS = INSERT_TS;


        IF SQL%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
        END IF;

        SELECT
          (SJ.STREAM_NAME || '_STREAM_BEGIN')
        INTO
          V_DEP_JOB_NAME
        FROM
          SESS_JOB  SJ
        WHERE SJ.JOB_NAME = JOB_NAME_IN;

        IF SQL%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
        END IF;

        SELECT
          (SJ.STREAM_NAME || '_STREAM_END')
        INTO
          V_DEP_PARENT_JOB_NAME
        FROM
          SESS_JOB  SJ
        WHERE
          JOB_ID = JOB_ID_SNIFFER_IN;

        IF SQL%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
        END IF;

        --INSERT INTO SESS_JOB_DEPENDENCY (JOB_ID,PARENT_JOB_ID,JOB_NAME,PARENT_JOB_NAME) VALUES(999,999,V_DEP_JOB_NAME,V_DEP_PARENT_JOB_NAME);
        --commit;

        DELETE FROM SESS_JOB_DEPENDENCY WHERE JOB_NAME = V_DEP_JOB_NAME AND PARENT_JOB_NAME = V_DEP_PARENT_JOB_NAME;

        IF SQL%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
        END IF;


        COMMIT;






        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := SUBSTR(NVL(ERRLINE_OUT, -1), 1, 1024);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

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

            ERRLINE_OUT := SUBSTR('NO DATA FOUND ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);

        WHEN OTHERS
        THEN
            ROLLBACK;

            EXIT_CD := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := SUBSTR('OTHER ERROR ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);


    END SP_SNFR_JOB_SNIFFED;

        PROCEDURE SP_SNFR_SKIP_UNPROCESSED(SOURCE_NM_IN IN VARCHAR2
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_SNFR_SKIP_UNPROCESSED
        IN parameters:
                       SOURCE_NM_IN
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
        Author:   Teradata - Vladimir Duchon
        Date:    2011-09-11
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME                  CONSTANT VARCHAR2(64) := 'SP_SNFR_SKIP_UNPROCESSED';
        --exceptions
        EX_RUN_TIME_IN_LIMIT EXCEPTION;
        EX_RUN_TIME_OUT_OF_LIMIT EXCEPTION;
        -- local variables
        V_STEP                       VARCHAR2(1024);
        V_ALL_DBG_INFO               PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID                INTEGER := 0;
        V_ENG_RUN_TIME               INTEGER := 0;
        V_ENG_RUN_TIME_DIFF          INTEGER := 0;
        --V_DWH_DATE                   DATE := TO_CHAR(TO_DATE(PCKG_FWRK.F_GET_CTRL_PARAMETERS('load_date', 'param_val_date'), 'DD.MM.YYYY'), 'DD.MM.YYYY');
        V_ERRORCODE                  INTEGER;
        V_ERRORTEXT                  VARCHAR2(1024);

    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;



        V_STEP := 'Open cursor';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        DECLARE
            CURSOR UNPROCESS_CUR
            IS
                  SELECT
                     CST.JOB_NAME
                    ,CJ.STREAM_NAME
                  FROM
                    CTRL_SRCTABLE CST
                  INNER JOIN
                    CTRL_SOURCE CS
                    ON
                      CS.SOURCE_ID=CST.SOURCE_ID
                  INNER JOIN
                    CTRL_JOB CJ
                    ON CST.job_name = CJ.job_name
                  WHERE
                    CS.SOURCE_NM = SOURCE_NM_IN
                    AND
                    CST.JOB_NAME NOT IN (
                       SELECT
                          SST.JOB_NAME
                       FROM
                          SESS_SRCTABLE SST
                       INNER JOIN
                          CTRL_SOURCE CS
                          ON
                            CS.SOURCE_ID=SST.SOURCE_ID
                       WHERE
                          SST.LOAD_STATUS<>'FAILED'
                    );

        BEGIN -- Level_2
            FOR R_UNPROCESS_CUR IN UNPROCESS_CUR
            LOOP
                V_STEP := 'Opening UNPROCESS_CUR';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE SESS_JOB
                SET status = 100, MAX_RUNS=MAX_RUNS+3 -- MAX_RUNS ARE INCREASED, BECAUSE FAILED JOB COULD REACH N_RUN=MAX_RUNS
                WHERE stream_name = R_UNPROCESS_CUR.stream_name;

            MERGE INTO SESS_SRCTABLE T  USING (
             SELECT
               CST.COMMON_TABLE_NAME AS TABLE_NAME
               ,CST.COMMON_TABLE_NAME AS LOG_NAME
               , CST.COMMON_TABLE_NAME
               , CS.SCHEMA_NAME
                , CST.SOURCE_ID
                , SJ.JOB_ID
                , CST.JOB_NAME
                , NULL EFF_LOAD_DATE
                , CP.PARAM_VAL_DATE AS LOAD_DATE
                , 'SKIPPED' LOAD_STATUS
                , sysdate INSERT_TS
             FROM
               CTRL_SRCTABLE CST
             INNER JOIN
               CTRL_SOURCE CS
                 ON CST.SOURCE_ID = CS.SOURCE_ID
             INNER JOIN
                CTRL_JOB CJ
                    ON
                    CS.SNIFFER_JOB_NAME = CJ.JOB_NAME
             INNER JOIN
                CTRL_PARAMETERS CP
                    ON
                    CP.PARAM_CD = CJ.ENGINE_ID
                    AND
                    CP.PARAM_NAME = 'LOAD_DATE'
             INNER JOIN
               SESS_JOB SJ
                 ON SJ.JOB_NAME = CST.JOB_NAME
             WHERE CST.JOB_NAME = R_UNPROCESS_CUR.job_name
        ) S
             ON (S.JOB_NAME = T.JOB_NAME)
             WHEN NOT MATCHED THEN
             INSERT
              (TABLE_NAME,LOG_NAME,COMMON_TABLE_NAME,SCHEMA_NAME,SOURCE_ID,JOB_ID,JOB_NAME,EFF_LOAD_DATE,LOAD_DATE,LOAD_STATUS,INSERT_TS)
              VALUES (S.TABLE_NAME,S.LOG_NAME,S.COMMON_TABLE_NAME,S.SCHEMA_NAME,S.SOURCE_ID,S.JOB_ID,S.JOB_NAME,S.EFF_LOAD_DATE,S.LOAD_DATE,S.LOAD_STATUS,S.INSERT_TS)
             WHEN MATCHED THEN
            UPDATE SET
                 TABLE_NAME = S.TABLE_NAME
                 ,LOG_NAME = S.LOG_NAME
                 ,COMMON_TABLE_NAME = S.COMMON_TABLE_NAME
                 ,SCHEMA_NAME = S.SCHEMA_NAME
                 ,SOURCE_ID = S.SOURCE_ID
                 ,JOB_ID = S.JOB_ID
                 ,EFF_LOAD_DATE = S.EFF_LOAD_DATE
                 ,LOAD_DATE = S.LOAD_DATE
                 ,LOAD_STATUS = S.LOAD_STATUS
                 ,INSERT_TS = S.INSERT_TS;

          END LOOP;
        END; -- Level_2


        ERRMSG_OUT := NVL(ERRMSG_OUT, 'FINISHED OK');

        ERRCODE_OUT := NVL(ERRCODE_OUT, TO_CHAR(EXIT_CD));

        ERRLINE_OUT := SUBSTR(NVL(ERRLINE_OUT, -1), 1, 1024);

        IF DEBUG_IN = 1
        THEN
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

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

            ERRLINE_OUT := SUBSTR('NO DATA FOUND ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);

        WHEN OTHERS
        THEN
            EXIT_CD := -2;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := SUBSTR('OTHER ERROR ' || V_STEP, 1, 1024);

            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := EXIT_CD;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRMSG_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ERRCODE_OUT;
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := SUBSTR(ERRLINE_OUT, 1, 1024);

            PCKG_PLOG.INFO(V_STEP);
            PCKG_PLOG.FATAL();
            PCKG_PLOG.SETPROCPARAMS(PROCEDURE_NAME_IN => C_PROC_NAME, ALL_ARGUMENTS_IN => V_ALL_DBG_INFO);


    END SP_SNFR_SKIP_UNPROCESSED;



END;

