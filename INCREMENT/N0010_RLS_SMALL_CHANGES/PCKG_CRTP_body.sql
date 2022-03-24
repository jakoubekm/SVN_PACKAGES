
  CREATE OR REPLACE PACKAGE BODY "PDC"."PCKG_CRTP" IS

  PROCEDURE SP_CRTP_CALC_CRITICAL_PATH(VERTEX_IN IN BINARY_INTEGER
                                        , LOAD_DATE_IN IN DATE
                                        , ENGINE_ID_IN IN BINARY_INTEGER
                                        , DEBUG_IN IN   INTEGER:= 0
                                        , EXIT_CD   OUT NOCOPY NUMBER
                                        , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                        , ERRCODE_OUT   OUT NOCOPY NUMBER
                                        , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
  IS
    /******************************************************************************
    Object type:   PROCEDURE
    Name:    SP_CRTP_CALC_CRITICAL_PATH
    IN parameters:
             VERTEX_IN    - JOB_ID of job that is used as root for computation
                    of critical path.
             LOAD_DATE_IN - date of load which critical path is computed for.
             ENGINE_ID_IN - id of PDC engine that controls investigated load.
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
    Project: PDC
    Author:  Teradata - Tomas Kupka
    Date:    2014-06-23
    -------------------------------------------------------------------------------
    Description: The procedure populates table TEMP_CRTP_JOB_DISTANCES that contains
           maximal distances from root (initial) job to every other job.

           Moreover every job has defined order in computed critical path for
           a given load date.(if order is defined as -1 then job lies out of
           the critical path).
    -------------------------------------------------------------------------------
    Modified:  Teradata - Tomas Kupka
    Version:   1.0
    Date:	   2014-06-23
    Modification: Initial version
    *******************************************************************************/
    -- constants
    C_PROC_NAME                  CONSTANT VARCHAR2(64) := 'SP_CRTP_CALC_CRITICAL_PATH';
    -- exceptions
    GRAPH_NOT_FOUND  EXCEPTION;
    VERTEX_NOT_FOUND EXCEPTION;
    SUB_PROCEDURE_FAIL EXCEPTION;
    -- local variables
    V_STEP                       VARCHAR2(1024);
    V_ALL_DBG_INFO               PCKG_PLOG.T_VARCHAR2;
    V_DBG_INFO_ID                INTEGER := 0;
    V_ENG_RUN_TIME               INTEGER := 0;
    V_ENG_RUN_TIME_DIFF          INTEGER := 0;
    V_ERRORCODE                  INTEGER;
    V_ERRORTEXT                  VARCHAR2(1024);

    V_VERTEX                     BINARY_INTEGER;
    V_CAN_BE_TREATED             BOOLEAN;
    I                            BINARY_INTEGER;
    V_DUMMY                      VARCHAR(10);
    V_TREATED                    STACK_INTEGER_TAB; 			-- Vertex exists in this list if it was treated.
    V_STACK                      STACK_INTEGER_TAB;				-- Stack of vertices that are going to be treated.
    V_ORDER_IN_PATH              STACK_INTEGER_TAB;		    -- The order of vertex in critical path (-1 if vertex is out it).
    V_PREDECESSOR                STACK_INTEGER_TAB; 		  -- Predecessor for every vertex.
    V_DISTANCE                   STACK_DOUBLE_TAB;
    V_MINIMUM                    BINARY_INTEGER;
    V_ALTERNATIVE                BINARY_DOUBLE;
    V_MAXIMAL_DISTANCE           BINARY_DOUBLE;
    V_MAXIMAL_ENDPOINT           BINARY_INTEGER;
    V_INC                        BINARY_INTEGER;

    CURSOR INIT_CUR IS
       SELECT PARENT_JOB_ID VERTEX
       FROM TEMP_CRTP_DEPENDENCY_GRAPH
       WHERE LOAD_DATE = LOAD_DATE_IN
       AND ENGINE_ID = ENGINE_ID_IN
       UNION
       SELECT JOB_ID VERTEX
       FROM TEMP_CRTP_DEPENDENCY_GRAPH
       WHERE LOAD_DATE = LOAD_DATE_IN
       AND ENGINE_ID = ENGINE_ID_IN;

    CURSOR DISTANCE_CUR(PC_VERTEX_IN IN BINARY_INTEGER) IS
       SELECT JOB_ID DESTINATION, DURATION DISTANCE
       FROM TEMP_CRTP_DEPENDENCY_GRAPH
       WHERE LOAD_DATE = LOAD_DATE_IN
       AND ENGINE_ID = ENGINE_ID_IN
       AND PARENT_JOB_ID = PC_VERTEX_IN;

    CURSOR UP_NEIGHBOUR_CUR(PC_VERTEX_IN IN BINARY_INTEGER) IS
       SELECT JOB_ID DESTINATION, DURATION DISTANCE
       FROM TEMP_CRTP_DEPENDENCY_GRAPH
       WHERE LOAD_DATE = LOAD_DATE_IN
       AND ENGINE_ID = ENGINE_ID_IN
       AND PARENT_JOB_ID = PC_VERTEX_IN;

    CURSOR DOWN_NEIGHBOUR_CUR(PC_VERTEX_IN IN BINARY_INTEGER) IS
       SELECT PARENT_JOB_ID SOURCE, DURATION DISTANCE
       FROM TEMP_CRTP_DEPENDENCY_GRAPH
       WHERE LOAD_DATE = LOAD_DATE_IN
       AND ENGINE_ID = ENGINE_ID_IN
       AND JOB_ID = PC_VERTEX_IN;


    BEGIN
      -- Initialize logging.
      BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;
      END;

      -- Initialize dependency graph
      BEGIN
        V_STEP := 'Computation od dependencies and population of input table TEMP_CRTP_DEPENDENCY_GRAPH';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        PCKG_CRTP.SP_CRTP_LOAD_DEPENDENCY_GRAPH(ENGINE_ID_IN   => ENGINE_ID_IN
                                              , LOAD_DATE_IN   => LOAD_DATE_IN
                                              , DEBUG_IN       => DEBUG_IN
                                              , EXIT_CD        => EXIT_CD
                                              , ERRMSG_OUT     => ERRMSG_OUT
                                              , ERRCODE_OUT    => ERRCODE_OUT
                                              , ERRLINE_OUT    => ERRLINE_OUT);

        IF EXIT_CD != 0
          THEN
          RAISE SUB_PROCEDURE_FAIL;
        END IF;
      END;

      BEGIN
        V_STEP := 'Checking valid load date';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT 'TRUE' INTO V_DUMMY
        FROM DUAL
        WHERE EXISTS (
          SELECT *
          FROM TEMP_CRTP_DEPENDENCY_GRAPH
          WHERE LOAD_DATE = LOAD_DATE_IN
          AND ENGINE_ID = ENGINE_ID_IN
        );
        EXCEPTION
          WHEN NO_DATA_FOUND
            THEN RAISE GRAPH_NOT_FOUND;
      END;

      BEGIN
        V_STEP := 'Checking valid root vertex';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT 'TRUE' INTO V_DUMMY
        FROM DUAL
        WHERE EXISTS (
          SELECT *
          FROM TEMP_CRTP_DEPENDENCY_GRAPH
          WHERE LOAD_DATE = LOAD_DATE_IN
          AND (PARENT_JOB_ID = VERTEX_IN OR JOB_ID = VERTEX_IN)
          AND ENGINE_ID = ENGINE_ID_IN
        );
        EXCEPTION
          WHEN NO_DATA_FOUND
            THEN RAISE VERTEX_NOT_FOUND;
      END;

    /*----------------------------------------------------------------------
    ------------------------------  Start process --------------------------
    ------------------------------------------------------------------------*/

      /*-- Inicialize target table and temporary vectors:
        --		- Delete target table.
        --		- Uncheck all vertices.
        --		- Set no predecessor for every vertex.
        --		- Set no infinity distance to every vertex.
        --		- Set distance 0 to initial vertex.
        ------------------------------------------------------------------*/
      BEGIN
        V_STEP := 'Delete target table';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        DELETE FROM TEMP_CRTP_JOB_DISTANCES;

        V_STEP := 'Initialization of temporary structures';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        FOR INIT_REC IN INIT_CUR
        LOOP
          V_PREDECESSOR(INIT_REC.VERTEX) := NULL;
          V_DISTANCE(INIT_REC.VERTEX) := -1;
          V_ORDER_IN_PATH(INIT_REC.VERTEX) := -1;
        END LOOP;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        -- Set initial distance to root, add it to stack and put it on critical path.
        V_DISTANCE(VERTEX_IN) := 0;
        V_STACK(VERTEX_IN) := NULL;
        V_ORDER_IN_PATH(VERTEX_IN) := 1;
        -- Set initial maximal endpoint.
        V_MAXIMAL_DISTANCE := 0;
        V_MAXIMAL_ENDPOINT := VERTEX_IN;
      END;

      /*-- Iterate over all vertices and derive maximal distances --*/
      BEGIN
        V_STEP := 'Starting of computation of maximal distances to all vertices';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        -- Repeat till all vertices are checked.
        WHILE (V_STACK.COUNT > 0)
        LOOP
          V_VERTEX := V_STACK.FIRST;
          V_TREATED(V_VERTEX) := NULL;
          -- For every up-neighbour UP_NEIGHBOUR of vertex V_VERTEX do:
          FOR UP_NEIGHBOUR IN UP_NEIGHBOUR_CUR(V_VERTEX)
          LOOP
            V_CAN_BE_TREATED := TRUE;
            -- For every down-neighbour DOWN_NEIGHBOUR of vertex UP_NEIGHBOUR do:
            -- (Check whether UP_NEIGHBOUR can be treated).
            FOR DOWN_NEIGHBOUR IN DOWN_NEIGHBOUR_CUR(UP_NEIGHBOUR.DESTINATION)
            LOOP
              IF (V_TREATED.EXISTS(DOWN_NEIGHBOUR.SOURCE) = FALSE) THEN
                V_CAN_BE_TREATED := FALSE;
              END IF;
            END LOOP;
            -- If UP_NEIGHBOUR can be treated add it to stack.
            IF (V_CAN_BE_TREATED) THEN
              V_STACK(UP_NEIGHBOUR.DESTINATION) := NULL;
            END IF;
            -- Modify distance to UP_NEIGHBOUR.
            V_ALTERNATIVE := V_DISTANCE(V_VERTEX) + UP_NEIGHBOUR.DISTANCE;
            IF (V_ALTERNATIVE > V_DISTANCE(UP_NEIGHBOUR.DESTINATION)) THEN
              V_DISTANCE(UP_NEIGHBOUR.DESTINATION) := V_ALTERNATIVE;
              V_PREDECESSOR(UP_NEIGHBOUR.DESTINATION) := V_VERTEX;
            END IF; 			
          END LOOP;
          -- Check whether vertex is not maximal endpoint
          IF (V_MAXIMAL_DISTANCE < V_DISTANCE(V_VERTEX)) THEN
            V_MAXIMAL_ENDPOINT := V_VERTEX;
            V_MAXIMAL_DISTANCE := V_DISTANCE(V_VERTEX);
          END IF;
          V_STACK.DELETE(V_VERTEX);
        END LOOP;
      END;

      /*--  Derive critical path --*/
      BEGIN
        V_STEP := 'Computation of count of edges that forms a critical path';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        -- Derive length of path
        V_VERTEX := V_MAXIMAL_ENDPOINT;
        V_INC := 0;
        WHILE (V_VERTEX IS NOT NULL)
        LOOP
          V_INC := V_INC + 1;
          V_VERTEX := V_PREDECESSOR(V_VERTEX);
        END LOOP;
        V_STEP := 'Deriving order and distances of vertices in critical path';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        -- Derive order and distances of vertices in critical path.
        V_VERTEX := V_MAXIMAL_ENDPOINT;
        WHILE (V_VERTEX IS NOT NULL)
        LOOP
          V_ORDER_IN_PATH(V_VERTEX) := V_INC;
          V_VERTEX := V_PREDECESSOR(V_VERTEX);
          V_INC:= V_INC - 1;
        END LOOP; 	
      END;

      /*-- Write result to target table --*/
      BEGIN
        V_STEP := 'Write result to target table TEMP_CRTP_JOB_DISTANCES';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
        WHILE (V_TREATED.COUNT > 0)
        LOOP
          V_VERTEX := V_TREATED.FIRST;
          -- Insert treated vertex to target table
          INSERT INTO TEMP_CRTP_JOB_DISTANCES VALUES (
            ENGINE_ID_IN,
            V_VERTEX,
            V_DISTANCE(V_VERTEX),
            V_PREDECESSOR(V_VERTEX),
            LOAD_DATE_IN,
            V_ORDER_IN_PATH(V_VERTEX)
          );		
          V_TREATED.DELETE(V_VERTEX);
        END LOOP;
      END;

      /*-- Finalize --*/
      BEGIN
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
      END;

      EXCEPTION
        WHEN SUB_PROCEDURE_FAIL
          THEN
            EXIT_CD := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := SUBSTR('THE POPULATION OF TABLE TEMP_CRTP_DEPENDENCY_GRAPH FAILED - ' || V_STEP, 1, 1024);

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
        WHEN GRAPH_NOT_FOUND
          THEN
            EXIT_CD := -1;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := SUBSTR('THE GRAPH FOR LOAD_DATE ' || LOAD_DATE_IN || ' WAS NOT FOUND IN TABLE TEMP_CRTP_DEPENDENCY_GRAPH - ' || V_STEP, 1, 1024);

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
        WHEN VERTEX_NOT_FOUND
          THEN
            EXIT_CD := -2;
            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);
            ERRCODE_OUT := SQLCODE;
            ERRLINE_OUT := SUBSTR('THE VERTEX TO START THE ALGORITHM WAS NOT FOUND - ' || V_STEP, 1, 1024);

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
            EXIT_CD := -3;

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
  END SP_CRTP_CALC_CRITICAL_PATH;

  PROCEDURE SP_CRTP_CALC_LOAD_STATISTICS(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_CRTP_CALC_LOAD_STATISTICS
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
        Author:   Teradata - Milan Budka
        Date:    2014-06-23
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/

        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_CRTP_CALC_LOAD_STATISTICS';
        -- local variables
        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;

        V_FIRST_START_TS       SESS_STATUS.STATUS_TS%TYPE;
        V_LAST_START_TS        DATE; --sess_status.status_ts%TYPE;
        V_LAST_STATUS_TS       SESS_STATUS.STATUS_TS%TYPE;
        V_END_TS               DATE; --sess_status.status_ts%TYPE;
        V_LAST_STATUS          SESS_STATUS.STATUS%TYPE;
        V_N_RUN                SESS_STATUS.N_RUN%TYPE;
        V_LOAD_DATE            SESS_STATUS.LOAD_DATE%TYPE;
        V_DAY_IN_WEEK          NUMBER(1, 0);
        V_DAY_IN_MONTH         NUMBER(3, 0);
        V_AVG_DURATION         NUMBER(30, 0);
        V_AVG_END_TM           NUMBER(30, 0);
        V_PREV_LOAD_DATE       DATE;
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        V_STEP := 'TRUNCATE TEMP_CRTP_JOB_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM TEMP_CRTP_JOB_STATISTICS WHERE ENGINE_ID=ENGINE_ID_IN;


        V_STEP := 'select PREV_LOAD_DATE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;


        /*
          min - if initialization has been done, there are some technical jobs with new load_date
        */
        SELECT   PARAM_VAL_DATE
          INTO   V_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
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

        V_STEP := 'INSERT INTO TEMP_CRTP_JOB_STATISTICS';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        INSERT INTO TEMP_CRTP_JOB_STATISTICS(JOB_NAME
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
                AND JOB_NAME IN (SELECT JOB_NAME FROM CTRL_JOB WHERE ENGINE_ID=ENGINE_ID_IN)
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
    END SP_CRTP_CALC_LOAD_STATISTICS;

PROCEDURE SP_CRTP_LOAD_DEPENDENCY_GRAPH(ENGINE_ID_IN IN NUMBER DEFAULT 0
                                      , LOAD_DATE_IN IN DATE
                                      , DEBUG_IN IN   INTEGER:= 0
                                      , EXIT_CD   OUT NOCOPY NUMBER
                                      , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                      , ERRCODE_OUT   OUT NOCOPY NUMBER
                                      , ERRLINE_OUT   OUT NOCOPY VARCHAR2)
    IS
        /******************************************************************************
        Object type:   PROCEDURE
        Name:    SP_CRTP_LOAD_DEPENDENCY_GRAPH
        IN parameters:
                      ENGINE_ID_IN
                      DEBUG_IN
					  LOAD_DATE_IN
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
        Date:    2014-06-24
        -------------------------------------------------------------------------------
        Description:
        -------------------------------------------------------------------------------
        Modified:
        Version:
        Date:
        Modification:
        *******************************************************************************/
        --constants
        C_PROC_NAME            CONSTANT VARCHAR2(64) := 'SP_CRTP_LOAD_DEPENDENCY_GRAPH';
        -- local variables
        V_STEP                 VARCHAR2(1024);
        V_ALL_DBG_INFO         PCKG_PLOG.T_VARCHAR2;
        V_DBG_INFO_ID          INTEGER := 0;

		V_ACTUAL_LOAD_DATE     CTRL_PARAMETERS.PARAM_VAL_DATE%TYPE;
		
		SUB_PROCEDURE_FAIL EXCEPTION;
		
    BEGIN
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := 'Execute ' || C_PCKG_NAME || '.' || C_PROC_NAME;
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := DEBUG_IN;
        EXIT_CD := 0;

        V_STEP := 'TRUNCATE TEMP_CRTP_DEPENDENCY_GRAPH';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        DELETE FROM TEMP_CRTP_DEPENDENCY_GRAPH WHERE ENGINE_ID=ENGINE_ID_IN;
		
        V_STEP := 'select LOAD_DATE';
        V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
        V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;

        SELECT   PARAM_VAL_DATE
          INTO   V_ACTUAL_LOAD_DATE
          FROM   CTRL_PARAMETERS
         WHERE   PARAM_NAME = 'LOAD_DATE'
             AND PARAM_CD = ENGINE_ID_IN;

		IF V_ACTUAL_LOAD_DATE = LOAD_DATE_IN THEN

			V_STEP := 'calc actual load date statistics';
			V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
			V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
			
			PCKG_CRTP.SP_CRTP_CALC_LOAD_STATISTICS(ENGINE_ID_IN   => ENGINE_ID_IN
                                          , DEBUG_IN       => DEBUG_IN
                                          , EXIT_CD        => EXIT_CD
                                          , ERRMSG_OUT     => ERRMSG_OUT
                                          , ERRCODE_OUT    => ERRCODE_OUT
                                          , ERRLINE_OUT    => ERRLINE_OUT);

		    IF EXIT_CD != 0
				THEN
				RAISE SUB_PROCEDURE_FAIL;
			END IF;

			V_STEP := 'load of TEMP_CRTP_DEPENDENCY_GRAPH ';
			V_DBG_INFO_ID := V_DBG_INFO_ID + 1;
			V_ALL_DBG_INFO(V_DBG_INFO_ID) := ' STEP> ' || V_STEP;
						
			INSERT INTO TEMP_CRTP_DEPENDENCY_GRAPH (
				JOB_ID,
				JOB_NAME,
				PARENT_JOB_ID,
				PARENT_JOB_NAME,
				DURATION,
				LOAD_DATE,
				ENGINE_ID)
			SELECT 	SB.JOB_ID,
					SB.JOB_NAME,
					SB.PARENT_JOB_ID,
					SB.PARENT_JOB_NAME,
				  CASE WHEN TJS.AVG_DURATION IS NULL
                THEN 0
               ELSE TJS.AVG_DURATION
          END AS DURATION,
				  LOAD_DATE_IN,
				  ENGINE_ID_IN
			FROM SESS_JOB_DEPENDENCY_BCKP SB
      LEFT OUTER JOIN TEMP_CRTP_JOB_STATISTICS TJS
        ON SB.PARENT_JOB_NAME=TJS.JOB_NAME
			WHERE   SB.JOB_ID IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP WHERE ENGINE_ID=ENGINE_ID_IN)
			AND SB.PARENT_JOB_ID IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP WHERE ENGINE_ID=ENGINE_ID_IN);
			
		ELSE
		
			INSERT INTO TEMP_CRTP_DEPENDENCY_GRAPH (
				JOB_ID,
				JOB_NAME,
				PARENT_JOB_ID,
				PARENT_JOB_NAME,
				DURATION,
				LOAD_DATE,
				ENGINE_ID)
			SELECT 	SB.JOB_ID,
					SB.JOB_NAME,
					SB.PARENT_JOB_ID,
					SB.PARENT_JOB_NAME,
				  CASE WHEN TJS.AVG_DURATION IS NULL
                THEN 0
               ELSE TJS.AVG_DURATION
          END AS DURATION,
				  LOAD_DATE_IN,
				  ENGINE_ID_IN
			FROM SESS_JOB_DEPENDENCY_BCKP SB
      LEFT OUTER JOIN STAT_JOB_STATISTICS TJS
        ON SB.PARENT_JOB_NAME=TJS.JOB_NAME
			WHERE   SB.JOB_ID IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP WHERE ENGINE_ID=ENGINE_ID_IN)
			AND SB.PARENT_JOB_ID IN (     SELECT   JOB_ID FROM SESS_JOB_BCKP WHERE ENGINE_ID=ENGINE_ID_IN)
			AND TJS.LOAD_DATE=LOAD_DATE_IN
      AND TJS.AVG_DURATION IS NOT NULL;		
			
		END IF;


    EXCEPTION
        WHEN SUB_PROCEDURE_FAIL
        THEN
            ROLLBACK;

            EXIT_CD := -1;

            ERRMSG_OUT := SUBSTR(SQLERRM, 1, 1024);

            ERRCODE_OUT := SQLCODE;

            ERRLINE_OUT := 'Fail of  ' || V_STEP;

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
    END SP_CRTP_LOAD_DEPENDENCY_GRAPH;
END PCKG_CRTP;

