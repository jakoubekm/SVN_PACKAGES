<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SessTables.aspx.cs" Inherits="PDC.SessTables" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="PortletBoxInner">
        <p>
            <span class="ModuleHeader">Session Tables: SESS_JOB</span>
            <br />Rowcount:&nbsp;<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>
        </p>
        <p>
        SESS (session) tables contain production metadata and store actual status of objects. SESS TABLES part enables changes in the table content. Such change can represent increasing actual job priority, command line changes and so on.
        </p>
    </div>
    <!-- inner portlet 2 tab test  -->

    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
        <p class="PDCPagingInfo">
            <asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
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
        <div class="scrollable">
            <asp:GridView ID="GridView2" runat="server" 
                DataSourceID="SqlDataSource1" AllowPaging="True"
             AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" OnRowDataBound="GridView2_RowDataBound" DataKeyNames="JOB_ID"
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom"  
            ondatabound="GridView2_DataBound" AutoGenerateEditButton="True" 
            EditRowStyle-Width="100" onrowupdating="GridView2_RowUpdating">
                <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom">
                </PagerSettings>
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
                <SelectedRowStyle CssClass="PDCTblSelRow" />
                <SortedAscendingHeaderStyle CssClass="sort_asc" />
                <SortedDescendingHeaderStyle CssClass="sort_desc" />
                <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                <HeaderStyle CssClass="PDCTblHeader" />
                <Columns>
                    <asp:BoundField DataField="JOB_ID" HeaderText="JOB_ID" ReadOnly="true" />
                    <asp:BoundField DataField="STREAM_ID" HeaderText="STREAM_ID" ReadOnly="true" />
                    <asp:BoundField DataField="JOB_NAME" HeaderText="JOB_NAME" ReadOnly="true" />
                    <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" ReadOnly="true" />
                    <asp:BoundField DataField="STATUS" HeaderText="STATUS" ReadOnly="true" />
                    <asp:TemplateField SortExpression="LAST_UPDATE" HeaderText="LAST_UPDATE" >
                        <EditItemTemplate>
                            <asp:DropDownList ID="DDListLAST_UPDATE" Runat="server"  AppendDataBoundItems="True">
                            </asp:DropDownList>
                            <asp:Label Runat="server" Text='<%# Bind("LAST_UPDATE") %>' ID="Label1"></asp:Label>
                        </EditItemTemplate>
                        <ItemTemplate >
                            <asp:Label Runat="server" Text='<%# Bind("LAST_UPDATE") %>' ID="Label1"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="LOAD_DATE" HeaderText="LOAD_DATE" ReadOnly="true" />
                    <asp:BoundField DataField="PRIORITY" HeaderText="PRIORITY" />
                    <asp:BoundField DataField="TOUGHNESS" HeaderText="TOUGHNESS" />
                    <asp:BoundField DataField="CMD_LINE" HeaderText="CMD_LINE" />
                    <asp:BoundField DataField="JOB_CATEGORY" HeaderText="JOB_CATEGORY" ReadOnly="true" />
                    <asp:BoundField DataField="JOB_TYPE" HeaderText="JOB_TYPE" ReadOnly="true" />
                    <asp:BoundField DataField="N_RUN" HeaderText="N_RUN" ReadOnly="true" />
                    <asp:BoundField DataField="MAX_RUNS" HeaderText="MAX_RUNS" />
                </Columns>
                <EditRowStyle Width="100px"></EditRowStyle>
                <PagerStyle CssClass="PDCTblPaging" />
                <FooterStyle CssClass="PDCTblFooter" />
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            onselected="SqlDataSource_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_SESS_JOB_ALL" 
            SelectCommandType="StoredProcedure"

            UpdateCommandType="StoredProcedure" 
            UpdateCommand="PCKG_GUI.SP_GUI_UPDT_SESS_JOB" 
            onupdating="SqlDataSource_Updating"
            OnUpdated="SqlDataSource_Updated">
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
            <UpdateParameters>
                <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
                <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
                <asp:Parameter Name="JOB_ID_IN" DefaultValue="DBG" Direction="Input" Type="String"  Size="255" />

                <asp:Parameter Name="LAST_UPDATE_IN" Direction="Input" Type="DateTime"   />

                <asp:Parameter Name="PRIORITY_IN" Direction="Input" Type="Int32" />
                <asp:Parameter Name="CMD_LINE_IN" DefaultValue="DBG" Direction="Input" Type="String"  Size="1000" />
                
                <asp:Parameter Name="TOUGHNESS_IN" Direction="Input" Type="Int32" />
                <asp:Parameter Name="MAX_RUNS_IN" Direction="Input" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
    </asp:Panel>
    <!-- inner portlet 3 Oracle table log  -->
</asp:Content>
