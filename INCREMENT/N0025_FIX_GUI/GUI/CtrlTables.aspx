<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CtrlTables.aspx.cs" Inherits="PDC.CtrlTables" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 <div class="PortletBoxInner">
            <p>
                <span class="ModuleHeader">Control Tables</span>
            </p>
            <p>
                CTRL (control) tables store configuration metadata of jobs, streams, their dependences, locks and calendars. This part of GUI application is used for creating or changing this metadata. Application automatically checks correctness of typed values. Changes are enabled only when a label is selected which is necessary for change management process package creation.
            </p>
</div>
<div class="PortletBoxInner">
    <p>
        <span class="ModuleHeader">Current Label:</span>
        <asp:Label ID="lTChangeManagementLabel" runat="server" Text="N/A" EnableViewState="false"></asp:Label>
    </p>
</div>
   <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
      <p>
                <span class="ModuleHeader">Select Label:</span>
                <br />
                
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
        Rowcount:&nbsp;<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>

        <div class="scrollable"><asp:GridView ID="GridView2" runat="server" DataSourceID="SqlDataSource1" AllowPaging="True"
             AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" DataKeyNames="LABEL_NAME"
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound"  
            OnSelectedIndexChanged="GridView2_SelectedIndexChanged"
            EditRowStyle-Width="100">

<PagerSettings Mode="NumericFirstLast" Position="TopAndBottom"></PagerSettings>

            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
            <asp:CommandField ButtonType="Button" ControlStyle-CssClass="detailLink" 
                    SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png" 
                    SelectText="" ShowSelectButton="True">
                <ControlStyle CssClass="detailLink" />
                </asp:CommandField>
            
                
                <asp:BoundField DataField="LABEL_NAME" HeaderText="LABEL_NAME" />
                <asp:BoundField DataField="LABEL_STATUS" HeaderText="LABEL_STATUS" />
                <asp:BoundField DataField="USER_NAME" HeaderText="USER_NAME" ReadOnly="True" />
                <asp:BoundField DataField="CREATE_TS" HeaderText="CREATE_TS" ReadOnly="True" />
                <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" />
                <asp:BoundField DataField="ENV" HeaderText="ENV" ReadOnly="True" />

            </Columns>

            <EditRowStyle Width="100px"></EditRowStyle>
            <PagerStyle CssClass="PDCTblPaging" />
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView></div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            onselected="SqlDataSource_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CHM" 
            SelectCommandType="StoredProcedure"
>
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
    </asp:Panel>
</asp:Content>
