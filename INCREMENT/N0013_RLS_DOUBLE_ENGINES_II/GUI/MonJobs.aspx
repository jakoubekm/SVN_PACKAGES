<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MonJobs.aspx.cs" Inherits="PDC.MonJobs" %>

<%@ Register src="UserControls/PDCMonitorHeader.ascx" tagname="PDCMonitorHeader" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:SqlDataSource ID="SqlDataSource_gv_Master" runat="server" 
          onselected="SqlDataSource_Selected" 
      onselecting="SqlDataSource_Selecting"
      ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
      ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_JOB_STATS" 
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
 <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl1" runat="server"
          onselected="SqlDataSource_Selected" 
      onselecting="SqlDataSource_Selecting"
      ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
      ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_JOB_DETAILS" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Master" Name="STATUS_IN" PropertyName="SelectedValue" Type="Int32" />
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
        <asp:ControlParameter ControlID="gv_Detail_lvl1" Name="JOB_ID_IN" PropertyName="SelectedValue" Type="Decimal" />
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


    <asp:Panel ID="p_Master" runat="server" EnableViewState="False" CssClass="PortletBoxInner">

        <div class="PortletBoxInnerHalf">
            <p>
            
                <span class="ModuleHeader">Job Statistics</span>
            </p>
            <asp:GridView ID="gv_Master" runat="server" DataKeyNames="STATUS" DataSourceID="SqlDataSource_gv_Master"
                AllowPaging="False" AllowSorting="True" AutoGenerateColumns="False" CellPadding="2"
                CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
                EnableViewState="False" ShowFooter="True" OnSelectedIndexChanged="gv_Master_SelectedIndexChanged">
                <Columns>
                    <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png"
                        SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink"/>
                    <asp:BoundField DataField="STATUS" HeaderText="Status" SortExpression="STATUS" FooterText="Total" />
                    <asp:BoundField DataField="DESCRIPTION" HeaderText="Description" SortExpression="DESCRIPTION" />
                    <asp:BoundField DataField="CNT" HeaderText="Count" SortExpression="CNT" />
                </Columns>
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
                <SelectedRowStyle CssClass="PDCTblSelRow" />
                <SortedAscendingHeaderStyle CssClass="sort_asc" />
                <SortedDescendingHeaderStyle CssClass="sort_desc" />
                <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                <HeaderStyle CssClass="PDCTblHeader" />
                <FooterStyle CssClass="PDCTblFooter" />
            </asp:GridView>
        </div>
    <div class="breaker_simple">&nbsp;</div>
    </asp:Panel>
    <div class="breaker_simple">&nbsp;</div>
    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
        <p>
            <span class="ModuleHeader">Job Details&nbsp;(<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>)</span>&nbsp;&gt;&nbsp;<asp:Label ID="l_Detail_lvl1_lbl"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
        </p>
        <p class="PDCPagingInfo"><asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
        &nbsp;
        Number of rows per page:
        &nbsp;
        <asp:DropDownList 
                ID="PagerCountperPage" runat="server" AutoPostBack="True" 
                onselectedindexchanged="PagerCountperPage_SelectedIndexChanged">
            <asp:ListItem>10</asp:ListItem>
            <asp:ListItem>20</asp:ListItem>
            <asp:ListItem>50</asp:ListItem>
            <asp:ListItem>100</asp:ListItem><asp:ListItem>200</asp:ListItem>
            <asp:ListItem>500</asp:ListItem>
            
            </asp:DropDownList>
        </p>
        <div class="scrollable"><asp:GridView ID="gv_Detail_lvl1" runat="server" DataKeyNames="JOB_ID" DataSourceID="SqlDataSource_gv_Detail_lvl1"
            AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="False" PageSize="<%$ AppSettings:DefaultPageItemCount %>" PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="gv_Detail_lvl1_DataBound" OnSelectedIndexChanged="gv_Detail_lvl1_SelectedIndexChanged" >
            <Columns>
                <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png"
                    SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink" />    
                <asp:BoundField DataField="JOB_ID" FooterText="Total" HeaderText="Job ID" ReadOnly="True" SortExpression="JOB_ID" />
                <asp:BoundField DataField="JOB_NAME" HeaderText="Job Name" ReadOnly="True" SortExpression="JOB_NAME" />
                <asp:BoundField DataField="STREAM_NAME" HeaderText="Stream Name" ReadOnly="True" SortExpression="STREAM_NAME" />
                <asp:BoundField DataField="LAST_UPDATE" HeaderText="Last Update" ReadOnly="True" SortExpression="LAST_UPDATE" />
                <asp:BoundField DataField="N_RUN" HeaderText="Run" ReadOnly="True" SortExpression="N_RUN" />
                <asp:BoundField DataField="STATUS" HeaderText="Status" ReadOnly="True" SortExpression="STATUS" />

                <asp:BoundField DataField="TABLE_NAME" HeaderText="Table Name" ReadOnly="True" SortExpression="TABLE_NAME" />
                <asp:BoundField DataField="SYSTEM_NAME"  HeaderText="System name" ReadOnly="True" SortExpression="SYSTEM_NAME" />
                <asp:BoundField DataField="JOB_CATEGORY" HeaderText="Job Category" ReadOnly="True" SortExpression="JOB_CATEGORY" />
                <asp:BoundField DataField="JOB_TYPE" HeaderText="Job Type" ReadOnly="True" SortExpression="JOB_TYPE" />
                <asp:BoundField DataField="PHASE"  HeaderText="Phase" ReadOnly="True" SortExpression="PHASE" />

                
            </Columns>
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
            <PagerStyle CssClass="PDCTblPaging" />
            
        </asp:GridView></div>
    </asp:Panel>
    <div class="breaker_simple">&nbsp;</div>
    <asp:Panel ID="p_Detail_lvl2" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
        <p>
            <span class="ModuleHeader">Jobs details - :</span>&nbsp;&gt;&nbsp;<asp:Label ID="l_Detail_lvl2_lbl"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
        </p>
        
        <asp:DetailsView ID="gv_Detail_lvl2" runat="server" DataSourceID="SqlDataSource_gv_Detail_lvl2"
            AutoGenerateRowa="True" CellPadding="2"
            CellSpacing="1" GridLines="Both" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="false">
            <FieldHeaderStyle CssClass="PDCHighlight" />
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:DetailsView>

 
  
    </asp:Panel>
    <div class="breaker_simple">&nbsp;</div>

 
</asp:Content>
