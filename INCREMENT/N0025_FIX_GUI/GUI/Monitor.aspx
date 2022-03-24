<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Monitor.aspx.cs" Inherits="PDC.Monitor" %>

<%@ Register src="UserControls/PDCMonitorHeader.ascx" tagname="PDCMonitorHeader" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:SqlDataSource ID="SqlDataSource_gv_Stream" runat="server" 
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
    <asp:SqlDataSource ID="SqlDataSource_gv_Jobs" runat="server"
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
  
    <!-- PDC Monitor Header - Custom Control -->
    
    <uc1:PDCMonitorHeader ID="PDCMonitorHeader1" runat="server" />

    <!-- PDC Monitor Header - Custom Control (END) -->
<asp:UpdatePanel ID="AJAXUpdatePanelMonitorHeader" runat="server">
<ContentTemplate>
    
     <asp:Panel ID="p_Master_Info" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
        <div class="PortletBoxInnerHalf">
            <p>
                <span class="ModuleHeader">Stream Statistics</span>
            </p>
            <asp:GridView ID="gv_Stream" runat="server" DataKeyNames="RUNABLE" DataSourceID="SqlDataSource_gv_Stream"
                AllowSorting="True" AutoGenerateColumns="False" CellPadding="2" CellSpacing="1"
                GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
                EnableViewState="False" ShowFooter="True">
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="detailLink">
                        <ItemTemplate>
                            <asp:HyperLink ID="gvHL1" runat="server" NavigateUrl='<%# Eval("RUNABLE","~/MonStream.aspx?filter={0}") %>'
                                EnableViewState="False">
                                <asp:Image ID="gvGo1" EnableViewState="False" runat="server" ImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png" />
                            </asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
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
        <div class="PortletBoxInnerHalfR">
            <p>
                <span class="ModuleHeader">Job Statistics</span>
            </p>
            <asp:GridView ID="gv_Jobs" runat="server" DataKeyNames="STATUS" DataSourceID="SqlDataSource_gv_Jobs"
                AllowPaging="False" AllowSorting="True" AutoGenerateColumns="False" CellPadding="2"
                CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
                EnableViewState="False" ShowFooter="True">
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="detailLink">
                        <ItemTemplate>
                            <asp:HyperLink ID="gvHL1" runat="server" NavigateUrl='<%# Eval("STATUS","~/MonJobs.aspx?filter={0}") %>'
                                EnableViewState="False">
                                <asp:Image ID="gvGo1" EnableViewState="False" runat="server" ImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png" />
                            </asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
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
        <div class="breaker_portlet">&nbsp;</div>
    </asp:Panel>
</ContentTemplate>
<Triggers>
    <asp:AsyncPostBackTrigger ControlID="RefreshTimer" EventName="Tick" />
</Triggers>
</asp:UpdatePanel>
   



  
</asp:Content>
