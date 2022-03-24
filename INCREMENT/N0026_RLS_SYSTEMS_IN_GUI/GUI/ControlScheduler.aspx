<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ControlScheduler.aspx.cs" Inherits="PDC.ControlScheduler" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<asp:Panel ID="p_ControlSchedulerHandling" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
    <p>
        <span class="ModuleHeader">Scheduler&nbsp;</span>
    </p>
    <p>
    <asp:LinkButton ID="LBControlSchedulerStart" runat="server"  CommandName="COMMAND_SCHED_START" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span><b class="SchedStart">Start</b></span></asp:LinkButton>
    &nbsp;-&nbsp;Start of Scheduler. This action returns Scheduler possibility supply jobs to Engine for launching.
    </p>
    <p>
    <asp:LinkButton ID="LBControlSchedulerStop" runat="server"  CommandName="COMMAND_SCHED_STOP" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span><b class="SchedStop">Stop</b></span></asp:LinkButton>
    &nbsp;-&nbsp;Stop of Scheduler. This action removes Scheduler possibility to choose jobs for processing. (concurrent running jobs = 0)
    </p>
    <p>
    <asp:LinkButton ID="LBControlSchedulerStopAll" runat="server"  CommandName="COMMAND_SCHED_STOP_ALL" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span><b class="SchedStop">Stop All</b></span></asp:LinkButton>
    &nbsp;-&nbsp;Stops all Schedulers.
    </p>
</asp:Panel>

<asp:Panel ID="p_ControlSchedulerNumberOfJobs" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
    <p>
        <span class="ModuleHeader">SCHEDULER - number of Running jobs&nbsp;</span>
    </p>


    <asp:SqlDataSource ID="SqlDataSource_tNumberOfJobs" runat="server" 
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>"
            EnableViewState="False"
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CTRL_SCHED_NUM_JOB"
                                    SelectCommandType="StoredProcedure"
                                    OnSelecting="SqlDataSource_Lookup_Selecting">
                                    <SelectParameters>
                                    <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="Int32" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                                    <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                                    <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="Int32"/>
                                    <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="Int32"/>
                                    <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                                    <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="Int32"/>
                                    <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>           
                                    <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                                    </SelectParameters>
        </asp:SqlDataSource>
    Number of Concurent Jobs:&nbsp;
    <asp:DropDownList ID="tNumberOfJobsSel" runat="server" 
        AutoPostBack="False" DataSourceID="SqlDataSource_tNumberOfJobs" 
        DataTextField="LKP_VAL_DESC" DataValueField="LKP_VAL_DESC" >
    </asp:DropDownList>
    <p>
    <asp:LinkButton ID="LBControlSchedulerJobsNoTemp" runat="server"  CommandName="COMMAND_SCHED_NUM_JOB_TEMP" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span>Set Temporarily</span></asp:LinkButton>
    &nbsp;-&nbsp;set the number of concurrent jobs for current job processing. Next day initialization returns the value of concurrently running jobs to default.
    </p>
    <p>
    <asp:LinkButton ID="LBControlSchedulerJobsNoPerm" runat="server"  CommandName="COMMAND_SCHED_NUM_JOB_PERM" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span>Set Permanently</span></asp:LinkButton>
    &nbsp;-&nbsp;set the number of concurrent jobs permanently, it means that also default is changed. 
    </p>
</asp:Panel>

<asp:Panel ID="Panel1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
    <p>
        <span class="ModuleHeader">Systems&nbsp; - enable/disable system</span>
    </p>
      <asp:GridView ID="gv_Systems" runat="server" DataSourceID="SqlDataSource_GUI_SYS_STAT"
            GridLines="None" CssClass="PDCFilterButtons" CellPadding="2" CellSpacing="1" 
            EnableViewState="False" AutoGenerateColumns="False" OnRowDataBound="gv_Systems_RowDataBound">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:BoundField DataField="PARAM_VAL_CHAR" HeaderText="System" />
                <asp:BoundField DataField="SYS_STATUS" HeaderText="Status" />
                <asp:TemplateField ControlStyle-CssClass="PDCButton"  HeaderStyle-CssClass="PDCButton" ItemStyle-CssClass="PDCButton">
                      <ItemTemplate>
                          <asp:LinkButton ID="systemAction" runat="server"  CommandName="SYSTEM" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" EnableViewState="False"><span>ENABLE/DISABLE</span></asp:LinkButton>
                      </ItemTemplate>
                 </asp:TemplateField>

            </Columns>
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource_GUI_SYS_STAT" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        
    ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_HEADER_SYS_STAT"
        SelectCommandType="StoredProcedure"
    onselecting="SqlDataSource_Procedure_Selecting" EnableViewState="False">
        <SelectParameters>
            <asp:Parameter Name="SYS_STATUS_OUT" Direction="Output" />
            <asp:Parameter Name="SYS_NUMBER_ON" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SYS_NUMBER_OFF" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SELECTED_ENG_ID_IN" Direction="InputOutput" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Panel>

</asp:Content>

