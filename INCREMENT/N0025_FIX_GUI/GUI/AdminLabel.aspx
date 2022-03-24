<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminLabel.aspx.cs" Inherits="PDC.AdminLabel" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="PortletBoxInner">
    <p>
        <span class="ModuleHeader">Label Maintenance</span>
    </p>

    <div>
            <p>
                <span class="ModuleHeader">Current Label:</span>
                <asp:Label ID="lTChangeManagementLabel" runat="server" Text="N/A" EnableViewState="false"></asp:Label>
            </p>
    </div>
    <div class="breaker_portlet">&nbsp;</div>
</div>



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
            
                
                <asp:BoundField DataField="LABEL_NAME" HeaderText="LABEL_NAME"  ReadOnly="True" />
                <asp:BoundField DataField="LABEL_STATUS" HeaderText="LABEL_STATUS"  ReadOnly="True" />
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
            SelectCommandType="StoredProcedure">
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
        <asp:SqlDataSource ID="SqlDataSource_New" runat="server" 
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_UPDT_LABEL" 
            SelectCommandType="StoredProcedure"
            OnSelecting="SqlDataSource_New_Selecting"
            OnSelected="SqlDataSource_New_Selected">
            <SelectParameters>
    
              <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
             
                <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
                <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />

                <asp:Parameter Name="LABEL_NAME_IN" DefaultValue="DBG" Direction="Input" Type="String"  Size="255" />
                <asp:Parameter Name="LABEL_STATUS_IN" DefaultValue="DBG" Direction="Input" Type="String"  Size="255" />
                <asp:Parameter Name="DESCRIPTION_IN" DefaultValue="DBG" Direction="Input" Type="String"  Size="255" />


            </SelectParameters>

        </asp:SqlDataSource>
            <div class="breaker_portlet">&nbsp;</div>
    </asp:Panel>
 

 <div class="PortletBoxInner">
    <p>
        <span class="ModuleHeader">New Label</span>
    </p>

    <div>
            <table cellspacing="0">
            <tr>
                <td>
                Label Name:&nbsp;
                </td>
                <td>
                <asp:TextBox ID="tLabelName" runat="server" EnableViewState="False"></asp:TextBox>
                &nbsp;<asp:RequiredFieldValidator id="rfv1" CssClass="T4" runat="server" ErrorMessage="Required!" ControlToValidate="tLabelName"></asp:RequiredFieldValidator>  
                </td>
            </tr>
            <tr>
                <td>
                Label Status:&nbsp;
                </td>
                <td>
                    <asp:DropDownList ID="DDLLabelStatus" runat="server" EnableViewState="False">
                    <asp:ListItem>OPEN</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>
                Label Description:&nbsp;
                </td>
                <td>
                <asp:TextBox ID="tLabelDescription" runat="server" EnableViewState="False"></asp:TextBox>     
                </td>
            </tr>

            </table>
                <div class="breaker_portlet">&nbsp;</div>    
    </div>
       

     
    <asp:Panel ID="Panel1" runat="server"  EnableViewState="False">
                <asp:LinkButton ID="lbCMDNewLabel" runat="server"  CommandName="COMMAND_NEW_LABEL" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Create Label</span></asp:LinkButton>
            </asp:Panel>
    <div class="breaker_portlet">&nbsp;</div>
</div>
</asp:Content>
