<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MonJobsReady.aspx.cs" Inherits="PDC.MonJobsReady" EnableEventValidation="false"%>
<%@ Register src="UserControls/PDCMonitorHeader.ascx" tagname="PDCMonitorHeader" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl1" runat="server" 
        onselected="SqlDataSource_Selected" 
        onselecting="SqlDataSource_Selecting"
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_JOBS_READY_TO_RUN" 
        SelectCommandType="StoredProcedure" >
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
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>

             <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>

        </SelectParameters>
       </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl2" runat="server"
    onselected="SqlDataSource_Selected" 
      onselecting="SqlDataSource_Selecting"
      ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
      ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_SESS_JOB" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Detail_lvl1" Name="JOB_ID_IN" PropertyName="SelectedPersistedDataKey.Value" Type="Decimal" />
        <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_STREAM_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_JOB_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_JOB_TYPE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_TABLE_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_PHASE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:SessionParameter Name="FLT_JOB_CATEGORY_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
        <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
        <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
        <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
        <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
        
        <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
      
      </SelectParameters>
</asp:SqlDataSource>



    <!-- PDC Monitor Header - Custom Control -->
    <uc1:PDCMonitorHeader ID="PDCMonitorHeader1" runat="server" />
    <!-- PDC Monitor Header - Custom Control (END) -->

    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
            <p>
                <span class="ModuleHeader">Ready to Run Jobs&nbsp;(<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>)</span>
            </p>
            <p class="PDCPagingInfo">
                <asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
                &nbsp; Number of rows per page: &nbsp;
                <asp:DropDownList ID="PagerCountperPage" runat="server" AutoPostBack="True" OnSelectedIndexChanged="PagerCountperPage_SelectedIndexChanged">
                    <asp:ListItem>10</asp:ListItem>
                    <asp:ListItem>20</asp:ListItem>
                    <asp:ListItem>50</asp:ListItem>
                    <asp:ListItem>100</asp:ListItem><asp:ListItem>200</asp:ListItem>
                    <asp:ListItem>500</asp:ListItem>
                    
                </asp:DropDownList>
            </p>
            <div class="scrollable"><asp:GridView ID="gv_Detail_lvl1" runat="server" DataKeyNames="JOB_ID" DataSourceID="SqlDataSource_gv_Detail_lvl1"
                AllowSorting="True" AutoGenerateColumns="False" CellPadding="2" CellSpacing="1"
                GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
                EnableViewState="False" OnSelectedIndexChanged="gv_Detail_lvl1_SelectedIndexChanged"
                AllowPaging="True" PageSize="<%$ AppSettings:DefaultPageItemCount %>" 
				OnDataBound="gv_Detail_lvl1_DataBound" PagerSettings-Position="TopAndBottom" 
                PagerSettings-Mode="NumericFirstLast"
                EnablePersistedSelection="true">
                <Columns>
                    <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png" SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink"/>
                    <asp:BoundField DataField="JOB_ID" HeaderText="JOB_ID" ReadOnly="True" SortExpression="JOB_ID" />
                    <asp:BoundField DataField="JOB_NAME" HeaderText="JOB_NAME" ReadOnly="True" SortExpression="JOB_NAME" />
                    <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" ReadOnly="True" SortExpression="STREAM_NAME" />
                    <asp:BoundField DataField="LAST_UPDATE" HeaderText="LAST_UPDATE" ReadOnly="True" SortExpression="LAST_UPDATE" />
                    <asp:BoundField DataField="N_RUN" HeaderText="N_RUN" ReadOnly="True" SortExpression="N_RUN" />                    
                    <asp:BoundField DataField="STATUS" HeaderText="STATUS" ReadOnly="True" SortExpression="STATUS" />
                    <asp:BoundField DataField="SYSTEM_NAME" HeaderText="SYSTEM_NAME" ReadOnly="True" SortExpression="SYSTEM_NAME" />
                    <asp:BoundField DataField="JOB_CATEGORY" HeaderText="JOB_CATEGORY" ReadOnly="True" SortExpression="JOB_CATEGORY" />
                    <asp:BoundField DataField="ENGINE_ID" HeaderText="ENGINE_ID" ReadOnly="True" SortExpression="ENGINE_ID" />
                </Columns>
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
                <SelectedRowStyle CssClass="PDCTblSelRow" />
                <SortedAscendingHeaderStyle CssClass="sort_asc" />
                <SortedDescendingHeaderStyle CssClass="sort_desc" />
                <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                <HeaderStyle CssClass="PDCTblHeader" />
                <PagerStyle CssClass="PDCTblPaging" />
            </asp:GridView></div>
    </asp:Panel>
    <div class="breaker_simple">&nbsp;</div>
    <asp:Panel ID="p_Detail_lvl2" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
            <p>
                <span class="ModuleHeader">Job Details</span>&nbsp;&gt;&nbsp;<asp:Label ID="l_Detail_lvl2_lbl"
                    runat="server" Text="Label" EnableViewState="False"></asp:Label>

            </p>
              <asp:Panel ID="p_CONTROL" runat="server"  EnableViewState="False" Visible="False">
                <asp:LinkButton ID="BJobControl_MARKASFINISHED" runat="server"  CommandName="COMMAND_JOB_MARKASFINISHED" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Mark as Finished</span></asp:LinkButton>
                </asp:Panel>   

            <div class="breaker_simple">&nbsp;</div>
            <asp:DetailsView ID="gv_Detail_lvl2" runat="server" DataSourceID="SqlDataSource_gv_Detail_lvl2"
                CellPadding="2" CellSpacing="1" GridLines="Both" CssClass="PDCTbl" EmptyDataText="No rows"
                 OnDataBound="gv_Detail_lvl2_DataBound"
                 EnableViewState="False">
                <FieldHeaderStyle CssClass="PDCHighlight" />
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
            </asp:DetailsView>
    </asp:Panel>
</asp:Content>
