<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PDCMonitorHeader.ascx.cs" Inherits="PDC.UserControls.PDCMonitorHeader" %>


<asp:UpdatePanel ID="AJAXUpdatePanelMonitorHeader" runat="server">
<ContentTemplate>
    

    <div class="PortletBoxInner">
        <p>
            <span class="ModuleHeader">PDC Status Overview</span>
        </p>
        <table class="PDCStatTable" border="0" cellspacing="1" cellpadding="2">
            <thead class="PDCStatTable">
                <tr>
                    <th>
                        Engine Name
                    </th>
                    <th>
                        Environment
                    </th>
                    <th>
                        Load Date
                    </th>
                    <th>
                        Task Type
                    </th>
                    <th>
                        Provided by
                    </th>
                    <th>
                        Task(s)
                    </th>
                    <th>
                        Refresh Rate
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="PDCStatTable">
                        <asp:Label ID="l_statEngName" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                        
                    </td>
                    <td class="PDCStatTable">
                        <asp:Label ID="l_StatEnv" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                        
                    </td>
                    <td class="PDCStatTable">
                        <asp:Label ID="l_StatLoadDate" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                        
                    </td>
                    <td class="PDCStatTable">
                        <asp:Label ID="l_StatTaskType" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                        
                    </td>
                    <td class="PDCStatTable">
                        <asp:Label ID="l_StatProvidedBy" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                     
                    </td>
                    <td class="PDCStatTable">
                           <asp:Label ID="l_StatTaskCount" runat="server" Text="Label" EnableViewState="False"></asp:Label> 
                    </td>
                    <td class="PDCStatTable">
                       <asp:Label ID="l_RefreshRate" runat="server" Text="Label" EnableViewState="False"></asp:Label>
                    </td>
                </tr>
            </tbody>
        </table>
        <div class="breaker_portlet">&nbsp;</div>&nbsp;<div class="breaker_simple">&nbsp;</div>
        <table class="PDCStatTable" border="0" cellspacing="1" cellpadding="2">
            <thead class="PDCStatTable">
                <tr>
                    <th>
                        Running Jobs
                    </th>
                    <th>
                        Failed Jobs
                    </th>
                    <th>
                        Ready to Run Jobs
                    </th>
                    <th>
                        Finnished Jobs
                    </th>
                    <th>
                        Odd Jobs
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="PDCStatTable centerMe">
                        <asp:HyperLink ID="HLStatLink1" runat="server" NavigateUrl="~/MonJobsRunning.aspx"><asp:Label ID="l_StatJobsRunningCount" runat="server" Text="Label" CssClass="B4 fontBig" EnableViewState="False"></asp:Label></asp:HyperLink>
                        
                    </td>
                    <td class="PDCStatTable centerMe">
                        <asp:HyperLink ID="HLStatLink2" runat="server" NavigateUrl="~/MonJobsFailed.aspx"><asp:Label ID="l_StatJobsFailedCount" runat="server" Text="Label" CssClass="T2 fontBig" EnableViewState="False"></asp:Label></asp:HyperLink>
                    </td>
                    <td class="PDCStatTable centerMe">
                        <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/MonJobsReady.aspx"><asp:Label ID="l_StatJobsReadyToRunCount" runat="server" Text="Label" CssClass="TDGreen fontBig" EnableViewState="False"></asp:Label></asp:HyperLink>
                    </td>
                    <td class="PDCStatTable centerMe">
                        <asp:HyperLink ID="HLStatLink3" runat="server" NavigateUrl="~/MonJobsFinished.aspx"><asp:Label ID="l_StatFinishedCount" runat="server" Text="Label" CssClass="TDGreen fontBig" EnableViewState="False"></asp:Label></asp:HyperLink>
                    </td>
                    <td class="PDCStatTable centerMe">
                        <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="~/MonJobsOdd.aspx"><asp:Label ID="l_StatOddlyCount" runat="server" Text="Label" CssClass="T2 fontBig" EnableViewState="False"></asp:Label></asp:HyperLink>
                    </td>
                </tr>
            </tbody>
        </table>
         <p class="font-small G4">
            <asp:Label ID="lAJAXRefreshTime" runat="server" Text="Last refresh at: " EnableViewState="False"></asp:Label>
            <span class="rightMe"><asp:LinkButton ID="lbRefreshHeader" runat="server" CommandName="cmdRefreshHeader" CommandArgument="true" OnCommand="BPDCCommandPressed" EnableViewState="False" CssClass="refreshButton">Refresh</asp:LinkButton></span>
        </p>
    </div>
    <!-- inner portlet 1 PDC Status Overview  -->
</ContentTemplate>
<Triggers>
    <asp:AsyncPostBackTrigger ControlID="RefreshTimer" EventName="Tick" />
</Triggers>
</asp:UpdatePanel>


<asp:SqlDataSource ID="SqlDataSource_GUI_Header" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
    ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_VIEW_HEADER_MAIN"
    SelectCommandType="StoredProcedure" OnSelected="SqlDataSource_Procedure_Selected" OnSelecting="SqlDataSource_Procedure_Selecting">
    <SelectParameters>
           <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255"/>

            <asp:SessionParameter Name="FLT_STREAM_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_TYPE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_TABLE_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_PHASE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_CATEGORY_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>

     
        <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />

        <asp:Parameter Name="ENV_NAME_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="ENGINE_NAME_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="TASK_TYPE_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="PROVIDED_BY_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255" />
        <asp:Parameter Name="LOAD_DATE_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="TASKS_NUMBER_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="NUMBER_RUNNING_JOBS_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="NUMBER_FAILED_JOBS_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="NUMBER_READY_JOBS_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="NUMBER_FINISHED_JOBS_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="GUI_REFRESH_RATE_OUT" Direction="Output" DbType="String" Size="255" />
        <asp:Parameter Name="NUMBER_ODD_JOBS_OUT" Direction="Output" DbType="String" Size="255" />
		<asp:Parameter Name="GUI_COLOUR_OUT" Direction="Output" DbType="String" Size="255" />
    </SelectParameters>
</asp:SqlDataSource>