
  CREATE OR REPLACE PACKAGE BODY "PDC"."PCKG_INIT"
AS
    PROCEDURE SP_INIT_INITIALIZE(ENGINE_ID_IN IN NUMBER DEFAULT 0
                               , DEBUG_IN IN   INTEGER:= 0
                               , EXIT_CD   OUT NOCOPY NUMBER
                               , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                               , ERRCODE_OUT   OUT NOCOPY NUMBER
                               , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_INITIALIZE
        IN parameters:
                      engine_id_in
        OUT parameters:
                      exit_cd - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT

        Called from: PERL script %PMRootDir%\Bin\Framework\Initialization
        \Init_Initialize.pl
        Calling: SP_INIT_UPDATE_JOB_STATUS
        SP_INIT_SRCTABLE
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - main part
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME             CONSTANT VARCHAR2(64) := 'SP_INIT_INITIALIZE';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE             INTEGER;
        V_ERRORTEXT             VARCHAR2(1024);
        V_STEP                  VARCHAR2(1024);
        V_LOAD_DATE             DATE;
        V_CNT                   INTEGER;
        V_ANSWER                VARCHAR2(16);
        V_APPLICATION_ID        INTEGER;
        V_DATA_QUALITY_ACTIVE   INTEGER;

        V_ALL_ARGUMENTS         PCKG_PLOG.T_VARCHAR2;

        V_ALL_DBG_INFO          PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID           INTEGER := 0;
        V_MIN_TOUGHNESS   INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'DEBUG> ' || V_STEP || '. LOAD_DATE: ' || TO_CHAR(V_LOAD_DATE);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Taking value of APPLICATION_ID parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_APPLICATION_ID
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking value of DATA_QUALITY_ACTIVE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_DATA_QUALITY_ACTIVE := 1;

        SELECT   PARAM_VAL_INT
          INTO   V_DATA_QUALITY_ACTIVE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'DQ_ACTIVE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking minimal toughness defined in CTRL_TASK_PARAMETERS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT MIN(PARAM_VAL_INT_DEFAULT)
          INTO V_MIN_TOUGHNESS
        FROM ctrl_task_parameters WHERE ENGINE_ID=ENGINE_ID_IN
          AND param_type IN ('TOUGH_CATEGORY_CONTROL','TOUGH_JOB_CONTROL','TOUGH_SPEC_CATEGORY_CONTROL');


        V_STEP := 'Exec SP_INIT_RECALC_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        PCKG_INIT.SP_INIT_RECALC_STATISTICS(ENGINE_ID_IN   => ENGINE_ID_IN
                                          , DEBUG_IN       => DEBUG_IN
                                          , EXIT_CD        => EXIT_CD
                                          , ERRMSG_OUT     => ERRMSG_OUT
                                          , ERRCODE_OUT    => ERRCODE_OUT
                                          , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;


        V_STEP := 'SP_INIT_RECALC_STATISTICS executed';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        DECLARE
            V_STEP   PLS_INTEGER := 0;
        BEGIN
            V_STEP := 1;

            --
            DELETE FROM   SESS_JOB_TABLE_REF A
                  WHERE   A.JOB_NAME IN (SELECT   B.JOB_NAME
                                           FROM   CTRL_JOB B
                                          WHERE   B.ENGINE_ID = ENGINE_ID_IN);

            V_STEP := 2;

            --
            INSERT INTO SESS_JOB_TABLE_REF
                SELECT   CJTB.JOB_NAME
                       , CJTB.DATABASE_NAME
                       , CJTB.TABLE_NAME
                       , CJTB.LOCK_TYPE
                  FROM   CTRL_JOB_TABLE_REF CJTB
                 WHERE   CJTB.JOB_NAME IN (SELECT   CJ.JOB_NAME
                                             FROM   CTRL_JOB CJ
                                            WHERE   CJ.ENGINE_ID = ENGINE_ID_IN);

            V_STEP := 3;

            IF V_DATA_QUALITY_ACTIVE != 1
            THEN
                DELETE FROM   SESS_JOB_TABLE_REF A
                      WHERE   UPPER(A.TABLE_NAME) = 'STAT_DATA_QUALITY_LOG'
                          AND A.JOB_NAME IN (SELECT   B.JOB_NAME
                                               FROM   CTRL_JOB B
                                              WHERE   B.ENGINE_ID = ENGINE_ID_IN);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                IF V_STEP = 1
                THEN
                    INSERT INTO SESS_JOB_TABLE_REF
                        SELECT   CJTB.JOB_NAME
                               , CJTB.DATABASE_NAME
                               , CJTB.TABLE_NAME
                               , CJTB.LOCK_TYPE
                          FROM   CTRL_JOB_TABLE_REF CJTB
                         WHERE   CJTB.JOB_NAME IN (SELECT   CJ.JOB_NAME
                                                     FROM   CTRL_JOB CJ
                                                    WHERE   CJ.ENGINE_ID = ENGINE_ID_IN);
                ELSIF V_STEP = 2
                THEN
                    IF V_DATA_QUALITY_ACTIVE != 1
                    THEN
                        DELETE FROM   SESS_JOB_TABLE_REF A
                              WHERE   UPPER(A.TABLE_NAME) = 'STAT_DATA_QUALITY_LOG'
                                  AND A.JOB_NAME IN (SELECT   B.JOB_NAME
                                                       FROM   CTRL_JOB B
                                                      WHERE   B.ENGINE_ID = ENGINE_ID_IN);
                    END IF;
                END IF;
        END;

        --

        DELETE FROM   SESS_JOB_BCKP
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := ' STEP> ' || V_STEP;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Deleting jobs from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP)
                   OR PARENT_JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP);

        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_BEGIN jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , toughness
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID_SEQ.NEXTVAL
                   , CJ.STREAM_NAME || '_STREAM_BEGIN'
                   , CJ.STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_BEGIN' --job_type
                   , 0 --toughness
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID_IN
              FROM   (  SELECT   STREAM_NAME
                          FROM   CTRL_JOB
                         WHERE   NVL(PHASE, 'N/A') <> 'INITIALIZATION'
                             AND ENGINE_ID = ENGINE_ID_IN
                      GROUP BY   STREAM_NAME) CJ;


        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_END jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , toughness
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID
                   , STREAM_NAME || '_STREAM_END'
                   , STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_END' --job_type
                   , 0 --toughness
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting jobs from streams  <> INITIALIZATION into SESS_JOB_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , toughness
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , SJ.STREAM_ID
                   , CJ.JOB_NAME
                   , CJ.STREAM_NAME
                   , 0 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , CJ.PRIORITY
                   , CJ.CMD_LINE
                   , CJ.SRC_SYS_ID
                   , CJ.PHASE
                   , CJ.TABLE_NAME
                   , CJ.JOB_CATEGORY
                   , CJ.JOB_TYPE
                   , V_MIN_TOUGHNESS  -- temporary, before final toughness calculation from CTRL_TASK_PARAMETERS
                   , CJ.CONT_ANYWAY
                   , CJ.ALWAYS_RESTART --restart
                   , CJ.ALWAYS_RESTART
                   , 0 --n_rub
                   , CJ.MAX_RUNS
                   , CJ.WAITING_HR
                   , CJ.DEADLINE_HR
                   , V_APPLICATION_ID
                   , CJ.ENGINE_ID
              FROM       CTRL_JOB CJ
                     INNER JOIN
                         SESS_JOB_BCKP SJ
                     ON CJ.STREAM_NAME = SJ.STREAM_NAME
                    AND SJ.JOB_NAME = CJ.STREAM_NAME || '_STREAM_BEGIN'
                    AND CJ.ENGINE_ID = ENGINE_ID_IN
             WHERE   NVL(CJ.PHASE, 'N/A') <> 'INITIALIZATION';

        V_STEP := 'Update sess_job_bkp - calculation of toughness of jobs - DEFAULT VALUES';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE SESS_JOB_BCKP SJB
        SET TOUGHNESS = NVL((select CTP.PARAM_VAL_INT_DEFAULT
        FROM CTRL_TASK_PARAMETERS CTP
        INNER JOIN CTRL_JOB CJ ON CJ.job_category=CTP.task_subtype AND UPPER(CJ.toughness)=UPPER(CTP.param_name)
        WHERE CTP.param_type='TOUGH_CATEGORY_CONTROL' AND CTP.ENGINE_ID=ENGINE_ID_IN
        AND SJB.job_name= cj.job_name AND cj.engine_id=ENGINE_ID_IN),V_MIN_TOUGHNESS) WHERE SJB.ENGINE_ID=ENGINE_ID_IN;

        V_STEP := 'Update sess_job_bkp - phase specific toughness  calculation';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE SESS_JOB_BCKP SJB
        SET TOUGHNESS = nvl((select CTP.PARAM_VAL_INT_DEFAULT
        FROM CTRL_TASK_PARAMETERS CTP
        INNER JOIN CTRL_JOB CJ ON CTP.PARAM_NAME=CJ.TOUGHNESS
        WHERE CTP.param_type='TOUGH_SPEC_CATEGORY_CONTROL'
          AND CTP.PARAM_DIMENSION=SJB.PHASE
          AND CTP.ENGINE_ID=ENGINE_ID_IN
          AND SJB.JOB_NAME=CJ.JOB_NAME
          AND SJB.ENGINE_ID=ENGINE_ID_IN),TOUGHNESS);

        V_STEP := 'Update sess_job_bkp - calculation of toughness of jobs - EXCEPTIONS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE SESS_JOB_BCKP SJB
        SET TOUGHNESS = nvl((select CTP.PARAM_VAL_INT_DEFAULT
        FROM CTRL_TASK_PARAMETERS CTP
        WHERE CTP.param_type='TOUGH_JOB_CONTROL'
          AND CTP.ENGINE_ID=ENGINE_ID_IN
          AND SJB.job_name=CTP.param_name AND SJB.ENGINE_ID=ENGINE_ID_IN),TOUGHNESS);


        V_STEP := 'Inserting job dependency to INITIALIZE_STREAM_END job into SESS_JOB_DEPENDENCY table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Inserting job dependency to STREAM_END INITIALIZATION job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB PRNT
                     CROSS JOIN
                         SESS_JOB_BCKP CHLD
             WHERE   NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_END'
                 AND PRNT.ENGINE_ID = ENGINE_ID_IN
                 AND NVL(PRNT.PHASE, 'N/A') = 'INITIALIZATION'
                 AND CHLD.ENGINE_ID = ENGINE_ID_IN
                 AND NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_BEGIN';

        V_STEP := 'Inserting job dependency to STREAM_END of START job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   ALL_JOB.JOB_ID
                   , ALL_JOB.JOB_NAME
                   , PAR_JOB.JOB_ID PARENT_JOB_ID
                   , PAR_JOB.JOB_NAME PARENT_JOB_NAME
                   , NULL REL_TYPE
              FROM   SESS_JOB_BCKP ALL_JOB, (SELECT   JOB_ID, JOB_NAME, STREAM_ID
                                               FROM   SESS_JOB_BCKP
                                              WHERE   STREAM_NAME IN (SELECT   STREAM_NAME
                                                                        FROM   SESS_JOB_BCKP
                                                                       WHERE   NVL(PHASE, 'N/A') = 'START'
                                                                           AND ENGINE_ID = ENGINE_ID_IN)
                                                  AND JOB_TYPE = 'STREAM_END'
                                                  AND ENGINE_ID = ENGINE_ID_IN) PAR_JOB
             WHERE   ALL_JOB.STREAM_ID != PAR_JOB.STREAM_ID
                 AND ALL_JOB.JOB_TYPE = 'STREAM_BEGIN'
                 AND ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_END of all jobs from FINISH stream into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD_JOB.JOB_ID PARENT_JOB_ID
                   , CHLD_JOB.JOB_NAME PARENT_JOB_NAME
                   , ALL_JOB.JOB_ID
                   , ALL_JOB.JOB_NAME
                   , NULL REL_TYPE
              FROM   SESS_JOB_BCKP ALL_JOB, (SELECT   JOB_ID, JOB_NAME, STREAM_ID
                                               FROM   SESS_JOB_BCKP
                                              WHERE   STREAM_NAME IN (SELECT   STREAM_NAME
                                                                        FROM   SESS_JOB_BCKP
                                                                       WHERE   NVL(PHASE, 'N/A') = 'FINISH'
                                                                           AND ENGINE_ID = ENGINE_ID_IN)
                                                  AND JOB_TYPE = 'STREAM_BEGIN'
                                                  AND ENGINE_ID = ENGINE_ID_IN) CHLD_JOB
             WHERE   ALL_JOB.STREAM_ID != CHLD_JOB.STREAM_ID
                 AND ALL_JOB.JOB_TYPE = 'STREAM_END'
                 AND ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency from CTRL_JOB_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CJD.REL_TYPE
              FROM           CTRL_JOB_DEPENDENCY CJD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CJD.JOB_NAME
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CJD.PARENT_JOB_NAME
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting stream dependency from CTRL_STREAM_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CSD.REL_TYPE
              FROM           CTRL_STREAM_DEPENDENCY CSD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CSD.STREAM_NAME || '_STREAM_BEGIN'
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CSD.PARENT_STREAM_NAME || '_STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_BEGIN job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_BEGIN'
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(CHLD.JOB_TYPE, 'N/A') <> 'STREAM_BEGIN'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_END job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_END'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(PRNT.JOB_TYPE, 'N/A') <> 'STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Removing potential self dependency from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   PARENT_JOB_NAME = JOB_NAME;

        V_STEP := 'Calling procedure SP_INIT_UPDATE_JOB_STATUS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        PCKG_INIT.SP_INIT_UPDATE_JOB_STATUS(ENGINE_ID_IN   => ENGINE_ID_IN
                                          , DEBUG_IN       => DEBUG_IN
                                          , EXIT_CD        => EXIT_CD
                                          , ERRMSG_OUT     => ERRMSG_OUT
                                          , ERRCODE_OUT    => ERRCODE_OUT
                                          , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Procedure SP_INIT_UPDATE_JOB_STATUS finished';

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := ' Result: ' || TO_CHAR(EXIT_CD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_UPDATE_JOB_STATUS failed
            --            v_all_dbg_info(v_dbg_info_id+1) := 'ERROR> Procedure SP_INIT_UPDATE_JOB_STATUS failed, exiting ...';
            V_STEP := 'ERROR> Procedure SP_INIT_UPDATE_JOB_STATUS failed, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Calling procedure SP_INIT_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        SP_INIT_SRCTABLE(ENGINE_ID_IN   => ENGINE_ID_IN
                       , DEBUG_IN       => DEBUG_IN
                       , EXIT_CD        => EXIT_CD
                       , ERRMSG_OUT     => ERRMSG_OUT
                       , ERRCODE_OUT    => ERRCODE_OUT
                       , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Procedure SP_INIT_SRCTABLE finished';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := ' Result: ' || TO_CHAR(EXIT_CD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_SRCTABLE failed
            V_STEP := 'ERROR> Procedure SP_INIT_SRCTABLE failed, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Inserting all records from SESS_JOB_DEPENDENCY_BCKP into SESS_JOB_DEPENDENCY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY
            SELECT   *
              FROM   SESS_JOB_DEPENDENCY_BCKP
             WHERE   JOB_ID IN (SELECT   JOB_ID
                                  FROM   SESS_JOB_BCKP
                                 WHERE   ENGINE_ID = ENGINE_ID_IN)
                  OR PARENT_JOB_ID IN (SELECT   JOB_ID
                                         FROM   SESS_JOB_BCKP
                                        WHERE   ENGINE_ID = ENGINE_ID_IN);

        V_STEP := 'Inserting all records from SESS_JOB_BCKP into SESS_JOB';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB
            SELECT   *
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;


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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := -3;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
    END SP_INIT_INITIALIZE;

    PROCEDURE SP_INIT_PLAN(ENGINE_ID_IN IN NUMBER DEFAULT 0
                         , DEBUG_IN IN   INTEGER:= 0
                         , EXIT_CD   OUT NOCOPY NUMBER
                         , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                         , ERRCODE_OUT   OUT NOCOPY NUMBER
                         , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /****************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_PLAN
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
        OUT parameters:
                      EXIT_CD - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
        Called from: SP_INIT_UPDATE_JOB_STATUS
        Calling: None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - get status for plan
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        CURSOR GET_RUNPLAN_CUR
        IS
              SELECT   CSPR.RUNPLAN, CSPR.COUNTRY_CD
                FROM       CTRL_STREAM_PLAN_REF CSPR
                       JOIN
                           CTRL_JOB CJ
                       ON CSPR.STREAM_NAME = CJ.STREAM_NAME
                      AND CJ.ENGINE_ID = ENGINE_ID_IN
            GROUP BY   CSPR.RUNPLAN, CSPR.COUNTRY_CD;


        --constants
        C_PROC_NAME               CONSTANT VARCHAR2(64) := 'SP_INIT_PLAN';
        -- local variables
        V_ERRORCODE               INTEGER;
        V_ERRORTEXT               VARCHAR2(1024);
        V_STEP                    VARCHAR2(1024);
        V_LOAD_DATE               DATE;
        V_RUNPLAN                 VARCHAR2(9);
        V_COUNTRY_CD              VARCHAR2(4);
        V_GET_STATUS              INTEGER := 1; -- 0=zmen status spusteni na TRUE, 1=FALSE
        V_ALL_DBG_INFO            PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID             INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Deleting old record from TEMP_PLAN table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   TEMP_INIT_PLAN
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        FOR R1 IN GET_RUNPLAN_CUR
        LOOP
            V_STEP := 'Inserting destinct runplan from CTRL_STREAM_PLAN_REF into TEMP_PLAN table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            V_RUNPLAN := R1.RUNPLAN;
            V_COUNTRY_CD := R1.COUNTRY_CD;

            V_STEP := 'Updating status in TEMP_PLAN table';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            IF PCKG_TOOLS.F_DATE_MATCH_RUNPLAN(V_LOAD_DATE, V_RUNPLAN, V_COUNTRY_CD)=1 THEN
              V_GET_STATUS := 0;
            ELSE
              V_GET_STATUS := 100;
            END IF;

            V_STEP := 'Inserting into TEMP_INIT_PLAN';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            INSERT INTO TEMP_INIT_PLAN(RUNPLAN
                                     , COUNTRY_CD
                                     , LOAD_DATE
                                     , STATUS
                                     , ENGINE_ID)
              VALUES   (V_RUNPLAN
                      , V_COUNTRY_CD
                      , V_LOAD_DATE
                      , V_GET_STATUS
                      , ENGINE_ID_IN);
        END LOOP;

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
    END SP_INIT_PLAN;

    PROCEDURE SP_INIT_PREPARE(ENGINE_ID_IN IN NUMBER DEFAULT 0
                            , DEBUG_IN IN   INTEGER:= 0
                            , EXIT_CD   OUT NOCOPY NUMBER
                            , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                            , ERRCODE_OUT   OUT NOCOPY NUMBER
                            , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_PREPARE
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
        OUT parameters:
                      EXIT_CD - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
        Called from: PERL script %PMRootDir%\Bin\Framework\Initialization
        \Init_Prepare.pl
        Calling: None
        -------------------------------------------------------------------------------
        Version:        1.1
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - initial part
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2015-01-23
        Modification: Add initialization related to current date
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME               CONSTANT VARCHAR2(64) := 'SP_INIT_PREPARE';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE               INTEGER;
        V_ERRORTEXT               VARCHAR2(1024);
        V_STEP                    VARCHAR2(1024);
        V_LOAD_DATE               DATE;
        V_CNT                     INTEGER;
        V_ANSWER                  VARCHAR2(16);
        V_INIT_MUST_RUN           INTEGER;
        V_INIT_IS_RUNNING         INTEGER;
        V_INIT_RETENTION_PERIOD   INTEGER;
        V_INIT_PASS               INTEGER;
        V_DO_INITIALIZATION       INTEGER;
        V_APPLICATION_ID          INTEGER;
        V_INITIALIZATION_BEGIN    TIMESTAMP;
        V_LIMIT_MAX_LOAD_DATE     DATE;
        V_CURRDATE_RELATED        INTEGER;
        V_NEW_LOAD_DATE           DATE;

        V_ALL_DBG_INFO            PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID             INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;


        EXIT_CD := 0;

        V_STEP := 'Taking value of INITIALIZATION_CURRDATE_RELATED parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_CURRDATE_RELATED
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_CURRDATE_RELATED'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking value of INITIALIZATION_RETENTION_PERIOD parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_INIT_RETENTION_PERIOD
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_RETENTION_PERIOD'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Value of INITIALIZATION_RETENTION_PERIOD parameter is '|| to_char(V_INIT_RETENTION_PERIOD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Calculate value of V_NEW_LOAD_DATE variable';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF V_CURRDATE_RELATED = 1 THEN

          V_CNT:= FLOOR(((TRUNC (CURRENT_DATE, 'MI')- TRUNC (CURRENT_DATE, 'DDD'))*1440)/V_INIT_RETENTION_PERIOD);
          --(NUM OF MINUTES FROM BEGININING OF DAYS / RETENTION PERIOD) ROUNDED DOWN
          V_NEW_LOAD_DATE := TRUNC (CURRENT_DATE, 'DDD') + (V_CNT*V_INIT_RETENTION_PERIOD/1440);

        ELSE

          SELECT   PARAM_VAL_DATE + (V_INIT_RETENTION_PERIOD/1440)
          INTO V_NEW_LOAD_DATE
          FROM   CTRL_PARAMETERS
          WHERE   PARAM_CD = ENGINE_ID_IN
            AND PARAM_NAME = 'LOAD_DATE';

        END IF;

        V_STEP := 'Value of NEW_LOAD_DATE is '|| to_char(V_INIT_RETENTION_PERIOD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        V_STEP := 'Calculate value of V_LIMIT_MAX_LOAD_DATE variable';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   CASE WHEN PARAM_VAL_DATE<CURRENT_DATE THEN PARAM_VAL_DATE ELSE CURRENT_DATE END
          INTO   V_LIMIT_MAX_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'MAX_LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Check condition - LOAD_DATE < V_LIMIT_MAX_LOAD_DATE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        SELECT   CASE
                     WHEN  V_NEW_LOAD_DATE <= V_LIMIT_MAX_LOAD_DATE
                     THEN
                         1
                     ELSE
                         0
                 END
                     AS ANSWER
          INTO   V_CNT
          FROM   DUAL;

        IF V_CNT = 0
        THEN -- new load_date will be > max_load_date
            V_STEP := 'ERROR> New load_date override max value, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Taking value of INITIALIZATION_MUST_RUN parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_INIT_MUST_RUN
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_MUST_RUN'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Value of INITIALIZATION_MUST_RUN parameter is '|| to_char(V_INIT_MUST_RUN);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        V_STEP := 'Taking value of INITIALIZATION_BEGIN parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_TS
          INTO   V_INITIALIZATION_BEGIN
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_BEGIN'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking value of INITIALIZATION_IS_RUNNING parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_INIT_IS_RUNNING
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'INITIALIZATION_IS_RUNNING'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Value of INITIALIZATION_IS_RUNNING parameter is '|| to_char(V_INIT_IS_RUNNING);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Taking value of V_INIT_PASS parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT     EXTRACT(DAY FROM (CURRENT_TIMESTAMP - V_INITIALIZATION_BEGIN)) * 1440
                 + EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - V_INITIALIZATION_BEGIN)) * 60
                 + EXTRACT(MINUTE FROM (CURRENT_TIMESTAMP - V_INITIALIZATION_BEGIN)) + 5
          INTO   V_INIT_PASS
          FROM   DUAL;

        V_STEP := 'Value of V_INIT_PASS parameter is '|| to_char(V_INIT_PASS);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Check condition - number of not finished jobs yet';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT( * ) AS CNT
          INTO   V_CNT
          FROM       SESS_JOB SJ
                 JOIN
                     CTRL_JOB_STATUS CJS
                 ON SJ.STATUS = CJS.STATUS
                AND SJ.ENGINE_ID = ENGINE_ID_IN
                AND CJS.FINISHED = 0;

        V_STEP := 'Number of not finished job:'|| to_char(V_CNT);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Deside if initialization can be done';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF V_CNT > 0
        THEN
            IF V_INIT_MUST_RUN = 0
           AND V_INIT_RETENTION_PERIOD <= V_INIT_PASS
           AND V_INIT_IS_RUNNING = 0
            -- pokud inicializace nemusi bezet a jiz je cas, kdy by inicializace mela bezet
            THEN

                V_STEP := 'Initialization is not running and initialisation must not run';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                V_STEP := 'Updateing INITIALIZATION_BEGIN parameter';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_TS = CAST(CURRENT_TIMESTAMP AS TIMESTAMP)
                 WHERE   PARAM_CD = ENGINE_ID_IN
                     AND PARAM_NAME = 'INITIALIZATION_BEGIN';

                V_STEP := 'Updateing INITIALIZATION_END parameter';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_TS = CAST(CURRENT_TIMESTAMP AS TIMESTAMP)
                 WHERE   PARAM_CD = ENGINE_ID_IN
                     AND PARAM_NAME = 'INITIALIZATION_END';

                V_STEP := 'Updateing LOAD_DATE parameter';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_DATE = V_NEW_LOAD_DATE
                 WHERE   PARAM_NAME = 'LOAD_DATE'
                     AND PARAM_CD = ENGINE_ID_IN;

                UPDATE   CTRL_PARAMETERS
                   SET   PARAM_VAL_TS = PARAM_VAL_DATE
                 WHERE   PARAM_NAME = 'LOAD_DATE'
                     AND PARAM_CD = ENGINE_ID_IN;
            END IF;

            V_STEP := 'ERROR> Some jobs are not finished yet, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Setting parameter SCHEDULER_PROVIDED_BY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_CHAR = 'SCHEDULER'
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'SCHEDULER_PROVIDED_BY';

        V_STEP := 'Reseting parameter MANUAL_BATCH_LOAD_DATE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_DATE = NULL
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'MANUAL_BATCH_LOAD_DATE';

        V_STEP := 'Cleaning Application_id in LKP_APPLICATION';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   LKP_APPLICATION
           SET   IS_ACTIVE = 0
         WHERE   engine_id = ENGINE_ID_IN;

        V_STEP := 'Setting parameter INITIALIZATION_BEGIN';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_TS = CAST(CURRENT_TIMESTAMP AS TIMESTAMP)
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'INITIALIZATION_BEGIN';

        V_STEP := 'Setting parameter APPLICATION_ID';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_APPLICATION_ID := 1; -- Initialization

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = V_APPLICATION_ID
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'APPLICATION_ID';

        V_STEP := 'Checking SESS_QUEUE table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT( * )
          INTO   V_CNT
          FROM   SESS_QUEUE
         WHERE   ENGINE_ID = ENGINE_ID_IN;

        IF V_CNT < 48
        THEN
            V_STEP := 'DELETE FROM   SESS_QUEUE';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            DELETE FROM   SESS_QUEUE
                  WHERE   ENGINE_ID = ENGINE_ID_IN;

            FOR V_CNT IN 0 .. 47
            LOOP
                V_STEP := 'INSERT INTO SESS_QUEUE';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                INSERT INTO SESS_QUEUE(QUEUE_NUMBER
                                     , JOB_NAME
                                     , JOB_ID
                                     , AVAILABLE
                                     , LAST_UPDATE
                                     , ENGINE_ID)
                  VALUES   (V_CNT
                          , NULL -- job_name
                          , NULL -- JOB_ID
                          , 1 -- AVAILABLE
                          , NULL -- LAST_UPDATE
                          , ENGINE_ID_IN);
            END LOOP;
        END IF;

        V_STEP := 'UPDATE   SESS_QUEUE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   SESS_QUEUE
           SET   AVAILABLE = 1
         WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Checking CTRL_TASK_PARAMETERS table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   COUNT( * )
          INTO   V_CNT
          FROM   CTRL_TASK_PARAMETERS
         WHERE   ENGINE_ID = ENGINE_ID_IN;

        IF V_CNT = 0
        THEN
            V_STEP := 'INSERT INTO CTRL_TASK_PARAMETERS';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            INSERT INTO CTRL_TASK_PARAMETERS(PARAM_NAME
                                           , PARAM_TYPE
                                           , PARAM_VAL_INT_CURR
                                           , PARAM_VAL_INT_MAX
                                           , PARAM_VAL_INT_DEFAULT
                                           , TASK_SUBTYPE
                                           , TASK_TYPE
                                           , VALID_FROM
                                           , VALID_TO
                                           , ENGINE_ID
                                           , DESCRIPTION)
                SELECT   PARAM_NAME
                       , PARAM_TYPE
                       , PARAM_VAL_INT_CURR
                       , PARAM_VAL_INT_MAX
                       , PARAM_VAL_INT_DEFAULT
                       , TASK_SUBTYPE
                       , TASK_TYPE
                       , VALID_FROM
                       , VALID_TO
                       , ENGINE_ID_IN
                       , DESCRIPTION
                  FROM   CTRL_TASK_PARAMETERS
                 WHERE   ENGINE_ID = 0
                     AND PARAM_NAME = 'PARALLELISM_CONTROL';
        END IF;

        V_STEP := 'UPDATE   CTRL_TASK_PARAMETERS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_TASK_PARAMETERS
           SET   PARAM_VAL_INT_MAX = PARAM_VAL_INT_DEFAULT
         WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Deleting jobs from SESS_JOB table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        DELETE FROM   SESS_JOB
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Deleting jobs from SESS_JOB_DEPENDENCY table which jobs are not found in SESS_JOB table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY
              WHERE   JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB)
                   OR PARENT_JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB);

        V_STEP := 'Check if initialization is starting (0) or restarting (1)';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_CNT
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'INITIALIZATION_IS_RUNNING';

        IF V_CNT = 0 --IF level_1
        THEN -- initialization is starting, backup LOAD_DATE into
            -- PREV_LOAD_DATE
            V_STEP := 'Backuping LOAD_DATE into PREV_LOAD_DATE';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   CTRL_PARAMETERS
               SET   PARAM_VAL_DATE =
                         (SELECT   PARAM_VAL_DATE
                            FROM   CTRL_PARAMETERS
                           WHERE   PARAM_CD = ENGINE_ID_IN
                               AND PARAM_NAME = 'LOAD_DATE')
             WHERE   PARAM_NAME = 'PREV_LOAD_DATE'
                 AND PARAM_CD = ENGINE_ID_IN;

            UPDATE   CTRL_PARAMETERS
               SET   PARAM_VAL_TS =
                         (SELECT   PARAM_VAL_TS
                            FROM   CTRL_PARAMETERS
                           WHERE   PARAM_CD = ENGINE_ID_IN
                               AND PARAM_NAME = 'LOAD_DATE')
             WHERE   PARAM_NAME = 'PREV_LOAD_DATE'
                 AND PARAM_CD = ENGINE_ID_IN;

            V_STEP := 'Setting LOAD_DATE';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   CTRL_PARAMETERS
               SET   PARAM_VAL_DATE = V_NEW_LOAD_DATE
             WHERE   PARAM_NAME = 'LOAD_DATE'
                 AND PARAM_CD = ENGINE_ID_IN;

            UPDATE   CTRL_PARAMETERS
               SET   PARAM_VAL_TS = PARAM_VAL_DATE
             WHERE   PARAM_NAME = 'LOAD_DATE'
                 AND PARAM_CD = ENGINE_ID_IN;

            V_STEP := 'Setting LOAD_SEQ_NUM';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

            UPDATE   CTRL_PARAMETERS
               SET   PARAM_VAL_INT = PARAM_VAL_INT + 1
             WHERE   PARAM_NAME = 'LOAD_SEQ_NUM'
                 AND PARAM_CD = ENGINE_ID_IN;
        END IF; --IF level_1

        V_STEP := 'Setting INITIALIZATION_IS_RUNNING parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = 1
         WHERE   PARAM_NAME = 'INITIALIZATION_IS_RUNNING'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Stopping Engine';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = 0
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Insert into SESS_JOB - job INITIALIZATION_STREAM_BEGIN';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB(JOB_ID
                           , STREAM_ID
                           , JOB_NAME
                           , STREAM_NAME
                           , STATUS
                           , LAST_UPDATE
                           , LOAD_DATE
                           , PRIORITY
                           , CMD_LINE
                           , SRC_SYS_ID
                           , PHASE
                           , TABLE_NAME
                           , JOB_CATEGORY
                           , JOB_TYPE
                           , toughness
                           , CONT_ANYWAY
                           , RESTART
                           , ALWAYS_RESTART
                           , N_RUN
                           , MAX_RUNS
                           , WAITING_HR
                           , DEADLINE_HR
                           , APPLICATION_ID
                           , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID_SEQ.NEXTVAL
                   , CJ.STREAM_NAME || '_STREAM_BEGIN'
                   , CJ.STREAM_NAME
                   , 100 --status
                   , NULL
                   , V_LOAD_DATE
                   , 1000 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , 'INITIALIZATION' --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_BEGIN' --job_type
                   , 0 --toughness
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID_IN
              FROM   (  SELECT   STREAM_NAME
                          FROM   CTRL_JOB
                         WHERE   ENGINE_ID = ENGINE_ID_IN
                             AND NVL(PHASE, 'N/A') = 'INITIALIZATION'
                      GROUP BY   STREAM_NAME) CJ;

        V_STEP := 'Insert into SESS_JOB - job INITIALIZATION_STREAM_END';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB(JOB_ID
                           , STREAM_ID
                           , JOB_NAME
                           , STREAM_NAME
                           , STATUS
                           , LAST_UPDATE
                           , LOAD_DATE
                           , PRIORITY
                           , CMD_LINE
                           , SRC_SYS_ID
                           , PHASE
                           , TABLE_NAME
                           , JOB_CATEGORY
                           , JOB_TYPE
                           , toughness
                           , CONT_ANYWAY
                           , RESTART
                           , ALWAYS_RESTART
                           , N_RUN
                           , MAX_RUNS
                           , WAITING_HR
                           , DEADLINE_HR
                           , APPLICATION_ID
                           , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID
                   , STREAM_NAME || '_STREAM_END'
                   , STREAM_NAME
                   , 100 --status
                   , NULL
                   , V_LOAD_DATE
                   , 1000 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , 'INITIALIZATION' --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_END' --job_type
                   , 0 --toughness
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID
              FROM   SESS_JOB
             WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Insert jobs from INITIALIZATION stream into SESS_JOB table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB(JOB_ID
                           , STREAM_ID
                           , JOB_NAME
                           , STREAM_NAME
                           , STATUS
                           , LAST_UPDATE
                           , LOAD_DATE
                           , PRIORITY
                           , CMD_LINE
                           , SRC_SYS_ID
                           , PHASE
                           , TABLE_NAME
                           , JOB_CATEGORY
                           , JOB_TYPE
                           , toughness
                           , CONT_ANYWAY
                           , RESTART
                           , ALWAYS_RESTART
                           , N_RUN
                           , MAX_RUNS
                           , WAITING_HR
                           , DEADLINE_HR
                           , APPLICATION_ID
                           , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , SJ.STREAM_ID
                   , CJ.JOB_NAME
                   , CJ.STREAM_NAME
                   , 0 --status
                   , NULL
                   , V_LOAD_DATE
                   , CJ.PRIORITY
                   , CJ.CMD_LINE
                   , CJ.SRC_SYS_ID
                   , CJ.PHASE
                   , CJ.TABLE_NAME
                   , CJ.JOB_CATEGORY
                   , CJ.JOB_TYPE
                   , 0 --tougness
                   , CJ.CONT_ANYWAY
                   , CJ.ALWAYS_RESTART --restart
                   , CJ.ALWAYS_RESTART
                   , 0 --n_rub
                   , CJ.MAX_RUNS
                   , CJ.WAITING_HR
                   , CJ.DEADLINE_HR
                   , V_APPLICATION_ID
                   , CJ.ENGINE_ID
              FROM       CTRL_JOB CJ
                     INNER JOIN
                         SESS_JOB SJ
                     ON CJ.STREAM_NAME = SJ.STREAM_NAME
                    AND SJ.JOB_NAME = CJ.STREAM_NAME || '_STREAM_BEGIN'
                    AND CJ.ENGINE_ID = ENGINE_ID_IN
             WHERE   NVL(CJ.PHASE, 'N/A') = 'INITIALIZATION';

        --dependency defined in CTRL_JOB_DEPENDENCY table
        V_STEP := 'Inserting CTRL_JOB_DEPENDENCY into SESS_JOB_DEPENDENCY for INITIALIZATION stream only';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY(JOB_ID
                                      , JOB_NAME
                                      , PARENT_JOB_ID
                                      , PARENT_JOB_NAME
                                      , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , REL_TYPE
              FROM           CTRL_JOB_DEPENDENCY CJD
                         JOIN
                             SESS_JOB CHLD
                         ON CHLD.JOB_NAME = CJD.JOB_NAME
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB PRNT
                     ON PRNT.JOB_NAME = CJD.PARENT_JOB_NAME
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting dependency to STREAM_BEGIN';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY(JOB_ID
                                      , JOB_NAME
                                      , PARENT_JOB_ID
                                      , PARENT_JOB_NAME
                                      , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB CHLD
                     JOIN
                         SESS_JOB PRNT
                     ON NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_BEGIN'
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(CHLD.JOB_TYPE, 'N/A') <> 'STREAM_BEGIN'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting dependency to STREAM_END';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY(JOB_ID
                                      , JOB_NAME
                                      , PARENT_JOB_ID
                                      , PARENT_JOB_NAME
                                      , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB CHLD
                     JOIN
                         SESS_JOB PRNT
                     ON NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_END'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(PRNT.JOB_TYPE, 'N/A') <> 'STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Starting Engine';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT =
                     (SELECT   MIN(PARAM_VAL_INT)
                        FROM   CTRL_PARAMETERS
                       WHERE   PARAM_CD = ENGINE_ID_IN
                           AND PARAM_NAME IN ('MAX_CONCURRENT_JOBS_SET', 'MAX_CONCURRENT_JOBS_DFLT'))
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENGINE_ID_IN;

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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := 0;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
      commit;
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
    END SP_INIT_PREPARE;

    PROCEDURE SP_INIT_SRCTABLE(ENGINE_ID_IN IN NUMBER DEFAULT 0
                             , DEBUG_IN IN   INTEGER:= 0
                             , EXIT_CD   OUT NOCOPY NUMBER
                             , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                             , ERRCODE_OUT   OUT NOCOPY NUMBER
                             , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_SRCTABLE
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
        OUT parameters:
                      EXIT_CD - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
        Called from: SP_INIT_INITIALIZE
        Calling: None
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - initialize new SRCTABLEs
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        V_LOAD_DATE      DATE;
        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_INIT_SRCTABLE';
        -- local variables
        V_ERRORCODE      INTEGER;
        V_ERRORTEXT      VARCHAR2(1024);
        V_STEP           VARCHAR2(1024);

        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Inserting new tables from CTRL_SRCTABLE into STAT_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO STAT_SRCTABLE(COMMON_TABLE_NAME, INCREMENT_DATE, SNAPSHOT_DATE)
              SELECT   CTRLSRC.COMMON_TABLE_NAME, TO_DATE('2000-01-01', 'YYYY-MM-DD') --increment_date
                                                                                     , TO_DATE('2000-01-01', 'YYYY-MM-DD') --snapshot_date
                FROM   CTRL_SRCTABLE CTRLSRC
               WHERE   NOT EXISTS (SELECT   'x'
                                     FROM   STAT_SRCTABLE STATSRC
                                    WHERE   CTRLSRC.COMMON_TABLE_NAME = STATSRC.COMMON_TABLE_NAME)
            GROUP BY   CTRLSRC.COMMON_TABLE_NAME, TO_DATE('2000-01-01', 'YYYY-MM-DD'), TO_DATE('2000-01-01', 'YYYY-MM-DD');

        V_STEP := 'Inserting tables for MAN SOURCE into SESS_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_SRCTABLE
              WHERE   SOURCE_ID = 0;

        INSERT INTO SESS_SRCTABLE(TABLE_NAME
                                , LOG_NAME
                                , COMMON_TABLE_NAME
                                , SCHEMA_NAME
                                , SOURCE_ID
                                , JOB_ID
                                , JOB_NAME
                                , EFF_LOAD_DATE
                                , LOAD_DATE
                                , LOAD_STATUS
                                , INSERT_TS)
            SELECT   TABLE_NAME
                   , 'UNUSED'
                   , 'UNUSED'
                   , 'UNUSED'
                   , SOURCE_ID
                   , 0
                   , 'UNUSED'
                   , V_LOAD_DATE
                   , V_LOAD_DATE
                   , 'VALIDATED'
                   , CURRENT_TIMESTAMP
              FROM   CTRL_SRCTABLE
             WHERE   SOURCE_ID IN ( SELECT SOURCE_ID FROM CTRL_SOURCE WHERE SNIFFER_JOB_NAME IS NULL);

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
    END SP_INIT_SRCTABLE;

    PROCEDURE SP_INIT_UPDATE_JOB_STATUS(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_UPDATE_JOB_STATUS
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
        OUT parameters:
                      EXIT_CD - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
        Called from: SP_INIT_INITIALIZE
        Calling: SP_INIT_PLAN
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - get status for jobs
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME      CONSTANT VARCHAR2(64) := 'SP_INIT_UPDATE_JOB_STATUS';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE      INTEGER;
        V_ERRORTEXT      VARCHAR2(1024);
        V_STEP           VARCHAR2(1024);
        E_SP_INIT_PLAN_FAILED EXCEPTION;
        V_ALL_DBG_INFO   PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID    INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Calling procedure SP_INIT_PLAN';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        SP_INIT_PLAN(ENGINE_ID_IN   => ENGINE_ID_IN
                   , DEBUG_IN       => DEBUG_IN
                   , EXIT_CD        => EXIT_CD
                   , ERRMSG_OUT     => ERRMSG_OUT
                   , ERRCODE_OUT    => ERRCODE_OUT
                   , ERRLINE_OUT    => ERRLINE_OUT);

        V_STEP := 'Procedure SP_INIT_PLAN finished';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_PLAN failed
            V_STEP := 'SP_INIT_PLAN failed';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Taking value of DATA_QUALITY_ACTIVE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Updating job status from TEMP_INIT_PLAN table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   SESS_JOB_BCKP SJB
           SET   STATUS =
                     (SELECT   NVL(MIN(STATUS), 100)
                        FROM   (SELECT   TIP.STATUS
                                       , TIP.LOAD_DATE
                                       , TIP.ENGINE_ID
                                       , CSPR.STREAM_NAME
                                  FROM       TEMP_INIT_PLAN TIP
                                         JOIN
                                             CTRL_STREAM_PLAN_REF CSPR
                                         ON CSPR.RUNPLAN = TIP.RUNPLAN) X
                       WHERE   SJB.STREAM_NAME = X.STREAM_NAME
                           AND SJB.ENGINE_ID = X.ENGINE_ID
                           AND SJB.LOAD_DATE = X.LOAD_DATE)
         WHERE   UPPER(SJB.JOB_NAME) NOT LIKE '%STREAM_BEGIN'
             AND UPPER(SJB.JOB_NAME) NOT LIKE '%STREAM_END';

        V_STEP := 'Updating status for SRCTABLE_READER jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   SESS_JOB_BCKP
           SET   STATUS = 100 -- skip
         WHERE   STREAM_NAME IN (SELECT   STREAM_NAME
                                   FROM   CTRL_JOB
                                  WHERE   UPPER(NVL(JOB_TYPE, 'N/A')) IN ('SCD1', 'LOADER_L0', 'TS_EXTRACTOR', 'DATA_QUALITY', 'DATA_QUALITY_CHECKER_2')
                                      AND ENGINE_ID = ENGINE_ID_IN)
             AND (JOB_NAME NOT LIKE '%STREAM_BEGIN'
               OR JOB_NAME NOT LIKE '%STREAM_END');

        V_STEP := 'Setting statuses from DATA QUALITY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := 'Applying status_begin values';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   SESS_JOB_BCKP SJB
           SET   SJB.STATUS =
                     (SELECT   CJ.STATUS_BEGIN
                        FROM   CTRL_JOB CJ
                       WHERE   SJB.JOB_NAME = CJ.JOB_NAME
                           AND CJ.STATUS_BEGIN IS NOT NULL
                           AND SJB.ENGINE_ID = ENGINE_ID_IN)
         WHERE   SJB.JOB_NAME IN (SELECT   CJ2.JOB_NAME
                                    FROM   CTRL_JOB CJ2
                                   WHERE   SJB.JOB_NAME = CJ2.JOB_NAME
                                       AND CJ2.STATUS_BEGIN IS NOT NULL
                                       AND SJB.ENGINE_ID = ENGINE_ID_IN);


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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := 0;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
    END SP_INIT_UPDATE_JOB_STATUS;

    PROCEDURE SP_INIT_INITIALIZE_END(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_INITIALIZE_END
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
        OUT parameters:
                      EXIT_CD - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT
        Called from: PERL script
        Calling: NONE
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - get status for jobs
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_INIT_UPDATE_JOB_STATUS';
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        E_SP_INIT_PLAN_FAILED EXCEPTION;
        V_APPLICATION_ID   INTEGER;
        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
        V_STATUS_TS        TIMESTAMP(6) := PCKG_FWRK.F_GET_CTRL_PARAMETERS('initialization_begin', 'param_val_ts', ENGINE_ID_IN);
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Inserting intialization end timestamp into CTRL_PARAMETERS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_TS = CURRENT_TIMESTAMP
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'INITIALIZATION_END';

        V_STEP := 'Inserting intialization end into CTRL_PARAMETERS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = 0
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'INITIALIZATION_IS_RUNNING';

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
                   , 'INITIALIZATION' --SIGNAL
                   , APPLICATION_ID
                   , SJ.ENGINE_ID
              FROM   SESS_JOB SJ
             WHERE   NVL(SJ.PHASE, 'N/A') <> 'INITIALIZATION'
             and engine_id=ENGINE_ID_IN;

        V_STEP := 'Setting parameter APPLICATION_ID';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_APPLICATION_ID := 0; -- Initialization End

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = V_APPLICATION_ID
         WHERE   PARAM_CD = ENGINE_ID_IN
             AND PARAM_NAME = 'APPLICATION_ID';

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
    END SP_INIT_INITIALIZE_END;

    PROCEDURE SP_INIT_RECALC_STATISTICS(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_INIT_RECALC_STATISTICS
        IN parameters:
                      ENGINE_ID_IN
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
        Date:    2010-02-24
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified: Milan Budka
        Version: 1.1
        Date: 2015-02-10
        Modification: Optimalization
        *******************************************************************************/

        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_INIT_RECALC_STATISTICS';
        -- local variables
        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;

        V_LOAD_DATE            SESS_STATUS.LOAD_DATE%TYPE;
        V_DAY_IN_WEEK          NUMBER(1, 0);
        V_DAY_IN_MONTH         NUMBER(3, 0);
        V_PREV_LOAD_DATE       SESS_STATUS.LOAD_DATE%TYPE;
        E_SP_INIT_PLAN_FAILED EXCEPTION;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
        V_STEP := 'DELETE FROM   SESS_JOB_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_STATISTICS
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'select PREV_LOAD_DATE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        /*
          min - if initialization has been done, there are some technical jobs with new load_date
        */
        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'PREV_LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'select day in week';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_DAY_IN_WEEK := PCKG_TOOLS.F_GET_DAY_OF_WEEK(V_LOAD_DATE);

        IF TO_NUMBER(TO_CHAR(V_LOAD_DATE, 'DD')) = TO_NUMBER(TO_CHAR(LAST_DAY(V_LOAD_DATE), 'DD'))
        THEN
          V_STEP := 'select day in mnth = 999';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
          V_DAY_IN_MONTH := 999;
        ELSE
          V_STEP := 'select day in mnth';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
          V_DAY_IN_MONTH := TO_NUMBER(TO_CHAR(V_LOAD_DATE, 'DD'));
        END IF;

        V_STEP := 'INSERT INTO STAT_JOB_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO STAT_JOB_STATISTICS (JOB_NAME
                                          , LOAD_DATE
                                          , DAY_IN_WEEK
                                          , DAY_IN_MONTH
                                          , FIRST_START_TS
                                          , LAST_START_TS
                                          , LAST_STATUS_TS
                                          , END_TS
                                          , LAST_STATUS
                                          , N_RUN
                                          , AVG_DURATION
                                          , AVG_END_TM
                                          , ENGINE_ID
                                          , IGNORE_STAT
                                          , DWH_DATE)
        SELECT  last_st.JOB_NAME,
                V_LOAD_DATE,
                V_DAY_IN_WEEK,
                V_DAY_IN_MONTH,
                start_ts.FIRST_START_TS,
                start_ts.LAST_START_TS,
                last_st.STATUS_TS,
                end_ts.END_TS,
                last_st.STATUS,
                last_st.N_RUN,
                PCKG_TOOLS.F_SEC_BETWEEN(LAST_START_TS, END_TS) as AVG_DURATION,
                PCKG_TOOLS.F_SEC_BETWEEN(V_PREV_LOAD_DATE, END_TS) as AVG_END_TM,
                ENGINE_ID_IN,
                0,
                V_PREV_LOAD_DATE

                FROM
        (
          --select last status_ts,status, n_run
          SELECT * FROM
          (
                SELECT  JOB_NAME,STATUS_TS,STATUS,N_RUN,
                ROW_NUMBER() OVER (PARTITION BY JOB_NAME    ORDER BY STATUS_TS DESC, STATUS DESC) AS rn
                FROM   SESS_STATUS SS
                WHERE   ENGINE_ID = ENGINE_ID_IN
                AND LOAD_DATE = V_LOAD_DATE
                AND PCKG_TOOLS.F_GET_IGNORE_STATS(APPLICATION_ID) = 0
                AND JOB_NAME IN (SELECT JOB_NAME FROM CTRL_JOB WHERE ENGINE_ID=0)
          ) WHERE rn=1
        ) last_st
        LEFT JOIN
        (
          --select end_ts
          SELECT  JOB_NAME,MAX(SS.STATUS_TS) END_TS
                  FROM   SESS_STATUS SS
                 WHERE   SS.ENGINE_ID = ENGINE_ID_IN
                     AND LOAD_DATE = V_LOAD_DATE
                     AND PCKG_TOOLS.F_GET_IGNORE_STATS(SS.APPLICATION_ID) = 0
                     AND SS.STATUS IN (SELECT   CJS.STATUS
                                         FROM   CTRL_JOB_STATUS CJS
                                        WHERE   CJS.FINISHED_SUCCESSFULLY = 1)
          GROUP BY JOB_NAME
        ) end_ts
        ON end_ts.job_name=last_st.job_name
        LEFT JOIN
        (
          --select start_ts
          SELECT  JOB_NAME,MIN(SS.STATUS_TS) FIRST_START_TS, MAX(SS.STATUS_TS) LAST_START_TS
                  FROM   SESS_STATUS SS
                 WHERE   SS.ENGINE_ID = ENGINE_ID_IN
                     AND LOAD_DATE = V_LOAD_DATE
                     AND PCKG_TOOLS.F_GET_IGNORE_STATS(SS.APPLICATION_ID) = 0
                     AND SS.STATUS IN (SELECT   CJS.STATUS
                                         FROM   CTRL_JOB_STATUS CJS
                                        WHERE   CJS.RUNABLE = 'RUNNING')
          GROUP BY JOB_NAME
        ) start_ts
        ON start_ts.job_name=last_st.job_name;

      V_STEP := 'INSERT INTO STAT_STATUS';
      V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
      V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

      INSERT INTO STAT_STATUS(JOB_ID
                            , JOB_NAME
                            , STREAM_NAME
                            , STATUS_TS
                            , LOAD_DATE
                            , STATUS
                            , N_RUN
                            , SIGNAL
                            , APPLICATION_ID
                            , ENGINE_ID
                            , DWH_DATE)
          SELECT   JOB_ID
                 , JOB_NAME
                 , STREAM_NAME
                 , STATUS_TS
                 , LOAD_DATE
                 , STATUS
                 , N_RUN
                 , SIGNAL
                 , APPLICATION_ID
                 , ENGINE_ID
                 , V_PREV_LOAD_DATE
            FROM   SESS_STATUS
           WHERE   ENGINE_ID = ENGINE_ID_IN
           AND LOAD_DATE=V_LOAD_DATE;

        V_STEP := 'DELETE FROM   SESS_STATUS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_STATUS
              WHERE   ENGINE_ID = ENGINE_ID_IN
              AND LOAD_DATE=V_LOAD_DATE;

        COMMIT;

        V_STEP := 'Taking value of LOAD_DATE parameter - actual load';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'select day in week - actual load';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_DAY_IN_WEEK := PCKG_TOOLS.F_GET_DAY_OF_WEEK(V_LOAD_DATE);

        IF TO_NUMBER(TO_CHAR(V_LOAD_DATE, 'DD')) = TO_NUMBER(TO_CHAR(LAST_DAY(V_LOAD_DATE), 'DD'))
        THEN
          V_STEP := 'select day in mnth = 999';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
          V_DAY_IN_MONTH := 999;
        ELSE
          V_STEP := 'select day in mnth';
          V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
          V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
          V_DAY_IN_MONTH := TO_NUMBER(TO_CHAR(V_LOAD_DATE, 'DD'));
        END IF;

        INSERT INTO SESS_JOB_STATISTICS(JOB_NAME
                      , LOAD_DATE
                      , DAY_IN_WEEK
                      , DAY_IN_MONTH
                      , FIRST_START_TS
                      , LAST_START_TS
                      , LAST_STATUS_TS
                      , END_TS
                      , LAST_STATUS
                      , N_RUN
                      , AVG_DURATION
                      , AVG_END_TM
                      , ENGINE_ID)
        SELECT JOB_NAME
                  , V_LOAD_DATE
                  , V_DAY_IN_WEEK
                  , V_DAY_IN_MONTH
                  , PCKG_TOOLS.F_GET_UNIX_TS_DATE(MAX(S.FIRST_START_TS))
                  , PCKG_TOOLS.F_GET_UNIX_TS_DATE(MAX(S.LAST_START_TS))
                  , PCKG_TOOLS.F_GET_UNIX_TS_DATE(MAX(LAST_STATUS_TS))
                  , PCKG_TOOLS.F_GET_UNIX_TS_DATE(MAX(END_TS))
                  , NULL
                  , NULL
                  , MAX(AVG_DURATION)
                  , MAX(AVG_END_TM)
                  , ENGINE_ID_IN
        FROM
                ( SELECT JOB_NAME
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.FIRST_START_TS)) AS FIRST_START_TS
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.LAST_START_TS)) AS LAST_START_TS
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.LAST_STATUS_TS)) AS LAST_STATUS_TS
                        , MAX(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.END_TS)) AS END_TS
                        , AVG(AT.AVG_DURATION) AS AVG_DURATION, AVG(AT.AVG_END_TM) AS AVG_END_TM
                  FROM   V_STAT_JOB_STATISTICS_DAY_IM AT
                  WHERE ENGINE_ID = ENGINE_ID_IN  AND DAY_IN_MONTH = V_DAY_IN_MONTH
                  GROUP BY JOB_NAME
                UNION ALL
                  SELECT JOB_NAME
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.FIRST_START_TS)) AS FIRST_START_TS
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.LAST_START_TS)) AS LAST_START_TS
                        , AVG(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.LAST_STATUS_TS)) AS LAST_STATUS_TS
                        , MAX(PCKG_TOOLS.F_GET_DATE_UNIX_TS(AT.END_TS)) AS END_TS
                        , AVG(AT.AVG_DURATION) AS AVG_DURATION
                        , AVG(AT.AVG_END_TM) AS AVG_END_TM
                  FROM   V_STAT_JOB_STATISTICS_DAY_IW AT
                  WHERE ENGINE_ID = ENGINE_ID_IN  AND DAY_IN_WEEK = V_DAY_IN_WEEK
                  GROUP BY JOB_NAME
                ) S
        GROUP BY JOB_NAME;

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
    END SP_INIT_RECALC_STATISTICS;

    PROCEDURE SP_GUI_INIT_INITIALIZE(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , EXIT_CD   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_GUI_INIT_INITIALIZE
        IN parameters:
                      engine_id_in
        OUT parameters:
                      exit_cd - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT

        Called from: PERL script %PMRootDir%\Bin\Framework\Initialization
        \Init_Initialize.pl
        Calling: SP_INIT_UPDATE_JOB_STATUS
        SP_INIT_SRCTABLE
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - main part
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_GUI_INIT_INITIALIZE';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_LOAD_DATE        DATE;
        V_CNT              INTEGER;
        V_ANSWER           VARCHAR2(16);
        V_APPLICATION_ID   INTEGER;

        V_ALL_ARGUMENTS    PCKG_PLOG.T_VARCHAR2;

        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'MANUAL_BATCH_LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'DEBUG> ' || V_STEP || '. LOAD_DATE: ' || TO_CHAR(V_LOAD_DATE);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Taking value of APPLICATION_ID parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   MAX(APPLICATION_ID)
          INTO   V_APPLICATION_ID
          FROM   LKP_APPLICATION
         WHERE   ENGINE_ID = ENGINE_ID_IN;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = V_APPLICATION_ID
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENGINE_ID_IN;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT =
                     (SELECT   PARAM_VAL_INT
                        FROM   CTRL_PARAMETERS
                       WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
                           AND PARAM_CD = ENGINE_ID_IN)
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS_BCKP'
             AND PARAM_CD = ENGINE_ID_IN;

        UPDATE   CTRL_PARAMETERS
           SET   PARAM_VAL_INT = 0
         WHERE   PARAM_NAME = 'MAX_CONCURRENT_JOBS'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Exec SP_INIT_RECALC_STATISTICS';

        DELETE FROM   SESS_JOB_BCKP
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := ' STEP> ' || V_STEP;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Deleting jobs from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP)
                   OR PARENT_JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP);

        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_BEGIN jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID_SEQ.NEXTVAL
                   , CJ.STREAM_NAME || '_STREAM_BEGIN'
                   , CJ.STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_BEGIN' --job_type
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID_IN
              FROM   (  SELECT   STREAM_NAME
                          FROM   CTRL_JOB
                         WHERE   NVL(PHASE, 'N/A') <> 'INITIALIZATION'
                             AND ENGINE_ID = ENGINE_ID_IN
                      GROUP BY   STREAM_NAME) CJ;


        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_END jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID
                   , STREAM_NAME || '_STREAM_END'
                   , STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_END' --job_type
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting jobs from streams  <> INITIALIZATION into SESS_JOB_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , SJ.STREAM_ID
                   , CJ.JOB_NAME
                   , CJ.STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , CJ.PRIORITY
                   , CJ.CMD_LINE
                   , CJ.SRC_SYS_ID
                   , CJ.PHASE
                   , CJ.TABLE_NAME
                   , CJ.JOB_CATEGORY
                   , CJ.JOB_TYPE
                   , CJ.CONT_ANYWAY
                   , CJ.ALWAYS_RESTART --restart
                   , CJ.ALWAYS_RESTART
                   , 0 --n_rub
                   , CJ.MAX_RUNS
                   , CJ.WAITING_HR
                   , CJ.DEADLINE_HR
                   , V_APPLICATION_ID
                   , CJ.ENGINE_ID
              FROM       CTRL_JOB CJ
                     INNER JOIN
                         SESS_JOB_BCKP SJ
                     ON CJ.STREAM_NAME = SJ.STREAM_NAME
                    AND SJ.JOB_NAME = CJ.STREAM_NAME || '_STREAM_BEGIN'
                    AND CJ.ENGINE_ID = ENGINE_ID_IN
             WHERE   NVL(CJ.PHASE, 'N/A') <> 'INITIALIZATION';

        V_STEP := 'Inserting job dependency from CTRL_JOB_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CJD.REL_TYPE
              FROM           CTRL_JOB_DEPENDENCY CJD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CJD.JOB_NAME
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CJD.PARENT_JOB_NAME
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting stream dependency from CTRL_STREAM_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CSD.REL_TYPE
              FROM           CTRL_STREAM_DEPENDENCY CSD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CSD.STREAM_NAME || '_STREAM_BEGIN'
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CSD.PARENT_STREAM_NAME || '_STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_BEGIN job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_BEGIN'
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(CHLD.JOB_TYPE, 'N/A') <> 'STREAM_BEGIN'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_END job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_END'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(PRNT.JOB_TYPE, 'N/A') <> 'STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Removing potential self dependency from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   PARENT_JOB_NAME = JOB_NAME;

        V_STEP := 'Calling procedure SP_INIT_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        SP_INIT_SRCTABLE(ENGINE_ID_IN   => ENGINE_ID_IN
                       , DEBUG_IN       => DEBUG_IN
                       , EXIT_CD        => EXIT_CD
                       , ERRMSG_OUT     => ERRMSG_OUT
                       , ERRCODE_OUT    => ERRCODE_OUT
                       , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Procedure SP_INIT_SRCTABLE finished';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := ' Result: ' || TO_CHAR(EXIT_CD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_SRCTABLE failed
            V_STEP := 'ERROR> Procedure SP_INIT_SRCTABLE failed, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        /*
                V_STEP := 'Inserting all records from SESS_JOB_DEPENDENCY_BCKP into SESS_JOB_DEPENDENCY';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                INSERT INTO SESS_JOB_DEPENDENCY
                    SELECT   *
                      FROM   SESS_JOB_DEPENDENCY_BCKP
                     WHERE   JOB_ID IN (SELECT   JOB_ID
                                          FROM   SESS_JOB_BCKP
                                         WHERE   ENGINE_ID = ENGINE_ID_IN)
                          OR PARENT_JOB_ID IN (SELECT   JOB_ID
                                                 FROM   SESS_JOB_BCKP
                                                WHERE   ENGINE_ID = ENGINE_ID_IN);

                V_STEP := 'Inserting all records from SESS_JOB_BCKP into SESS_JOB';
                V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
                V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

                UPDATE   SESS_JOB_BCKP
                   SET   STATUS = 100
                 WHERE   ENGINE_ID = ENGINE_ID_IN;

                INSERT INTO SESS_JOB
                    SELECT   *
                      FROM   SESS_JOB_BCKP
                     WHERE   ENGINE_ID = ENGINE_ID_IN;
        */

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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := -3;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
    END SP_GUI_INIT_INITIALIZE;

    PROCEDURE SP_INIT_FINAL_CUT(ENGINE_ID_IN IN NUMBER DEFAULT 0
                              , DEBUG_IN IN   INTEGER:= 0
                              , EXIT_CD   OUT NOCOPY NUMBER
                              , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                              , ERRCODE_OUT   OUT NOCOPY NUMBER
                              , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_INIT_INITIALIZE
        IN parameters:
                      engine_id_in
        OUT parameters:
                      exit_cd - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT

        Called from: PERL script %PMRootDir%\Bin\Framework\Initialization
        \Init_Initialize.pl
        Calling: SP_INIT_UPDATE_JOB_STATUS
        SP_INIT_SRCTABLE
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Petr Stefanek
        Date:  2010-01-22
        -------------------------------------------------------------------------------
        Description: DWH initialization - main part
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_INIT_INITIALIZE';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_LOAD_DATE        DATE;
        V_CNT              INTEGER;
        V_ANSWER           VARCHAR2(16);
        V_APPLICATION_ID   INTEGER;

        V_ALL_ARGUMENTS    PCKG_PLOG.T_VARCHAR2;

        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Taking value of LOAD_DATE parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'DEBUG> ' || V_STEP || '. LOAD_DATE: ' || TO_CHAR(V_LOAD_DATE);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Taking value of APPLICATION_ID parameter';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_INT
          INTO   V_APPLICATION_ID
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'APPLICATION_ID'
             AND PARAM_CD = ENGINE_ID_IN;

        V_STEP := 'Exec SP_INIT_RECALC_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        /*
        PCKG_INIT.SP_INIT_RECALC_STATISTICS(ENGINE_ID_IN   => ENGINE_ID_IN
                                          , DEBUG_IN       => DEBUG_IN
                                          , EXIT_CD        => EXIT_CD
                                          , ERRMSG_OUT     => ERRMSG_OUT
                                          , ERRCODE_OUT    => ERRCODE_OUT
                                          , ERRLINE_OUT    => ERRLINE_OUT);


        --        v_all_dbg_info(v_dbg_info_id+1) := 'DEBUG> ' || v_step || '. APPLICATION_ID: ' || TO_CHAR(v_application_id);
        */
        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Exec SP_INIT_RECALC_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_BCKP
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := ' STEP> ' || V_STEP;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Deleting jobs from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP)
                   OR PARENT_JOB_ID NOT IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP);

        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_BEGIN jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID_SEQ.NEXTVAL
                   , CJ.STREAM_NAME || '_STREAM_BEGIN'
                   , CJ.STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1000 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_BEGIN' --job_type
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID_IN
              FROM   (  SELECT   STREAM_NAME
                          FROM   CTRL_JOB
                         WHERE   NVL(PHASE, 'N/A') <> 'INITIALIZATION'
                             AND ENGINE_ID = ENGINE_ID_IN
                      GROUP BY   STREAM_NAME) CJ;


        V_STEP := 'Inserting into SESS_JOB_BCKP - STREAM_END jobs';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , STREAM_ID
                   , STREAM_NAME || '_STREAM_END'
                   , STREAM_NAME
                   , 100 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , 1000 --priority
                   , 'echo ON' --cmd_line
                   , 0 --src_sys_id
                   , NULL --phase
                   , NULL --table_name
                   , 'COMMAND' --job_category
                   , 'STREAM_END' --job_type
                   , 1 --cont_anyway
                   , 1 --restart
                   , 1 --always_restart
                   , 0 --n_run
                   , 3 --max_runs
                   , NULL --waiting_hr
                   , NULL --deadline_hr
                   , V_APPLICATION_ID
                   , ENGINE_ID
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting jobs from streams  <> INITIALIZATION into SESS_JOB_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_BCKP(JOB_ID
                                , STREAM_ID
                                , JOB_NAME
                                , STREAM_NAME
                                , STATUS
                                , LAST_UPDATE
                                , LOAD_DATE
                                , PRIORITY
                                , CMD_LINE
                                , SRC_SYS_ID
                                , PHASE
                                , TABLE_NAME
                                , JOB_CATEGORY
                                , JOB_TYPE
                                , CONT_ANYWAY
                                , RESTART
                                , ALWAYS_RESTART
                                , N_RUN
                                , MAX_RUNS
                                , WAITING_HR
                                , DEADLINE_HR
                                , APPLICATION_ID
                                , ENGINE_ID)
            SELECT   JOB_ID_SEQ.NEXTVAL
                   , SJ.STREAM_ID
                   , CJ.JOB_NAME
                   , CJ.STREAM_NAME
                   , 0 --status
                   , NULL --last_update
                   , V_LOAD_DATE
                   , CJ.PRIORITY
                   , CJ.CMD_LINE
                   , CJ.SRC_SYS_ID
                   , CJ.PHASE
                   , CJ.TABLE_NAME
                   , CJ.JOB_CATEGORY
                   , CJ.JOB_TYPE
                   , CJ.CONT_ANYWAY
                   , CJ.ALWAYS_RESTART --restart
                   , CJ.ALWAYS_RESTART
                   , 0 --n_rub
                   , CJ.MAX_RUNS
                   , CJ.WAITING_HR
                   , CJ.DEADLINE_HR
                   , V_APPLICATION_ID
                   , CJ.ENGINE_ID
              FROM       CTRL_JOB CJ
                     INNER JOIN
                         SESS_JOB_BCKP SJ
                     ON CJ.STREAM_NAME = SJ.STREAM_NAME
                    AND SJ.JOB_NAME = CJ.STREAM_NAME || '_STREAM_BEGIN'
                    AND CJ.ENGINE_ID = ENGINE_ID_IN
             WHERE   NVL(CJ.PHASE, 'N/A') <> 'INITIALIZATION';

        V_STEP := 'Inserting job dependency to INITIALIZE_STREAM_END job into SESS_JOB_DEPENDENCY table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        V_STEP := 'Inserting job dependency to STREAM_END INITIALIZATION job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB PRNT
                     CROSS JOIN
                         SESS_JOB_BCKP CHLD
             WHERE   NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_END'
                 AND PRNT.ENGINE_ID = ENGINE_ID_IN
                 AND NVL(PRNT.PHASE, 'N/A') = 'INITIALIZATION'
                 AND CHLD.ENGINE_ID = ENGINE_ID_IN
                 AND NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_BEGIN';


        V_STEP := 'Inserting job dependency from CTRL_JOB_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CJD.REL_TYPE
              FROM           CTRL_JOB_DEPENDENCY CJD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CJD.JOB_NAME
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CJD.PARENT_JOB_NAME
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting stream dependency from CTRL_STREAM_DEPENDEMCY into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , CSD.REL_TYPE
              FROM           CTRL_STREAM_DEPENDENCY CSD
                         JOIN
                             SESS_JOB_BCKP CHLD
                         ON CHLD.JOB_NAME = CSD.STREAM_NAME || '_STREAM_BEGIN'
                        AND CHLD.ENGINE_ID = ENGINE_ID_IN
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON PRNT.JOB_NAME = CSD.PARENT_STREAM_NAME || '_STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_BEGIN job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(PRNT.JOB_TYPE, 'N/A') = 'STREAM_BEGIN'
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(CHLD.JOB_TYPE, 'N/A') <> 'STREAM_BEGIN'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Inserting job dependency to STREAM_END job into SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY_BCKP(JOB_ID
                                           , JOB_NAME
                                           , PARENT_JOB_ID
                                           , PARENT_JOB_NAME
                                           , REL_TYPE)
            SELECT   CHLD.JOB_ID
                   , CHLD.JOB_NAME
                   , PRNT.JOB_ID
                   , PRNT.JOB_NAME
                   , NULL --rel_type
              FROM       SESS_JOB_BCKP CHLD
                     JOIN
                         SESS_JOB_BCKP PRNT
                     ON NVL(CHLD.JOB_TYPE, 'N/A') = 'STREAM_END'
                    AND CHLD.ENGINE_ID = ENGINE_ID_IN
                    AND CHLD.STREAM_NAME = PRNT.STREAM_NAME
                    AND NVL(PRNT.JOB_TYPE, 'N/A') <> 'STREAM_END'
                    AND PRNT.ENGINE_ID = ENGINE_ID_IN;

        V_STEP := 'Removing potential self dependency from SESS_JOB_DEPENDENCY_BCKP table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY_BCKP
              WHERE   PARENT_JOB_NAME = JOB_NAME;

        V_STEP := 'Calling procedure SP_INIT_UPDATE_JOB_STATUS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        PCKG_INIT.SP_INIT_UPDATE_JOB_STATUS(ENGINE_ID_IN   => ENGINE_ID_IN
                                          , DEBUG_IN       => DEBUG_IN
                                          , EXIT_CD        => EXIT_CD
                                          , ERRMSG_OUT     => ERRMSG_OUT
                                          , ERRCODE_OUT    => ERRCODE_OUT
                                          , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Procedure SP_INIT_UPDATE_JOB_STATUS finished';

        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := ' Result: ' || TO_CHAR(EXIT_CD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_UPDATE_JOB_STATUS failed
            --            v_all_dbg_info(v_dbg_info_id+1) := 'ERROR> Procedure SP_INIT_UPDATE_JOB_STATUS failed, exiting ...';
            V_STEP := 'ERROR> Procedure SP_INIT_UPDATE_JOB_STATUS failed, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Calling procedure SP_INIT_SRCTABLE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        SP_INIT_SRCTABLE(ENGINE_ID_IN   => ENGINE_ID_IN
                       , DEBUG_IN       => DEBUG_IN
                       , EXIT_CD        => EXIT_CD
                       , ERRMSG_OUT     => ERRMSG_OUT
                       , ERRCODE_OUT    => ERRCODE_OUT
                       , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
        THEN
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Procedure SP_INIT_SRCTABLE finished';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        V_STEP := ' Result: ' || TO_CHAR(EXIT_CD);
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        IF EXIT_CD != 0
        THEN -- SP_INIT_SRCTABLE failed
            V_STEP := 'ERROR> Procedure SP_INIT_SRCTABLE failed, exiting ...';
            V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
            V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
            RAISE EX_PROCEDURE_END;
        END IF;

        V_STEP := 'Inserting all records from SESS_JOB_DEPENDENCY_BCKP into SESS_JOB_DEPENDENCY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB_DEPENDENCY
            SELECT   *
              FROM   SESS_JOB_DEPENDENCY_BCKP
             WHERE   JOB_ID IN (SELECT   JOB_ID
                                  FROM   SESS_JOB_BCKP
                                 WHERE   ENGINE_ID = ENGINE_ID_IN)
                  OR PARENT_JOB_ID IN (SELECT   JOB_ID
                                         FROM   SESS_JOB_BCKP
                                        WHERE   ENGINE_ID = ENGINE_ID_IN);

        V_STEP := 'Inserting all records from SESS_JOB_BCKP into SESS_JOB';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO SESS_JOB
            SELECT   *
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;


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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := -3;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
    END SP_INIT_FINAL_CUT;

    PROCEDURE SP_GUI_INIT_INITIALIZE_STRT(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    AS
        /******************************************************************************
        Object type: PROCEDURE
        Name:  SP_GUI_INIT_INITIALIZE_STRT
        IN parameters:
                      engine_id_in
        OUT parameters:
                      exit_cd - procedure exit code (0 - OK)
                      ERRMSG_OUT
                      ERRCODE_OUT
                      ERRLINE_OUT

        Called from: PERL script %PMRootDir%\Bin\Framework\Initialization
        \Init_Initialize.pl
        Calling: SP_INIT_UPDATE_JOB_STATUS
        SP_INIT_SRCTABLE
        -------------------------------------------------------------------------------
        Version:        1.0
        -------------------------------------------------------------------------------
        Project: PDC
        Author:  Teradata - Marcel Samek
        Date:  2011-11-09
        -------------------------------------------------------------------------------
        Description: DWH manual batch initialization - main part
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME        CONSTANT VARCHAR2(64) := 'SP_GUI_INIT_INITIALIZE_STRT';
        --exception
        EX_PROCEDURE_END EXCEPTION;
        -- local variables
        V_ERRORCODE        INTEGER;
        V_ERRORTEXT        VARCHAR2(1024);
        V_STEP             VARCHAR2(1024);
        V_LOAD_DATE        DATE;
        V_CNT              INTEGER;
        V_ANSWER           VARCHAR2(16);
        V_APPLICATION_ID   INTEGER;

        V_ALL_ARGUMENTS    PCKG_PLOG.T_VARCHAR2;

        V_ALL_DBG_INFO     PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID      INTEGER := 0;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ENGINE_ID_IN;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;

        EXIT_CD := 0;

        V_STEP := 'Inserting all records from SESS_JOB_DEPENDENCY_BCKP into SESS_JOB_DEPENDENCY';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM   SESS_JOB_DEPENDENCY
              WHERE   JOB_ID NOT IN (SELECT   JOB_ID
                                       FROM   SESS_JOB_BCKP
                                      WHERE   ENGINE_ID = ENGINE_ID_IN)
                   OR PARENT_JOB_ID NOT IN (SELECT   JOB_ID
                                              FROM   SESS_JOB_BCKP
                                             WHERE   ENGINE_ID = ENGINE_ID_IN);

        DELETE FROM   SESS_JOB
              WHERE   ENGINE_ID = ENGINE_ID_IN;

        INSERT INTO SESS_JOB_DEPENDENCY
            SELECT   *
              FROM   SESS_JOB_DEPENDENCY_BCKP
             WHERE   JOB_ID IN (SELECT   JOB_ID
                                  FROM   SESS_JOB_BCKP
                                 WHERE   ENGINE_ID = ENGINE_ID_IN)
                  OR PARENT_JOB_ID IN (SELECT   JOB_ID
                                         FROM   SESS_JOB_BCKP
                                        WHERE   ENGINE_ID = ENGINE_ID_IN);

        V_STEP := 'Inserting all records from SESS_JOB_BCKP into SESS_JOB';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
/*
        UPDATE   SESS_JOB_BCKP
           SET   STATUS = 100
         WHERE   ENGINE_ID = ENGINE_ID_IN;*/

        INSERT INTO SESS_JOB
            SELECT   *
              FROM   SESS_JOB_BCKP
             WHERE   ENGINE_ID = ENGINE_ID_IN;

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
        WHEN EX_PROCEDURE_END
        THEN
            EXIT_CD := -3;
            ERRMSG_OUT := NVL(ERRMSG_OUT, 'JOB IS RUNNING IN LIMIT');

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
    END SP_GUI_INIT_INITIALIZE_STRT;
END PCKG_INIT;

