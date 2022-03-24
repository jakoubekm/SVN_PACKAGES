<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CTRL_STREAM_DEPENDENCY.aspx.cs" Inherits="PDC.CTRL_STREAM_DEPENDENCY" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="PortletBoxInner">
        <p>
            <span class="ModuleHeader">CTRL_STREAM_DEPENDENCY</span>
            <br />
            Rowcount:&nbsp;<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>
        </p>
        <div class="breaker_portlet">&nbsp;</div>
        <p>
                <span class="ModuleHeader">Current Label:</span>
                <asp:Label ID="lTChangeManagementLabel" runat="server" Text="N/A" EnableViewState="false"></asp:Label>
        </p>
        <p>
            <asp:Label ID="lNoLabelSelected" CssClass="infoLabel" runat="server" EnableViewState="False" Visible="True">Editable mode disabled. You have to set the label first.&nbsp;<a href="CtrlTables.aspx" class="infoLabel">Set Label</a></asp:Label>
        </p>
    </div>
    <!-- inner portlet 2 tab test  -->

    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
         <span class="ModuleHeader">Current stream:</span>
                <br />
                <br />
          <asp:Label ID="LabelNotChosenStream" CssClass="infoLabel" runat="server" EnableViewState="False"
                    Visible="True">Choose stream for view or modification its dependency.</asp:Label>    
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
        <div class="scrollable"><asp:GridView ID="gv_Listing" runat="server" DataSourceID="sql_Listing" AllowPaging="True"
            PageSize="<%$ AppSettings:DefaultPageItemCount %>" AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" DataKeyNames="STREAM_NAME"
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound"
            EditRowStyle-Width="100" 
            onselectedindexchanged="gv_Listing_SelectedIndexChanged">

            <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom"></PagerSettings>

            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:CommandField ButtonType="Button" SelectImageUrl="~/html/themes/teradata/images/PDC/Actions-go-next-view-icon.png"
                        SelectText="" ShowSelectButton="True" ControlStyle-CssClass="detailLink"/>
                <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" />
                <asp:BoundField DataField="STREAM_DESC" HeaderText="STREAM_DESC" />
                <asp:BoundField DataField="NOTE" HeaderText="NOTE" />

            </Columns>

            <EditRowStyle Width="100px"></EditRowStyle>
            <FooterStyle CssClass="PDCTblFooter" />
            <PagerStyle CssClass="PDCTblPaging" />

        </asp:GridView></div>
        <asp:SqlDataSource ID="sql_Listing" runat="server" 
            onselected="SqlDataSource_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CTRL_STREAM" 
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
    </asp:Panel>
    

    <div class="breaker_simple">&nbsp;</div>
    <asp:Panel ID="p_Detail_filter" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
        Filter:&nbsp;<asp:TextBox ID="TDependencyFilter" runat="server"></asp:TextBox>
        <asp:LinkButton ID="LinkButton1" runat="server"  CommandName="XXX" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Filter</span></asp:LinkButton>
    </asp:Panel>
    <asp:Panel ID="p_Detail_lvl2" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
        <p>
            <span class="ModuleHeader">Current Parent List for stream</span>&nbsp;&gt;&nbsp;<asp:Label ID="Label2"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
        </p>

        <div class="scrollable"><asp:GridView ID="gv_ActualParents" runat="server" DataSourceID="sql_ActualParents" 
                DataKeyNames="STREAM_NAME" AllowPaging="True"
            PageSize="<%$ AppSettings:DefaultPageItemCount %>" AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" 
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound"
            EditRowStyle-Width="100">

            <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom"></PagerSettings>

            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:TemplateField ControlStyle-CssClass="gridCheckBox">

                    <ItemTemplate>
                        <asp:CheckBox runat="server" ID="RowLevelCheckBox" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" />
                <asp:BoundField DataField="STREAM_DESC" HeaderText="STREAM_DESC" />
                <asp:BoundField DataField="NOTE" HeaderText="NOTE" />
                <asp:BoundField DataField="REL_TYPE" HeaderText="REL_TYPE" />
            </Columns>

            <EditRowStyle Width="100px"></EditRowStyle>
            <PagerStyle CssClass="PDCTblPaging" />
            <FooterStyle CssClass="PDCTblFooter" />

        </asp:GridView></div>
        <div class="breaker_simple">&nbsp;</div>
        <p>
            <asp:LinkButton ID="BDependencyDelete" runat="server" CommandName="DeleteDependency" CommandArgument="true"
                OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Delete Dependency</span></asp:LinkButton>
        </p>
        <div class="breaker_portlet">&nbsp;</div> 

        <div class="breaker_simple">&nbsp;</div>
        <asp:SqlDataSource ID="sql_ActualParents" runat="server" 
            onselecting="SqlDataSourceDep_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CTRL_STREAM_DEPAC" 
            SelectCommandType="StoredProcedure">
            <SelectParameters>
                     
            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
            <asp:ControlParameter ControlID="gv_Listing" Name="STREAM_NAME_IN" PropertyName="SelectedValue" Type="String" />
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
    <asp:Panel ID="p_Detail_lvl3" runat="server" EnableViewState="False" CssClass="PortletBoxInner"
        Visible="False">		        
        <p>
            <span class="ModuleHeader">Stream Parent</span>&nbsp;&gt;&nbsp;<asp:Label ID="Label1"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>

        </p>
      <p>
      Create dependency with relation type: 
          <asp:TextBox ID="tRleationType" runat="server" EnableViewState="False" Wrap="False" Width="12"></asp:TextBox>
      </p>
    
           <div class="scrollable"><asp:GridView ID="gv_Dependency" runat="server" DataSourceID="sql_Dependency" 
                DataKeyNames="STREAM_NAME" AllowPaging="True"
            PageSize="<%$ AppSettings:DefaultPageItemCount %>" AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" 
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound"
            EditRowStyle-Width="100">

            <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom"></PagerSettings>

            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:TemplateField ControlStyle-CssClass="gridCheckBox">
                    <ItemTemplate>
                        <asp:CheckBox runat="server" ID="RowLevelCheckBox" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" />
                <asp:BoundField DataField="STREAM_DESC" HeaderText="STREAM_DESC" />
                <asp:BoundField DataField="NOTE" HeaderText="NOTE" />
            </Columns>

            <EditRowStyle Width="100px"></EditRowStyle>
            <FooterStyle CssClass="PDCTblFooter" />
            <PagerStyle CssClass="PDCTblPaging" />

        </asp:GridView></div>
        <asp:SqlDataSource ID="sql_Dependency" runat="server" 
            onselected="SqlDataSource_Selected" 
            onselecting="SqlDataSourceDep_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CTRL_STREAM_DEP" 
            SelectCommandType="StoredProcedure">
            <SelectParameters>
                     
            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
            <asp:ControlParameter ControlID="gv_Listing" Name="STREAM_NAME_IN" PropertyName="SelectedValue" Type="String" />
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
        <p>
            <asp:LinkButton ID="BDependency" runat="server" CommandName="HandleDependency" CommandArgument="true"
                OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Create Dependency</span></asp:LinkButton>
        </p>
        <div class="breaker_portlet">&nbsp;</div> 
    </asp:Panel>



    <asp:SqlDataSource ID="sql_DependencyUpdate" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_UPDT_CTRL_STREAM_DEP"
        SelectCommandType="StoredProcedure" OnSelecting="SqlDataSourceDep_Update_Selecting" OnSelected="SqlDataSourceDep_Update_Selected">
        <SelectParameters>
            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="STREAM_NAME_IN" Direction="Input" DbType="String" Size="255" />
            <asp:Parameter Name="PARENT_STREAM_NAME_IN" Direction="Input" DbType="String" Size="255" />
            <asp:Parameter Name="STREAM_DEP_TYPE_IN" Direction="Input" DbType="String" Size="255" />  
            <asp:SessionParameter Name="LABEL_NAME_IN" Direction="Input" SessionField="TChangeManagementLabel" DbType="String" Size="255"/> 
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="sql_DependencyDelete" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_DEL_CTRL_STREAM_DEP"
        SelectCommandType="StoredProcedure" OnSelecting="SqlDataSourceDep_Delete_Selecting" OnSelected="SqlDataSourceDep_Delete_Selected">
        <SelectParameters>
            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="STREAM_NAME_IN" Direction="Input" DbType="String" Size="255" />
            <asp:Parameter Name="PARENT_STREAM_NAME_IN" Direction="Input" DbType="String" Size="255" />
            <asp:SessionParameter Name="LABEL_NAME_IN" Direction="Input" SessionField="TChangeManagementLabel" DbType="String" Size="255"/>
        </SelectParameters>
    </asp:SqlDataSource>


</asp:Content>

