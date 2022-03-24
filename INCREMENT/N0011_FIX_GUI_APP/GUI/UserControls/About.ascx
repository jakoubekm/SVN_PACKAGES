<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="About.ascx.cs" Inherits="PDC.UserControls.About" %>
<div class="page_background" style="z-index: 100" align="center">
 <div style="width: 800px;" align="left">
    <div class="tdpagetoplogin">
        <div class="tdpagetoplogin-left">
            <div class="tdpagetoplogin-right">
            <div class="rightMe">
            <a href="Monitor.aspx" class="layout-tab-close" alt="Close">&#160;</a>
            </div>
            </div>
        </div>
        
    </div>
    <div class="about_inner">
  
        <div>
        <div class="tdheader">
                    <span class="tdlogo">&#160; </span>
        </div>
          
            
            <p>
            <STRONG>PDC GUI Application</STRONG>  
            </p>
            <p>
              Metadata permits PDC application administers all parts of its functionality. GUI application is WEB based application supporting standard browser functionality and using Teradata Viewpoint graphical layout. The user must have appropriate permissions for working with any part of the application. The main ask on GUI application is to enable comfortable monitoring and controlling of job processing, but GUI application is not necessary for PDC work. Jobs can be located in different instances of PDC; these instances are totally independent and are used for controlling and monitoring independent data processing. GUI shows only jobs located in selected instance of PDC but on status line are displayed statuses of all instances simultaneously. For selecting only specific part of objects a filter can be used on stream and job level. GUI consists from several parts whose meaning and functionality is described below. The monitoring screen during job processing phase is shown on the below screenshot.
            </p>
            
            <p>
            <STRONG>Status line</STRONG>  
            </p>
            <p>
              Status line is located in the top level of GUI application and shows the number of the engine which is selected for monitoring and controlling. Statuses of other Engines and Schedulers are also displayed. For faster touching of information which is looked for a filter can be used.
            </p>
            <p>
            <STRONG>Monitor</STRONG>  
            </p>
            <p>
              Monitor is used for displaying of current status of processing. The information can be presented from stream or job point of view. Drill down functionality enables drill for further details, so from stream view the user can drill down the information of how many jobs are located in the stream, what they are and what their status is. User can also drill down to parameters of selected job. On job level the user operates the job; it means he can abort running job, restart or finishing failed job and so on. Jobs and streams are divided into processing classes which represents objects state such as prepare for run, running, finished, failed and so on. The environment, load date and task type is shown as well as display refresh rate and maximal number of concurrently running jobs. The status overview part contains number of currently running jobs, number of failed jobs, number of jobs prepared for run and number of already finished jobs shows. All these numbers support drill down functionality, it means you can directly get a list of jobs in a category by clicking on the appropriate number.
            </p>
            <p>
            <STRONG>Control</STRONG>  
            </p>
            <p>
              Control enables access to all necessary settings used for controlling of PDC application. Same basic functionality for job processing is also located on the monitor part, but Control part enables driving parallelisms, temporary stop the Scheduler or doing control task on job level simultaneously for group of jobs. User can also simply stop executing jobs on selected dependency branch by blocking its parent job. Manual Batch functionality enables recalculation of selected jobs for chosen load date. It’s often used for datamarts recalculation for the day.
            </p>
            <p>
            <STRONG>Logs</STRONG>  
            </p>
            <p>
              Logs display controlling steps done on PDC application – it enables potential supervisor cooperation on problem solving, and also all problems captured by Framework checker application.
            </p>
            <p>
            <STRONG>SESS TABLES</STRONG>  
            </p>
            <p>
              SESS (session) tables contain production metadata and store actual status of objects. SESS TABLES part enables changes in the table content. Such change can represent increasing actual job priority, command line changes and so on.

            </p>
            <p>
            <STRONG>CTRL TABLES</STRONG>  
            </p>
            <p>
              CTRL (control) tables store configuration metadata of jobs, streams, their dependences, locks and calendars. This part of GUI application is used for creating or changing this metadata. Application automatically checks correctness of typed values. Changes are enabled only when a label is selected which is necessary for change management process package creation.

            </p>
            <p>
            <STRONG>Admin</STRONG>  
            </p>
            <p>
              Admin section contains necessary administrative tasks such as label maintenance, change management process, access control and so on.
            </p>
            <p>
            <STRONG>Reports</STRONG>  
            </p>
            <p>
              Reports page is a signpost for customer reports related for PDC processing. Customers can simply use their reporting tools for creating reports based on PDC metadata and place them on this page.
            </p>
            
       
        </div>
    </div>
    <div class="tdpagebottomlogin">
        <div class="tdpagebottomlogin-left">
            <div class="tdpagebottomlogin-right">
            </div>
        </div>
    </div>
  </div>
</div>
