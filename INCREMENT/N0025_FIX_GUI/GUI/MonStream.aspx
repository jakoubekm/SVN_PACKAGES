<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MonStream.aspx.cs" Inherits="PDC.MonStream" %>
    
<%@ Register src="UserControls/PDCMonitorHeader.ascx" tagname="PDCMonitorHeader" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:SqlDataSource ID="SqlDataSource_gv_Master" runat="server"
        onselected="SqlDataSource_Selected" 
        onselecting="SqlDataSource_Selecting"
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_STREAM_STATS" 
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
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_STREAM_DETAILS" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Master" Name="RUNABLE" PropertyName="SelectedValue" Type="String" />
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
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_STREAM_DET_1" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Detail_lvl1" Name="STREAM_ID" PropertyName="SelectedValue"  Type="Decimal" />
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
    <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl2_2" runat="server" 
          onselected="SqlDataSource_Selected" 
      onselecting="SqlDataSource_Selecting"
      ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
      ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_STREAM_DET_2" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Detail_lvl1" Name="STREAM_ID" PropertyName="SelectedValue"  Type="Decimal" />
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
    <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl2_3" runat="server" 
          onselected="SqlDataSource_Selected" 
      onselecting="SqlDataSource_Selecting"
      ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
      ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
      SelectCommand="PCKG_GUI.SP_GUI_VIEW_GUI_STREAM_DET_3" 
      SelectCommandType="StoredProcedure" >
      <SelectParameters>
             
        <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
        <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
        <asp:ControlParameter ControlID="gv_Detail_lvl1" Name="STREAM_ID" PropertyName="SelectedValue"  Type="Decimal" />
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
    
    <!-- -->
    <asp:Panel ID="p_Master" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
        <div class="PortletBoxInnerHalf">
        <p>
            <span class="ModuleHeader">Stream Statistics</span>
        </p>
        <asp:GridView ID="gv_Master" runat="server" DataKeyNames="RUNABLE" 
                DataSourceID="SqlDataSource_gv_Master" AllowSorting="True" 
                AutoGenerateColumns="False" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="True" 
                OnSelectedIndexChanged="gv_Master_SelectedIndexChanged">
            <Columns>
                <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png"
                    SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink" />   
                <asp:BoundField DataField="RUNABLE" HeaderText="Runable" SortExpression="RUNABLE" FooterText="Total" />
                
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
            <span class="ModuleHeader">Stream Details</span>&nbsp;&gt;&nbsp;<asp:Label ID="l_Detail_lvl1_lbl"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
        </p>
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
        <div class="scrollable"><asp:GridView ID="gv_Detail_lvl1" runat="server" DataKeyNames="STREAM_ID" DataSourceID="SqlDataSource_gv_Detail_lvl1"
            AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="False" 
            OnSelectedIndexChanged="gv_Detail_lvl1_SelectedIndexChanged" 
            
            PagerSettings-Position="TopAndBottom" PagerSettings-Mode="NumericFirstLast" 
            ondatabound="gv_Detail_lvl1_DataBound">
            <Columns>
                <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png"
                    SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink" />    
                <asp:BoundField DataField="STREAM_ID" HeaderText="Stream ID" ReadOnly="True"
                    SortExpression="STREAM_ID" />                
                <asp:BoundField DataField="STREAM_NAME"  HeaderText="Stream Name"
                    ReadOnly="True" SortExpression="STREAM_NAME" />
                <asp:BoundField DataField="RUNABLE"  HeaderText="Runable" ReadOnly="True"
                    SortExpression="RUNABLE" />
                <asp:BoundField DataField="N_FINISHED"  HeaderText="N_FINISHED"
                    ReadOnly="True" SortExpression="N_FINISHED" />
                <asp:BoundField DataField="N_FORCE_FINISHED"  HeaderText="N_FORCE_FINISHED"
                    ReadOnly="True" SortExpression="N_FORCE_FINISHED" />
                <asp:BoundField DataField="N_VOID_FINISHED"  HeaderText="N_VOID_FINISHED"
                    ReadOnly="True" SortExpression="N_VOID_FINISHED" />
                <asp:BoundField DataField="N_FINISHED_ODDLY"  HeaderText="N_FINISHED_ODDLY"
                    ReadOnly="True" SortExpression="N_FINISHED_ODDLY" />
                <asp:BoundField DataField="N_RUNABLE"  HeaderText="N_RUNABLE" ReadOnly="True"
                    SortExpression="N_RUNABLE" />
                <asp:BoundField DataField="N_RUNNING"  HeaderText="N_RUNNING" ReadOnly="True"
                    SortExpression="N_RUNNING" />
                <asp:BoundField DataField="N_FAILED"  HeaderText="N_FAILED" ReadOnly="True"
                    SortExpression="N_FAILED" />
                <asp:BoundField DataField="N_BLOCKED"  HeaderText="N_BLOCKED" ReadOnly="True"
                    SortExpression="N_BLOCKED" />
                <asp:BoundField DataField="N_NOT_DEFINED"  HeaderText="N_NOT_DEFINED"
                    ReadOnly="True" SortExpression="N_NOT_DEFINED" />
                <asp:BoundField DataField="N_TOTAL"  HeaderText="N_TOTAL" ReadOnly="True"
                    SortExpression="N_TOTAL" />
                
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
            <span class="ModuleHeader">Jobs related to Stream details - Stream:</span>&nbsp;&gt;&nbsp;<asp:Label ID="l_Detail_lvl2_lbl"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
        </p>
        <asp:GridView ID="gv_Detail_lvl2" runat="server" DataSourceID="SqlDataSource_gv_Detail_lvl2"
            AllowPaging="False" AllowSorting="True" AutoGenerateColumns="False" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="false">
            <Columns>
                <asp:BoundField DataField="STREAM_ID" HeaderText="STREAM_ID" SortExpression="STREAM_ID" />
                <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" SortExpression="STREAM_NAME" />
                <asp:BoundField DataField="STREAM_DESC" HeaderText="STREAM_DESC" SortExpression="STREAM_DESC" />
                <asp:BoundField DataField="NOTE" HeaderText="NOTE" SortExpression="NOTE" />
            </Columns>
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
        <!--
        <p>
            <span class="ModuleHeader">Stream run status</span>
        </p>
        <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource_gv_Detail_lvl2_2"
            AllowPaging="False" AllowSorting="True" AutoGenerateColumns="True" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="false">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
        -->
        <p>
            <span class="ModuleHeader">Stream jobs</span>
        </p>
        <asp:GridView ID="GridView2" runat="server" DataSourceID="SqlDataSource_gv_Detail_lvl2_3"
            AllowPaging="False" AllowSorting="True" AutoGenerateColumns="True" CellPadding="2"
            CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
            EnableViewState="False" ShowFooter="false">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
    </asp:Panel>
    <div class="breaker_simple">&nbsp;</div>

 
</asp:Content>
