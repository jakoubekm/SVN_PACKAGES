<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="True" CodeBehind="CTRL_STREAM_PLAN_REF.aspx.cs" Inherits="PDC.CTRL_STREAM_PLAN_REF" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="PortletBoxInner">
        <p>
            <span class="ModuleHeader">CTRL_STREAM_PLAN_REF</span>
            <br />Rowcount:&nbsp;<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>
        </p>
        <div class="breaker_portlet">
            &nbsp;</div>
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
        <p class="PDCPagingInfo">
            <asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
        &nbsp;
        Number of rows per page:
        &nbsp;
            <asp:DropDownList 
                ID="PagerCountperPage" runat="server" AutoPostBack="True" 
                onselectedindexchanged="PagerCountperPage_SelectedIndexChanged">
                <asp:ListItem>10</asp:ListItem>
                <asp:ListItem>20</asp:ListItem>
                <asp:ListItem>50</asp:ListItem>
                <asp:ListItem>100</asp:ListItem>
                <asp:ListItem>200</asp:ListItem>
                <asp:ListItem>500</asp:ListItem>
            </asp:DropDownList>
        </p>
        <div class="scrollable">
            <asp:GridView ID="gv_Listing" runat="server" DataSourceID="sql_Listing" AllowPaging="True"
            PageSize="<%$ AppSettings:DefaultPageItemCount %>" AllowSorting="True" AutoGenerateColumns="False"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"
             EnableViewState="False" DataKeyNames="STREAM_NAME"
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom" 
            ondatabound="GridView2_DataBound"
            EditRowStyle-Width="100" 
            onselectedindexchanged="gv_Listing_SelectedIndexChanged">
                <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom">
                </PagerSettings>
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
                <PagerStyle CssClass="PDCTblPaging" />
                <EditRowStyle Width="100px"></EditRowStyle>
                <FooterStyle CssClass="PDCTblFooter" />
            </asp:GridView>
        </div>
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
        <div class="breaker_simple">
            &nbsp;</div>
    </asp:Panel>
    <asp:Panel ID="p_Detail_lvl2" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
        <div class="PortletBoxInnerHalf">
            <p>
                <span class="ModuleHeader">Stream Plan Reference for</span>&nbsp;&gt;&nbsp;<asp:Label ID="Label1"
                runat="server" Text="Label" EnableViewState="False"></asp:Label>
            </p>
            <asp:GridView ID="gv_Dependency" runat="server" DataSourceID="sql_Plans" 
                DataKeyNames="ROW_ID" AllowPaging="True"
            PageSize="<%$ AppSettings:DefaultPageItemCount %>" AllowSorting="True"
            CellPadding="2" CellSpacing="1" GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows"  AutoGenerateColumns="False"
             EnableViewState="False" 
            PagerSettings-Mode="NumericFirstLast" PagerSettings-Position="TopAndBottom"
            AutoGenerateEditButton="True"
            AutoGenerateDeleteButton="True"
            EditRowStyle-Width="100">
                <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom">
                </PagerSettings>
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
                <SelectedRowStyle CssClass="PDCTblSelRow" />
                <SortedAscendingHeaderStyle CssClass="sort_asc" />
                <SortedDescendingHeaderStyle CssClass="sort_desc" />
                <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                <HeaderStyle CssClass="PDCTblHeader" />
                <Columns>
                    <asp:TemplateField SortExpression="RUNPLAN" HeaderText="RUNPLAN" >
                        <EditItemTemplate>
                            <asp:DropDownList DataSourceID="SqlDataSource_RUNPLAN" DataTextField="LKP_VAL_DESC" DataValueField="LKP_VAL_DESC" ID="DDListRunplan" Runat="server" SelectedValue='<%# Bind("RUNPLAN") %>' >
                            </asp:DropDownList>
                        </EditItemTemplate>
                        <ItemTemplate >
                            <asp:Label Runat="server" Text='<%# Bind("RUNPLAN") %>' ID="Label1RUNPLAN"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField SortExpression="COUNTRY_CD" HeaderText="COUNTRY CODE" >
                        <EditItemTemplate>
                            <asp:DropDownList DataSourceID="SqlDataSource_COUNTRY_CD" DataTextField="LKP_VAL_DESC" DataValueField="LKP_VAL_DESC" ID="DDListCountry" Runat="server" SelectedValue='<%# Bind("COUNTRY_CD") %>' >
                            </asp:DropDownList>
                        </EditItemTemplate>
                        <ItemTemplate >
                            <asp:Label Runat="server" Text='<%# Bind("COUNTRY_CD") %>' ID="Label1COUNTRYCD"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EditRowStyle Width="100px"></EditRowStyle>
                <FooterStyle CssClass="PDCTblFooter" />
                <PagerStyle CssClass="PDCTblPaging" />
            </asp:GridView>
            <asp:FormView id="Fnewplan" runat="server" Visible="true" 
            DataSourceID="sql_Plans">
                <ItemTemplate>
                    <p>
                        <asp:LinkButton ID="NewRunPlan" runat="server" commandname="New" CssClass="PDCButton"><span>New RUNPLAN</span></asp:LinkButton>
                    </p>
                </ItemTemplate>
                <InsertItemTemplate>
                    <p>
                        <span>Runplan: </span>
                        <asp:DropDownList DataSourceID="SqlDataSource_RUNPLAN" DataTextField="LKP_VAL_DESC" DataValueField="LKP_VAL_DESC" ID="DDListRunplanNewPlan" Runat="server" >
                        </asp:DropDownList>
                        <span>Country: </span>
                        <asp:DropDownList DataSourceID="SqlDataSource_COUNTRY_CD" DataTextField="LKP_VAL_DESC" DataValueField="LKP_VAL_DESC" ID="DDListCountryNewPlan" Runat="server">
                        </asp:DropDownList>
                    </p>
                    <p>
                        <asp:LinkButton ID="BNewRunPlan" runat="server" commandname="Insert" CssClass="PDCButton"><span>Add RUNPLAN</span></asp:LinkButton>
                    </p>
                </InsertItemTemplate>
            </asp:FormView>
            <asp:SqlDataSource ID="sql_Plans" runat="server" 
            onselected="SqlDataSource_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
            
            SelectCommand="PCKG_GUI.SP_GUI_VIEW_CTRL_STREAM_PLAN" 
            SelectCommandType="StoredProcedure"
            
            UpdateCommandType="StoredProcedure" 
            UpdateCommand="PCKG_GUI.SP_GUI_UPDT_CTRL_STREAM_PL_REF" 
            onupdating="SqlDataSource_Updating" onupdated="SqlDataSource_Updated"
            
            DeleteCommand="PCKG_GUI.SP_GUI_DEL_CTRL_STREAM_PL_REF"
            DeleteCommandType="StoredProcedure"
            OnDeleting="SqlDataSource_Deleting" OnDeleted="SqlDataSource_Deleted"

            InsertCommand="PCKG_GUI.SP_GUI_INS_CTRL_STREAM_PL_REF"
            InsertCommandType="StoredProcedure"
            OnInserting="SqlDataSource_Inserting" OnInserted="SqlDataSource_Inserted">
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
                <UpdateParameters>
                    <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                    <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                    <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
                    <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ROW_ID" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="STREAM_NAME" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="RUNPLAN" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="COUNTRY_CD" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:SessionParameter Name="LABEL_NAME_IN" Direction="Input" SessionField="TChangeManagementLabel" DbType="String" Size="255"/>
                </UpdateParameters>
                <DeleteParameters>
                    <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                    <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                    <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
                    <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ROW_ID" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="STREAM_NAME" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:SessionParameter Name="LABEL_NAME_IN" Direction="Input" SessionField="TChangeManagementLabel" DbType="String" Size="255"/>
                </DeleteParameters>
                <InsertParameters>
                    <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                    <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                    <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
                    <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
                    <asp:Parameter Name="STREAM_NAME" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="RUNPLAN" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:Parameter Name="COUNTRY_CD" DefaultValue="" Direction="Input" Type="String"  Size="255" />
                    <asp:SessionParameter Name="LABEL_NAME_IN" Direction="Input" SessionField="TChangeManagementLabel" DbType="String" Size="255"/>
                </InsertParameters>
            </asp:SqlDataSource>
            <div class="breaker_simple">
                &nbsp;</div>
        </div>
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
    <asp:Panel ID="p_Detail_lvl3" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="false">
        <div class="PortletBoxInnerHalf">
            <p>
                <asp:GridView ID="GridView3" runat="server" DataSourceID="SqlDataSource_RUNPLAN_DESC" AllowPaging="False"
            AutoGenerateColumns="False"
            GridLines="None" EmptyDataText="No rows"
            PagerSettings-Mode="NumericFirstLast"
            EditRowStyle-Width="100">
                    <Columns>
                        <asp:boundfield DataField="LKP_VAL_DESC" HeaderText="DESCRIPTION OF RUNPLANS" HeaderStyle-HorizontalAlign="Left"/>
                    </Columns>
                </asp:GridView>
            </p>
            <div class="breaker_simple">
                &nbsp;&gt;&nbsp;</div>
        </div>
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
    <asp:SqlDataSource ID="SqlDataSource_RUNPLAN" runat="server" 
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" 
        EnableViewState="False"
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_LKP_RUNPLAN"
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
    <asp:SqlDataSource ID="SqlDataSource_RUNPLAN_DESC" runat="server" 
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" 
        EnableViewState="False"
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_LKP_RUNPLAN_DESC"
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
    <asp:SqlDataSource ID="SqlDataSource_COUNTRY_CD" runat="server" 
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" 
        EnableViewState="False"
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_LKP_COUNTRY_CD"
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
</asp:Content>
