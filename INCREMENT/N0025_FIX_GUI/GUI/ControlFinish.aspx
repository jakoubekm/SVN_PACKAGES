<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ControlFinish.aspx.cs" Inherits="PDC.ControlFinish" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript">
         function ChangeCheckBoxState(id, checkState) {
             var cb = document.getElementById(id);
             if (cb != null)
                 cb.checked = checkState;
         }

         function ChangeAllCheckBoxStates(checkState) {
             // Toggles through all of the checkboxes defined in the CheckBoxIDs array
             // and updates their value to the checkState input parameter
             if (CheckBoxIDs != null) {
                 for (var i = 0; i < CheckBoxIDs.length; i++)
                     ChangeCheckBoxState(CheckBoxIDs[i], checkState);
             }
         }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner">
            <p>
                <span class="ModuleHeader">Ready to run&nbsp;(<asp:Label ID="lDetailRowCount" runat="server" Text="-" EnableViewState="False"></asp:Label>)</span>
            </p>

            <p class="PDCPagingInfo">
                <asp:Label ID="PagingInformation" runat="server" Text=""></asp:Label>
                &nbsp; Number of rows per page: &nbsp;
                <asp:DropDownList ID="PagerCountperPage" runat="server" AutoPostBack="True" OnSelectedIndexChanged="PagerCountperPage_SelectedIndexChanged">
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

            <asp:Literal ID="CheckBoxIDsArray" runat="server" EnableViewState="False"></asp:Literal>

            <div class="scrollable"><asp:GridView ID="gv_Detail_lvl1" runat="server" DataKeyNames="JOB_ID"  DataSourceID="SqlDataSource_gv_Detail_lvl1"
                AllowSorting="True" AutoGenerateColumns="False" CellPadding="2" CellSpacing="1"
                GridLines="None" CssClass="PDCTbl" EmptyDataText="No rows" 
                EnableViewState="False" 
                AllowPaging="True" 
                ondatabound="gv_Detail_lvl1_DataBound"
                PagerSettings-Position="TopAndBottom" 
                PagerSettings-Mode="NumericFirstLast" 
                 ViewStateMode="Disabled" >
                <Columns>

                  <asp:TemplateField ControlStyle-CssClass="gridCheckBox">
                      <HeaderTemplate>
                          <asp:CheckBox runat="server" ID="HeaderLevelCheckBox" />
                      </HeaderTemplate>
                      <ItemTemplate>
                          <asp:CheckBox runat="server" ID="RowLevelCheckBox" />
                      </ItemTemplate>
                  </asp:TemplateField>

                    <asp:BoundField DataField="JOB_ID" HeaderText="JOB_ID" ReadOnly="True" SortExpression="JOB_ID" />
                    <asp:BoundField DataField="JOB_NAME" HeaderText="JOB_NAME" ReadOnly="True" SortExpression="JOB_NAME" />
                    <asp:BoundField DataField="STREAM_NAME" HeaderText="STREAM_NAME" ReadOnly="True"
                        SortExpression="STREAM_NAME" />
                    <asp:BoundField DataField="JOB_CATEGORY" HeaderText="JOB_CATEGORY" ReadOnly="True"
                        SortExpression="JOB_CATEGORY" />
                    <asp:BoundField DataField="ENGINE_ID" HeaderText="ENGINE_ID" ReadOnly="True" SortExpression="ENGINE_ID" />
                    <asp:BoundField DataField="N_RUN" HeaderText="N_RUN" ReadOnly="True" SortExpression="N_RUN" />
                    <asp:BoundField DataField="LAST_UPDATE" HeaderText="LAST_UPDATE" ReadOnly="True"
                        SortExpression="LAST_UPDATE" />
                    <asp:BoundField DataField="STATUS" HeaderText="STATUS" ReadOnly="True" SortExpression="STATUS" />
                </Columns>
                <RowStyle CssClass="PDCTblRow" Wrap="False" />
                <SelectedRowStyle CssClass="PDCTblSelRow" />
                <SortedAscendingHeaderStyle CssClass="sort_asc" />
                <SortedDescendingHeaderStyle CssClass="sort_desc" />
                <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                <HeaderStyle CssClass="PDCTblHeader" />
                
                <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom" />
                
                <PagerStyle CssClass="PDCTblPaging" />
            </asp:GridView></div>
                <asp:SqlDataSource ID="SqlDataSource_gv_Detail_lvl1" runat="server" 
        onselected="SqlDataSource_Selected" 
        onselecting="SqlDataSource_Selecting"
        ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" EnableViewState="False" 
        SelectCommand="PCKG_GUI.SP_GUI_VIEW_JOBS_EXECUTABLE" 
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


            <div class="breaker_portlet">&nbsp;</div>    

            <asp:Panel ID="Panel1" runat="server"  EnableViewState="False">
                <asp:LinkButton ID="BJobControl_MARKASFINISHED" runat="server"  CommandName="COMMAND_JOB_MARKASFINISHED" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Mark as Finished</span></asp:LinkButton>
            </asp:Panel> 
      <div class="breaker_portlet">&nbsp;</div> 
    </asp:Panel>
    
</asp:Content>
