<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LogsSTAT_LOG_EVENT_HIST.aspx.cs" Inherits="PDC.LogsSTAT_LOG_EVENT_HIST" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="PortletBoxInner">
        <p>
            <span class="ModuleHeader">Log Viewer: STAT_LOG_EVENT_HIST</span>
            <br />
            Rowcount:&nbsp;<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>
        </p>
    </div>
    <!-- inner portlet 2 tab test  -->
    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
        <p class="PDCPagingInfo"><asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
        &nbsp;
        Number of rows per page:
        &nbsp;
        <asp:DropDownList 
                ID="PagerCountperPage" runat="server" AutoPostBack="True" 
                onselectedindexchanged="PagerCountperPage_SelectedIndexChanged">
				<asp:ListItem Enabled="false" Value="Dummy due to asp bug"/>
				<asp:ListItem Value="10"></asp:ListItem>
				<asp:ListItem>20</asp:ListItem>
				<asp:ListItem>30</asp:ListItem>
				<asp:ListItem>40</asp:ListItem>
				<asp:ListItem>50</asp:ListItem>
				<asp:ListItem>100</asp:ListItem>
				<asp:ListItem>200</asp:ListItem>
				<asp:ListItem>300</asp:ListItem>
				<asp:ListItem>400</asp:ListItem>
				<asp:ListItem>500</asp:ListItem>
            </asp:DropDownList>
        </p>
        <div class="scrollable"><asp:GridView ID="gv_Detail_lvl1" runat="server" DataSourceID="SqlDataSource1" AllowPaging="True"
             AllowSorting="True" AutoGenerateColumns="True"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" ShowFooter="false" 
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
            <PagerStyle CssClass="PDCTblPaging" />
            <Columns>
            <asp:BoundField DataField="LOG_EVENT_ID" FooterText="Total" HeaderText="LOG_EVENT_ID" ReadOnly="True" SortExpression="LOG_EVENT_ID" />
            <asp:BoundField DataField="EVENT_TS" FooterText="Total" HeaderText="EVENT_TS" ReadOnly="True" SortExpression="EVENT_TS" />
            <asp:BoundField DataField="NOTIFICATION_CD" FooterText="Total" HeaderText="NOTIFICATION_CD" ReadOnly="True" SortExpression="NOTIFICATION_CD" />
            <asp:BoundField DataField="LOAD_DATE" FooterText="Total" HeaderText="LOAD_DATE" ReadOnly="True" SortExpression="LOAD_DATE" />
            <asp:BoundField DataField="JOB_NAME" FooterText="Total" HeaderText="JOB_NAME" ReadOnly="True" SortExpression="JOB_NAME" />
            <asp:BoundField DataField="JOB_ID" FooterText="Total" HeaderText="JOB_ID" ReadOnly="True" SortExpression="JOB_ID" />
            <asp:BoundField DataField="SEVERITY_LEVEL_CD" FooterText="Total" HeaderText="SEVERITY_LEVEL_CD" ReadOnly="True" SortExpression="SEVERITY_LEVEL_CD" />
            <asp:BoundField DataField="ERROR_CD" FooterText="Total" HeaderText="ERROR_CD" ReadOnly="True" SortExpression="ERROR_CD" />
            <asp:BoundField DataField="EVENT_CD" FooterText="Total" HeaderText="EVENT_CD" ReadOnly="True" SortExpression="EVENT_CD" />
            <asp:BoundField DataField="EVENT_DS" FooterText="Total" HeaderText="EVENT_DS" ReadOnly="True" SortExpression="EVENT_DS" />
            <asp:BoundField DataField="START_TS" FooterText="Total" HeaderText="START_TS" ReadOnly="True" SortExpression="START_TS" />
            <asp:BoundField DataField="END_TS" FooterText="Total" HeaderText="END_TS" ReadOnly="True" SortExpression="END_TS" />
            <asp:BoundField DataField="TRACKING_DURATION" FooterText="Total" HeaderText="TRACKING_DURATION" ReadOnly="True" SortExpression="TRACKING_DURATION" />
            <asp:BoundField DataField="LAST_STATUS" FooterText="Total" HeaderText="LAST_STATUS" ReadOnly="True" SortExpression="LAST_STATUS" />
            <asp:BoundField DataField="N_RUN" FooterText="Total" HeaderText="N_RUN" ReadOnly="True" SortExpression="N_RUN" />
            <asp:BoundField DataField="CHECKED_STATUS" FooterText="Total" HeaderText="CHECKED_STATUS" ReadOnly="True" SortExpression="CHECKED_STATUS" />
            <asp:BoundField DataField="MAX_N_RUN" FooterText="Total" HeaderText="MAX_N_RUN" ReadOnly="True" SortExpression="MAX_N_RUN" />
            <asp:BoundField DataField="AVG_DURARION_TOLERANCE" FooterText="Total" HeaderText="AVG_DURARION_TOLERANCE" ReadOnly="True" SortExpression="AVG_DURARION_TOLERANCE" />
            <asp:BoundField DataField="AVG_END_TM_TOLERANCE" FooterText="Total" HeaderText="AVG_END_TM_TOLERANCE" ReadOnly="True" SortExpression="AVG_END_TM_TOLERANCE" />
            <asp:BoundField DataField="ACTUAL_VALUE" FooterText="Total" HeaderText="ACTUAL_VALUE" ReadOnly="True" SortExpression="ACTUAL_VALUE" />
            <asp:BoundField DataField="THRESHOLD" FooterText="Total" HeaderText="THRESHOLD" ReadOnly="True" SortExpression="THRESHOLD" />
            <asp:BoundField DataField="OBJECT_NAME" FooterText="Total" HeaderText="OBJECT_NAME" ReadOnly="True" SortExpression="OBJECT_NAME" />
            <asp:BoundField DataField="NOTE" FooterText="Total" HeaderText="NOTE" ReadOnly="True" SortExpression="NOTE" />
            <asp:BoundField DataField="SENT_TS" FooterText="Total" HeaderText="SENT_TS" ReadOnly="True" SortExpression="SENT_TS" />
            <asp:BoundField DataField="DWH_DATE" FooterText="Total" HeaderText="DWH_DATE" ReadOnly="True" SortExpression="DWH_DATE" />

            </Columns>
        </asp:GridView></div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server"  ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False"
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_LOGS_STTLOGEVNTHST"  SelectCommandType="StoredProcedure"
            onselected="SqlDataSource1_Selected" OnSelecting="SqlDataSource1_Selecting">
            <SelectParameters>
                     
            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="Int32" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="Int32"/>
             <asp:SessionParameter Name="FLT_STREAM_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_TYPE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_TABLE_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_PHASE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:SessionParameter Name="FLT_JOB_CATEGORY_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="Int32"/>
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="Int32"/>
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
            
            <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>

        </SelectParameters>
        </asp:SqlDataSource>
    </asp:Panel>
    <!-- inner portlet 3 Oracle table log  -->
</asp:Content>
